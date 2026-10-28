# Build document: a Linux and a Windows test machine on a Mac

This document shows how to build two virtual machines (VMs) from nothing:
one with Debian Linux and one with Windows 11. Both run on a Mac, can reach
the internet, can see each other, and have a snapshot to go back to if
something breaks.

You do not need to know anything about virtual machines. Do the steps in
order. After some steps there is a **Check**: if what you see is different,
stop and fix it before you go on.

## Before you start

You need:

- A Mac with an Apple chip (M1, M2, M3 or M4). To check: Apple menu → **About This Mac** → the "Chip" line.
- At least 8 GB of memory (16 GB is more comfortable) and about 100 GB of free disk space.
- Internet, and about 2 hours.

Why an Apple chip matters: these chips are ARM processors. Only the **ARM64**
versions of Linux and Windows run on them. The normal Windows download (x64)
does not start on this Mac at all, so always pick the files with
**arm64** in the name.

### How to use the keyboard and mouse in a VM

- When you click inside a VM window, the mouse "goes into" the VM. To get it back to the Mac, press **Control + Command**.
- In the Debian installer the mouse does not work. Use the **arrow keys** to move, **Space** to tick a box, **Tab** to jump to the buttons, and **Enter** to press a button.

---

## Part 1. Prepare

### Step 1. Install VMware Fusion Pro

Go to the Broadcom website, make a free account, download **VMware Fusion Pro**
and install it like any other Mac app. When it starts for the first time,
choose the free personal-use licence.

Why Fusion and not another program: Fusion is free and runs on Apple chips,
and it can take and restore snapshots with two clicks, which is the main thing
we need. UTM is also free, but its snapshots are harder to use. Parallels is
the easiest but costs money every year.

### Step 2. Download the two installation files (ISO)

- Debian: `debian-testing-arm64-netinst.iso` from the Debian website (about 1 GB).
- Windows 11: go to https://www.microsoft.com/software-download/windows11arm64,
  choose **Windows 11 (multi-edition ISO for Arm64)**, then **English (United States)**,
  then **Download** (about 8 GB). Use Chrome; the Microsoft site sometimes does not work in Safari.

Why "netinst" for Debian: the file is small and the installer downloads the
newest packages during the install. The downside is that you need internet
during the install and it takes longer. A full DVD image works without
internet but is several GB.

> Check: in Finder you have two files and both names contain **arm64**.

---

## Part 2. The Linux machine (Debian)

### Step 3. Start a new virtual machine

Open Fusion, click **+** (top left) → **New…**. You see this screen:

![](evidence/01-new-vm-wizard.png)

Choose **Create a custom virtual machine** (bottom left) and click **Continue**.

Why not "Install from disc or image": I tried that first. Fusion started to
read the Debian file and the spinner turned for more than 5 minutes, the
**Continue** button stayed grey and nothing happened:

![](evidence/problem-iso-hang.png)

With "custom" Fusion does not try to read the file. You choose the system
yourself and connect the file later (Step 10).

### Step 4. Choose the operating system

On the left choose **Linux**, on the right **Debian 13.x 64-bit Arm**, then **Continue**.

![](evidence/build-02-choose-os.png)

Why: the file is Debian, and "Arm" because the Mac has an ARM chip. Fusion
uses this choice to pick the right default settings.

On the next screen (**Choose Firmware**) leave **UEFI** and click **Continue**.

### Step 5. Create the virtual disk

Leave **Create a new virtual disk** (20 GB) and click **Continue**.

![](evidence/build-03-new-disk.png)

Why 20 GB: Debian without a desktop uses about 5 GB; the rest is room for
updates and programs. The disk grows only when it is used, so it does not
take 20 GB from the Mac at once.

### Step 6. Save the machine

Click **Finish**. In the window that opens, type the name **ticket1-debian**,
do not tick "Share this virtual machine", click **Save**.

![](evidence/build-04-save-name.png)

Why: a short name without spaces is easy to find later and easy to type in Terminal.

**Do not start the machine yet.** If it starts by itself, use the menu
**Virtual Machine → Shut Down**.

### Step 7. Memory and processors

Click the **wrench** icon at the top of the VM window (or menu **Virtual
Machine → Settings…**). You see all settings:

![](evidence/build-05-settings.png)

Click **Processors & Memory**. Choose **2 processor cores**, type **1536** in the
memory box and press **Enter**.

![](evidence/build-06-cpu-memory.png)

Why 1536 MB and not the recommended 2048 MB: my Mac has only 8 GB, and Linux
and Windows must run at the same time. Windows needs at least 4096 MB, so
Linux gets 1536 MB and about 2.5 GB stays for macOS. If your Mac has 16 GB,
you can leave 2048 MB.

> Check: under the slider it says **6656 MB remaining for your Mac** (on an 8 GB Mac).
> If it still says 6144, you did not press Enter.

### Step 8. Disk settings

Click **Show All** → **Hard Disk (NVMe)** → open **Advanced options**.
Leave **Pre-allocate disk space** unticked.

![](evidence/02-disk-settings.png)

Why: without pre-allocation the disk file grows as it fills. This saves space
on the Mac. The price is that it is a little slower, which does not matter for
a test machine.

### Step 9. Network

Click **Show All** → **Network Adapter**. Choose **Share with my Mac**.

![](evidence/03-network-adapter.png)

Why "Share with my Mac" (this is NAT): both VMs get addresses in the same
private network (192.168.x.x), so they can see each other, and they go to the
internet through the Mac. "Autodetect / Wi-Fi" (bridged) does not work on the
university network, because it filters unknown devices by MAC address.
"Private to my Mac" (host-only) has no internet at all.

### Step 10. Connect the Debian file

Click **Show All** → **CD/DVD (SATA)**. Tick **Connect CD/DVD Drive**, open the
list → **Choose a disc or disc image…** → Downloads → the Debian file → **Open**.

![](evidence/build-07-cd-dvd.png)

Why: in "custom" mode Fusion does not connect the file by itself. Without
this the machine has nothing to start from and shows "No Media" and tries
to start from the network.

Close the settings window (red button). The settings are saved automatically.

### Step 11. Start the installer

Click the big **▶** button. After a few seconds of black screen you see this menu:

![](evidence/build-08-grub-install.png)

Leave **Install** selected and press **Enter**.

Why "Install" and not "Graphical install": the result is the same, and the
text installer is lighter and works only with the keyboard, so the mouse
cannot get stuck in the window.

### Step 12. Language, location, keyboard

Language **English** → Enter.

![](evidence/build-09-language.png)

Location: choose **other → Asia → Kazakhstan**. Keyboard: **American English**.

Why Kazakhstan: the location sets the time zone. I chose United States here,
so the clock was wrong and I had to fix it later (Step 20).

### Step 13. Machine name

Type the hostname **ticket1** → Continue. Leave **Domain name** empty → Continue.

![](evidence/build-10-hostname.png)

Why: the hostname is how the machine is called in the network and in the
prompt (`ticket1@ticket1`). The domain is only needed in a company network.

### Step 14. Users and passwords

- **Root password**: leave it **empty**, press Enter twice.
- **Full name**: anything. **Username**: I used **ticket1**.
- **Password** for this user: make one up, **write it down**, type it twice.

Why an empty root password: then Debian gives your own user the right to use
`sudo` (run commands as administrator). You have one password to remember
instead of two. Step 19 checks that this worked.

### Step 15. Disk partitioning

Choose **Guided – use entire disk and set up LVM** → Enter.

![](evidence/build-11-partition-lvm.png)

Then: choose the only disk → Enter. **All files in one partition** → Enter.
For the size question, leave the number as it is → Enter.

**Careful:** when the installer asks **"Write the changes to disks…?"**, the
selected answer is **No**. Press the **left arrow** so that **Yes** is red, then
Enter. If you press Enter on "No", you go back to the main menu and have to
start partitioning again (this happened to me).

When you see this overview, choose **Finish partitioning and write changes to
disk** → Enter → again **Yes** → Enter.

![](evidence/build-12-partition-result.png)

Why LVM: with LVM the disk can be made bigger later without reinstalling.
I did not choose "encrypted LVM", because then you must type a password every
time the machine starts, which is not needed for a test machine.

> Check: in the overview you see `/` (about 18 GB), `swap` (about 1 GB), `ESP` and `/boot`.

### Step 16. Packages

- "Scan extra installation media?" → **No**.
- Mirror country → **United States** (or the one offered) → **deb.debian.org**.
- HTTP proxy → leave empty.
- "Participate in the package usage survey?" → **No**.

Why deb.debian.org: it is not one server but a network of servers that sends
files from the one closest to you. Then wait: downloading takes 5–15 minutes
and depends on your internet.

### Step 17. Software selection

Move with the arrows and use **Space** to make it look like this:
**no** star at "Debian desktop environment" and "GNOME", a star `[*]` at
**SSH server** and **standard system utilities**. Then **Tab** → **Continue** → Enter.

![](evidence/build-13-software-selection.png)

Why no desktop: a desktop needs about 2 GB more memory, and with Windows
running at the same time it does not fit in 8 GB. Why SSH: it lets you run
commands in the VM from the Mac Terminal and save the output as a text file.

If it asks to install the GRUB boot loader, answer **Yes** and choose the disk.

### Step 18. Finish the install

When you see **Installation complete**, press Enter on **Continue**. The machine restarts.

![](evidence/build-14-install-complete.png)

If after the restart you see the blue installer menu from Step 11 again, the
Debian file is still connected: shut the VM down, untick **Connect CD/DVD
Drive** (Step 10) and start it again.

### Step 19. Log in and check

At `ticket1 login:` type your username, Enter, then your password, Enter
(the password is not shown while you type). Then type these commands, one
per line:

```
whoami
sudo whoami
hostname
free -h
ip addr
```

![](evidence/build-15-first-login-check.png)

> Check:
> - `whoami` shows your user, `sudo whoami` shows **root** (your user is an administrator);
> - `hostname` shows **ticket1**;
> - `free -h` shows about **1.4Gi** total memory (this is 1536 MB);
> - `ip addr` shows an address like **192.168.246.x** (mine was 192.168.246.132). Write it down.

### Step 20. Set the time zone

```
sudo timedatectl set-timezone Asia/Almaty
date
```

> Check: `date` shows the same time as the clock on the Mac.

---

## Part 3. The Windows machine

### Step 21. Start a new virtual machine

Fusion → **+** → **New…** → **Create a custom virtual machine** → **Continue**
(the same as Step 3). On the left choose **Microsoft Windows**, on the right
**Windows 11 64-bit Arm** → **Continue**.

### Step 22. Firmware

Leave **UEFI** and **tick UEFI Secure Boot** → **Continue**.

![](evidence/win-01.png)

Why: Windows 11 requires UEFI with Secure Boot. Without it the installer can
refuse to install. "Legacy BIOS" is grey because ARM computers do not have it.

### Step 23. Encryption password

Leave **Only the files needed to support a virtual TPM will be encrypted**.
Type a password of at least 8 characters twice. Leave **Remember password in
the macOS Keychain** ticked → **Continue**.

![](evidence/win-02.png)

**Write this password down.** Without it the machine cannot be opened and
Fusion shows it as "Locked".

Why: Windows 11 requires a security chip called TPM 2.0. Fusion gives the VM
a virtual TPM, but it must be stored encrypted, so a password is required.
We encrypt only the TPM files, not the whole disk, because full encryption
makes the machine slower and is not needed for a test machine.

### Step 24. Virtual disk

Leave **Create a new virtual disk**, 64 GB → **Continue**. Then **Finish**, save
the machine as **ticket1-windows** (like Step 6). Do not start it yet.

![](evidence/win-03.png)

Why 64 GB: this is the minimum for Windows 11. The disk grows only when it is used.

### Step 25. Memory and processors

Settings (wrench) → **Processors & Memory**: **2 processor cores**, **4096** MB → Enter.

![](evidence/win-04.png)

Why: 4096 MB is the minimum for Windows 11, and together with Debian
(1536 MB) it still leaves about 2.5 GB for macOS.

> Check: it says **4096 MB remaining for your Mac**.

### Step 26. Network

**Show All** → **Network Adapter** → **Share with my Mac**.

![](evidence/win-05.png)

Why: the same network as Debian, so the two machines can see each other (see Step 9).

### Step 27. Connect the Windows file

**Show All** → **CD/DVD (SATA)** → tick **Connect CD/DVD Drive** → **Choose a
disc or disc image…** → choose the Windows file (`Windows11_Client_arm64…iso`) → **Open**.

![](evidence/win-06.png)

Close the settings window.

### Step 28. Start and choose the language

Click **▶**. **Be ready:** the text **"Press any key to boot from CD or DVD…"**
is shown for only about 5 seconds. Click inside the window and press **Space**
a few times. If you miss it, use **Virtual Machine → Shut Down** and start again.

Language **English (United States)**, time and currency format **Kazakh
(Kazakhstan)** → **Next**. Keyboard **US** → **Next**. Then **Install Windows 11**,
tick "I agree…" → **Next**.

![](evidence/win-07.png)

Why: an English interface matches the commands in this document; the format
"Kazakhstan" gives the local date and number format.

### Step 29. Product key

Click **I don't have a product key** (bottom left).

![](evidence/win-08.png)

Why: this test machine has no licence. Windows works without one but is not
activated (a message on the screen, some personal settings are locked).
For a real employee the company must buy a licence.

### Step 30. Edition

Choose **Windows 11 Pro** → **Next**. Then **Accept** the licence.

![](evidence/win-09.png)

Why Pro and not Home: Pro has tools a developer may need (for example Remote
Desktop and Hyper-V). Without a licence, both editions work the same way.

### Step 31. Where to install

Choose **Disk 0 Unallocated Space** (64 GB) → **Next**.

![](evidence/win-10.png)

Windows installs for 15–20 minutes and restarts by itself.

**Careful:** after the restart "Press any key to boot from CD or DVD…" appears
again. This time **do not press anything**, or the installation starts from the beginning.

### Step 32. No network: skip the internet

Choose the country and keyboard (**Yes**, then **Skip** for a second keyboard).
Then this screen appears, and **Next** is grey:

![](evidence/win-11.png)

This is normal: Windows does not yet have a driver for Fusion's network card
(it comes with VMware Tools in Step 35). To go on without internet:

1. Press **Shift + F10** (on a Mac keyboard: **fn + Shift + F10**). A black command window opens.
2. Type `OOBE\BYPASSNRO` (the slash is the backslash `\`) and press Enter.

![](evidence/win-12.png)

The machine restarts and comes back to the same screen, now with the link
**I don't have internet**. Click it, then **Continue with limited setup**.

![](evidence/win-13.png)

Why: without internet Windows 11 does not let you make a Microsoft account
and does not let you continue. This command allows a local account instead.
A local account is also simpler for a test machine.

### Step 33. User and privacy

Name: **student** → **Next**. Make up a password, **write it down**, type it
twice, answer the three security questions. On the privacy screens turn
everything **Off** → **Accept**.

![](evidence/win-14.png)

Why privacy Off: a test machine does not need to send data to Microsoft.

### Step 34. The desktop

After a few minutes you see the Windows desktop.

![](evidence/win-16.png)

> Check: next to the clock there is a globe icon with no connection. This is
> expected until the next step.

### Step 35. Install VMware Tools

Mac menu at the top: **Virtual Machine → Install VMware Tools** (if Fusion asks
to disconnect the Windows disc, agree). In Windows open **File Explorer**
(yellow folder) → **This PC** → **DVD Drive (D:) VMware Tools** → double-click **setup**.

![](evidence/win-17.png)

Answer **Yes** to "Do you want to allow…", then **Next → Typical → Install → Finish**, and restart when asked.

![](evidence/win-18.png)

Why: VMware Tools are drivers for Windows inside Fusion. The most important
one is the network driver. They also fix the screen size and allow copying
from the Mac into Windows.

### Step 36. Check the network

Right-click the **Start** button → **Terminal (Admin)** → **Yes**. Type:

```
ipconfig
```

![](evidence/win-19.png)

> Check: **IPv4 Address** is like **192.168.246.x** (mine was 192.168.246.133),
> the same network as Debian. Write it down.

### Step 37. Allow ping in the Windows firewall

In the same window type:

```
netsh advfirewall firewall add rule name="Allow ICMPv4 Echo In" protocol=icmpv4:8,any dir=in action=allow
```

![](evidence/win-20.png)

> Check: the answer is `Ok.`

Why: by default Windows blocks ping coming from other computers, so Debian
cannot "see" Windows. This rule opens only ping. Turning the whole firewall
off would also work, but it opens everything.

---

## Part 4. Check that the two machines see each other

### Step 38. Ping in both directions

Both VMs must be running. In **Debian** (use your Windows address):

```
ping -c 4 192.168.246.133
ping -c 4 8.8.8.8
```

In **Windows** (use your Debian address):

```
ping -n 4 192.168.246.132
ping -n 4 8.8.8.8
```

> Check: every ping says **4 received, 0% packet loss** (Debian) or
> **Received = 4, Lost = 0** (Windows). My result is in
> [evidence/05-ping-between-guests.txt](evidence/05-ping-between-guests.txt).

---

## Part 5. Snapshots: how to "try things without breaking anything"

### Step 39. Take a clean snapshot of each machine

Shut both machines down (Debian: `sudo poweroff`; Windows: Start → Power → Shut down).
Then for each machine: menu **Virtual Machine → Snapshots…** → camera icon
(**Take Snapshot**) → name **clean-install**.

![](evidence/06-snapshot-list.png)

![](evidence/win-21.png)

Why take it with the machine off: the snapshot is smaller and restores to a
clean start, without a "frozen" memory state.

### Step 40. When something breaks: go back

Shut the machine down → **Virtual Machine → Snapshots…** → click
**clean-install** → **Restore** (the circular-arrow icon) → start the machine.
Everything is exactly as it was right after the install.

This is the whole point of the test machine: the developer can install,
delete and change anything, and in one minute go back to a clean system.
