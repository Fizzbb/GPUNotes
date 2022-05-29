#include <dlfcn.h>
#include <string.h>
#include <iostream>
#include <cuda.h>
#include <chrono>
#include <ctime>

#define STRINGIFY(x) STRINGIFY_AUX(x)
#define STRINGIFY_AUX(x) #x

/*
   1) use stringify wrap function name, so cuMemAlloc and cuMemAlloc_v2 can be all intercepted
   2) make sure function input types write, refer to cuda driver api https://docs.nvidia.com/cuda/cuda-driver-api/group__CUDA__MEM.html
   3) if function not intercepted succesfully, prob is caused that name of function is not called. e.g., cuMemcpy is not called, instead used cuMemcpyHtoD
*/
extern "C" {void *__libc_dlsym(void *map, const char *name);}
extern "C" {void *__libc_dlopen_mode(const char *name, int maddArgumentode);}

typedef void *(*fnDlsym)(void *, const char *);
static void *real_dlsym(void *handle, const char *symbol)
{
    static fnDlsym internal_dlsym = (fnDlsym)__libc_dlsym(__libc_dlopen_mode("libdl.so.2", RTLD_LAZY), "dlsym");
    return (*internal_dlsym)(handle, symbol);
}

typedef enum HookSymbolsEnum {
    SYM_CU_INIT,
    SYM_CU_MEM_ALLOC,
    SYM_CU_MEM_CPY_HTOD,
    SYM_CU_MEM_CPY,
    SYM_CU_SYMBOLS,
} HookSymbols;
static void* real_func[SYM_CU_SYMBOLS];

CUresult cuInit(unsigned int flag) {
    std::cout << "====cuInit hooked====at ";
    std::chrono::time_point<std::chrono::system_clock> now = std::chrono::system_clock::now();
    auto duration = now.time_since_epoch();
    std::cout << duration.count() << std::endl;
    if (real_func[SYM_CU_INIT] == NULL) real_func[SYM_CU_INIT] = real_dlsym(RTLD_NEXT, "cuInit");
    return  ((CUresult (*)(unsigned int))real_func[SYM_CU_INIT])(flag);
}

CUresult cuMemcpyHtoD (CUdeviceptr dst, const void* srcHost, size_t ByteCount) {
    std::cout << "@@@@==cuMemcpyHtoD hooked=****===at ";
    std::chrono::time_point<std::chrono::system_clock> now = std::chrono::system_clock::now();
    auto duration = now.time_since_epoch();
    std::cout << duration.count() << std::endl;
    if (real_func[SYM_CU_MEM_CPY_HTOD] == NULL) real_func[SYM_CU_MEM_CPY_HTOD] = real_dlsym(RTLD_NEXT, "cuMemcpyHtoD");
    return  ((CUresult (*)(CUdeviceptr,const void*,size_t))real_func[SYM_CU_MEM_CPY_HTOD])(dst, srcHost, ByteCount);
}
CUresult cuMemcpy (CUdeviceptr dst, CUdeviceptr src, size_t ByteCount) {
    std::cout << "@@@@==cuMemcpy hooked=****===" << std::endl;
    if (real_func[SYM_CU_MEM_CPY] == NULL) real_func[SYM_CU_MEM_CPY] = real_dlsym(RTLD_NEXT, "cuMemcpy");
    return  ((CUresult (*)(CUdeviceptr,CUdeviceptr,size_t))real_func[SYM_CU_MEM_CPY])(dst, src, ByteCount);
}

CUresult cuMemAlloc (CUdeviceptr* dptr, size_t bytesize)
{ 
    std::cout << "@@@@==cuMemAlloc hooked====" << std::endl;
    if (real_func[SYM_CU_MEM_ALLOC] == NULL) real_func[SYM_CU_MEM_ALLOC] = real_dlsym(RTLD_NEXT, "cuMemAlloc");
    return  ((CUresult (*)(CUdeviceptr*, size_t))real_func[SYM_CU_MEM_ALLOC])(dptr, bytesize);
}

void *dlsym(void *handle, const char *symbol)   
{
    if (strcmp(symbol, STRINGIFY(cuMemcpyHtoD)) == 0) {
        if(real_func[SYM_CU_MEM_CPY_HTOD] == NULL) real_func[SYM_CU_MEM_CPY_HTOD] = real_dlsym(handle, symbol); 
        return (void*)(&cuMemcpyHtoD);
    }
    
    if (strcmp(symbol, STRINGIFY(cuInit)) == 0) {
        if(real_func[SYM_CU_INIT] == NULL) real_func[SYM_CU_INIT] = real_dlsym(handle, symbol);
        return (void*)(&cuInit);
    }
    
    if (strcmp(symbol, STRINGIFY(cuMemAlloc)) == 0) {
	if(real_func[SYM_CU_MEM_ALLOC] == NULL) real_func[SYM_CU_MEM_ALLOC] = real_dlsym(handle, symbol);
        return (void*)(&cuMemAlloc);
    }
    
    return (real_dlsym(handle, symbol));
}
