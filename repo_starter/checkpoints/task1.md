# Task 1a: 

| Figure | This computer | Command it came from |
|---|---|---|
| CPU model | Apple M2 | `sysctl -n machdep.cpu.brand_string` |
| Cores / logical processors | 8 cores / 8 logical| `sysctl hw.physicalcpu hw.logicalcpu` |
| Hardware virtualization: supported? enabled in firmware? | Supported: yes. Enabled: yes, Apple Silicon has no firmware toggle, it is always on | `sysctl kern.hv_support` |
| Memory: total / available now | 8 GB / about 3.0 GB | `sysctl -n hw.memsize`, `memory_pressure` |
| System disk: size, free space, SSD or HDD | 494G total, 100G free, SSD (APPLE SSD AP0512Z) | `df -H /`, `system_profiler SPStorageDataType` |
| Partition style of the system disk | GUID_partition_scheme, APFS container inside | `diskutil list disk0` |
| OS and version | macOS 26.5.2 (build 25F84) | `sw_vers` |

# Task 1b: 
## 1. Both guests?

Guest sizes from my Lab 1–2 build log: Ubuntu Server 2 vCPU / 2 GB / 25 GB dynamic; Windows 11 2 vCPU / 4 GB / 64 GB dynamic
Host assumption: Windows 11 Home itself needs about 3 GB RAM and 1–2 threads to stay usable

| Resource | Laptop has | Guests need | Host needs | Result |
|---|---|---|---|---|
| CPU | 4 threads| 2 + 2 = 4 vCPU | 1–2 threads | 4 + 1 = 5 > 4, host gets nothing |
| Memory | 8 GB | 2 + 4 = 6 GB | ~3 GB | 6 + 3 = 9 GB > 8 GB |
| Disk | 31 GB free | 25 + 64 = 89 GB max | a few GB for updates | 89 > 31; even dynamic, the installs use ~25–30 GB and fill the disk |

**Answer: no.** Memory and disk fail outright, and CPU leaves the host nothing. There is also a blocker before any arithmetic: in S mode, Windows only installs Store apps, so VirtualBox cannot be installed at all. Windows 11 Home also has no Hyper-V

## 2. Upgrade first

Nothing in the hardware can be upgraded: the RAM is soldered LPDDR4X and the storage is soldered eMMC, and the CPU is fixed.
The first change is software: **switch out of S mode** (free, through the Microsoft Store, one-way). Without that, no hypervisor can be installed.
Instead of two guests I would run **only the Ubuntu Server guest** (1 vCPU, 1–2 GB RAM, 20 GB dynamic disk, ideally on an external USB SSD because eMMC is slow), and run the Windows 11 guest on a bigger machine or a cloud VM.
