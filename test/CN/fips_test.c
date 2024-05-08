#include <stdio.h>
#include <openssl/evp.h>
#include <openssl/provider.h>

int main() {
    OSSL_PROVIDER *fips_provider = NULL;
    OSSL_PROVIDER *default_provider = NULL;
    int result = 1;

    // 加载默认提供者
    default_provider = OSSL_PROVIDER_load(NULL, "default");
    if (!default_provider) {
        fprintf(stderr, "加载默认提供者失败。\n");
        goto end;
    }

    // 加载 FIPS 提供者
    fips_provider = OSSL_PROVIDER_load(NULL, "fips");
    if (!fips_provider) {
        fprintf(stderr, "加载 FIPS 提供者失败。\n");
        goto end;
    }

    // 检查 FIPS 提供者是否正常工作
    if (EVP_default_properties_is_fips_enabled(NULL)) {
        printf("FIPS 模块已启用，并正常工作。\n");
        result = 0;
    } else {
        printf("FIPS 模块未启用，或者未正常工作。\n");
    }

end:
    // 清理提供者对象
    if (fips_provider) OSSL_PROVIDER_unload(fips_provider);
    if (default_provider) OSSL_PROVIDER_unload(default_provider);

    return result;
}
