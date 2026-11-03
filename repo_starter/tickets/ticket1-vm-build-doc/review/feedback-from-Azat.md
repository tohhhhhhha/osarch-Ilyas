# Feedback on Togzhan's BUILD.md

Reviewer: Zhansaya <!-- add surname -->
Commit reviewed: https://github.com/tohhhhhhha/osarch-Ilyas/blob/adade2ea3cd19d2b16f5ac19c44876a674619865/repo_starter/tickets/ticket1-vm-build-doc/BUILD.md
Hypervisor I used: VMware Fusion Pro, version ... <!-- Fusion → About VMware Fusion. Also write: Mac model, Apple chip, memory (8 or 16 GB), and whether it was your own Mac or Ilyas's -->

Background: I had never used a Mac before this review. I followed BUILD.md from Step 1 to Step 40 without the author's help.

## First step where I got stuck

<!--
Fill in from what really happened. The doc says "Looks good" is not a review,
and a step you solved from your own knowledge still counts as stuck.
The most likely candidate is below. If it is not true for you, replace it with your real first stop.
If Fusion and the ISOs were already on the Mac, write that, because Steps 1–2 were then not tested.
-->

Step number: 2
What the step says: "Debian: `debian-testing-arm64-netinst.iso` from the Debian website (about 1 GB)." There is no link (Windows has one).
What I did: ...
What happened / what I had to guess: ... <!-- e.g. where on debian.org you found it; whether the front page offered a different file (debian-13.x.x-arm64-netinst.iso) and which one you took -->

## Other places I hesitated

<!-- Keep only the points that are true for you, and add your own. -->

- Step 1: "make a free account, download VMware Fusion Pro". On Broadcom I also had to fill in a profile and a compliance form and find the free-downloads filter; none of this is in the step. It also says "personal-use licence", but this machine is for a company employee.
- Step 7: the screenshot shows 1536 MB but "6144 MB remaining for your Mac". The Check says that number means I did not press Enter, so the picture shows the wrong state. I was not sure if my screen or the picture was right.
- Step 12: after choosing English + other → Asia → Kazakhstan, the installer asked ... <!-- locale (no English locale for Kazakhstan) and/or time zone list? If yes: which screens, what you chose -->. The document does not mention these screens.
- Step 19 / Step 36: the Check says "an address like 192.168.246.x". Mine was 192.168.___.x. <!-- if different --> The step does not say which part has to match. `ip addr` also prints several addresses, and I had to guess which line is the right one.
- Step 32: `OOBE\BYPASSNRO` ... <!-- worked / "not recognized"? Which Windows build (shown in the cmd window title line)? --> The screenshot `win-12.png` already shows "I don't have internet" before the command is run, but `win-11.png` does not. So I could not tell whether the link should appear before or after the restart.
- Step 38: the commands contain the author's addresses (.133, .132). I had to replace them with mine; placeholders would be clearer.
- Step 40: nothing says that restoring the snapshot deletes everything done after it, including the developer's own files. I only understood this after trying it.

## Settings I would not have chosen without the document

- "Create a custom virtual machine" instead of the default "Install from disc or image" (Step 3).
- Only ARM64 ISOs. I would have downloaded the normal x64 Windows ISO (Before you start, Step 2).
- 1536 MB for Debian instead of the recommended 2048 MB, so that both VMs fit in 8 GB (Step 7).
- "Share with my Mac" (NAT) as the network (Step 9).
- Empty root password, so that my user gets `sudo` (Step 14).
- "Guided – use entire disk and set up LVM" (Step 15).
- No desktop in Debian, only SSH server + standard system utilities (Step 17).
- Ticking UEFI Secure Boot and encrypting only the TPM files (Steps 22–23).
- "I don't have a product key" and Windows 11 Pro (Steps 29–30).
- `OOBE\BYPASSNRO` and a local account (Step 32). I would not have known any way past the network screen.
- A firewall rule for ping only, instead of turning the firewall off (Step 37).
- Taking the snapshot with the machine shut down (Step 39).

## One thing that worked well

- The **Check** after the important steps, with the exact output to expect (for example `sudo whoami` → `root`, and `4 received, 0% packet loss` in Step 38). As a first-time Mac user I always knew whether I could go on or had to stop. The warnings were also useful, especially the default "No" in Step 15 and not pressing a key at the second "Press any key to boot from CD" in Step 31.
