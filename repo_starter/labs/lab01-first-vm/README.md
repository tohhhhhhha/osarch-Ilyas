# Lab 1 — Your first virtual machine

Pair: none (worked alone)   
 Driver first half: me  
Machine: MacBook, Apple M2, 8 GB RAM, macOS, VMware Fusion  
Date: 17.10.2026

## What I did

Steps, with commands in code blocks.

Resource calculation (host: 8 threads, 8 GB RAM, 242.21 GB free on the VM volume; Activity Monitor idle: 5.38 GB used):

```
uname -m
arm64
```

Created the VM in VMware Fusion from `debian-testing-arm64-netinst.iso` (the instructor allowed Debian because on Apple Silicon the arm64 ISO link is Debian). Settings: 2 vCPU, 1536 MB RAM, 20 GB dynamically allocated disk, NAT. Installed with hostname `lab01`, LVM, only "SSH server" and "standard system utilities".

Resource justification: My host has 8 threads (8 cores, Apple M2), 8 GB of RAM and 242.21 GB free on the VM volume (Lab 0). Idle, the host already uses about 5.38 GB of RAM. I gave the guest 2 vCPU of my 8 threads because Debian Server needs only 1, and 2 stays below the limit of half my threads (4) and leaves 6 for macOS and the Windows guest next week. I gave it 1.5 GB (1536 MB) of my 8 GB RAM because about 2.62 GB is free after the host's 5.38 GB, and I keep about 1 GB for the Windows guest in Lab 2, so 1.5 GB is the most I can give without pushing the host into heavy swap. I gave it a 20 GB dynamically allocated disk of my 242.21 GB free because Debian Server needs about 5 GB minimum, 20 GB leaves room for updates, and it keeps more than 180 GB free for a Windows guest (60 GB+) next week.

Guest release, from the host over SSH:

```
ssh student@192.168.246.129 lsb_release -a > guest-release.txt
Distributor ID: Debian
Description:    Debian GNU/Linux forky/sid
Release:        n/a
Codename:       forky
```

Snapshot `clean-install` taken with the VM powered off. Then I broke it (option A):

```
cat /etc/hostname
lab01
sudo rm /etc/hostname
sudo reboot
cat /etc/hostname
cat: /etc/hostname: No such file or directory
hostnamectl
Static hostname: (unset)
```

Rolled back: Virtual Machine -> Snapshots -> clean-install -> Restore, powered on, then:

```
cat /etc/hostname
lab01
```

## Result

The VM boots and runs Debian arm64 with 2 vCPU, 1.5 GB RAM and a 20 GB disk. The hostname was deleted, confirmed broken (file missing, static hostname unset, prompt changed to localhost), and fully restored by reverting to the `clean-install` snapshot.

## What did not work the first time

- The VM was suspended and booted into the EFI boot manager and then tried PXE, because the ISO was not connected. I powered it off, connected the ISO in CD/DVD settings, and the installer started
- I took two snapshots by accident, renamed one to `clean-install` and deleted the other (both before breaking anything)
- The memory stayed at the default 2048 MB when I created the VM. I noticed it in the settings after the install and changed it to 1536 MB to match my calculation.
- `vm-settings.png` was taken after the install, not before the first power-on. In Fusion CPU/memory and disk are on separate pages, so the disk is in `vm-settings-disk.png`.

## Evidence

- [evidence/](evidence/)
  - `vm-settings.png` — 2 processor cores and 1536 MB memory
  - `vm-settings-disk.png` — 20 GB disk
  - `guest-release.txt` — output of `lsb_release -a` inside the guest
  - `broken.png` — `cat /etc/hostname` and `hostnamectl` showing the broken state
  - `snapshot-list.png` — snapshot list with `clean-install`, taken after the rollback