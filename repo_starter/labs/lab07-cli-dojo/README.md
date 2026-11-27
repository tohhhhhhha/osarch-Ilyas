# Lab 7 — CLI dojo

Pair: myself                   Driver first half:
Machine: MacBook host, VMware Fusion, Windows guest
Date: 2026-11-28 (start 12:23:14 on the guest clock)
Shell: cmd.exe (PowerShell not needed); prompt set with `prompt $T$S$P$G` so every line shows the clock

## Result

Time = minutes:seconds since the clock started (00:00 = 12:23:14 on the guest clock). #19's evidence was written after #20, so its time is later.

| # | Challenge | Command | Time |
|---|-----------|---------|------|
| 1 | Print the full path of the current directory | `cd` | 00:29 |
| 2 | Computer name and logged-in account | `hostname & whoami` | 02:30 |
| 3 | Create C:\dojo\logs\old and C:\dojo\backup with one command | `mkdir C:\dojo\logs\old C:\dojo\backup` | 02:54 |
| 4 | notes.txt with "dojo started" and the current time | `(echo dojo started& echo %time%) > C:\dojo\notes.txt` | 03:34 |
| 5 | Full path of ping | `where ping` | 03:49 |
| 6 | Only IPv4, default gateway, DNS servers | `ipconfig /all \| findstr /c:"IPv4" /c:"Default Gateway" /c:"DNS Servers"` | 04:38 |
| 7 | Save processes to procs.txt, count lines | `tasklist > C:\dojo\procs.txt & type C:\dojo\procs.txt \| find /c /v ""` | 04:58 |
| 8 | Start Notepad, find PID, kill by PID | `start notepad` → `tasklist /fi "imagename eq notepad.exe"` → `taskkill /f /pid 9700 /pid 9472` | 06:43 |
| 9 | Only ERROR lines of app.log | `findstr "ERROR" C:\dojo\logs\app.log` | 07:11 |
| 10 | Number of non-INFO lines | `type C:\dojo\logs\app.log \| find /v /c "INFO"` | 07:27 |
| 11 | Copy app.log to backup, size of both with one dir | `copy C:\dojo\logs\app.log C:\dojo\backup\` → `dir /s C:\dojo\app.log` | 07:44 |
| 12 | dir C:\nothing-here silently, error to errors.txt | `dir C:\nothing-here >nul 2>C:\dojo\errors.txt` | 08:29 |
| 13 | Ping gateway once, print OK / DOWN only | `ping -n 1 192.168.246.2 \| find "TTL=" >nul && echo gateway OK \|\| echo gateway DOWN` | 10:25 |
| 14 | Lines with user1, case-insensitive, numbered | `findstr /i /n "user1" C:\dojo\logs\app.log` | 10:54 |
| 15 | scores.txt sorted high → low | `sort /r C:\dojo\scores.txt` | 11:11 |
| 16 | Processes using more than 50 MB | `tasklist /fi "memusage gt 51200"` | 11:26 |
| 17 | Process listening on TCP 135 (name) | `netstat -ano \| findstr ":135"` → `tasklist /svc /fi "pid eq 552"` | 11:48 |
| 18 | dojo.test → 127.0.0.1, prove, undo, prove | see "Challenge 18" below | 12:43 |
| 19 | Every file under C:\dojo with path and size | `for /r C:\dojo %f in (*) do @echo %f %~zf` | 21:42 |
| 20 | robocopy mirror ×4 with exit codes | see "Challenge 20" below | 15:14 |

## What I did

### Challenge 14 — why more than one line

`findstr` matches a substring, so `user1` also matches `user10` … `user19`
(INFO lines 10–19). On top of that, user1 appears in all three sections:
`INFO user1`, `ERROR ... user1`, `WARN ... user1`. Total: 13 lines.
To match only user1 itself: `findstr /i /n /r "user1\>" C:\dojo\logs\app.log` (3 lines).

### Challenge 17 — answer

`netstat -ano` shows `0.0.0.0:135` and `[::]:135` LISTENING with PID 552.
`tasklist /svc /fi "pid eq 552"` → **svchost.exe**, hosting the RPC services RpcEptMapper and RpcSs.

### Challenge 18 — hosts file (elevated cmd)

```
powershell -c "Start-Process cmd -Verb RunAs"
copy %SystemRoot%\System32\drivers\etc\hosts %TEMP%\hosts.bak
(echo.& echo 127.0.0.1 dojo.test)>> %SystemRoot%\System32\drivers\etc\hosts
ipconfig /flushdns
ping -n 1 dojo.test
copy /y %TEMP%\hosts.bak %SystemRoot%\System32\drivers\etc\hosts
ipconfig /flushdns
ping -n 1 dojo.test
```

Before undo: `Pinging dojo.test [127.0.0.1]` with a reply.
After undo: `Ping request could not find host dojo.test`.

### Challenge 20 — robocopy exit codes

```
robocopy C:\dojo\logs C:\dojo\backup\logs /MIR /LOG+:C:\dojo\robocopy.log
echo run1 exit code: %errorlevel%
echo test> C:\dojo\logs\extra.txt
robocopy C:\dojo\logs C:\dojo\backup\logs /MIR /LOG+:C:\dojo\robocopy.log
echo run2 exit code: %errorlevel%
del C:\dojo\logs\extra.txt
robocopy C:\dojo\logs C:\dojo\backup\logs /MIR /LOG+:C:\dojo\robocopy.log
echo run3 exit code: %errorlevel%
robocopy C:\dojo\logs C:\dojo\backup\logs /MIR /LOG+:C:\dojo\robocopy.log
echo run4 exit code: %errorlevel%
```

| Run | Code | Meaning |
|-----|------|---------|
| 1 — first mirror | 1 | Files were copied (app.log, folder `old`) |
| 2 — after adding extra.txt | 1 | One new file copied |
| 3 — after deleting extra.txt | 2 | Extra file found in the destination and purged by /MIR, nothing copied |
| 4 — once more | 0 | Source and destination identical, nothing to do |

robocopy's exit code is a bit mask: 1 = copied, 2 = extra files in destination,
4 = mismatches, 8 = some copies failed, 16 = fatal error. 0–7 = success, 8+ = failure.

## What did not work the first time

1. **Challenge 8, wrong PID.** I typed `taskkill /f /pid 4520` and got
   `ERROR: The process "4520" not found.` I had copied an example number instead of
   reading the PID from `tasklist`. The real output showed two `Notepad.exe` processes
   (9700 and 9472) — Windows 11 Notepad runs two. Fix: `taskkill /f /pid 9700 /pid 9472`,
   then `tasklist` confirmed no Notepad was left.
2. **Challenge 13, placeholder left in.** I ran `ping -n 1 GW ...` with the literal word
   `GW`, so ping tried to resolve a host called "GW". I looked up the real gateway with
   `ipconfig | findstr /c:"Default Gateway"` (192.168.246.2) and ran it again → `gateway OK`.
3. **Setup run twice.** The first time, `mkdir C:\dojo\logs` said the folder already
   existed and the `>>` lines appended a second copy of the log. Fix: `rmdir /s /q C:\dojo`
   and run the setup again; `type app.log | find /c /v ""` then showed 41 lines.

## Evidence

- [evidence/output-all-challenges.txt](evidence/output-all-challenges.txt) — output and errors of every solved challenge, one `===== #NN =====` header each
- [evidence/screenshots/](evidence/screenshots/) — `ch01.png` … `ch20.png`, terminal with the command, output and clock
