#include <dlfcn.h>
#include <string.h>
#include <iostream>
#include <cuda.h>

extern "C" {void *__libc_dlsym(void *map, const char *name);}
extern "C" {void *__libc_dlopen_mode(const char *name, int maddArgumentode);}

typedef void *(*fnDlsym)(void *, const char *);
static void *real_dlsym(void *handle, const char *symbol)
{
    static fnDlsym internal_dlsym = (fnDlsym)__libc_dlsym(__libc_dlopen_mode("libdl.so.2", RTLD_LAZY), "dlsym");
    return (*internal_dlsym)(handle, symbol);
}

static void *realFunctions;

CUresult CUDAAPI cuInit(unsigned int flag) {
    CUresult ret;
    std::cout << "func overlap works" << std::endl;
    if (realFunctions == NULL) realFunctions = real_dlsym(RTLD_NEXT, "cuInit");
    return  ((CUresult (*)(unsigned int))realFunctions)(flag);
}

void *dlsym(void *handle, const char *symbol)   
{
    if (strcmp(symbol, "cuInit") == 0) {
        if(realFunctions == NULL) realFunctions = real_dlsym(handle, symbol); 
        return (void*)(&cuInit);
    }
    return (real_dlsym(handle, symbol));
}
