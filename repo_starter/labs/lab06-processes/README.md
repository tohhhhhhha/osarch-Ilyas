# Lab 6 — Live processes and memory pressure

Pair: solo    Driver first half: myself
Machine: MacBook M2, macOS (host); Debian GNU/Linux forky/sid arm64 guest (1.9 GiB RAM, 1.0 GiB swap) and Windows 11 ARM guest in VMware Fusion
Date: 2026-11-22

## What I did

### 1. One process, three tools

The process: **`vmtoolsd`, the VMware Tools core service**. It is the same program in both guests, so the
three tools look at the same thing. Task Manager and Process Explorer look at the *same process* (PID 828)
on Windows; htop looks at the same program on Linux (PID 697) — one process cannot be in two operating systems.

Windows runs **two** `vmtoolsd.exe` processes; Linux runs one:

    PS> Get-Process vmtoolsd | Select-Object Id, ProcessName
       Id ProcessName
      828 vmtoolsd         # user part (vmusr): user student, parent explorer.exe (3252)
     3288 vmtoolsd         # service part (vmsvc): user SYSTEM, parent services.exe (812)

    PS> Get-Process -Id 3252 | Select-Object Id, ProcessName
     3252 explorer

On Debian:

    $ pgrep -a vmtoolsd
    697 /usr/bin/vmtoolsd
    $ ps -o pid,ppid,user,cmd -p 697
        PID    PPID USER     CMD
        697       1 root     /usr/bin/vmtoolsd
    $ ps -o pid,cmd -p 1
          1 /sbin/init                 # systemd
    $ grep -E 'Name|PPid|VmSize|VmRSS|Threads' /proc/697/status
    Name:   vmtoolsd
    PPid:   1
    VmSize:   116232 kB
    VmRSS:     13884 kB
    Threads:  4
    $ sudo ls /proc/697/fd | wc -l
    8

| | Task Manager (Details) | Process Explorer | htop / `/proc` (Linux) |
|---|---|---|---|
| PID | 828 | 828 | 697 |
| Parent | — (not a column) | PPID 3252 = explorer.exe | PPID 1 = systemd (`/sbin/init`) |
| User | student | DESKTOP-5UHTR3O\student | root |
| All mapped address space | — | Virtual Size **2,151,907,764 K** (≈ 2 TB) | VIRT **113M** (VmSize 116,232 kB) |
| In RAM now | Working set **22,120 K** | Working Set **21,164 K** | RES **13,884 K** (VmRSS) |
| Of that, shared | — | WS Shareable **19,644 K** | (SHR not shown in my htop layout) |
| Private | Memory (active private working set) **2,480 K**; Commit size **6,492 K** | Private Bytes **5,540 K** | PRIV **3,648 K** |
| Threads | 5 | 5 | 4 — shown as 4 separate rows (697, 880, 892, 893) |
| Handles / fds | Handles **240** | Handles **240** (lower pane: ALPC Port, Desktop, Directory, Event, File, Key) | **8** file descriptors |
| State | Running | — | S (sleeping) |

Screenshots: `evidence/task-manager.png`, `evidence/process-explorer.png`, `evidence/htop.png`.

### 2. Where the tools disagree

1. **"Memory" in Task Manager is not "Working set".** For the same process, at the same moment, Task Manager's
   default *Memory* column says **2,480 K** and its *Working set* column says **22,120 K** — nine times more.
   Process Explorer explains it: **WS Shareable 19,644 K** of the 21,164 K working set is shared DLL pages that
   other processes use too. Task Manager's default number is the *private* working set only.
2. **Three names, three numbers for "private memory".** Task Manager *Memory* 2,480 K (private and in RAM),
   Task Manager *Commit size* 6,492 K and Process Explorer *Private Bytes* 5,540 K (private, whether in RAM or not),
   htop *PRIV* 3,648 K. Each tool picks a different definition.
3. **Virtual size is not RAM.** Process Explorer shows a Virtual Size of about **2 TB** for a process with 21 MB
   in RAM — reserved address space, not memory in use. The same program on Linux has VIRT **113M**:
   the two kernels reserve address space very differently.
4. **Threads as rows.** htop shows `vmtoolsd` as **four rows** (697 plus threads 880, 892, 893, in green);
   Task Manager and Process Explorer show one row and a *Threads* count.
5. **Handles vs file descriptors.** Windows: **240 handles**, and the lower pane of Process Explorer shows most of
   them are not files at all — registry keys (`HKLM\SOFTWARE\Microsoft\Ole`…), events
   (`\BaseNamedObjects\VMwareToolsQuitEvent_vmusr`), ALPC ports, directories. Linux: **8** file descriptors.
   The counts cannot be compared.
6. **User name.** For the service instance (PID 3288) Task Manager shows **SYSTEM**, Process Explorer shows
   **`<access denied>`** — Process Explorer was not run as administrator, so it could not read the owner.
7. The live numbers moved between screenshots (Working Set 22,120 K → 21,164 K → 38,856 K) — memory figures are
   a snapshot, not a constant.

### 3. Memory pressure (Linux)

Snapshot `before-lab6` taken first. Before:

    $ free -h
                   total        used        free      shared  buff/cache   available
    Mem:           1.9Gi       230Mi       1.5Gi       776Ki       286Mi       1.7Gi
    Swap:          1.0Gi          0B       1.0Gi

Second terminal, `free -h` every 3 seconds appended to the evidence file:

    while true; do { echo "=== DURING $(date +%T)"; free -h | head -3; } | tee -a memory-pressure.txt; sleep 3; done

First terminal, the allocator from the brief (100 MB per second):

    python3 -c "
    import time
    a = []
    while True:
        a.append(b'x' * 100_000_000)
        print(len(a) * 100, 'MB', flush=True)
        time.sleep(1)
    "
    ...
    2800 MB
    2900 MB
    Killed

Figures from `evidence/memory-pressure.txt` (run 2):

| Time | Mem used | available | buff/cache | Swap used | Stage |
|---|---|---|---|---|---|
| 00:41:13 (before) | 230Mi | 1.7Gi | 286Mi | **0B** | idle |
| 00:46:28 | 605Mi | 1.3Gi | 60Mi | 2.7Mi | 1 — page cache dropped (286 → 60 MB) |
| 00:46:40 | 1.6Gi | 301Mi | 60Mi | 2.7Mi | RAM filling |
| 00:46:43 | 1.9Gi | **32Mi** | 57Mi | 9.3Mi | RAM full |
| 00:46:46 | 1.9Gi | 21Mi | 57Mi | 214Mi | 2 — swapping |
| 00:46:49 | 1.9Gi | 21Mi | 57Mi | 486Mi | swapping |
| 00:46:52 | 1.9Gi | 21Mi | 57Mi | 763Mi | swapping |
| 00:46:55 | 1.9Gi | 26Mi | **12Mi** | **1.0Gi** (32Ki free) | swap full |
| 00:46:56 | — | — | — | — | 4 — process killed |
| 00:46:58 (after) | 201Mi | 1.7Gi | 31Mi | 3.2Mi | memory back within two seconds |

Responsiveness: the SSH session kept answering, but the 3-second `free` lines arrived late while swap was filling.
Thrashing never lasted: swap (1 GiB) was full nine seconds after RAM, and the kernel killed the process.

### 4. The kernel's record

    $ sudo journalctl -k --since today | grep -iE 'invoked oom-killer|out of memory|killed process'
    Nov 22 00:43:41 lab01 kernel: bash invoked oom-killer: gfp_mask=0x440dc0(...), order=0, oom_score_adj=0
    Nov 22 00:43:41 lab01 kernel: Out of memory: Killed process 1509 (python3) total-vm:2754508kB, anon-rss:1710240kB, ... UID:1000 ...
    Nov 22 00:46:56 lab01 kernel: python3 invoked oom-killer: gfp_mask=0x440dc0(...), order=0, oom_score_adj=0
    Nov 22 00:46:56 lab01 kernel: Out of memory: Killed process 1958 (python3) total-vm:2948572kB, anon-rss:1809804kB, ... UID:1000 ...
    $ systemctl is-active systemd-oomd
    inactive

- The kill at **00:46:56** falls between the `free` lines at 00:46:55 (swap full) and 00:46:58 (memory free).
- In run 1 the OOM killer was **invoked by bash** — bash happened to ask for memory when none was left — but
  the **victim was python3**, the process with the highest `oom_score`. The one who asks is not the one who dies.
- `systemd-oomd` is not running on Debian, so the kernel's own OOM killer acted. Full output:
  `evidence/kernel-log-extract.txt`.

### 5. The Windows side

Windows has no OOM killer, so I pushed it the same way and recorded what it did instead:

    PS> $list = [System.Collections.Generic.List[byte[]]]::new()
    PS> while ($true) { $list.Add([byte[]]::new(200MB)); ... }
      ...
      4200 MB allocated   free virtual memory: 316 MB
      4400 MB allocated   free virtual memory: 933 MB
      ...
      8400 MB allocated   free virtual memory: 93 MB
    ALLOCATION FAILED: ... 'System.OutOfMemoryException' was thrown.

- **Windows refused the allocation instead of killing a process** — the program got an `OutOfMemoryException`.
- "Free virtual memory" fell by 200 MB per step and then **jumped back up by ~800 MB** (316 → 933, 317 → 1,030,
  435 → 1,269): Windows was **growing pagefile.sys on the fly**. Linux swap stayed fixed at 1 GiB.

The record (`evidence/windows-event-log.txt`):

    === Resource-Exhaustion-Resolver/Operational
    TimeCreated : 11/21/2026 11:51:44 AM
    Id          : 1015
    Message     : The Windows Resource Exhaustion Resolver received an event from the Windows Resource Exhaustion Detector.
    TimeCreated : 11/21/2026 11:51:44 AM
    Id          : 1001
    Message     : The Windows Resource Exhaustion Resolver started.

The Windows guest clock is on US Pacific time: 11:51 there is 00:51 in Almaty, the minute the allocation failed.

## Result

- One program, `vmtoolsd`, compared in Task Manager, Process Explorer and htop; seven disagreements found, the main
  one: Task Manager *Memory* 2,480 K vs *Working set* 22,120 K for the same process, explained by 19,644 K of
  shared pages.
- Linux memory pressure: page cache dropped, swap filled from 0 to 1.0 GiB in 12 seconds, then the kernel's OOM
  killer killed python3 at 2.9 GB (`Out of memory: Killed process 1958 (python3)` at 00:46:56).
- Windows: allocation failed at 8.4 GB with the page file growing underneath; the Resource Exhaustion Detector
  signalled the Resolver at 11:51:44 (Pacific).

## What did not work the first time

1. **No "during" figures.** In my first run I started the allocator without the second terminal, so I only had
   "before" and the `Killed` line. I recorded "after run 1", opened a second SSH tab with the `free -h` loop and
   ran the allocator again. Both runs are in the kernel log; the table above is run 2.
2. **Event 2004 was the wrong event.** `Get-WinEvent -FilterHashtable @{LogName='System'; Id=2004}` returned one
   event — but from **Microsoft-Windows-Setup** ("Successfully logged OS information", the install date). The same
   ID is used by different providers. Filtered by `ProviderName='Microsoft-Windows-Resource-Exhaustion-Detector'`
   there was nothing, even after the test. `Get-Service DPS` showed the Diagnostic Policy Service running, and
   `Get-WinEvent -ListLog *Exhaustion*` showed two dedicated logs. The test's record was in
   **Resource-Exhaustion-Resolver/Operational**, not in System.
3. **SSH hung.** The Debian guest got a new address after the weekend (192.168.246.139 → .141). `hostname -I` in the
   guest console gave the new one; the host key fingerprint was unchanged.

## Evidence

- [evidence/task-manager.png](evidence/task-manager.png) — PID 828 in Task Manager Details: user, Working set, Memory (private working set), Commit size, Handles, Threads
- [evidence/process-explorer.png](evidence/process-explorer.png) — PID 828 in Process Explorer: PPID, Private Bytes, Working Set, WS Shareable, Virtual Size, and the Handles pane
- [evidence/htop.png](evidence/htop.png) — PID 697 in htop with its three threads as rows; Mem and Swp meters before the test
- [evidence/memory-pressure.txt](evidence/memory-pressure.txt) — `free -h` before, during (every 3 s) and after, two runs
- [evidence/kernel-log-extract.txt](evidence/kernel-log-extract.txt) — the kernel's OOM records from `journalctl -k` and `dmesg -T`; `systemd-oomd` inactive
- [evidence/windows-event-log.txt](evidence/windows-event-log.txt) — the Windows record: Resource-Exhaustion Resolver events, and the unrelated System event 2004

## AI declaration

I used Claude (Anthropic) as a step-by-step guide during this lab: it told me which commands to run and explained
what their output meant. I ran every command myself, and every figure in this README comes from my own terminals,
screenshots and evidence files. The README text was drafted by Claude from my results, and I checked it.
