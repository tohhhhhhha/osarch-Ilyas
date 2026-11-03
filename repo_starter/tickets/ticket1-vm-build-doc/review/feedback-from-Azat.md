# Feedback on Togzhan's BUILD.md

Reviewer: Zhansaya Azat
Commit reviewed: https://github.com/tohhhhhhha/osarch-Ilyas/blob/adade2ea3cd19d2b16f5ac19c44876a674619865/repo_starter/tickets/ticket1-vm-build-doc/BUILD.md
Hypervisor I used: VMware Fusion Pro 26.0.1, on Togzhan's MacBook Air (Apple M2, 8 GB)

Background: I had never used a Mac before this review. I worked on the author's Mac, where VMware Fusion and the ISO files were already there, so I did not test Steps 1–2 (installing Fusion, downloading the ISOs). From Step 3 on I followed BUILD.md myself, and both machines worked at the end.

## First step where I got stuck

Step number: 12
What the step says: "Location: choose **other → Asia → Kazakhstan**." The "Why" says that the location sets the time zone.
What I did: I chose other → Asia → Kazakhstan, as written.
What happened / what I had to guess: I had never set a country and a time zone during an installation before, so this part was new for me and I was not sure I was doing it right. The step tells me which country to pick, but not which screens come after it or what I should see there. I only knew that the time was correct later, in Step 20, when `date` showed the same time as the Mac.

## Other places I hesitated

- The whole installation: I was often afraid to press the wrong button, because I did not know which mistakes can be undone and which cannot. The warnings in Step 15 (the default answer is **No**) and Step 31 (do not press a key the second time) helped a lot. One sentence at the start, like "until Step 39 you can always delete the VM and start again", would have made me calmer.

## Settings I would not have chosen without the document

- "Create a custom virtual machine" instead of the default "Install from disc or image" (Step 3).
- 1536 MB for Debian instead of the recommended 2048 MB, so that both VMs fit in 8 GB (Step 7).
- "Share with my Mac" (NAT) as the network (Step 9).
- An empty root password, so that my user gets `sudo` (Step 14).
- "Guided – use entire disk and set up LVM" (Step 15).
- No desktop in Debian, only SSH server + standard system utilities (Step 17).
- Ticking UEFI Secure Boot and encrypting only the TPM files (Steps 22–23).
- "I don't have a product key" and Windows 11 Pro (Steps 29–30).
- `OOBE\BYPASSNRO` and a local account (Step 32). I would not have known any way past the network screen.
- A firewall rule for ping only, instead of turning the firewall off (Step 37).
- Taking the snapshot with the machine shut down (Step 39).

## One thing that worked well

- The **Check** after the important steps, with the exact result to expect. As a first-time Mac user I always knew whether I could go on or had to stop. Thanks to the guide, everything worked.
