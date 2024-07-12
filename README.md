# OpenSSL 3.0 With FIPS Provider on Alpine Linux Container

The latest verified FIPS module version is v3.0.9(2024/07/12), check https://csrc.nist.gov/projects/cryptographic-module-validation-program/certificate/4282.

- OpenSSL 3.0 (Enable FIPS Module/Provider)

## Summary 
- Remove Vendor official openssl
- Install development purpose software
- Build OpenSSL 3.0 with "`fips`" parameter to build FIPS provider
- Install OpenSSL 3.0 or only install OpenSSL 3.0 FIPS provider
- Configure OpenSSL configuration to enable FIPS Provider

## How to Use

### Build Your Own Container image
```
docker build -t alpine-fips:latest -f Dockerfile .
```

### Use Pre-Build Image 
```
docker pull shuimqcn/alpine-fips:latest
```

### Use Pre-Build FIPS Provider
- Run alpine 3.20 container
- Copy "`fips.so`" from "`libs/3.0.9/fips.so`" or "*shuimqcn/alpine-fips:latest:/usr/lib/ossl-modules/fips.so*" into "/usr/lib/ossl-modules/fips.so"
- Use "`openssl fipsinstall`" to generate "`fipsmodule.cnf`" by "`/usr/lib/ossl-modules/fips.so`"
  `openssl fipsinstall -out /etc/ssl/fipsmodule.cnf -module /usr/lib/ossl-modules/fips.so`
- Modify "`openssl.cnf`" to enable **FIPS** provider

More information can refer to [Dockerfile](./Dockerfile) stage 2.

## Test
```
#include <stdio.h>
#include <openssl/evp.h>
#include <openssl/provider.h>

int main() {
    OSSL_PROVIDER *fips_provider = NULL;
    OSSL_PROVIDER *default_provider = NULL;
    int result = 1;

    // Load default provider
    default_provider = OSSL_PROVIDER_load(NULL, "default");
    if (!default_provider) {
        fprintf(stderr, "Loading default provider failed.\n");
        goto end;
    }

    // Load FIPS Provider
    fips_provider = OSSL_PROVIDER_load(NULL, "fips");
    if (!fips_provider) {
        fprintf(stderr, "Loading FIPS provider failed.\n");
        goto end;
    }

    // Check FIPS Provider whether works well
    if (EVP_default_properties_is_fips_enabled(NULL)) {
        printf("FIPS module enabled and works well.\n");
        result = 0;
    } else {
        printf("FIPS module not enabled or can not work.\n");
    }

end:
    // Clean Provider object 
    if (fips_provider) OSSL_PROVIDER_unload(fips_provider);
    if (default_provider) OSSL_PROVIDER_unload(default_provider);

    return result;
}
```
**Compile**
```
/ # gcc -o fips_test fips_test.c -lcrypto -ldl
```
**Run**
```
/ # ./fips_test
FIPS module enabled and works well.
/ # 
```
