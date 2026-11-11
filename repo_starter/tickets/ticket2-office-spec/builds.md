# Four builds for the second office

Every price and every specification below comes from the product page of that part on **shop.kz** (Белый Ветер, delivers across Kazakhstan), read on **2026-11-11**. Prices are the "Цена в интернет-магазине", VAT included ("Цены указаны с учетом НДС"). Each line, with its link, is in [`budget.csv`](budget.csv). The pages are saved in [`evidence/vendor-quotes/`](evidence/vendor-quotes/).

## What all four share, and why

The machines are **not** identical. They share one base, so one spare part fits every desk.

| Part | Model | Price, ₸ | Why this one (from the product page) |
|---|---|---|---|
| Platform | AMD AM4 + DDR4 | — | 32 GB DDR4 (2×16) costs 146 990 ₸; 32 GB DDR5 (Kingston Fury Beast 2×16, 5200) costs 332 990 ₸. AM4 saves 186 000 ₸ per 32 GB machine, 558 000 ₸ across three. |
| Cooler | DeepCool AG400 | 10 490 | All three CPUs are sold "OEM (без системы охлаждения!)"; the AG400 page lists AM4. |
| SSD | Kingston NV3 1 TB | 79 400 | Meets the 1 TB requirement; TLC, PCIe 4.0, up to 6000/4000 MB/s, 320 TBW, 60-month warranty. |
| Case | DeepCool CG380 3F | 28 990 | Takes Micro-ATX boards; 3 fans included; GPU up to 410 mm. No PSU inside, so the PSU is a separate line. |
| Power supply | FSP VIC-550BD 550 W | 19 990 | 80 PLUS Bronze, 36-month warranty. The designer's graphics card page asks for at least 450 W, so one PSU model fits all four. |
| Windows | Windows 11 Pro, BOX, USB | 122 990 | The page lists BitLocker device encryption, which matters for payroll and tax data. The cheaper OEM DVD (102 990 ₸) is "Продается только в комплекте с компьютером", and we are buying parts, not a computer. |
| Keyboard + mouse | Logitech MK270 | 14 290 | Wireless keyboard and mouse in one set; one receiver per desk. |

**Trade-off accepted for the platform:** AM4 is an older platform. In four years the upgrades will be memory, storage and graphics, not a newer processor.

---

### Build 1: accountant

**Load:** 1C:Бухгалтерия, Excel, a browser with the ИС ЭСФ portal, the tax cabinet and online banking, NCALayer for the digital signature. Single user, one or two heavy windows at a time.

**Bottleneck:** nothing in the machine is stretched. The risk is **data and power**: a 1C database open during a power cut can be damaged.

**Trade-off:** the cheapest parts that meet the requirement, and the saving kept in the reserve for a UPS for this desk. Not taken: 32 GB (+70 000 ₸), which this load would not use.

| Part | Model | Price, ₸ | Why this one |
|---|---|---|---|
| CPU | AMD Ryzen 5 5500GT | 79 190 | 6 cores / 12 threads, Zen 3, built-in Radeon Vega 7, so no graphics card. |
| Motherboard | ASUS Prime A520M-K | 32 790 | Page lists Zen 3 support; HDMI and VGA outputs for the built-in graphics; 2 DDR4 slots, 1 M.2. |
| Memory | Team Group Elite 16 GB (2×8) DDR4-3200 | 76 990 | Meets 16 GB; two modules fill both slots; 36-month warranty. |
| Monitor | Philips 24E1N1200A 23.8″ | 53 990 | IPS 1920×1080, 120 Hz, HDMI/VGA/DisplayPort, built-in speakers, 24-month warranty. |
| Shared parts | cooler, SSD, case, PSU, Windows, keyboard | 276 150 | See table above. |

**Total:** 519 110 ₸ (`budget.csv`, rows 2–12)

### Build 2: sales manager

**Load:** CRM in a browser with 30–40 tabs, Excel, messengers, about four hours of video calls a day, often all at once.

**Bottleneck:** **memory.** The ticket's own example puts forty tabs plus a video call at 11–12 GB; with Excel and messengers open, 16 GB runs out and Windows starts swapping in the middle of a call. The CPU mostly idles in this role.

**Trade-off:** same CPU and board as the accountant; the saving went into 32 GB and a webcam.

| Part | Model | Price, ₸ | Why this one |
|---|---|---|---|
| CPU | AMD Ryzen 5 5500GT | 79 190 | Same as the accountant; a faster CPU would not be felt in this role. |
| Motherboard | ASUS Prime A520M-K | 32 790 | Same board; 2 slots are enough for 2×16 GB (page: up to 64 GB). |
| Memory | GeIL Pristine 32 GB (2×16) DDR4-3200 | 146 990 | Removes the memory bottleneck. |
| Monitor | Philips 24E1N1200A 23.8″ | 53 990 | Built-in speakers serve the calls; no separate speakers needed. |
| Webcam | HP 320 Full HD | 18 600 | 1920×1080 with a built-in microphone; the monitor page lists no camera. |
| Shared parts | cooler, SSD, case, PSU, Windows, keyboard | 276 150 | See table above. |

**Total:** 607 710 ₸ (`budget.csv`, rows 13–24)

### Build 3: web developer

**Load:** VS Code, Docker with several containers (database, backend, frontend) through WSL2, `npm` builds, two or three browsers open for testing.

**Bottleneck:** **memory first, then CPU threads.** Containers and browsers all sit in memory at once, and builds use every core. Graphics do not matter.

**Trade-off:** an 8-core CPU with built-in graphics (no graphics card), and a board with room to grow. Not taken: Linux instead of Windows (it would save 122 990 ₸, but the developer must test sites in Windows browsers, and nobody in a small office supports a Linux desktop).

| Part | Model | Price, ₸ | Why this one |
|---|---|---|---|
| CPU | AMD Ryzen 7 5700G | 115 590 | 8 cores / 16 threads, Zen 3, built-in Radeon Graphics, so no graphics card. |
| Motherboard | ASUS Prime B550M-A | 50 990 | **4** DDR4 slots (up to 128 GB) and 2 M.2: memory can be doubled later without throwing anything away. 18 200 ₸ more than the A520. |
| Memory | GeIL Pristine 32 GB (2×16) DDR4-3200 | 146 990 | Uses two of the four slots. |
| Monitor | AOC Q27B36X 27″ | 86 990 | IPS 2560×1440: two files side by side; HDMI cable included. |
| Shared parts | cooler, SSD, case, PSU, Windows, keyboard | 276 150 | See table above. |

**Total:** 676 710 ₸ (`budget.csv`, rows 25–35)

### Build 4: designer

**Load:** assumed graphic and web design (Photoshop, Illustrator, Figma) with short video edits for social media. The request does not say; see README §2.

**Bottleneck:** **the graphics card and the screen.** Photoshop and video editing use the graphics card for previews and export, and a screen that shows colour wrongly makes every file wrong.

**Trade-off:** the money went to the graphics card and the monitor. To pay for that, the CPU is the 5700X without built-in graphics, the platform stays AM4/DDR4, and the card is the 8 GB RTX 5060, not the 16 GB RTX 5060 Ti (452 990 ₸, +163 000 ₸). Rejected cheaper option: Palit RTX 3050 6 GB (166 990 ₸) saves 123 000 ₸, but it has less and older video memory (6 GB GDDR6 against 8 GB GDDR7).

| Part | Model | Price, ₸ | Why this one |
|---|---|---|---|
| CPU | AMD Ryzen 7 5700X | 83 990 | 8 cores / 16 threads, Zen 3; no built-in graphics, which is fine because the card does the display. 31 600 ₸ cheaper than the 5700G. |
| Motherboard | ASUS Prime B550M-A | 50 990 | 4 memory slots; the page warns its video outputs do not work without built-in graphics, so the monitor plugs into the card. |
| Memory | GeIL Pristine 32 GB (2×16) DDR4-3200 | 146 990 | Two Adobe programs and a browser at once. |
| Graphics card | Gigabyte RTX 5060 OC Low Profile | 289 990 | 8 GB GDDR7; minimum PSU 450 W, so the shared 550 W PSU is enough. The Gigabyte Aero and ASUS TUF versions were sold out. |
| Monitor | Philips 27B2U3601 27″ | 191 990 | IPS 2560×1440, 125 % sRGB, USB-C, height adjustment and 90° pivot for portrait layouts. |
| Shared parts | cooler, SSD, case, PSU, Windows, keyboard | 276 150 | See table above. |

**Total:** 1 040 100 ₸ (`budget.csv`, rows 36–47)

---

## Totals

| Build | Total, ₸ |
|---|---|
| Accountant | 519 110 |
| Sales manager | 607 710 |
| Web developer | 676 710 |
| Designer | 1 040 100 |
| **All four** | **2 843 630** |
| Reserve within 3 000 000 | 156 370 (5 %) |

The reserve is deliberate. Prices on shop.kz moved within one day: the catalogue page showed the 32 GB DDR4 kit at 139 990 ₸ and its product page at 146 990 ₸. The accountant's UPS and delivery also come out of the reserve.

**Why not four identical machines:** four copies of the designer build cost **4 160 400 ₸**, 1.16 million over budget. Four copies of the accountant build (2 076 440 ₸) fit, but then the designer has no graphics card and the developer and sales manager run out of memory.
