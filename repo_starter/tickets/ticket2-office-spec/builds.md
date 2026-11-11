# Four builds for the second office

All prices are from **shop.kz** (Белый Ветер), which sells online with delivery across Kazakhstan. Prices are online-store prices in tenge, VAT included, taken on **2026-11-11**. Every line is in [`budget.csv`](budget.csv) with its link and date.

## What every machine shares, and why

The four machines are **not** identical, but they are built on one base:

- **Platform: AMD AM4 with DDR4.** On the price date, 32 GB of DDR5 cost 332 990 ₸ and 32 GB of DDR4 cost 139 990 ₸ at the same shop. That is 193 000 ₸ per machine. AM5/DDR5 would be the newer platform with a longer upgrade path, but it would cost 579 000 ₸ more across the three 32 GB machines, and for these loads DDR4 is not the bottleneck. **Trade-off accepted:** AM4 is the end of its line, so in four years the upgrade options will be memory, storage and graphics, not a new CPU generation.
- **Same case, cooler, SSD, keyboard set and Windows edition** on all four. One spare of each covers every desk, and whoever looks after them learns one layout.
- **Windows 11 Pro, retail (USB) licence.** Pro gives BitLocker (the accountant's machine holds payroll and tax data) and Remote Desktop for support. The retail licence moves to a new machine later; the cheaper OEM DVD licence (102 990 ₸) stays tied to the first motherboard.
- **1 TB Kingston NV3** on every machine meets the 1 TB requirement at the lowest price. It is a DRAM-less drive; see Build 4 for where that matters.
- **OEM processors come without a cooler**, so each build has a DeepCool AG400 (10 490 ₸).

---

### Build 1: accountant

**Load:** 1C:Бухгалтерия, Excel, a browser with the ИС ЭСФ portal, the tax cabinet and online banking, NCALayer for the digital signature (ЭЦП). Single-user work, one or two heavy windows at a time.

**Bottleneck:** none of the CPU, memory or graphics is stretched. The risks are **data and power**: a 1C database open when the power drops can be corrupted, and an accounting PC is the one where losing a day of work costs the most.

**Trade-off:** took the cheapest part that meets the requirement everywhere (Ryzen 5 5500GT with built-in graphics, A520 board, 16 GB as 2×8 for dual channel) and kept money in the reserve for a UPS for this desk. Not taken: 32 GB (+63 000 ₸), which this load would not use.

**Total:** 517 810 ₸ (`budget.csv`, rows 2–12)

### Build 2: sales manager

**Load:** CRM in a browser with 30–40 tabs, Excel, WhatsApp/Telegram web, about four hours a day of video calls, often all at once.

**Bottleneck:** **memory.** A browser with forty tabs plus a video call already takes 11–12 GB; add Excel and messengers and 16 GB is not enough. When memory runs out Windows starts swapping to the SSD in the middle of a customer call. The CPU is mostly idle in this role.

**Trade-off:** same cheap CPU and board as the accountant, and the saving went into 32 GB (2×16) and a Full HD webcam with a microphone. The monitor has built-in speakers, so there is no separate audio. Not taken: a faster CPU, which this role would not feel.

**Total:** 599 410 ₸ (`budget.csv`, rows 13–24)

### Build 3: web developer

**Load:** VS Code, Docker (several containers: database, backend, frontend dev server) through WSL2, `npm` builds, two or three browsers open for testing.

**Bottleneck:** **memory first, then CPU threads.** WSL2 and Docker hold on to a large share of memory while they run, and builds use every core. Graphics do not matter.

**Trade-off:** 8-core Ryzen 7 5700G (it has built-in graphics, so no graphics card) and 32 GB. The B550 board costs 18 200 ₸ more than the A520, but it has **four** memory slots and two M.2 slots, so this machine can go to 64 GB later without throwing anything away. The 27″ 1440p monitor (86 990 ₸) shows two files side by side. Not taken: a graphics card, and Linux instead of Windows (it would save the 122 990 ₸ licence, but the developer has to test sites in Windows browsers, and nobody in a small office supports a Linux desktop).

**Total:** 668 410 ₸ (`budget.csv`, rows 25–35)

### Build 4: designer

**Load:** assumed to be graphic and web design: Photoshop, Illustrator and Figma, with short video edits for social media (see README §2, the request does not say).

**Bottleneck:** **the graphics card and the screen.** Photoshop and video editing use the GPU for filters, previews and export. A screen that shows colour wrongly makes all the work wrong, however fast the PC is.

**Trade-off:** spent the money where it shows: an RTX 5060 8 GB (288 990 ₸) and a 27″ 1440p IPS monitor with 125 % sRGB coverage, USB-C and a height/pivot stand (191 990 ₸). To pay for that: Ryzen 7 5700X on AM4 with DDR4 instead of AM5 with DDR5, and the 8 GB card instead of the 16 GB RTX 5060 Ti (~470 000 ₸). Rejected cheaper option: an RTX 3050 6 GB (161 690 ₸) saves 127 300 ₸ but is weak for video, and buying it means replacing it inside two years. The 650 W power supply leaves headroom for the card.

**Known weak point:** the same DRAM-less 1 TB NV3 as the others. Fine for opening files; slow for copying or exporting tens of gigabytes at once (see README, question 3).

**Total:** 1 033 100 ₸ (`budget.csv`, rows 36–47)

---

## Totals

| Build | Total, ₸ |
|---|---|
| Accountant | 517 810 |
| Sales manager | 599 410 |
| Web developer | 668 410 |
| Designer | 1 033 100 |
| **All four** | **2 818 730** |
| Reserve within 3 000 000 | 181 270 (6 %) |

The reserve is deliberate: memory prices moved during the week of this research (the Ryzen 7 5700X showed 92 990 ₸ on the catalogue page and 83 990 ₸ on its product page on the same day), and the accountant's UPS and delivery come out of it.

**Why not four identical machines:** four copies of the designer build cost 4 132 400 ₸, which is 1.13 million over budget. Four copies of the accountant build (2 071 240 ₸) fit, but then the designer has no graphics card and the developer and sales manager run out of memory. Identical machines are either unaffordable or wrong for three of the four people.
