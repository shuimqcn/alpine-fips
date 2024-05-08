### Use Pre-Build FIPS Provider
- Run alpine 3.19 container
- Copy "`fips.so`" from "`libs/3.0.9/fips.so`" or "*shuimqcn/alpine-fips:3.19:/usr/lib/ossl-modules/fips.so*" into "/usr/lib/ossl-modules/fips.so"
- Use "`openssl fipsinstall`" to generate "`fipsmodule.cnf`" by "`/usr/lib/ossl-modules/fips.so`"
  `openssl fipsinstall -out /etc/ssl/fipsmodule.cnf -module /usr/lib/ossl-modules/fips.so`
- Modify "`openssl.cnf`" to enable **FIPS** provider

More information can refer to [Dockerfile](../Dockerfile) stage 2.