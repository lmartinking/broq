CC := gcc

CFLAGS := -std=c++14
CFLAGS_32 := -m32
CFLAGS_64 := -m64

CFLAGS_M := -bundle -undefined dynamic_lookup
CFLAGS_L := -shared -fPIC -lstdc++

LIBBROTLIDEC_CFLAGS := -O2 -fPIC
LIBBROTLIDEC_32 := libbrotlidec_32.a
LIBBROTLIDEC_64 := libbrotlidec_64.a

libbrotli/autogen.sh:
	git submodule init
	git submodule update

libbrotli/Makefile: libbrotli/autogen.sh
	cd libbrotli && ./autogen.sh && ./configure

$(LIBBROTLIDEC_32): libbrotli/Makefile
	cd libbrotli && make clean && make CFLAGS="$(CFLAGS_32) $(LIBBROTLIDEC_CFLAGS)" && cp .libs/libbrotlidec.a ../libbrotlidec_32.a

$(LIBBROTLIDEC_64): libbrotli/Makefile
	cd libbrotli && make clean && make CFLAGS="$(CFLAGS_64) $(LIBBROTLIDEC_CFLAGS)" && cp .libs/libbrotlidec.a ../libbrotlidec_64.a

m32: dec.cpp $(LIBBROTLIDEC_32)
	$(CC) $(CFLAGS) $(CFLAGS_32) $(CFLAGS_M) dec.cpp $(LIBBROTLIDEC_32) -o broq_m32.so

m64: dec.cpp $(LIBBROTLIDEC_64)
	$(CC) $(CFLAGS) $(CFLAGS_64) $(CFLAGS_M) dec.cpp $(LIBBROTLIDEC_64) -o broq_m64.so

l32: dec.cpp $(LIBBROTLIDEC_32)
	$(CC) $(CFLAGS) $(CFLAGS_32) $(CFLAGS_L) dec.cpp $(LIBBROTLIDEC_32) -o broq_l32.so

l64: dec.cpp $(LIBBROTLIDEC_64)
	$(CC) $(CFLAGS) $(CFLAGS_64) $(CFLAGS_L) dec.cpp $(LIBBROTLIDEC_64) -o broq_l64.so

clean:
	rm -f $(LIBBROTLIDEC_32) $(LIBBROTLIDEC_64)
	rm -f broq_*.so

.PHONY: clean
