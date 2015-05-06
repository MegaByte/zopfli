CC = gcc
CXX = g++

CFLAGS = -W -Wall -Wextra -ansi -pedantic -lm -O3
CXXFLAGS = -W -Wall -Wextra -ansi -pedantic -O3
CAVXFLAGS = -mavx -mtune=corei7-avx -march=corei7-avx
CNEONFLAGS = -march=armv7-a -mcpu=cortex-a9 -mfpu=neon -mfloat-abi=hard

ZOPFLILIB_SRC = src/zopfli/blocksplitter.c src/zopfli/cache.c\
                src/zopfli/deflate.c src/zopfli/gzip_container.c\
                src/zopfli/hash.c src/zopfli/katajainen.c\
                src/zopfli/lz77.c src/zopfli/squeeze.c\
                src/zopfli/tree.c src/zopfli/util.c\
                src/zopfli/zlib_container.c src/zopfli/zopfli_lib.c
ZOPFLILIB_OBJ := $(patsubst src/zopfli/%.c,%.o,$(ZOPFLILIB_SRC))
ZOPFLIBIN_SRC := src/zopfli/zopfli_bin.c
LODEPNG_SRC := src/zopflipng/lodepng/lodepng.cpp src/zopflipng/lodepng/lodepng_util.cpp
ZOPFLIPNGLIB_SRC := src/zopflipng/zopflipng_lib.cc
ZOPFLIPNGBIN_SRC := src/zopflipng/zopflipng_bin.cc

.PHONY: zopfli zopflipng

# Zopfli binary
zopfli:
	$(CC) $(ZOPFLILIB_SRC) $(ZOPFLIBIN_SRC) $(CFLAGS) -o zopfli
	
zopfliavx:
	$(CC) -static $(ZOPFLILIB_SRC) $(ZOPFLIBIN_SRC) $(CFLAGS) $(CAVXFLAGS) -o zopfli

zopflineon:
	$(CC) -static $(ZOPFLILIB_SRC) $(ZOPFLIBIN_SRC) $(CFLAGS) $(CNEONFLAGS) -o zopfli

# Zopfli shared library
libzopfli:
	$(CC) $(ZOPFLILIB_SRC) $(CFLAGS) -fPIC -c
	$(CC) $(ZOPFLILIB_OBJ) $(CFLAGS) -shared -Wl,-soname,libzopfli.so.1 -o libzopfli.so.1.0.1

# ZopfliPNG binary
zopflipng:
	$(CC) $(ZOPFLILIB_SRC) $(CFLAGS) -c
	$(CXX) $(ZOPFLILIB_OBJ) $(LODEPNG_SRC) $(ZOPFLIPNGLIB_SRC) $(ZOPFLIPNGBIN_SRC) $(CFLAGS) -o zopflipng
	
zopflipngavx:
	$(CC) $(ZOPFLILIB_SRC) $(CFLAGS) $(CAVXFLAGS) -c
	$(CXX) -static -static-libgcc $(ZOPFLILIB_OBJ) $(LODEPNG_SRC) $(ZOPFLIPNGLIB_SRC) $(ZOPFLIPNGBIN_SRC) $(CFLAGS) $(CAVXFLAGS) -o zopflipng

zopflipngneon:
	$(CC) $(ZOPFLILIB_SRC) $(CFLAGS) $(CNEONFLAGS) -c
	$(CXX) -static -static-libgcc $(ZOPFLILIB_OBJ) $(LODEPNG_SRC) $(ZOPFLIPNGLIB_SRC) $(ZOPFLIPNGBIN_SRC) $(CFLAGS) $(CNEONFLAGS) -o zopflipng

# ZopfliPNG shared library
libzopflipng:
	$(CC) $(ZOPFLILIB_SRC) $(CFLAGS) -fPIC -c
	$(CXX) $(ZOPFLILIB_OBJ) $(LODEPNG_SRC) $(ZOPFLIPNGLIB_SRC) $(CFLAGS) -fPIC --shared -Wl,-soname,libzopflipng.so.1 -o libzopflipng.so.1.0.0

# Remove all libraries and binaries
clean:
	rm -f zopflipng zopfli $(ZOPFLILIB_OBJ) libzopfli*