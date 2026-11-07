# Lab 4 — Partition, mirror, fail, recover

Pair: Togzhan Ilyas (solo)        Driver first half: Togzhan Ilyas
Machine: MacBook (Apple M2), VMware Fusion — guests Windows 11 ARM and Debian arm64 (lab01)
Date: 2026-11-07 / 2026-11-08

## What I did

### 1. Windows — partition, format, letter (PowerShell as Administrator)

```
Get-Disk
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter E
Format-Volume -DriveLetter E -FileSystem NTFS -NewFileSystemLabel LAB4
$env:firmware_type
UEFI
Get-Disk | Format-Table Number,FriendlyName,Size,PartitionStyle,OperationalStatus -AutoSize
Number FriendlyName                    Size PartitionStyle OperationalStatus
     0 VMware Virtual NVMe Disk 68719476736 GPT            Online
     1 VMware Virtual NVMe Disk  2147483648 GPT            Online
Get-Partition -DiskNumber 1 | Format-Table PartitionNumber,DriveLetter,Offset,Size,Type -AutoSize
PartitionNumber DriveLetter   Offset       Size Type
              1                17408   16759808 Reserved
              2           E 16777216 2130640896 Basic
```

### 2. Linux — record the layout, install tools

```
mkdir -p ~/lab04/evidence && cd ~/lab04/evidence
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT > lsblk-before.txt
sudo apt install --no-install-recommends mdadm
sudo apt install parted
```

### 3. Partition two disks and build the mirror

```
sudo parted /dev/nvme0n2 --script mklabel gpt mkpart lab4 1MiB 100% set 1 raid on
sudo parted /dev/nvme0n3 --script mklabel gpt mkpart lab4 1MiB 100% set 1 raid on
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/nvme0n2p1 /dev/nvme0n3p1
mdadm: array /dev/md0 started.
cat /proc/mdstat
md0 : active raid1 nvme0n3p1[1] nvme0n2p1[0]
      2093056 blocks super 1.2 [2/2] [UU]
date > array-healthy.txt; cat /proc/mdstat >> array-healthy.txt; sudo mdadm --detail /dev/md0 >> array-healthy.txt
```

### 4. Format, mount, write the proof

```
sudo mkfs.ext4 -L lab4 /dev/md0
sudo mkdir -p /mnt/mirror && sudo mount /dev/md0 /mnt/mirror && sudo chown $USER /mnt/mirror
echo "Lab 4 - Ilyas - $(date)" > /mnt/mirror/proof.txt
dd if=/dev/urandom of=/mnt/mirror/random.bin bs=1M count=200
209715200 bytes (210 MB, 200 MiB) copied
sync
sha256sum /mnt/mirror/proof.txt /mnt/mirror/random.bin > checksum-before.txt
a7b26047faad45dadca48f9f2bad2e7411b247320b06cabd0b748d6a75f21d18  /mnt/mirror/proof.txt
ebcbd430649f7486682f1f845b99fd0cbd6bec91daa651de301098ffe0e24867  /mnt/mirror/random.bin
```

### 5. Fail one half, prove the data survived (from disk, not cache)

```
sudo mdadm /dev/md0 --fail /dev/nvme0n3p1
md/raid1:md0: Disk failure on nvme0n3p1, disabling device.
date > array-degraded.txt; cat /proc/mdstat >> array-degraded.txt; sudo mdadm --detail /dev/md0 >> array-degraded.txt
md0 : active raid1 nvme0n3p1[1](F) nvme0n2p1[0]
      2093056 blocks super 1.2 [2/1] [U_]
State : clean, degraded
sudo mdadm /dev/md0 --remove /dev/nvme0n3p1
sudo umount /mnt/mirror && sudo mount /dev/md0 /mnt/mirror
sha256sum /mnt/mirror/proof.txt /mnt/mirror/random.bin > checksum-after-failure.txt
diff checksum-before.txt checksum-after-failure.txt && echo MATCH
MATCH
```

### 6. Rebuild onto the third disk

```
sudo sysctl -w dev.raid.speed_limit_max=10000
sudo parted /dev/nvme0n4 --script mklabel gpt mkpart lab4 1MiB 100% set 1 raid on
sudo mdadm /dev/md0 --add /dev/nvme0n4p1
watch -n 1 cat /proc/mdstat
[=>...................]  recovery =  9.6% (201728/2093056) finish=3.1min speed=10086K/sec
md0 : active raid1 nvme0n4p1[2] nvme0n2p1[0]
      2093056 blocks super 1.2 [2/2] [UU]
date > array-rebuilt.txt; cat /proc/mdstat >> array-rebuilt.txt; sudo mdadm --detail /dev/md0 >> array-rebuilt.txt
```

## Result

**MBR or GPT — and why**

- Disk 0 (system): **GPT**, firmware_type **UEFI**. Windows 11 on ARM (Apple M2) can only boot via UEFI, and UEFI boots from a GPT disk — so GPT was forced.
- New disk (Disk 1): **GPT**, my choice. 2 GB fits either table; GPT keeps a backup copy of the partition table with CRC checks and has no 4-primary-partition limit. The choice would matter for a disk over 2 TB, a disk you boot from in UEFI mode, or more than four partitions.
- Partition 1 on Disk 1 is the 16 MB Microsoft Reserved Partition that Windows creates on every GPT disk, so E: is partition 2.

**Linux layout — before**

```
NAME                  SIZE TYPE FSTYPE      MOUNTPOINT
sr0                  1024M rom
nvme0n1                20G disk
├─nvme0n1p1            16M part
├─nvme0n1p2           952M part vfat        /boot/efi
├─nvme0n1p3           952M part ext4        /boot
└─nvme0n1p4          18.1G part LVM2_member
  ├─lab01--vg-root   17.1G lvm  ext4        /
  └─lab01--vg-swap_1 1008M lvm  swap        [SWAP]
nvme0n2                 2G disk
nvme0n3                 2G disk
nvme0n4                 2G disk
```

**Linux layout — after the rebuild**

```
NAME                   SIZE TYPE  FSTYPE            MOUNTPOINT
nvme0n1                 20G disk  (system, unchanged)
nvme0n2                  2G disk
└─nvme0n2p1              2G part  linux_raid_member
  └─md0                  2G raid1 ext4              /mnt/mirror
nvme0n3                  2G disk
└─nvme0n3p1              2G part  linux_raid_member
nvme0n4                  2G disk
└─nvme0n4p1              2G part  linux_raid_member
  └─md0                  2G raid1 ext4              /mnt/mirror
```

`md0` now sits on `nvme0n2p1` and `nvme0n4p1`; `nvme0n3p1` is left with a partition that belongs to nothing.

| Role          | Device    |
|---------------|-----------|
| Mirror half A | nvme0n2p1 |
| Failed half   | nvme0n3p1 |
| Replacement   | nvme0n4p1 |

**The question:** your colleague deleted the wrong file from the mirror an hour ago. Does RAID 1 help? Why?

No, RAID 1 does not help. A mirror repeats every write on both disks at the same moment, so the deletion was applied to both halves instantly and the file is gone from both. RAID 1 only protects against a disk failing; to get the file back you need a backup or snapshot taken before the deletion.

## What did not work the first time

- **`lsblk: unknown column: NAME,`** — I typed `lsblk -o NAME, SIZE, TYPE, ...` with spaces after the commas. The shell split it into separate arguments, so `lsblk` got the column name `NAME,`. Fixed by writing the list with no spaces: `NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT`.
- **`mdadm: command not found`** — the Debian guest is minimal and has neither `mdadm` nor `parted`. Installed both with `apt` (`--no-install-recommends` for mdadm, so it did not pull in a mail server).
- **Wrong disk count in Windows** — I added one virtual disk too many to the Windows VM. Removed it in VMware Fusion settings before booting, so `Get-Disk` showed exactly one new RAW disk.
- **Typo in an evidence file name** — `date > array-health.txt` went to a different file than `array-healthy.txt`. Deleted both and saved the healthy state again while the array was still `[UU]`.

## Evidence

- [evidence/lsblk-before.txt](evidence/lsblk-before.txt) — the three new 2 GB disks, empty, before any change
- [evidence/array-healthy.txt](evidence/array-healthy.txt) — mirror built and synced: `[2/2] [UU]`, `State : clean`
- [evidence/checksum-before.txt](evidence/checksum-before.txt) — SHA-256 of `proof.txt` and `random.bin` on the healthy mirror
- [evidence/array-degraded.txt](evidence/array-degraded.txt) — saved right after the failure: `nvme0n3p1[1](F)`, `[2/1] [U_]`, `clean, degraded`
- [evidence/checksum-after-failure.txt](evidence/checksum-after-failure.txt) — SHA-256 after unmount/remount on one disk, identical to before (`diff` → `MATCH`)
- [evidence/array-rebuilt.txt](evidence/array-rebuilt.txt) — after recovery onto `nvme0n4p1`: `[2/2] [UU]` again
