# Lab 0 — Inventory your own machine

Pair: none
Driver first half: me
Machine: Macbook Air M2, Mac14,2
Date: 10.10.2026

## What I did

```
sysctl -n machdep.cpu.brand_string
sysctl hw.physicalcpu hw.logicalcpu
Apple M2
hw.physicalcpu: 8
hw.logicalcpu: 8
```

```
system_profiler SPMemoryDataType
Memory: 8 GB
Type: LPDDR5
```

```
system_profiler SPStorageDataType SPNVMeDataType
df -h /
Model: APPLE SSD AP0512Z
Free: 242,21 GB
```

```
system_profiler SPHardwareDataType
System Firmware Version: 18000.121.3
```
```
sysctl kern.hv_support
kern.hv_support: 1
```
## Result

| What | Value | Where I got it |
|------|-------|----------------|
| CPU | Apple M2 | `sysctl -n machdep.cpu.brand_string` |
| Cores / threads | 8 / 8 | `sysctl hw.physicalcpu hw.logicalcpu` |
| RAM | 8 GB LPDDR5 | `system_profiler SPMemoryDataType` |
| RAM modules / speed | no separate modules (soldered), speed not shown | `system_profiler SPMemoryDataType` |
| Disk model | APPLE SSD AP0512Z | `system_profiler SPStorageDataType SPNVMeDataType` |
| Disk type | NVMe SSD | `system_profiler SPNVMeDataType` |
| Free space | 242,21 GB | `system_profiler SPStorageDataType` |
| Firmware | Apple Silicon, no BIOS/UEFI, version 18000.121.3 | `system_profiler SPHardwareDataType` |
| Virtualization | enabled | `sysctl kern.hv_support` (1) |

## What did not work the first time

- I ran `git clone` and got `fatal: destination path 'osarch-Ilyas' already exists and is not an empty directory`. It turned out I had already cloned this repository before. `git status` showed nothing to commit, so I deleted the old folder with `rm -rf osarch-Ilyas` and cloned it again
- I typed two commands on one line (`cd labd ls`) and got `cd: string not in pwd: labd`. The shell read `labd` and `ls` as arguments of `cd`. I entered the commands one per line instead, and `cd repo_starter/labs/lab00-inventory` worked
- At first I found it hard to understand what the task required and how to start, so I used an AI assistant for explanations of the steps and the commands. I ran all the commands myself on my own MacBook, and all values in the table come from my own output

## Evidence

- [evidence/cpu.txt](evidence/cpu.txt) — CPU model, cores, threads
- [evidence/memory.txt](evidence/memory.txt) — RAM size and type
- [evidence/disk.txt](evidence/disk.txt) — disk model, type, free space
