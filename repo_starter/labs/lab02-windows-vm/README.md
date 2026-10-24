# Lab 2 — A Windows guest, and a network between them

Pair: — (worked alone)          Driver first half: —
Machine: MacBook, Apple Silicon (ARM64), 8 GB RAM, VMware Fusion
Date: 2026-10-25

## What I did

**1. Built a Windows 11 VM (ARM64, no product key).** The x64 evaluation ISO cannot be virtualised on
Apple Silicon, so I used the official Windows 11 Arm64 ISO from Microsoft
(`Windows11_Client_arm64_en-us_26300_9457.iso`). Fusion: custom VM, Windows 11 64-bit Arm, UEFI +
Secure Boot, TPM (encryption of TPM files only), 4096 MB, 2 cores, 64 GB disk. Setup: "I don't have a
product key", Windows 11 Pro, local account. Then installed VMware Tools for the network driver.

**2. Network mode: "Share with my Mac" (NAT) on both guests.**

```
C:\> ipconfig
   IPv4 Address. . . . . . . . . . . : 192.168.246.130
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . : 192.168.246.2
```

```
student@lab01:~$ ip addr
2: enp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
    inet 192.168.246.129/24 brd 192.168.246.255 scope global dynamic enp2s0
```

Why this mode: it puts both VMs on one virtual subnet (192.168.246.0/24), so they reach each other
directly, and gives them internet through NAT on the Mac. Bridged was not used because the campus network
uses MAC filtering and would silently drop the guests' frames. Host-only would connect the guests to each
other but give no internet.

```
                 Internet
                    │
        ┌───────────┴────────────┐
        │   macOS host (NAT)     │
        │  gateway 192.168.246.2 │
        └───────────┬────────────┘
                    │  "Share with my Mac"  192.168.246.0/24
          ┌─────────┴──────────┐
   ┌──────┴───────┐     ┌──────┴────────┐
   │ Debian lab01 │◄───►│ Windows 11    │
   │ .246.129     │ICMP │ .246.130      │
   └──────────────┘     └───────────────┘
```

**3. Internet from both guests.**

```
C:\> ping -n 4 8.8.8.8
Packets: Sent = 4, Received = 3, Lost = 1 (25% loss)

student@lab01:~$ ping -c 4 8.8.8.8
4 packets transmitted, 4 received, 0% packet loss
```

**4. Ping both ways + firewall rule** (firewall left on, only ICMPv4 Echo Request allowed):

```
student@lab01:~$ ping -c 4 192.168.246.130
4 packets transmitted, 0 received, 100% packet loss

C:\Windows\System32> netsh advfirewall firewall add rule name="Allow ICMPv4 Echo In" protocol=icmpv4:8,any dir=in action=allow
Ok.

student@lab01:~$ ping -c 4 192.168.246.130
4 packets transmitted, 4 received, 0% packet loss

C:\> ping -n 4 192.168.246.129
Packets: Sent = 4, Received = 4, Lost = 0 (0% loss)
```

**5. Memory overcommitment.** Measured the host with both VMs off, then set both guests to 5120 MB
(10 GB total on an 8 GB host), started both, loaded them (Edge with many tabs in Windows; in Linux:)

```
student@lab01:~$ head -c 4G /dev/zero | tail
```

and measured again in Activity Monitor → Memory.

**6. Returned allocations to sane values:** Windows 4096 MB, Debian 2048 MB.

## Result

Both guests reach each other and the internet. The network mode is "Share with my Mac" (NAT), for the
reasons above.

Overcommitment, Activity Monitor → Memory:

| Metric | Before (VMs off) | After (2 × 5 GB, loaded) |
|---|---|---|
| Memory pressure | green | **yellow** |
| Memory used | 6.01 GB | 7.11 GB |
| Cached files | 1.85 GB | 0.85 GB |
| Compressed | 0.57 GB | **3.23 GB** |
| Swap used | 2.86 GB | **4.11 GB** |
| App memory | 3.27 GB | 1.42 GB |

What the host did: Fusion only checks each VM on its own ("3072 MB remaining for your Mac") and did not
stop me from giving 10 GB in total. Both VMs started. macOS did not crash or refuse. It reclaimed memory
in stages: it dropped file cache (about −1 GB), compressed memory (×5.7, up to 3.23 GB), and paged out to
disk (swap +1.25 GB). Memory pressure turned yellow, and the Mac's own apps lost resident memory
(3.27 → 1.42 GB) to make room for the guests.

## What did not work the first time

- **Ping from Linux to Windows: 100% packet loss.** Windows classified the new network as *Public*, and
  in that profile the firewall drops inbound ICMPv4 Echo Requests by default. I did not turn the firewall
  off. I added one inbound rule allowing ICMPv4 type 8 only (`netsh` command above), and ping then got
  4/4 replies.
- **The x64 Windows ISO would not run.** The file was `...x64FRE...`, boot file `bootx64.efi`. My Mac is
  Apple Silicon (Debian from Lab 1 is arm64), so x64 could only be emulated, which is unusably slow. The
  Evaluation Center page lists an Arm64 ISO but has no download link for it (search for "arm" on the
  page: 0 results). I used the official Windows 11 Arm64 ISO from Microsoft instead, with no product key.
- **VM booted to "No Media" / "Time out".** The ISO was selected in Fusion but not *connected*
  (CD/DVD → "Connect CD/DVD"). After connecting, the "Press any key to boot from CD" prompt timed out
  twice. Pressing space repeatedly right after restart fixed it.
- **No network during Windows setup.** Windows on ARM has no driver for the VMware network adapter until
  VMware Tools is installed. I set `BypassNRO` (Shift+F10) to create a local account offline, then
  installed VMware Tools and got an IP by DHCP.

## Use of AI assistance

I used an AI assistant (Claude) during this lab. It guided me step by step and helped write this README
from my own results. All commands were run by me on my own VMs, and every number and IP address here comes
from my own screenshots and command output.

## Evidence

- [evidence/ipconfig-windows.txt](evidence/ipconfig-windows.txt) — Windows IP 192.168.246.130/24, gateway .2: Windows is on the shared NAT network
- [evidence/ip-addr-linux.txt](evidence/ip-addr-linux.txt) — Debian IP 192.168.246.129/24: Linux is on the same subnet as Windows
- [evidence/ping-both-ways.txt](evidence/ping-both-ways.txt) — Linux→Windows and Windows→Linux 0% loss, and Linux reaches the internet
- [evidence/host-memory-before.png](evidence/host-memory-before.png) — host memory with VMs off: pressure green, swap 2.86 GB
- [evidence/host-memory-after.png](evidence/host-memory-after.png) — host memory with 2 × 5 GB guests on an 8 GB host: pressure yellow, compressed 3.23 GB, swap 4.11 GB
