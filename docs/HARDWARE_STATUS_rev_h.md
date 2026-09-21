# Micro Core hardware status — rev h → i

**Date:** 2026-09-21 (UTC+2)  
**Repo:** `quintinbannink42/micro-core` @ `main`  
**KiCad basename:** `microcore` (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`)  
**BOARD_REVISION:** **i** (PCB content change this pass: J8 GND stitch). Rev **h** was restore + Edge.Cuts origin `(107.5, 148.0872)`.  
**Create Board artifacts:** last green `boards/microcore-h/`; `boards/microcore-i/` expected from CI after this push.

## Verdict

**Not fab-ready.** J8 GND stitch and FET/gate LCSC assigns landed; injector/LS flyback+TVS (+ second 12 Ω high-Z) still missing from schematic/PCB; remaining DRC noise is mostly Hellen keepout / empty-net module-pad merge.

## DRC summary (kicad-cli **10.0.6**)

Command: `kicad-cli pcb drc --format report --severity-all --output … microcore.kicad_pcb`  
(Board is KiCad 10 format; Debian kicad 9.0.2 cannot load it.)

### vs prior status (rev g doc, KiCad 9.0.2 on pre-merge style counts)

| Category | Rev g (K9 doc) | Rev i after J8 stitch (K10) | Notes |
|---|---:|---:|---|
| Total DRC violations | (large; mixed cats) | **425** | Different checker/taxonomy under K10 |
| shorting_items | **147** | **4** | No mass GND↔SGND pairs under K10; remaining = empty-net module pad G vs signal/GND |
| unconnected_items | **2** (zone island + **J8 GND**) | **1** | **J8 cleared**; leftover = F.Cu GND zone ↔ M2 pad S1 inside module keepout (copperpour/tracks not_allowed) — treat as Hellen-merge false positive unless copper review says otherwise |
| padstack | 159 | 159 | Unchanged Hellen merge noise |
| items_not_allowed | (n/a in g doc) | 199 | Keepout / local override tracks in module keepouts |
| silk_* | ~51 | 43 | Cosmetic |
| clearance | 28 | 12 | Improved vs g doc |

Top shorting leftovers (4): `/VR_OUT`↔empty M3 pad G; GND↔empty M1/M3 pad G. **Not** GND↔`/SGND` pairs in this K10 report.

## Must-list vs `docs/SPEC.md` (Boss brief)

| # | Item | Status after this pass |
|---|---|---|
| 1 | GND↔SGND shorts / AMPSEAL fanout | **Mostly cleared under K10 DRC** (0 GND↔SGND short pairs). Residual empty-net module-pad shorts + AMPSEAL fanout still need human copper eye before claiming clean. |
| 2 | J8 GND ↔ zone connectivity | **Fixed on PCB (rev i):** GND via @ `(114.9, 79.5)` + F.Cu tracks from J8 pads 5/6 (L-path on pad 6L to clear VBUS). J8 no longer in unconnected set. |
| 3 | SMBJ33A + UF flyback (+ 2×12 Ω) on INJ4/LS3 + bom_replace/LCSC | **BLOCKER — not fab-ready.** Sheets still text-only “flyback/TVS TBD”. Only **1×12 Ω gate** per channel on sch/PCB (`R1–R7`). No DO-214/SMA in `footprints/`; FET cluster packed. Do **not** fake parts. Needs layout pass (or SPEC change). |
| 4 | ANALOG + HALL conditioning | **Waived** — mega-module-only input lite written into `docs/SPEC.md` + this status. Frame stubs stay passthrough. |
| 5 | Q1–Q7 + gate Rs on JLC BOM with LCSC | **Assigned in `bom_replace_microcore-i.csv`:** Q=C155647 (VND14NV04-E), R=C22783 (12 Ω 0603). Lands on JLC BOM at next Create Board. |
| 6 | Create Board after PCB change; bump revision | **BOARD_REVISION=i**; Create Board on push will refresh artifacts. |

## Inventory

| Area | Present |
|---|---|
| Last green board package | `boards/microcore-h/` gerber/BOM/CPL/ibom/png/pdf |
| Pending | `boards/microcore-i/` after CI |
| Frame FETs Q1–Q7 + R1–R7 | On sch+PCB; LCSC via bom_replace (i) |
| Flyback/TVS | **Absent** |

## Leftovers — **fab-ready** (must) — for Boss

1. **Add SMBJ33A + UF flyback per INJ/LS channel** (and second 12 Ω high-Z where SPEC requires) to schematic **and** PCB, with LCSC / `bom_replace` — or explicitly revise SPEC. **True layout blocker** (space + footprints).  
2. Human copper pass on residual **empty-net module pad G** shorts / AMPSEAL fanout (and confirm M2 S1 keepout unconnected is acceptable).  
3. Confirm Create Board **`boards/microcore-i/`** green with Q1–Q7/R1–R7 on JLC BOM.

## Leftovers — nice-to-have

1. LCSC duplicate-partnumber warnings (100n / BAT54S).  
2. Silk cleanup.  
3. Title-block still says rev C in places.  
4. Diff-pair VR_P/VR_N noise.

## Quick safe fixes done this pass

- KiCad 10 DRC on current PCB; compared to rev-g status counts.  
- J8 GND via+track stitch (rev **i**).  
- `bom_replace_microcore-i.csv` LCSC for Q1–Q7 + R1–R7.  
- ANALOG/HALL mega-module-only waiver in SPEC.  
- README → microcore-h (last green) / microcore-i (pending CI); this status doc.  
- Kept incident note below.

**PCB content changed** → revision **i**.

## Incident: empty PCB on main (ce63db4)

Commit `ce63db4` (“Fix drill origin…”) **wiped** `microcore.kicad_pcb` to ~49 bytes (16063 lines → 1). Cause: an edit that replaced the whole file instead of only changing `aux_axis_origin` / `grid_origin`. Restored from `298ebd5` (rev h content) and set drill/place origin to Edge.Cuts bottom-left `(107.5, 148.0872)` (Hellen practice: Y grows downward → bottom-left = `(min_x, max_y)`). Guard: `bin/check-pcb-not-empty.sh` + Create Board job `guard-pcb-not-empty`.
