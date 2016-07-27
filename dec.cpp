#include <cstdio>
#include <cstdlib>
#include <sys/stat.h>

#include "libbrotli/brotli/dec/decode.h"

#define KXVER 3
#include "k.h"

namespace {
    static char err_type[] = "type";
    static char err_open[] = "open";
    static char err_stat[] = "stat";
    static char err_mem[] = "mem";
    static char err_read[] = "read";
    static char err_parse[] = "dec_parse";
    static char err_dec[] = "dec";
};

extern "C" K broqdec(K x)
{
    const char* path = nullptr;
    uint8_t* enc_data = nullptr;

    if (x->t == -(KS))
    {
        path = x->s;

        if (path[0] == ':')
        {
            path++;
        }
    }
    else
    {
        return krr(err_type);
    }

    FILE* f = fopen(path, "rb");
    if (f == nullptr)
    {
        return krr(err_open);
    }

    struct stat f_info;

    if (fstat(fileno(f), &f_info) != 0)
    {
        fclose(f);
        return krr(err_stat);
    }

    size_t enc_size = f_info.st_size;

    enc_data = (uint8_t*)malloc(enc_size);
    if (enc_data == nullptr)
    {
        fclose(f);
        return krr(err_mem);
    }

    if (fread(enc_data, 1, enc_size, f) != enc_size)
    {
        fclose(f);
        free(enc_data);
        return krr(err_read);
    }

    fclose(f);

    size_t dec_size = 0;
    if (BrotliDecompressedSize(enc_size, enc_data, &dec_size) != 1)
    {
        free(enc_data);
        return krr(err_parse);
    }

    K dec = ktn(KC, dec_size);

    if (dec_size) {
        uint8_t *dec_buf = &kC(dec)[0];
        size_t dec_actual_size = dec_size;

        auto r = BrotliDecompressBuffer(enc_size, enc_data, &dec_actual_size, dec_buf);

        if (r != BROTLI_RESULT_SUCCESS)
        {
            free(enc_data);
            r0(dec);
            return krr(err_dec);
        }
    }

    free(enc_data);

    return dec;
}

