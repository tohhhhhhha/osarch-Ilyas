# Ticket 1 — VM build document

## 1. What was asked

> From: Aigerim T. (Office Manager)
> Subject: test machine for new dev
>
> Hi, we have someone starting on Monday and he needs a test computer
> set up. Nothing special, just so he can try things without breaking
> anything. Can you write down how to do it so I can do the next one
> myself? Thanks

## 2. What was actually needed

### What the request left out, what I would ask, and what I assumed

| Question I would ask Aigerim | What I assumed instead |
|---|---|
| On which computer will the test machine run? How much memory and disk does it have? Mac or PC? | My own MacBook Air M2 with 8 GB of memory. This decides a lot: the M2 is an ARM chip, so only ARM64 Linux and Windows run on it, and 8 GB is not enough for two systems with a desktop at the same time. |
| Which operating system does the developer need? | Both: one Linux (Debian) and one Windows 11, so he can test on both. |
| Does it need internet? Must the machines see each other? | Yes to both. He needs internet to install packages, and he may test a program on one machine against the other. So I used NAT ("Share with my Mac"). |
| Is there a Windows licence? | No. I installed Windows without a product key. It works for testing but is not activated. For a real employee the company must buy one. |
| "Test computer" — a real computer or a virtual one? | A virtual machine. It is free, and it can be reset with a snapshot. But it still needs a real host with enough memory. |
| Who will read the instructions? | Aigerim herself, who is not an IT person. |

### Where the request is wrong

- **"Nothing special"** is not true. "Try things without breaking anything"
  *is* the special part: it means the machine needs a **snapshot** to go back
  to after he breaks something. Without a snapshot a VM is just a second
  computer that can break too. So I took a `clean-install` snapshot of both
  machines and BUILD.md explains how to restore it (Steps 39–40).
- **"Write down how to do it so I can do the next one myself"** means the
  reader is not technical. So BUILD.md starts from installing the program,
  explains every choice in normal words, warns about every place where I
  got stuck, and has a "Check" after the important steps.
- **"The next one"** suggests this will be repeated. Rebuilding by hand takes
  about two hours. For the next developer a faster way would be to clone the
  clean machine (Fusion can make a full clone). I still wrote the full build,
  because that is what was asked and a clone needs the first machine to exist.
- The new developer **starts on Monday**, but nothing says he has his own
  computer that can run VMs. On an 8 GB machine both VMs work, but slowly.
  I would recommend a host with 16 GB.

## 3. What I did

The full steps are in [BUILD.md](BUILD.md). Here are the numbers, the
decisions, and what went wrong.

### Host

MacBook Air, Apple M2 (8 cores), 8 GB memory, 494 GB SSD
(see [evidence/00-host-specs.txt](evidence/00-host-specs.txt)).
Hypervisor: VMware Fusion Pro (free licence).

### Resource calculation

Memory is the limit on this Mac. Idle, macOS already uses about 5.4 GB
(measured in Lab 1). Both guests must run at the same time to test the
network between them.

| | Memory | CPU cores | Disk (maximum) | Disk really used |
|---|---|---|---|---|
| Windows 11 ARM64 | 4096 MB — the minimum for Windows 11 | 2 | 64 GB — the minimum for Windows 11 | 20.6 GB |
| Debian arm64, no desktop | 1536 MB | 2 | 20 GB | 2.4 GB |
| **Both guests** | **5632 MB of 8192 MB** | **4 of 8** | **84 GB** | **23 GB** |
| Left for macOS | about 2.5 GB | 4 | | |

Why not more memory: in Lab 2 I gave two VMs 5 GB each (10 GB on an 8 GB
Mac). Fusion allowed it, but memory pressure went yellow, compressed memory
went from 0.57 GB to 3.23 GB and swap grew by 1.25 GB. With 4 GB + 1.5 GB
both machines ran at the same time and the ping test worked.

Why 2 cores each: Debian without a desktop needs 1, Windows needs 2. Four
of eight leaves half of the CPU for macOS.

Disk: even if both disks grow to the full 84 GB, there is enough free space
(see 00-host-specs.txt). The real use after installing is 23 GB.

### Settings that differ from the default

| Setting | Default | Mine | Why |
|---|---|---|---|
| How the VM is created | "Install from disc or image" | "Create a custom virtual machine" | The default hung while reading the Debian file (see below) |
| Debian memory | 2048 MB (recommended) | 1536 MB | So both guests fit in 8 GB |
| Debian location / time zone | — | United States, then fixed to Asia/Almaty with `timedatectl` | My mistake in the installer; fixed after install |
| Debian root password | installer asks for one | empty | Then my user gets `sudo`: one password instead of two |
| Debian partitioning | Guided – use entire disk | Guided – use entire disk **and set up LVM** | LVM lets me make the disk bigger later without reinstalling |
| Debian software | Debian desktop + GNOME | no desktop; SSH server + standard system utilities | A desktop needs ~2 GB more memory. SSH lets me save command output as text from the Mac |
| Windows Secure Boot | off | on | Windows 11 requires UEFI with Secure Boot |
| Windows account | Microsoft account (needs internet) | local account `student`, via `OOBE\BYPASSNRO` | No network driver during setup, so an online account is impossible |
| Windows product key | asked | "I don't have a product key" | No licence for a test machine |
| Windows privacy settings | on | all off | A test machine does not need to send data to Microsoft |
| Windows firewall | blocks incoming ping | rule that allows only ICMP echo (ping) | So the guests can test the connection; the rest of the firewall stays on |

Settings I kept as default on purpose: network **Share with my Mac** (NAT),
**not** pre-allocated disks, TPM encryption of **only the TPM files**, Windows memory 4096 MB.

### Decisions and alternatives

- **VMware Fusion Pro, not UTM or Parallels.** All three run on Apple chips.
  Fusion is free and its snapshots are two clicks, which matters most for
  "try without breaking". UTM is free and open source, but snapshots are
  harder. Parallels is the easiest but costs money every year.
- **NAT ("Share with my Mac"), not Bridged or Host-only.** With NAT both VMs
  are in one private network (192.168.246.x), see each other and reach the
  internet through the Mac. Bridged does not work on the university network
  because of MAC filtering. Host-only ("Private to my Mac") has no internet.
  If the developer must reach the VM from another computer, Bridged would be
  needed, and then the filtering must be solved separately.
- **Debian without a desktop, not with one.** I lose the graphical
  interface in Linux, but both VMs run at the same time on 8 GB. On a 16 GB
  host I would add the desktop.
- **Debian netinst, not the full DVD image.** Small file and the newest
  packages, but it needs internet and the install takes longer.
- **Encrypt only the TPM files, not the whole VM.** Full encryption is slower
  and gives nothing to a test machine. The cost of any encryption: the
  password must be kept, or Fusion shows the VM as "Locked" and it cannot be opened.
- **Firewall rule, not firewall off.** Turning it off is faster but opens
  everything; the rule opens only ping.
- **Snapshots taken with the machine off, not running.** Smaller, and
  restoring gives a clean start.

### What went wrong

**1. Fusion hung when reading the Debian ISO.** In the normal way ("Install
from disc or image") Fusion started to analyse `debian-testing-arm64-netinst.iso`
and the spinner turned for more than 5 minutes; **Continue** stayed grey
([evidence/problem-iso-hang.png](evidence/problem-iso-hang.png)). I cancelled,
chose **Create a custom virtual machine**, picked "Debian 13.x 64-bit Arm"
myself and connected the ISO in the CD/DVD settings. This worked at once.
In BUILD.md the custom way is now the main way, and the hang is a warning in Step 3.

**2. The Windows ping output could not be copied to the Mac.** I wanted to
copy the Windows ping output with the shared clipboard and paste it into
`05-ping-between-guests.txt` with `pbpaste`. Twice the file got the wrong
text: the text of the command I had just copied on the Mac. I found out that
VMware Tools copied **from the Mac into Windows**, but **not back**. So I sent
the output from Windows to Debian over SSH, and read it from the Mac:

```
# in Windows PowerShell
$(ping -n 4 192.168.246.132; ping -n 4 8.8.8.8) | ssh ticket1@192.168.246.132 "cat > win-ping.txt"

# on the Mac
ssh ticket1@192.168.246.132 'cat win-ping.txt' | tr -d '\r' >> evidence/05-ping-between-guests.txt
```

`tr -d '\r'` removes the Windows line endings. I deleted the wrong lines
with `sed -i '' '$d'` first.

Smaller problems, all now written as warnings in BUILD.md:
- In the Debian partitioner the default answer to "Write the changes to
  disks?" is **No**. I pressed Enter and was sent back to the main menu, so I
  had to do the partitioning again (Step 15).
- I chose "United States" as location, so Debian got the US time zone. Fixed
  with `sudo timedatectl set-timezone Asia/Almaty` (Step 20).
- Windows has no network during setup, because the network driver comes
  only with VMware Tools. Solved with `OOBE\BYPASSNRO` and a local account
  (Step 32). I knew this from Lab 2.
- Windows blocks incoming ping. I knew this from Lab 2 (100% packet loss
  there), so I added the firewall rule before testing (Step 37).

### Peer review

*(Week 5: who reviewed, the first step where they got stuck, and what I changed. Link to the commit.)*

## 4. Evidence

| File | What it proves |
|---|---|
| [evidence/00-host-specs.txt](evidence/00-host-specs.txt) | The real host figures used in the resource calculation |
| [evidence/01-new-vm-wizard.png](evidence/01-new-vm-wizard.png) | The VM was created in VMware Fusion with the New VM wizard |
| [evidence/02-disk-settings.png](evidence/02-disk-settings.png) | Debian disk is 20 GB and not pre-allocated (grows when used) |
| [evidence/03-network-adapter.png](evidence/03-network-adapter.png) | The network is "Share with my Mac" (NAT) |
| [evidence/04-guest-uname.txt](evidence/04-guest-uname.txt) | Debian (forky) is installed and runs on ARM (`aarch64`); taken over SSH from the Mac |
| [evidence/05-ping-between-guests.txt](evidence/05-ping-between-guests.txt) | Debian (.132) and Windows (.133) reach each other and the internet (8.8.8.8), 0% loss in all four tests |
| [evidence/06-snapshot-list.png](evidence/06-snapshot-list.png) | Debian has the `clean-install` snapshot |
| [evidence/win-21.png](evidence/win-21.png) | Windows has the `clean-install` snapshot |
| [evidence/06-snapshot-list.txt](evidence/06-snapshot-list.txt) | Both snapshots, as text from `vmrun listSnapshots` |
| [evidence/problem-iso-hang.png](evidence/problem-iso-hang.png) | The problem from section 3: Fusion stuck reading the Debian ISO |
| [evidence/build-15-first-login-check.png](evidence/build-15-first-login-check.png) | Debian user has `sudo`, hostname is `ticket1`, memory is 1.4 GiB (1536 MB) |
| [evidence/win-19.png](evidence/win-19.png) | Windows got 192.168.246.133 after VMware Tools |
| [evidence/win-20.png](evidence/win-20.png) | The firewall rule for ping was added (`Ok.`) |

The other `build-*.png` and `win-*.png` files are the screenshots used in BUILD.md.

## 5. What I would do differently

I would take a screenshot of **every** installer screen during the first
build, including the user and password screens. I skipped the Debian
root-password and user screens, so in BUILD.md those steps (Step 14) have no
picture and I had to prove the result with `whoami` / `sudo whoami` instead.
I would also choose Kazakhstan as the location in the Debian installer, so
the time zone is right from the start.
