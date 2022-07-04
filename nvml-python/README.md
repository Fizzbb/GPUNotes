Install the latest pynvml package, or install from their [github](https://github.com/gpuopenanalytics/pynvml)

We basically want to query device-level utilization (memory, io, sm) and process level utilization. Important functions are used in the [query-example.py](./query_example.py) file


[Nvidia function definition](https://docs.nvidia.com/deploy/nvml-api/group__nvmlGridQueries.html#group__nvmlGridQueries_1gb0ea5236f5e69e63bf53684a11c233bd)

**the following function works on TitanX and V100, does not respond in K80**

```
nvmlReturn_t nvmlDeviceGetProcessUtilization ( nvmlDevice_t device, nvmlProcessUtilizationSample_t* utilization, unsigned int* processSamplesCount, unsigned long long lastSeenTimeStamp ) 
```

```
lastSeenTimeStamp Return only samples with timestamp greater than lastSeenTimeStamp. If set 0, return all available values.
```
The timestamp unit seems to be micro second.

Sample outputs
```
Device 0, GPU util rate 0, Memory util Rate 0
Device 0 is free
Device 1, GPU util rate 100, Memory util Rate 0
Device 1 is used
process id 4145, used memory 936378368
process id 4145, timestamp 1653167163586231, sm util 99, mem util 0, decUtil 0, encUtil:0
Device 2, GPU util rate 100, Memory util Rate 0
Device 2 is used
process id 4146, used memory 936378368
process id 4146, timestamp 1653167151828549, sm util 99, mem util 0, decUtil 0, encUtil:0
Device 3, GPU util rate 100, Memory util Rate 0
Device 3 is used
process id 4147, used memory 936378368
process id 4147, timestamp 1653167155435855, sm util 99, mem util 0, decUtil 0, encUtil:0
Device 4, GPU util rate 0, Memory util Rate 0
Device 4 is free
Device 5, GPU util rate 0, Memory util Rate 0
Device 5 is free
Device 6, GPU util rate 0, Memory util Rate 0
Device 6 is free
Device 7, GPU util rate 0, Memory util Rate 0
Device 7 is free

```

As for the setting of LastSeenTimestamp, 0 will give you the earliest value saved in nvml. Don't use current time (now), which will not find any value and return error. typically use (current time - 1) sec is a safe bet.  Not sure the frequency nvml sample the process utilization. Also not sure the size of its buffer, i.e., how many values are saved. 

Some sample returns are like following. Same timestamp could have different utilzation value.
```
current time: 1656911469205174
2022/07/03 22:11:09 Beginning to serve on port :9876
        [ 0] ProcessInfo: {Pid:2677 UsedGpuMemory:12512657408 GpuInstanceId:4294967295 ComputeInstanceId:4294967295}
now timestamp 1656911472080277
1 last seen timestamp 0, [{2677 1656911469751200 45 25 0 0}]
3 last seen timestamp 1656911471080277, [{2677 1656911471929781 52 29 0 0}]
4 last seen timestamp 1656911470080277, [{2677 1656911471929781 51 28 0 0}]
5 last seen timestamp 1656911469080277, [{2677 1656911469751200 51 28 0 0}]
```

Another run 
```
now timestamp 1656912048933412
1 last seen timestamp 0, [{19043 1656912043074951 44 24 0 0}]
3 last seen timestamp 1656912047933412, [{19043 1656912048930155 43 24 0 0}]
4 last seen timestamp 1656912046933412, [{19043 1656912048930155 43 24 0 0}]
5 last seen timestamp 1656912045933412, [{19043 1656912048930155 43 24 0 0}]
6 last seen timestamp 1656912044933412, [{19043 1656912048930155 43 24 0 0}]
```
