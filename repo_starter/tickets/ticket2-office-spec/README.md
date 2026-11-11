# Ticket 2 — Office hardware specification

## 1. What was asked

> From: Daniyar K. (Director)
> Subject: computers for the new office
>
> We are opening the second office and need four computers — accountant, sales, web developer, designer. Budget 3,000,000 tenge for everything. Everyone says we should just buy the same four machines, is that right? Make sure they last a few years. Monitors included.

## 2. What was actually needed

**Where the request is wrong.** "Just buy the same four machines" is the wrong answer to the director's own question. The four jobs stress different parts: the accountant stresses nothing, the sales manager stresses memory, the developer stresses memory and CPU threads, and the designer stresses the graphics card and the screen. Four copies of a machine good enough for the designer cost **4 160 400 ₸**, 1.16 million over budget. Four copies of the accountant's machine fit (2 076 440 ₸), but then the designer has no graphics card and two other people run out of memory. The right answer is four different machines on one shared base (same platform, case, power supply, SSD, keyboard set and Windows edition), so spares and support stay simple.

**What the request left out, and what I assumed instead:**

| Missing from the request | What I would ask Daniyar | What I assumed |
|---|---|---|
| What kind of designer | "Print and web graphics, or video and 3D?" | Graphic and web design with short video edits, so an 8 GB RTX 5060, not a 16 GB card |
| Desktop or laptop | "Does sales visit clients?" | Desktops for everyone, because "monitors included" suggests fixed desks |
| Software licences | "Do you already have 1C, Microsoft Office and Adobe?" | Not in this budget. Only Windows is included. 1C, Office and Adobe are paid separately, and the director should know that before he calls 3 000 000 "everything" |
| Keyboards, mice, webcams, UPS | "Is anything coming from the first office?" | Nothing. A keyboard and mouse for everyone, a webcam for sales, a UPS for the accountant from the reserve |
| "A few years" | "How many years before you expect to replace them?" | Four years, so 32 GB where the load grows and a 4-slot board for the developer |
| What "budget for everything" includes | "Does it include delivery and setup?" | Prices include VAT (shop.kz states this). Delivery and the UPS are paid from the 156 370 ₸ reserve |

## 3. What I did

1. Wrote down each person's daily load and named the one part that load runs out of first (the bottleneck). The reasoning, with a "why this one" line for every part, is in [`builds.md`](builds.md).
2. Took every price and specification from the **product page** of the part on **shop.kz**, on **2026-11-11**. shop.kz delivers across Kazakhstan. One vendor keeps prices comparable and means one order and one invoice.
3. Dropped anything the product page showed as sold out ("Увы, этот товар закончился"): Ryzen 5 7600, 8600G, Intel i5-12400, the Gigabyte RTX 5060 Aero and ASUS RTX 5060 TUF, the ASUS ProArt monitor, and others.
4. Found that memory decides the platform: on the same site 32 GB DDR5 was 332 990 ₸ and 32 GB DDR4 was 146 990 ₸. I chose AM4 with DDR4 for all four machines.
5. Put every part into [`budget.csv`](budget.csv) with its model, price, link and date, and checked the totals with a script.
6. Priced the same four as pre-built machines from the same shop (question 2 below).
7. Checked each build against the hard requirements: ≥16 GB memory, 1 TB SSD, licensed OS, monitor. All four pass.

**Result:** 2 843 630 ₸ for four complete workstations, with 156 370 ₸ (5 %) left in reserve.

| Build | Memory | SSD | OS | Monitor | Total, ₸ |
|---|---|---|---|---|---|
| Accountant | 16 GB DDR4 | 1 TB | Windows 11 Pro | 23.8″ FHD | 519 110 |
| Sales manager | 32 GB DDR4 | 1 TB | Windows 11 Pro | 23.8″ FHD + webcam | 607 710 |
| Web developer | 32 GB DDR4 | 1 TB | Windows 11 Pro | 27″ QHD | 676 710 |
| Designer | 32 GB DDR4 + RTX 5060 8 GB | 1 TB | Windows 11 Pro | 27″ QHD, 125 % sRGB | 1 040 100 |

### Question 1. Which machine will I upgrade first, eighteen months from now, and why?

**The web developer's memory, from 32 GB to 64 GB.** His load grows fastest: every new project adds containers, and each database, backend or browser instance adds to the total. That is why his build has the B550M-A with **four** memory slots (up to 128 GB per its page): the upgrade is one more 2×16 GB kit in the two empty slots (146 990 ₸ on the price date), and nothing is thrown away. The accountant's and sales manager's A520 boards have only two slots, so an upgrade there would mean replacing both modules, and those loads are not expected to grow.

### Question 2. The same four as pre-built machines: what does the company gain and lose?

shop.kz sells its own assembled machines ("WW-KZ"). Below are the closest matches, brought up to the hard requirements. Both product pages list the operating system as "Отсутствует", and the office model has only a 500 GB SSD.

| Role | Pre-built base (shop.kz, 2026-11-11) | Added to meet the requirements | Pre-built total, ₸ | My build, ₸ | Difference, ₸ |
|---|---|---|---|---|---|
| Accountant | Офисный WW-KZ i5-12400, 16 GB, 500 GB, keyboard+mouse: 343 090 | 1 TB SSD, Windows 11 Pro, monitor | 599 470 | 519 110 | +80 360 |
| Sales | same base: 343 090 | +16 GB, 1 TB SSD, Windows, monitor, webcam | 692 060 | 607 710 | +84 350 |
| Web developer | same base: 343 090 | +16 GB, 1 TB SSD, Windows, 27″ monitor | 706 460 | 676 710 | +29 750 |
| Designer | Игровой WW-KZ i5-14400, RTX 3050 6 GB, 32 GB DDR5, 1 TB + 512 GB: 771 590 | Windows, 27″ monitor, keyboard+mouse | 1 100 860 | 1 040 100 | +60 760 |
| **Total** | | | **3 098 850** | **2 843 630** | **+255 220** |

**What the company gains:** the machines arrive assembled and tested, one box per desk, one place to return a broken machine, and the shop has to find the faulty part. Nobody in the office has to build PCs.

**What it loses:**
- **Money:** 255 220 ₸, which puts the total **over the 3 000 000 budget**.
- **Parts:** the designer's pre-built has an RTX 3050 6 GB, not the RTX 5060 8 GB, and the office model needs a second SSD to reach 1 TB.
- **Warranty:** both pre-built pages give 12 months for the whole machine. Bought as parts, the warranties on shop.kz are 60 months for the SSD, 36 for the boards, the power supply and the 16 GB memory kit (99 for the 32 GB kit), and 24 for the 23.8″ monitor and the graphics card. Only the processors have 12.

For this office I would build the machines. A director who has nobody to assemble and support them could reasonably pay the extra 255 000 ₸ for pre-builts, but only after cutting the designer's monitor to fit the budget.

### Question 3. Who will complain about performance within a month, and about what?

**The designer, about video editing.** The designer's graphics card, the RTX 5060, has **8 GB** of video memory (product page: 8 GB GDDR7). That was the trade-off: the 16 GB RTX 5060 Ti costs 452 990 ₸ and did not fit. Photoshop and Figma fit in 8 GB, but the first time the designer edits a Full HD or 4K video with effects while Photoshop is still open, the preview will start to stutter and exports will take longer, and it will feel like "the most expensive computer is slow". The fix would be the 16 GB card (+163 000 ₸), which is more than the reserve, so it is a decision for Daniyar if video becomes a regular part of the job.

## 4. Evidence

- [`budget.csv`](budget.csv): every part with role, model, price in KZT, product-page link and date, plus subtotals per build and the total. The totals were checked by script.
- [`builds.md`](builds.md): load, bottleneck and trade-off for each machine, and a "why this one" line for every part, taken from its product page.
- [`evidence/price-check-2026-11-11.md`](evidence/price-check-2026-11-11.md): as text, what each product page showed on the price date (price, specs, warranty, sold-out parts).
- [`evidence/pcpartpicker-links.md`](evidence/pcpartpicker-links.md): why PCPartPicker cannot price for Kazakhstan, the compatibility checks done against the product pages, and the links for each build.
- [`evidence/vendor-quotes/`](evidence/vendor-quotes/): every shop.kz product page saved as PDF on the price date, as proof of the price and the date.

## 5. What I would do differently

I would take every price from the **product page from the start**, not from the catalogue list. My first draft used catalogue prices, and when I checked the product pages, several were different (the 32 GB DDR4 kit was 139 990 ₸ in the list but 146 990 ₸ on its page) and the graphics card I had chosen was sold out. That changed the total by 25 000 ₸ and forced a different card. I would also ask Daniyar what kind of designer he is hiring before choosing the graphics card. It is the most expensive single part, and question 3 shows it is exactly where the assumption could be wrong.
