#include <dlfcn.h>
#include <string.h>
#include <iostream>
#include <cuda.h>


int main() {
    std::cout << "testing cuInit..." << std::endl;
    cuInit(0);
    return 0;
}
