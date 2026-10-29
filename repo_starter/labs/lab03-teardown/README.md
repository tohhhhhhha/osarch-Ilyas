# Lab 3 — Teardown without a screwdriver

All Part A facts were read on the **host** (macOS on the real laptop), not inside a VM.

## 1. The machine

| Field | Value | Source |
|---|---|---|
| Manufacturer | Apple | `system_profiler SPHardwareDataType` |
| Model | MacBook Air (M2, 2022), 13-inch | Model Identifier `Mac14,2` |
| Model Number | MLY23LL/A | `system_profiler SPHardwareDataType` |
| Chip | Apple M2: 8-core CPU (4 performance + 4 efficiency), 10-core GPU | `SPHardwareDataType`, `SPDisplaysDataType` |
| Memory / storage | 8 GB / 512 GB | `SPHardwareDataType`, `SPNVMeDataType` |
| Logic board part | 661-25636 (M2, 10-core GPU, 8 GB, 512 GB) | Manual: Exploded View and Orderable Parts |

**How I found it:** TODO — 1–2 sentences in your own words.

**Service manual:** [MacBook Air (M2, 2022) Repair Manual](https://support.apple.com/100603), Apple Self Service Repair, Manual ID PTGVKD. Figure and parts list: [Exploded View and Orderable Parts](https://support.apple.com/100604).

Evidence: [`evidence/macos-specs.txt`](evidence/macos-specs.txt). Serial numbers and UUIDs replaced with `XXXX`.

## 2. Components

![Exploded view of MacBook Air (M2, 2022)](evidence/manual-figures/exploded-view.png)

*Figure 1. Exploded view from Apple's repair manual. The numbers are Apple's.*

| # | What | Connects to | Limits |
|---|---|---|---|
| 24 | Logic board: Apple M2 SoC with 8 GB LPDDR5 and 512 GB storage on the same board; sold only as a whole (661-25636) | 10 flex cables: battery + TODO (9 names from step 7 of the Logic Board procedure); heat sink (23) on top | Memory, storage and CPU cannot be replaced separately. A replacement board needs a new heat sink and a new Touch ID board |
| 25 | Battery | TODO | TODO |
| 23 | Heat sink | TODO | TODO |
| 28 | Display | TODO | TODO |
| 26 | Top case with keyboard | TODO | TODO |
| 27, 22 | Trackpad and trackpad flex cable | TODO | TODO |
| 20 | MagSafe 3 board | TODO | TODO |
| 21 | USB-C boards | TODO | TODO |
| 17 | Audio board | TODO | TODO |
| 18 | Touch ID board | TODO | TODO |
| 3 | Left and right speakers with antennas | TODO | TODO |
| 15 | Lid angle sensor | TODO | TODO |
| 1 | Bottom case | TODO | TODO |
| 2, 9, 4–14, 16, 19 | Hinge covers, connector cowlings, MagSafe board wedge | Screwed over connectors and hinges | Mechanical only; no effect on upgrades |

## 3. Upgrade verdict

| Component | Manual says | OS says | Verdict |
|---|---|---|---|
| Memory | No separate memory part; the logic board (part 24) is sold in 8 / 16 / 24 GB variants (Exploded View and Orderable Parts) | `SPMemoryDataType`: 8 GB, LPDDR5, no modules or slots listed | **No:** on the logic board, fixed at purchase |
| Storage | No separate SSD part; logic board variants include 256 GB to 2 TB (same page) | `SPNVMeDataType`: APPLE SSD AP0512Z, Detachable Drive: No; `diskutil`: Removable Media: Fixed | **No:** on the logic board, no M.2 slot |
| CPU | "M2" is part of every logic board variant (same page) | `sysctl -n machdep.cpu.brand_string`: Apple M2 | **No:** part of the SoC; no socket |

TODO — your paragraph on where the manual and the OS disagree, and which one you trust and why.

<!-- Hints (delete this comment):
- Manual names the board variant "512 GB"; OS shows 500.28 GB.
- macOS says "8 GB", but hw.memsize = 8589934592 bytes = exactly 8 GiB.
- system_profiler lists the disk under "NVMExpress", diskutil says "Apple Fabric".
-->

## 4. Three-OS table

| Fact | macOS (host) | Debian (VM) | Windows (VM) |
|---|---|---|---|
| CPU model | `sysctl -n machdep.cpu.brand_string` → Apple M2 | `lscpu` Model name → `-` (Vendor ID: Apple) | `Win32_Processor` Name → Apple silicon |
| Physical cores | `sysctl hw.physicalcpu` → 8 | `lscpu` Core(s) per socket × Socket(s) → 2 × 1 | `Win32_Processor` NumberOfCores → 1 per CPU × 2 CPUs |
| Logical CPUs | `sysctl hw.logicalcpu` → 8 | `lscpu` CPU(s) → 2 | `Win32_ComputerSystem` NumberOfLogicalProcessors → 2 |
| Max clock | not shown on Apple Silicon | `lscpu` → no CPU max MHz line | `Win32_Processor` MaxClockSpeed → 2000 MHz |
| Total memory | `sysctl hw.memsize` → 8589934592 bytes | `free -h` total → 1.9Gi | `Win32_ComputerSystem` TotalPhysicalMemory → 4289474560 bytes |
| Memory type / speed | `SPMemoryDataType` Type → LPDDR5 | `dmidecode -t memory` → DRAM, 4800 MT/s | `Win32_PhysicalMemory` SMBIOSMemoryType → 3 (DRAM), 4800 |
| Memory slots | `SPMemoryDataType` → no modules | `dmidecode -t memory` Number Of Devices → 64, 1 used | `Win32_PhysicalMemory` BankLabel → RAM slot #0 |
| Disk is SSD | `diskutil info disk0` Solid State → Yes | `lsblk` ROTA → 0 | `Get-PhysicalDisk` MediaType → SSD |
| Disk interface | `diskutil info disk0` Protocol → Apple Fabric | `lsblk` TRAN → nvme | `Get-PhysicalDisk` BusType → NVMe |
| Disk model / size | APPLE SSD AP0512Z, 500.28 GB | VMware Virtual NVMe Disk, 20G | VMware Virtual NVMe Disk, 64 GiB |
| Motherboard | Model Identifier → Mac14,2 | `dmidecode -t baseboard` → VMware, Inc. VBSA | `Win32_BaseBoard` → VMware, Inc. VBSA |

TODO — 2–3 sentences: which names differed most, which values differed between host and VMs, and why.

<!-- Hints (delete this comment):
- Same fact, different names: hw.logicalcpu / CPU(s) / NumberOfLogicalProcessors.
- Same 2 vCPUs: Debian sees 1 socket x 2 cores, Windows sees 2 CPUs x 1 core.
- Both VMs show the same invented memory and board: one VMware firmware table, not two sources.
-->

Debian and Windows run as VMware Fusion guests (arm64), so their values describe virtual hardware, not the laptop. The Windows transcript shows a US date because the VM's time zone is UTC−7.

Evidence: [`macos-specs.txt`](evidence/macos-specs.txt), [`linux-specs.txt`](evidence/linux-specs.txt), [`windows-specs.txt`](evidence/windows-specs.txt).
