#pynvml github, implemenation ref https://github.com/gpuopenanalytics/pynvml/blob/master/pynvml/nvml.py
from pynvml import *
import time

def get_utilization_per_process():
    nvmlInit()
    deviceCount = nvmlDeviceGetCount()
    for i in range(deviceCount):
        handle = nvmlDeviceGetHandleByIndex(i)
        use = nvmlDeviceGetUtilizationRates(handle)
        print("Device {}, GPU util rate {}, Memory util Rate {}".format(i, use.gpu, use.memory))
        processes = nvmlDeviceGetComputeRunningProcesses(handle)
        if len(processes)>0:
            print("Device {} is used".format(i))
            # get memory used per process
            for j in processes:
                print("process id {}, used memory {}".format(j.pid,j.usedGpuMemory))

            # get gpu util used per process
            # lastseentimestamp = 0 # set 0 to return all samples buffered 
            # get the sample within 1 sec from now
            lastseentimestamp = round((time.time()-1)*1e6)
            # how to check this function fails(empty buffer), 
            # sometimes, no samples found, still return a list with all zero values
            samples = nvmlDeviceGetProcessUtilization(handle, lastseentimestamp)
            #print(samples)
            for sample in samples:
                #available attribute 'decUtil', 'encUtil', 'memUtil', 'pid', 'smUtil', 'timeStamp'i
                if (int(sample.pid)!=0):
                    print("process id {}, timestamp {}, sm util {}, mem util {}, decUtil {}, encUtil:{}".format(sample.pid, sample.timeStamp,sample.smUtil,sample.memUtil,sample.decUtil,sample.encUtil))
            
            print("number of samples: {}".format(len(samples)))
        else:
            print("Device {} is free".format(i))


if __name__ == "__main__":
   get_utilization_per_process()
