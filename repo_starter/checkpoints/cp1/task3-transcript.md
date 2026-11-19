# Task 3

Ticket: `/var/log/nightly-report.log` has not been written since the script was updated last week; the scheduler says the job runs every two minutes

## Transcript

| # | Evidence file (command) | What I expected | What I found | What I concluded |
|---|-------------------------|-----------------|--------------|------------------|
| 1 | 05 (`systemctl --failed`) | nightly-report failing | Two units failed: `legacy-sync.service` and `nightly-report.service` | Two leads. Check which one is related to the ticket |
| 2 | 10 (`systemctl status legacy-sync.service`) | A reason it is failing | Description says "old office, no longer used"; `ExecStart=/bin/false`, exit status 1; failed since Nov 09 09:51:22, 6 days ago | Dead end. It fails by design (`/bin/false`) and has nothing to do with the report. Not touching it. |
| 3 | 11 (`journalctl -u legacy-sync.service`) | Whether it started failing only recently | Same failure on Sep 14, Oct 02, Oct 19, Nov 09: once per boot, always status=1 | Dead end confirmed. Long-standing, unrelated to "last week's script update". |
| 4 | 06 (`systemctl list-timers`) | The timer exists and fires | `nightly-report.timer` is active, last fired 09:42:01, next 09:44:01, activates `nightly-report.service` | The scheduler works as the accountant said. The fault is in what the timer starts, not in the timer. |
| 5 | 08 (`systemctl cat nightly-report.service nightly-report.timer`) | Unit points at the right script | `Type=oneshot`, `ExecStart=/usr/local/bin/nightly-report.sh`; timer is `OnBootSec=1min`, `OnUnitActiveSec=2min` | Unit files are fine and the path is correct. Interval matches the ticket. |
| 6 | 07 (`systemctl status nightly-report.service`) | An exit code that says why | `status=203/EXEC`, "Failed to execute ... No such file or directory" | 203/EXEC means systemd could not start the program. The script was never run, so nothing could be written to the log. The error wording is suspicious: see next rows. |
| 7 | 13 (`ls -l /usr/local/bin`) | The file is missing (the error says "No such file") | `-rwxr-xr-x root root 91 Nov 9 14:20 nightly-report.sh` | The file exists, is executable and is owned by root. "No such file" is misleading. Modified Nov 9 14:20, which matches "updated last week". |
| 8 | 09 (`journalctl -u nightly-report.service`) | When it started failing | Runs succeeded every 2 min until Nov 09 14:18:01; from 14:20:01 on every run fails with 203/EXEC, and the last run on Nov 16 09:42 fails the same way | The fault started exactly at the script update (14:20), not before. |
| 9 | 15 (`tail -n 20 /var/log/nightly-report.log`) and 14 (`ls -l /var/log`) | Log stops at the failure time | The last entry is Mon Nov 9 14:18:01; log mtime is Nov 9 14:18; the file is root-owned `rw-r--r--` | The log stopped at the last good run, which fits the 203 failures. The log file itself is not the problem. |
| 10 | 21 (`tail -n 12 /var/log/apt/history.log`) | Maybe an upgrade broke something | `apt full-upgrade` on Nov 9 09:38–09:41 upgraded bash, systemd and the kernel | Dead end. It happened about 4.5 hours before the first failure, and the timer ran fine from 09:50 to 14:18 after the reboot. The upgrade is not the cause. |
| 11 | 20 (`which bash; ls -l /bin/bash`) | `/bin/bash` is present, in case the shebang points at nothing | `/bin/bash` exists, `-rwxr-xr-x`, `/usr/bin/bash` | The interpreter is present, so a missing bash is not the cause. |
| 12 | 22 (`tail -n 15 ~/.bash_history`) | What was done at the update | After the reboot, `sudo cp ~/nightly-report.sh /usr/local/bin/...`, `chmod +x`, start, status, then `chmod 755`, start, status again | A new copy of the script was put in place from the home directory, which matches the 14:20 mtime. Both `chmod` attempts did not help, which rules out permissions (see row 7). The problem is inside the file. |
| 13 | 12 (`journalctl -p err -b`) | Other errors that could be related | Only vboxguest and vmwgfx kernel messages, the legacy-sync failure, and the nightly-report 203 errors | Dead end. The kernel/drm lines are normal noise for a VirtualBox VM. |
| 14 | 03, 04, 01, 02 (`df -h`, `free -h`, `hostnamectl`, `uptime`) | Disk or memory exhaustion | `/` 48% used, 5.8G free; 1.5Gi memory available; load ~0; uptime 6 days | Dead end. No resource problem. Machine is healthy. |
| 15 | 19 (run by hand, two ways) | The script runs by hand | `cannot execute: required file not found`; with sudo: `No such file or directory` | It fails the same way outside systemd. So this is not a systemd problem and not a permissions problem (sudo does not help). The kernel cannot start the interpreter named in the first line. |
| 16 | 16 (`cat /usr/local/bin/nightly-report.sh`) | A broken path or syntax error | `#!/bin/bash` and a one-line command that looks correct | Looks perfectly fine to the eye. A hidden character is likely. |
| 17 | 17 (`cat -A /usr/local/bin/nightly-report.sh`) | Hidden characters | Every line ends in `^M$` | The file has Windows (CRLF) line endings. |
| 18 | 18 (`head -1 ... \| od -c`) | Confirm what is after `bash` on line 1 | `# ! / b i n / b a s h \r \n` | Root cause confirmed. The kernel reads the interpreter as `/bin/bash\r`, which does not exist, so exec fails with ENOENT ("No such file or directory"). |
| 19 | (not in the pack) `systemctl is-enabled nightly-report.timer` | `enabled`, so the timer survives a reboot | Not available. The timer is running now (row 4), and its unit has `WantedBy=timers.target`. | I cannot prove from the pack that it is enabled. I will check it in the verification step. |
| 20 | (not in the pack) `ls -l ~/nightly-report.sh; file ~/nightly-report.sh` | The source copy in aigerim's home also has CRLF | Not available. The history shows the server file was copied from there. | The source copy probably has the same problem. If I only fix the server copy, the next `cp` will bring the fault back, so I will fix both. |

## Root cause

`/usr/local/bin/nightly-report.sh` was replaced on Nov 9 at 14:20 with a copy that has Windows (CRLF) line endings: `cat -A` shows `^M$` on every line, and `od -c` shows `\r\n` after `#!/bin/bash` (files 17, 18). The kernel looks for an interpreter called `/bin/bash\r`, which does not exist, so systemd gets `203/EXEC` "No such file or directory" even though the file is present and executable (files 07, 13, 19), and the script never runs. The permissions, the upgrade, the disk, the timer and `legacy-sync` are all ruled out.

## Fix

Run on the server, in order:

```bash
# 1. keep a copy of the broken file
sudo cp -a /usr/local/bin/nightly-report.sh /root/nightly-report.sh.crlf.bak

# 2. strip the carriage returns (dos2unix may not be installed, sed is always there)
sudo sed -i 's/\r$//' /usr/local/bin/nightly-report.sh

# 3. make sure mode and owner are still right
sudo chown root:root /usr/local/bin/nightly-report.sh
sudo chmod 755 /usr/local/bin/nightly-report.sh

# 4. fix the source copy too, so the next cp does not bring the problem back
sed -i 's/\r$//' ~/nightly-report.sh

# 5. clear the failed state and run the job once now
sudo systemctl reset-failed nightly-report.service
sudo systemctl start nightly-report.service
```

I do not touch `legacy-sync.service`: it is unrelated and intentionally fails (`ExecStart=/bin/false`). If the team wants it gone it is a separate change (`sudo systemctl disable legacy-sync.service`) after checking with them.

## Verification

1. The file is clean:
   ```bash
   cat -A /usr/local/bin/nightly-report.sh
   head -1 /usr/local/bin/nightly-report.sh | od -c
   ```
   Expected: lines end in `$` with no `^M`, and the first line is `# ! / b i n / b a s h \n`.

2. It runs by hand, and as a service:
   ```bash
   sudo /usr/local/bin/nightly-report.sh && echo OK
   systemctl status nightly-report.service
   ```
   Expected: `OK` and no error. The status shows `Deactivated successfully` or `status=0/SUCCESS`, not `203/EXEC`.

3. The log is being written again:
   ```bash
   ls -l /var/log/nightly-report.log
   tail -n 8 /var/log/nightly-report.log
   ```
   Expected: the mtime is now. The new entries are a `date` line, the `df -h /` output and the `free -h` output.

4. The timer keeps firing (wait about 4 minutes, so at least two runs):
   ```bash
   systemctl list-timers nightly-report.timer
   journalctl -u nightly-report.service --since "10 minutes ago" --no-pager
   systemctl --failed
   ```
   Expected: runs every 2 minutes, each one `Finished nightly-report.service`. `systemctl --failed` lists only `legacy-sync.service`, which is the known unrelated unit.

5. It still works after a reboot:
   ```bash
   systemctl is-enabled nightly-report.timer      # expect: enabled
   sudo reboot
   # reconnect over SSH, then:
   uptime                                         # expect: up for 1-2 min, so the reboot really happened
   systemctl list-timers nightly-report.timer     # expect: timer active, with a next run time
   # wait 3-4 minutes (OnBootSec=1min, then every 2 min)
   tail -n 8 /var/log/nightly-report.log          # expect: new entries with timestamps after the boot
   journalctl -u nightly-report.service -b --no-pager   # expect: only "Finished" lines, no 203/EXEC
   ```
   If `is-enabled` says `disabled`, I would run `sudo systemctl enable nightly-report.timer` and repeat the reboot test.
