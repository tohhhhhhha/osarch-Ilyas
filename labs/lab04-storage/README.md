# Lab 4 — Storage

Host: MacBook (Apple M2), VMware Fusion. Guests: Windows 11 ARM and Debian (arm64). All virtual disks are on the NVMe controller, so Linux names them `nvme0nX`.

## Windows

Disk 0: partition style **GPT**, firmware_type **UEFI** — because this guest is Windows 11 on ARM (Apple M2, VMware Fusion), which can only boot via UEFI, and UEFI boots from a GPT disk.

New disk (Disk 1): partition style **GPT** — 2 GB fits either table, so I chose GPT: it stores a backup copy of the partition table with CRC checks and has no 4-primary-partition limit. The choice would matter for a disk over 2 TB (MBR cannot address it), a disk you boot from in UEFI mode, or more than four partitions.

Note: partition 1 is the 16 MB Microsoft Reserved Partition (MSR) that Windows creates automatically on GPT disks, so my E: volume is partition 2.

```
Number FriendlyName                    Size PartitionStyle OperationalStatus
------ ------------                    ---- -------------- -----------------
     0 VMware Virtual NVMe Disk 68719476736 GPT            Online
     1 VMware Virtual NVMe Disk  2147483648 GPT            Online

PartitionNumber DriveLetter   Offset       Size Type
--------------- -----------   ------       ---- ----
              1                17408   16759808 Reserved
              2           E 16777216 2130640896 Basic

$env:firmware_type: UEFI
```

## Linux layout — before

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

## Linux layout — after the rebuild

```
NAME                   SIZE TYPE  FSTYPE            MOUNTPOINT
sr0                   1024M rom
nvme0n1                 20G disk
├─nvme0n1p1             16M part
├─nvme0n1p2            952M part  vfat              /boot/efi
├─nvme0n1p3            952M part  ext4              /boot
└─nvme0n1p4           18.1G part  LVM2_member
  ├─lab01--vg-root    17.1G lvm   ext4              /
  └─lab01--vg-swap_1  1008M lvm   swap              [SWAP]
nvme0n2                  2G disk
└─nvme0n2p1              2G part  linux_raid_member
  └─md0                  2G raid1 ext4              /mnt/mirror
nvme0n3                  2G disk
└─nvme0n3p1              2G part  linux_raid_member
nvme0n4                  2G disk
└─nvme0n4p1              2G part  linux_raid_member
  └─md0                  2G raid1 ext4              /mnt/mirror
```

`md0` now sits on `nvme0n2p1` and `nvme0n4p1`; `nvme0n3p1` is left with a partition that belongs to no array.

| Role          | Device    |
|---------------|-----------|
| Mirror half A | nvme0n2p1 |
| Failed half   | nvme0n3p1 |
| Replacement   | nvme0n4p1 |

## Evidence

| File | State |
|------|-------|
| `evidence/lsblk-before.txt` | disks before any change |
| `evidence/array-healthy.txt` | `[2/2] [UU]`, `State : clean` |
| `evidence/checksum-before.txt` | SHA-256 of `proof.txt` and `random.bin` on the healthy mirror |
| `evidence/array-degraded.txt` | `nvme0n3p1[1](F)`, `[2/1] [U_]`, `State : clean, degraded` |
| `evidence/checksum-after-failure.txt` | SHA-256 after unmount/remount on one disk — identical (`diff` → `MATCH`) |
| `evidence/array-rebuilt.txt` | after recovery onto `nvme0n4p1`: `[2/2] [UU]` |

## The question

Your colleague deleted the wrong file from the mirror an hour ago. Does RAID 1 help? Why?

No, RAID 1 does not help. A mirror repeats every write on both disks at the same moment, so the deletion was applied to both halves instantly and the file is gone from both. RAID 1 only protects against a disk failing; to get the file back you need a backup or snapshot taken before the deletion.
