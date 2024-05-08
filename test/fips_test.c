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

