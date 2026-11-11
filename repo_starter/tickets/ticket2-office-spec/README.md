# Ticket 2 — Office hardware specification

## 1. What was asked

> From: Daniyar K. (Director)
> Subject: computers for the new office
>
> We are opening the second office and need four computers — accountant, sales, web developer, designer. Budget 3,000,000 tenge for everything. Everyone says we should just buy the same four machines, is that right? Make sure they last a few years. Monitors included.

## 2. What was actually needed

**Where the request is wrong.** "Just buy the same four machines" is the wrong answer to the director's own question. The four jobs stress different parts: the accountant stresses nothing, the sales manager stresses memory, the developer stresses memory and CPU threads, and the designer stresses the graphics card and the screen. Four copies of a machine good enough for the designer cost **4 132 400 ₸**, 1.13 million over budget. Four copies of the accountant's machine fit the budget (2 071 240 ₸), but then the designer has no graphics card and two other people run out of memory. The right answer is four different machines on one shared base (same platform, case, SSD, keyboard set and Windows edition), so spares and support stay simple.

**What the request left out, and what I assumed instead:**

| Missing from the request | What I would ask Daniyar | What I assumed |
|---|---|---|
| What kind of designer | "Print and web graphics, or video and 3D?" | Graphic and web design with short video edits, so a mid-range RTX 5060, not a 16 GB card |
| Desktop or laptop | "Does sales visit clients?" | Desktops for everyone, because "monitors included" suggests fixed desks |
| Software licences | "Do you already have 1C, Microsoft Office and Adobe?" | Not in this budget. Only Windows is included. 1C, Office and Adobe are paid separately, and the director should know that before he calls 3 000 000 "everything" |
| Keyboards, mice, webcams, UPS | "Is anything coming from the first office?" | Nothing. A keyboard and mouse for everyone, a webcam for sales, a UPS for the accountant from the reserve |
| "A few years" | "How many years before you expect to replace them?" | Four years, so 32 GB where the load grows and a 4-slot board for the developer |
| What "budget for everything" includes | "Does it include delivery and setup?" | Prices include VAT (shop.kz states this). Delivery and the UPS are paid from the 181 270 ₸ reserve |

## 3. What I did

1. Wrote down each person's daily load and named the one part that load runs out of first (the bottleneck). The full reasoning is in [`builds.md`](builds.md).
2. Collected prices on **2026-11-11** from one vendor, **shop.kz**, which delivers across Kazakhstan. One vendor keeps prices comparable and means one order and one invoice. Many parts were sold out (Ryzen 5 7600, 8600G, i5-12400, several monitors), so the builds use what was in stock that day.
3. Found that memory decides the platform: 32 GB of DDR5 was 332 990 ₸ and 32 GB of DDR4 was 139 990 ₸. I chose AM4 with DDR4 for all four machines and wrote down what that costs in upgrade options.
4. Put every part into [`budget.csv`](budget.csv) with its model, price, link and date. I checked the totals with a script, not by hand.
5. Priced the same four as pre-built machines from the same shop (question 2 below).
6. Checked each build against the hard requirements: ≥16 GB memory, 1 TB SSD, licensed OS, monitor. All four pass.

**Result:** 2 818 730 ₸ for four complete workstations, 181 270 ₸ (6 %) left in reserve.

| Build | Memory | SSD | OS | Monitor | Total, ₸ |
|---|---|---|---|---|---|
| Accountant | 16 GB DDR4 | 1 TB | Windows 11 Pro | 23.8″ FHD | 517 810 |
| Sales manager | 32 GB DDR4 | 1 TB | Windows 11 Pro | 23.8″ FHD + webcam | 599 410 |
| Web developer | 32 GB DDR4 | 1 TB | Windows 11 Pro | 27″ QHD | 668 410 |
| Designer | 32 GB DDR4 + RTX 5060 | 1 TB | Windows 11 Pro | 27″ QHD, 125 % sRGB | 1 033 100 |

### Question 1. Which machine will I upgrade first, eighteen months from now, and why?

**The web developer's memory, from 32 GB to 64 GB.** His load grows fastest: every new project adds containers, and each Node, database or browser instance adds to the total. That is why his build has the B550 board with four memory slots: the upgrade is one more 2×16 GB kit in the empty slots (139 990 ₸ on the price date), with nothing thrown away. The accountant's and sales manager's boards have only two slots, so memory upgrades there would mean replacing both sticks, and those loads are not expected to grow.

### Question 2. The same four as pre-built machines: what does the company gain and lose?

shop.kz sells its own assembled machines ("WW-KZ"). The closest matches, brought up to the hard requirements (pre-builts come **without Windows**, and the office model has only a 500 GB SSD):

| Role | Pre-built base (shop.kz, 2026-11-11) | Added to meet the requirements | Pre-built total, ₸ | My build, ₸ | Difference, ₸ |
|---|---|---|---|---|---|
| Accountant | Офисный WW-KZ i5-12400, 16 GB, 500 GB, keyboard+mouse: 343 090 | 1 TB SSD, Windows 11 Pro, monitor | 599 470 | 517 810 | +81 660 |
| Sales | same base: 343 090 | +16 GB, 1 TB SSD, Windows, monitor, webcam | 692 060 | 599 410 | +92 650 |
| Web developer | same base: 343 090 | +16 GB, 1 TB SSD, Windows, 27″ monitor | 706 460 | 668 410 | +38 050 |
| Designer | Игровой WW-KZ i5-14400, RTX 3050 6 GB, 32 GB DDR5, 1.5 TB: 771 590 | Windows, 27″ monitor, keyboard+mouse | 1 100 860 | 1 033 100 | +67 760 |
| **Total** | | | **3 098 850** | **2 818 730** | **+280 120** |

**What the company gains:** the machines arrive assembled and tested, with one 12-month warranty per box and one place to return it. If something fails, the shop has to find the faulty part, not us. Nobody in the office has to build PCs.

**What it loses:** 280 120 ₸, which pushes the total **over the 3 000 000 budget**. It also gets worse parts for the money: the designer's pre-built has an RTX 3050 6 GB, not the RTX 5060, and the office model needs its 500 GB SSD supplemented. Its parts and power supply are not named in detail, so I cannot plan an upgrade. A 12-month box warranty is also shorter than the warranties on many of the individual parts.

For this office I would still build, but a director who has nobody to assemble and support the machines could reasonably pay the 280 000 for the pre-builts, after cutting the designer's monitor to fit the budget.

### Question 3. Who will complain about performance within a month, and about what?

**The designer, about saving and exporting large files.** Every machine has the same 1 TB Kingston NV3, the cheapest 1 TB that met the requirement. It is a DRAM-less drive: it writes fast only into a small cache, and once that fills during a long write (exporting a video, copying a project folder of tens of gigabytes, Photoshop's scratch disk on a big file) the speed drops sharply. The accountant and sales manager never write that much at once, so they will not notice. The designer will notice in the first week of real work, and it will look like "the expensive computer freezes when I save". The fix is a second SSD with a DRAM cache for the working files (~40–50 000 ₸ from the reserve).

## 4. Evidence

- [`budget.csv`](budget.csv): every part with role, model, price in KZT, link and date. Subtotals per build and the total, checked by script.
- [`builds.md`](builds.md): load, bottleneck and trade-off for each machine.
- [`evidence/pcpartpicker-links.md`](evidence/pcpartpicker-links.md): why PCPartPicker cannot price for Kazakhstan, and the per-build shop links and compatibility checks used instead.
- [`evidence/vendor-quotes/`](evidence/vendor-quotes/): the shop.kz product pages saved as PDF on the price date, one per part, as proof of the price and the date.
- [`evidence/price-check-2026-11-11.md`](evidence/price-check-2026-11-11.md): what each product page showed (price, in stock or sold out), as text.

## 5. What I would do differently

I would ask Daniyar what kind of designer he is hiring **before** choosing the graphics card. It is the single most expensive part (288 990 ₸), and I chose it on an assumption. I would also give the designer a DRAM-cache SSD from the start instead of the same cheap NV3 as everyone else: I made all four drives identical to keep things simple, and that is exactly the identical-machines mistake the director's question was about.
