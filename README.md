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

## H100 Performance and Architecture [link](https://developer.nvidia.com/blog/nvidia-hopper-architecture-in-depth/)
- 132 SMs provide a 22% SM count increase over the A100 108 SMs
- Each of the H100 SMs is 2x faster, thanks to its new fourth-generation Tensor Core.
- Within each Tensor Core, the new FP8 format and associated transformer engine provide another 2x improvement.
- Increased clock frequencies in H100 deliver another approximately 1.3x performance improvement.
- The transformer engine intelligently manages and dynamically chooses between FP8 and FP16 calculations, automatically handling re-casting and scaling between FP8 and 16-bit in each layer to deliver up to 9x faster AI training and up to 30x faster AI inference speedups on large language models compared to the prior generation A100.

In total, these improvements give H100 approximately 6x the peak compute throughput of A100, a major leap for the world’s most compute-hungry workloads.

## cuda Driver API intercept


## GPU utilization query
