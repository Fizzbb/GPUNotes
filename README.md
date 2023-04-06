# GPUNotes
GPUNotes
## Terminologies based on cuda
- 1 cuda core means a warp, 32 thread. 
- A warp is SIMD, single instruction multiple data. i.e., all the 32 threads execute the same instruction
- SM(stream processor) includes floatpoint unit, int unit, tensor core, etc
- Each SM can have thounds of thread, e.g. a titanV SM has 2048 threads, a total of 80 SM has 5120 cuda core (80*2048/32)
- Block, a group of thread, logical concept, could be 32,64,128,256--1024, typical choose 256, thread within a block have shared memory space (L1)
- when calculate how many block, it equals int(number of calculation/thread(e.g,256))
- Memory hiearchy 2 level cache: e.g., A100, Registers 256KB per SM -> L1 192KB SMEM per SM -> L2 40 MB shared among SM -> External GDDR 40G or 80G 
- GDDR, HBM (high bandwidth memory), external address can be 1024bits, compared traditional 64bit ddr4, also low power
- GDDR6 data transfer speeed 14-16GB per sec, DDR4 1.6-3.2GB per sec
## cuda Driver API intercept


## GPU utilization query
