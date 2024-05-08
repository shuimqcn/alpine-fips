# Stage 1: Build OpenSSL with FIPS provider in Alpine Linux
FROM alpine:3.19 as builder

ENV OPENSSL_VER=3.0.9
 
RUN apk add --update wget gcc gzip tar libc-dev ca-certificates perl make coreutils gnupg linux-headers zlib-dev \
    && wget https://github.com/openssl/openssl/archive/refs/tags/openssl-${OPENSSL_VER}.tar.gz && ls -lha \
    && tar -zxf openssl-${OPENSSL_VER}.tar.gz && cd openssl-openssl-${OPENSSL_VER} \
    && perl ./Configure linux-x86_64 --prefix=/usr --libdir=lib --openssldir=/etc/ssl fips shared zlib enable-md2 enable-ec_nistp_64_gcc_128 -DOPENSSL_NO_BUF_FREELISTS -Wa,--noexecstack enable-ssl2 \
    && make && make test \
    && make install \
    && openssl version -a || true \
    && openssl list -providers || true \
    # Configure FIPS providers
    && openssl fipsinstall -out /etc/ssl/fipsmodule.cnf -module /usr/lib/ossl-modules/fips.so \
    && sed -i "s/^# fips = fips_sect/fips = fips_sect/g" /etc/ssl/openssl.cnf \
    && sed -i "s/^#[[:space:]]*activate = 1/activate = 1/g" /etc/ssl/openssl.cnf \
    && sed -i '18s/$/\n.include \/etc\/ssl\/fipsmodule.cnf/g' /etc/ssl/openssl.cnf \
    && sed -i -E 's,(providers = provider_sect),\1\nalg_section = algorithm_sect\n\n[algorithm_sect]\ndefault_properties = fips=yes,' /etc/ssl/openssl.cnf || true \
    && openssl list -providers || true \
    # Test FIPS provider, If command rasie exception, FIPS module works well
    && openssl md5 /etc/hosts || true \
    # Clean
    && apk del wget gcc gzip tar libc-dev ca-certificates perl make coreutils gnupg linux-headers zlib-dev \
    && rm -rf /var/cache/apk/* /root/.gnupg/ ~/.bash_history /root/.wget-hsts /tmp/*

# Above content can save into a single Dockerfile to build Alpine FIPS image
 
# Stage 2: Install openssl by apk command and enable FIPS provider with the FIPS library built in stage 1.
FROM alpine:3.19 as midd

COPY --from=builder /usr/lib/ossl-modules/fips.so /tmp/fips.so

RUN apk update && apk upgrade && apk add openssl \
    && mv /tmp/fips.so /usr/lib/ossl-modules/fips.so \
    && openssl fipsinstall -out /etc/ssl/fipsmodule.cnf -module /usr/lib/ossl-modules/fips.so \
    && sed -i "s/^# fips = fips_sect/fips = fips_sect/g" /etc/ssl/openssl.cnf || true \
    && sed -i "s/^#[[:space:]]*activate = 1/activate = 1/g" /etc/ssl/openssl.cnf || true \
    && sed -i '18s/$/\n.include \/etc\/ssl\/fipsmodule.cnf/g' /etc/ssl/openssl.cnf || true \
    && sed -i -E 's,(providers = provider_sect),\1\nalg_section = algorithm_sect\n\n[algorithm_sect]\ndefault_properties = fips=yes,' /etc/ssl/openssl.cnf || true \
    && openssl list -providers || true \
    && openssl md5 /etc/hosts || true\
    && rm -rf /var/cache/apk/* /root/.gnupg/ ~/.bash_history /root/.wget-hsts /tmp/*

# Stage 3: To reduce the size of image
FROM scratch

COPY --from=midd / /

# ENTRYPOINT [ "sh" ]

CMD ["sh"]