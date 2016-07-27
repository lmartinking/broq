broq - brotli decompression for kdb+/q
--------------------------------------

# Build

    make {m32,m64,l32,l64}

# Install

    cp broq_{m32,m64,l32,l64}.so /path/to/q/{m32,m64,l32,l64}/broq.so

# Use

    q) broqdec: `broq 2: (`broqdec;1)
    q) dec: broqdec `:/path/to/file.bro

Currently supports extracting by file path only.

NOTE: You might need to set `DYLD_LIBRARY_PATH` or `LD_LIBRARY_PATH` environment variables
(Mac and Linux respectively) to the directory where the `.so` lives before running `q`.

# Licence

MIT. (See `LICENCE`).
