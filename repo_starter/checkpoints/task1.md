# Task 1a: The computer in front of you

| Figure | This computer | Command it came from |
|---|---|---|
| CPU model | Apple M2 | `sysctl -n machdep.cpu.brand_string` |
| Cores / logical processors | 8 cores (4 Performance + 4 Efficiency) / 8 logical (no SMT on Apple Silicon) | `sysctl hw.physicalcpu hw.logicalcpu` |
| Hardware virtualization: supported? enabled in firmware? | Supported: yes (kern.hv_support = 1). Enabled: yes, Apple Silicon has no firmware toggle, it is always on | `sysctl kern.hv_support` |
| Memory: total / available now | 8 GB / about 3.0 GB | `sysctl -n hw.memsize`, `memory_pressure` |
| System disk: size, free space, SSD or HDD | 494G total, 100G free, SSD (APPLE SSD AP0512Z) | `df -H /`, `system_profiler SPStorageDataType` |
| Partition style of the system disk | GUID_partition_scheme (GPT), APFS container inside | `diskutil list disk0` |
| OS and version | macOS 26.5.2 (build 25F84) | `sw_vers` |

Raw command output: [evidence/task1.txt](evidence/task1.txt)
