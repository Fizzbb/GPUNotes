# Location of the CUDA Toolkit
CUDA_PATH      ?= /usr/local/cuda
SANITIZER_PATH ?= $(CUDA_PATH)/compute-sanitizer

HOST_COMPILER  ?= g++
NVCC           := $(CUDA_PATH)/bin/nvcc -ccbin $(HOST_COMPILER)

INCLUDE_FLAGS  := -I$(CUDA_PATH)/include -I$(SANITIZER_PATH)/include

LINK_FLAGS     := -L$(SANITIZER_PATH) -fPIC -shared
LINK_LIBS      := -lsanitizer-public

# Target rules
all: build

build: libApiTracker.so

libApiTracker.so: ApiTracker.cpp
	$(HOST_COMPILER) $(INCLUDE_FLAGS) $(LINK_FLAGS) -o $@ $< $(LINK_LIBS)

clean:
	rm -f libApiTracker.so

clobber: clean


