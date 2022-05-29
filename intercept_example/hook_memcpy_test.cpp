#include <dlfcn.h>
#include <string.h>
#include <iostream>
#include <cuda.h>


int main() {
    std::cout << "testing cuMemcpy..." << std::endl;
    long long unsigned int a, *d_a;
    //cuInit(0);
    cuMemAlloc(d_a, sizeof(d_a[0]));
    cuMemcpy(*d_a, a, sizeof(a));
    return 0;
}
