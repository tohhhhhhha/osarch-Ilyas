# Task 2: Plan and justify

Host: MacBook Air M2, 8 cores (4 performance + 4 efficiency, no SMT), 8 GB unified memory (~3.0 GB available with my apps open), 494 GB SSD with ~100 GB free, macOS 26.5.2. Hypervisor: VirtualBox 7.1+ (Apple Silicon build)

Important constraint: the M2 is ARM64. Both guests must be ARM64 builds: **Ubuntu Server ARM64** and **Windows 11 ARM64**. An x86 Windows 11 ISO will not boot on this host

## Allocation

| | Ubuntu Server (ARM64) | Windows 11 (ARM64) |
|---|---|---|
| vCPUs | 2 | 2 |
| Memory | 1 GB (1024 MB) | 4 GB (4096 MB) |
| Disk size | 20 GB | 64 GB |
| Disk type | Dynamically allocated | Dynamically allocated |
| Network | Adapter 1: NAT, port forward host 127.0.0.1:2222 → guest :22 | Adapter 1: NAT |
| Other | Headless, no GUI | EFI + Secure Boot, TPM 2.0 enabled |

## Arithmetic

Host assumption: macOS with Terminal, VirtualBox and a light browser needs about 3 GB RAM and at least 2 cores to stay responsive, plus ~10 GB free disk for swap and updates (with 8 GB RAM, macOS swaps to disk under pressure).

| Resource | Host has | Ubuntu | Windows | Left for host | Enough? |
|---|---|---|---|---|---|
| CPU | 8 cores | 2 | 2 | 8 − 2 − 2 = **4 cores** | Yes |
| Memory | 8 GB | 1 GB | 4 GB | 8 − 1 − 4 = **3 GB** (minus ~0.3 GB VirtualBox overhead) | Barely |
| Disk (worst case, both disks full) | 100 GB free | 20 GB | 64 GB | 100 − 20 − 64 = **16 GB** | Yes |
| Disk (right after install) | 100 GB free | ~4 GB | ~22 GB | 100 − 4 − 22 ≈ **74 GB** | Yes |

**Conclusion:** the plan fits, but memory is the bottleneck. 3 GB left for macOS matches what was free when I measured with my usual apps open, so with both guests running I must close heavy host apps (browser tabs, etc.). This is the closest configuration that works; what it gives up is listed below.

## Justification

- **vCPUs (2 + 2, not more):** 8 cores is plenty, and Windows 11 requires at least 2. Giving each guest 2 leaves 4 cores for macOS. More vCPUs would not help, because memory, not CPU, is the limit.
- **Windows memory 4 GB (not more):** 4 GB is the Windows 11 minimum; setup refuses less. Any more would take memory from macOS.
- **Ubuntu memory 1 GB, below my lab size of 2 GB:** this is the one value I deliberately set below what I used before. Ubuntu Server has no GUI, and SSH plus basic services run fine in 1 GB. The cost: heavier workloads in the guest will swap. If the installer complains, I raise it to 2 GB for the install only and lower it back to 1 GB afterwards.
- **Disk sizes:** Windows 11 requires 64 GB, so I gave exactly the minimum. 20 GB is enough for Ubuntu Server plus packages.
- **Dynamically allocated, not fixed:** fixed disks would take all 84 GB immediately and leave only 16 GB, which macOS needs for swap on an 8 GB machine. Dynamic disks only use what the guests actually write (~26 GB at first). On an SSD the speed difference is small. The risk is that the disks can grow, so I watch free space with `df -H /`.
- **Ubuntu network: NAT with port forwarding, not the alternatives:**
  - NAT gives the guest internet access through the host.
  - The port forward (127.0.0.1:2222 → 22) makes SSH from the host work with one adapter.
  - Bridged would also work, but it puts the guest on the office Wi-Fi as a separate device, bridging over Wi-Fi on a Mac is unreliable, and it exposes SSH to the whole LAN.
  - Host-only alone gives SSH but no internet.
  - NAT + host-only (two adapters) would also satisfy the task, but it adds a second adapter for no gain here.
  - Binding the forward to 127.0.0.1 means only this Mac can reach the guest's SSH.
- **Windows network: NAT only:** Windows needs internet but nothing has to connect into it, so no port forward is needed.

**What this plan gives up:** macOS has little free memory while both guests run; Ubuntu has half the RAM it had in my lab; Windows runs at its minimum and will feel slow. If memory pressure goes red, the fallback is to run the two guests one at a time.

## Verification plan

| Where | Command | Expected output |
|---|---|---|
| Host | `VBoxManage showvminfo "ubuntu-srv" --machinereadable \| grep -E '^(cpus\|memory\|Forwarding)'` | `cpus=2`, `memory=1024`, `Forwarding(0)="ssh,tcp,127.0.0.1,2222,,22"` |
| Host | `VBoxManage showvminfo "win11" --machinereadable \| grep -E '^(cpus\|memory)'` | `cpus=2`, `memory=4096` |
| Host | `VBoxManage list hdds` | Two disks: Capacity 20480 MBytes and 65536 MBytes, Format VDI, both dynamic |
| Host | `df -H /` | Avail around 70 GB or more after both installs |
| Host | `memory_pressure \| tail -1` | `System-wide memory free percentage:` above ~15% with both guests running |
| Host | `ssh -p 2222 <user>@127.0.0.1` | Ubuntu login banner (`Welcome to Ubuntu ...`) and a shell prompt |
| Ubuntu | `nproc` | `2` |
| Ubuntu | `free -h` | Mem total about `960Mi` (slightly under 1 GB, the kernel reserves some) |
| Ubuntu | `lsblk` | Main disk (`sda` or `vda`) shown as `20G` |
| Ubuntu | `ip -4 addr` and `ip route` | Address `10.0.2.15/24`, `default via 10.0.2.2` (VirtualBox NAT) |
| Ubuntu | `ss -tln \| grep ':22'` | A line in state `LISTEN` on `0.0.0.0:22` |
| Ubuntu | `ping -c 3 1.1.1.1` | `3 packets transmitted, 3 received, 0% packet loss` |
| Ubuntu | `curl -sI https://example.com \| head -1` | `HTTP/2 200` (proves DNS and HTTPS work) |
| Windows (PowerShell) | `(Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors` | `2` |
| Windows (PowerShell) | `[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,1)` | about `4` |
| Windows (PowerShell) | `Get-Volume -DriveLetter C` | Size about `63 GB` |
| Windows (PowerShell) | `Test-NetConnection example.com -Port 443` | `TcpTestSucceeded : True` |
