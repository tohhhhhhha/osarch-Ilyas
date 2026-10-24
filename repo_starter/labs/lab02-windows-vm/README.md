# Lab 2 — A Windows guest, and a network between them

Pair: worked alone          Driver first half: me
Machine: MacBook Air M-chip, 8 GB RAM, VMware Fusion
Date: 25.10.2026

## What I did

1. Made a Windows 11 VM in VMware Fusion. My Mac is ARM (M-chip), so the x64 ISO from the share
didn't work. I downloaded the official Windows 11 ARM64 ISO from the Microsoft website and installed it
without a product key ("I don't have a product key"). Settings: UEFI + Secure Boot, TPM, 4 GB RAM,
2 cores, 64 GB disk. After install I put VMware Tools on it because there was no network driver.

2. Set both VMs (Debian from Lab 1 and Windows) to "Share with my Mac" (this is NAT in Fusion).

```
C:\> ipconfig
   IPv4 Address. . . . . . . . . . . : 192.168.246.130
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . : 192.168.246.2
```

```
student@lab01:~$ ip addr
    inet 192.168.246.129/24 brd 192.168.246.255 scope global dynamic enp2s0
```

I chose this mode because both VMs end up in the same network (192.168.246.x), so they can see
each other, and they also get internet through the Mac. Bridged is bad on the campus network because
of MAC filtering (the guest packets just get dropped). Host-only has no internet.

My network:

```
        Internet
           |
     [ Mac (NAT) ]  gateway 192.168.246.2
           |
   192.168.246.0/24
     |            |
 [Debian]     [Windows 11]
  .129           .130
```

3. Checked internet in both VMs.

```
C:\> ping -n 4 8.8.8.8
Packets: Sent = 4, Received = 3, Lost = 1 (25% loss)

student@lab01:~$ ping -c 4 8.8.8.8
4 packets transmitted, 4 received, 0% packet loss
```

4. Ping between the VMs. From Linux to Windows it didn't work at first (see below), so I added a
firewall rule in Windows (cmd as administrator). Firewall stayed on.

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

5. Memory experiment. First I took a screenshot of Activity Monitor with both VMs off. Then I set
both VMs to 5120 MB (so 10 GB total, but my Mac has 8 GB), started both, opened a lot of tabs in
Edge on Windows and ran this in Linux to use memory:

```
student@lab01:~$ head -c 4G /dev/zero | tail
```

Then took the second screenshot.

6. Put the memory back to normal: Windows 4096 MB, Debian 2048 MB.

## Result

Both VMs can ping each other and the internet.

Memory (Activity Monitor):

| | Before | After |
|---|---|---|
| Memory pressure | green | yellow |
| Memory used | 6.01 GB | 7.11 GB |
| Cached files | 1.85 GB | 0.85 GB |
| Compressed | 0.57 GB | 3.23 GB |
| Swap used | 2.86 GB | 4.11 GB |
| App memory | 3.27 GB | 1.42 GB |

Fusion let me set 5 GB for each VM. It only showed "3072 MB remaining for your Mac" for one VM
and didn't care that together it's more than 8 GB. Both VMs started fine. The Mac didn't crash,
but it started saving memory: cached files went down, compressed memory went up a lot
(0.57 -> 3.23 GB) and swap went up by about 1.25 GB. Memory pressure became yellow. Basically the
Mac took memory from its own apps and put stuff into compression and swap to fit the VMs.

## What did not work the first time

- Ping from Linux to Windows: 100% packet loss. It was the Windows firewall. Windows put the
  network as Public, and in Public it blocks incoming ping by default. I didn't turn the firewall
  off, I added a rule that only allows ICMP echo (the netsh command above). After that ping worked.
- The x64 ISO didn't fit my Mac. The file name had x64FRE and inside there was bootx64.efi, but my
  Mac is ARM. On the evaluation page it says there is an Arm64 ISO but I couldn't find the link
  (searched "arm" on the page, 0 results). So I used the Windows 11 ARM64 ISO from Microsoft.
- The VM showed "No Media" and then "Time out". The ISO was chosen but not connected. I clicked
  Connect CD/DVD and then had to press space many times right after restart to catch
  "Press any key to boot from CD".
- No internet during Windows setup, because there was no network driver yet. I used the BypassNRO
  command (Shift+F10) to make a local account, and after installing VMware Tools the network worked.

## AI use

I used an AI assistant (Claude) to help me with this lab. It explained the steps to me when I got
stuck and helped me write this README. I did all the steps myself on my VMs, and all the numbers
and IPs are from my own screenshots and outputs.

## Evidence

- [evidence/ipconfig-windows.txt](evidence/ipconfig-windows.txt) — Windows IP is 192.168.246.130, same network as Linux
- [evidence/ip-addr-linux.txt](evidence/ip-addr-linux.txt) — Linux IP is 192.168.246.129
- [evidence/ping-both-ways.txt](evidence/ping-both-ways.txt) — ping works Linux -> Windows, Windows -> Linux, and Linux -> internet
- [evidence/host-memory-before.png](evidence/host-memory-before.png) — Mac memory with VMs off
- [evidence/host-memory-after.png](evidence/host-memory-after.png) — Mac memory with two 5 GB VMs running, pressure yellow, more swap
