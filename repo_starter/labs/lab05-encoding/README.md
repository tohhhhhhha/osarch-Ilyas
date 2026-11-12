# Lab 5 — Encoding forensics

Pair: solo    Driver first half: —
Machine: MacBook M2, macOS (host); Debian GNU/Linux forky/sid arm64 guest and Windows 11 ARM guest in VMware Fusion
Date: 2026-11-12

Diagnosis and conversion were done in the Linux guest (Debian GNU/Linux forky/sid, arm64), over SSH
from the macOS host. Every "before" file was made from the untouched original before anything was converted.

SHA-256 of `evidence/staff-broken.csv`:
`919027f1f8c71d85cba3f12aad0f6c927d4e0450cfb2a2d63378a69f14cab270` —
the same on the host right after downloading it from Canvas, in the guest before the diagnosis,
and in the guest after the fix. The original was never changed.

## What I did

### 1. Diagnosis (before the fix)

**file says** (`evidence/file-before.txt`):

    staff-broken.csv: Non-ISO extended-ASCII text, with CRLF line terminators
    staff-broken.csv: Non-ISO extended-ASCII text, with CRLF line terminators

Both lines are the same: `file` 5.47 did not classify this file as CSV, so `-e csv` changed nothing and
the line terminators are already visible in the first line. "Non-ISO extended-ASCII" only means
"8-bit text that is not a Unicode encoding" — `file` cannot tell single-byte code pages apart, so it is
the first witness, not the verdict.

**First 16 bytes** (`evidence/hexdump-before.txt`):

    00000000: d2e0 e12e b93b d4c8 ce3b c4ee ebe6 edee  .....;...;......

| Offset | Bytes | What they are |
|---|---|---|
| 00 | D2 | No BOM — the file starts straight with text. `Т`: one byte for one Cyrillic letter |
| 01–02 | E0 E1 | `а`, `б` — one byte each |
| 03 | 2E | `.` (ASCII) |
| 04 | B9 | `№` — one byte |
| 05 | 3B | separator: semicolon |
| 06–08 | D4 C8 CE | `ФИО` |
| 09 | 3B | separator: semicolon |
| 0A–0F | C4 EE EB E6 ED EE | `Должно…` — the header continues as «Должность» |

Every Cyrillic letter is a single byte between 80 and FF, so this is a single-byte code page, not UTF-8
(where Cyrillic letters are two-byte pairs `D0 xx` / `D1 xx`). The line ending is also visible in the bytes:
`0D 0A` at offset 2E–2F, after the header.

**Is it UTF-8?**

    $ iconv -f UTF-8 -t UTF-8 staff-broken.csv > /dev/null && echo valid
    iconv: illegal input sequence at position 0

`D2` is a UTF-8 lead byte that must be followed by a byte in 80–BF; here it is followed by `E0`.

**Which code page?** Each candidate from `iconv -f <ENC> -t UTF-8 staff-broken.csv | head -5`:

| Candidate | Header | Employee 1001 | Employee 1003 | Verdict |
|---|---|---|---|---|
| CP866 | `┬рс.╣;╘╚╬;…` | `Нрё√ьютр гыш …` | — | wrong, even Russian is garbage |
| KOI8-R | `рЮА.╧;тхн;дНКФМНЯРЭ…` | `█ЮЯШЛНБЮ ёКХЪ …` | — | wrong, even Russian is garbage |
| CP1251 | `Таб.№;ФИО;Должность…` | `Ќасымова Јлия Серікќызы` | `Нўрланов Єалымжан Ерланўлы` | Russian right, Kazakh wrong |
| PT154 | `Таб.№;ФИО;Должность…` | `Қасымова Јлия Серікқызы` | `Нўрланов Әалымжан Ерланўлы` | Қ right, Ә Ұ Ғ wrong |
| **RK1048** | `Таб.№;ФИО;Должность…` | `Қасымова Әлия Серікқызы` | `Нұрланов Ғалымжан Ерланұлы` | **all correct** |

CP1251, PT154 and RK1048 agree on every Russian letter; the Kazakh letters decide it:

| Byte | CP1251 | PT154 | RK1048 |
|---|---|---|---|
| 8D | Ќ | Қ | **Қ** |
| A3 | Ј | Ј | **Ә** |
| 9D | ќ | қ | **қ** |
| A2 | ў | ў | **ұ** |
| AA | Є | Ә | **Ғ** |

Confirmation: `iconv -f RK1048 -t UTF-8 staff-broken.csv > /dev/null && echo ok` prints `ok` — no error
anywhere in the file — and reading the whole list with `less`, all 25 employees are correct, with all nine
Kazakh letters present (Ә, Ғ, Қ, Ң, Ө, Ұ, Ү, Һ, І — e.g. Өтебаев, Үсенова, Һашимов, Іңкәр).

**Line ending:**

    $ cat -A staff-broken.csv | head -3        # every line ends in ^M$
    $ tr -cd '\r' < staff-broken.csv | wc -c   # 26 CR bytes
    $ wc -l staff-broken.csv                   # 26 LF bytes

#### Diagnosis summary

- **Encoding: RK1048** (KZ-1048, the Windows Kazakh code page) — evidence: not valid UTF-8; one byte per
  Cyrillic letter; only RK1048 decodes the whole file and shows every Kazakh letter correctly (tables above).
- **Line ending: CRLF** (Windows) — evidence: `file` says "with CRLF line terminators"; `cat -A` shows `^M$`;
  26 CR = 26 LF; `0D 0A` in the hex dump.
- **BOM: absent** — evidence: the file starts with `D2`, not `EF BB BF` or `FF FE`.
- Separator: semicolon (`3B`).

### 2. What each application was doing wrong

- **Excel (Microsoft Excel for Mac 16.115):** there is no BOM and nothing in the file says RK1048, so Excel decoded every byte as **Mac Roman**, the classic Mac default code page: `D2`→`“`, `E0`→`‡`, `E1`→`·`, `B9`→`π` — «Таб.№» became `“‡·.π`. The ASCII parts (numbers, `E-mail`, addresses, dates) were intact and the columns were split on `;`.
- **Numbers 14.5** (used instead of LibreOffice Calc, see *Deviations*): guessed a Cyrillic code page and read the file as **Windows-1251**. All Russian text was right, but the Kazakh letters, which Windows-1251 does not have, came out as other letters: «Ќасымова Јлия Серікќызы», «Нўрланов Єалымжан», «Ћашимов» — exactly what `iconv -f CP1251` showed.
- **cat:** the Debian terminal (locale `C.UTF-8`) reads the bytes as UTF-8. Every RK1048 byte between 80 and FF
  is not a valid UTF-8 sequence, so each Cyrillic letter was shown as `?`.

What `cat staff-broken.csv | head -3` printed:

    ???.?;???;?????????;?????;E-mail;???? ?????
    1001;???????? ???? ???????;??????? ?????????;???????????;a.kassymova@tumar-office.kz;12.03.2019

The ASCII parts (`E-mail`, the addresses, the dates) are perfect — the bytes are intact, only the decoder
is wrong. A corrupted file would have broken those too.

### 3. BOM decision

| Reader | Without BOM | With BOM |
|---|---|---|
| Excel, double-click on the CSV | garbage — Excel falls back to the ANSI code page | correct |
| LibreOffice Calc | correct — the import dialog detects UTF-8 | correct |
| `cat` in a UTF-8 terminal | correct | correct — the BOM is invisible |
| A script reading the first column header | correct | the header gets an invisible U+FEFF in front of `Таб.№` |

The fixed file has one UTF-8 BOM. Excel decided it: on a double-click it only recognises UTF-8 when the
BOM is there. The cost is that scripts must strip it (Python: `encoding="utf-8-sig"`).

### 4. Fix

Script: `scripts/fix.sh`, run from this folder with `bash scripts/fix.sh`.

Changed:

- encoding **RK1048 → UTF-8** (`iconv -f RK1048 -t UTF-8`);
- line ending **CRLF → LF** (`sed 's/\r$//'`);
- BOM **added** (`EF BB BF`).

The file grew from 2460 to 3621 bytes: every Cyrillic letter now takes two bytes instead of one, `№` takes
three, the BOM adds three, and the 26 CR bytes are gone.

### 5. Verification

**file after** (`evidence/file-after.txt`) — no "CRLF" any more:

    staff-fixed.csv: Unicode text, UTF-8 (with BOM) text
    staff-fixed.csv: Unicode text, UTF-8 (with BOM) text

First 16 bytes after the fix:

    00000000: efbb bfd0 a2d0 b0d0 b12e e284 963b d0a4  ..............;..

`EF BB BF` = BOM; `D0 A2 D0 B0 D0 B1` = «Таб», two bytes per letter; `2E` = `.`; `E2 84 96` = `№`;
`3B` = `;`; `D0 A4` = «Ф».

**The script check** — `awk -F';' '{ print $NF "|" }'`, last column followed by `|`:

    before (CRLF)        after (LF)
    |??? ?????           Дата приёма|
    |2.03.2019           12.03.2019|
    |1.09.2017           01.09.2017|

Before the fix the hidden CR moved the cursor back to the start of the line, so `|` overwrote the first
character; after the fix it sits right after the value.

**Opened in three applications** — `evidence/opens-correctly.png`:

- `cat` on Debian GNU/Linux forky/sid — all 25 names correct;
- Numbers 14.5 on macOS — opened as is, all 25 names correct;
- Microsoft Excel for Mac 16.115 — opened directly, not through the import wizard: all names correct, columns split, and no stray character before `Таб.№` (Excel recognised the BOM and hid it).

## Result

- Source file: **RK1048** (KZ-1048), **CRLF** line endings, **no BOM**, `;` separator.
- Fixed file `evidence/staff-fixed.csv`: **UTF-8 with BOM, LF** line endings. The original is untouched (same SHA-256).
- The fixed file opens correctly, with every Kazakh letter, in `cat` on Debian, Microsoft Excel for Mac 16.115
  and Numbers 14.5 — `evidence/opens-correctly.png`.

## What did not work the first time

1. **Locale warning over SSH.** When I connected to the Debian guest over SSH from the Mac, every command printed
   `-bash: warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory`.
   It turned out macOS sends `LC_CTYPE=UTF-8`, which is not a locale name on Linux, so the shell fell back to the
   C locale — and in this lab the terminal really has to be UTF-8. I fixed it with:

        export LC_ALL=C.UTF-8
        echo 'export LC_ALL=C.UTF-8' >> ~/.bashrc
        locale | head -3        # LC_CTYPE="C.UTF-8"

2. **SSH was not running.** After `sudo apt install openssh-server` I could not connect, and the installer had
   printed `ssh.socket is a disabled or a static unit not running, not starting it`. I started it with:

        sudo systemctl enable --now ssh
        systemctl is-active ssh     # active

3. Excel and LibreOffice were not available in the Windows guest — see *Deviations from the brief*.

## Evidence

- [evidence/staff-broken.csv](evidence/staff-broken.csv) — the untouched original from Canvas (SHA-256 `919027f1…cab270`)
- [evidence/hexdump-before.txt](evidence/hexdump-before.txt) — first 16 bytes before the fix: no BOM, one byte per Cyrillic letter, `;` separator
- [evidence/file-before.txt](evidence/file-before.txt) — `file` before the fix: Non-ISO extended-ASCII text, CRLF
- [evidence/staff-fixed.csv](evidence/staff-fixed.csv) — the converted file
- [evidence/file-after.txt](evidence/file-after.txt) — `file` after the fix: UTF-8 (with BOM), no CRLF
- [evidence/opens-correctly.png](evidence/opens-correctly.png) — the fixed file in Excel for Mac, Numbers and `cat` side by side
- [scripts/fix.sh](scripts/fix.sh) — the conversion

## Deviations from the brief

- **Excel for Windows was not available.** The Windows 11 ARM guest has no Microsoft 365 licence, and the Office
  download did not finish before the deadline. Excel was checked with Microsoft Excel for Mac on the host instead —
  the same desktop Excel, opened the same way (directly, not through *Data → From Text/CSV*).
- **LibreOffice Calc was not available.** It was not installed in the Windows guest, and the 345 MB download
  (`winget install TheDocumentFoundation.LibreOffice`) did not finish in time. Apple Numbers was used as the third
  application instead.
- The files checked on the host are byte-for-byte the ones in `evidence/` (copied from the guest with `scp`,
  same sizes: 2460 and 3621 bytes).

## AI declaration

I used Claude to understand what I need to do if the Excel is downloading very slow. I ran every command myself, and every result in this README comes from my own
files and screenshots.
