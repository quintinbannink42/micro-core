> **Superseded for current work:** see [HARDWARE_STATUS_rev_h.md](HARDWARE_STATUS_rev_h.md) (rev h→i, 2026-09-21).

# Micro Core hardware status — rev g

**Date:** 2026-09-16 (Africa/Johannesburg)  
**Repo:** `quintinbannink42/micro-core` @ `main`  
**KiCad basename:** `microcore` (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`, `BOARD_REVISION=g`)  
**Create Board artifacts:** `boards/microcore-g/` (CI green on rev-g GND pours commit)

## Verdict

**Not fab-ready yet.** Create Board / gerber/BOM/CPL/preview package exists and CI succeeded, but injector/LS power-stage protection parts and analog/Hall conditioning are still stubs, and KiCad DRC reports real connectivity concerns that need a design pass (or confirmed Hellen-merge false positives) before ordering.

## Inventory (`boards/microcore-g/`)

| Area | Present |
|---|---|
| Board gerbers | Yes — `board/gerber/microcore-g.*` (GTL/GBL/G1/G2/mask/silk/paste/outline/drill) |
| JLC BOM + CPL | Yes — `microcore-g-BOM-JLC.csv`, `microcore-g-CPL.csv` |
| Previews / iBOM / schematic PDF | Yes — `microcore-g.png`, `misc/*-top/bottom/outline/components.png`, `ibom.html`, schematic PDF |
| Frame package | Yes — `frame/core.*` gerbers + BOM/CPL/schematic/VRML |
| Warnings log | Yes — LCSC duplicate-partnumber warnings only |

Root `gerber/` also holds a parallel export set (F/B/In Cu, masks, drill, net, pdf, wrl).

## DRC summary (kicad-cli 9.0.2)

Command: `kicad-cli pcb drc --format report --severity-all --output … microcore.kicad_pcb`

| Category | Count | Notes |
|---|---:|---|
| padstack | 159 | Typical Hellen multi-module merge noise |
| solder_mask_bridge | 154 | Merge noise / module pads |
| **shorting_items** | **147** | **Must triage** — see below |
| holes_co_located | 118 | Module stitch / stacked holes |
| tracks_crossing | 69 | Correlates with shorts |
| silk_* | ~51 | Cosmetic |
| clearance | 28 | Includes module pad G (no-net) interactions |
| unconnected_items | 2 | Zone island + **J8 GND ↔ F.Cu GND zone** |
| starved_thermal | 1 | Thermal relief |
| other | few | lib mismatch, edge clearance, diff-pair VR_P/VR_N |

Top shorting net-pairs (unique pairs ~93):

- **GND ↔ /SGND (16 reports)** — schematic nets are separate (`net 50` GND vs `net 34` `/SGND`); DRC claims copper shorts. Confirm whether frame tracks/vias truly bridge sensor ground to power ground.
- Empty-net module pads (`M1`/`M2`/`M3` pad G / N11) interacting with signal tracks — common Create Board artifact; still needs human review.
- Multiple I/O crossings near AMPSEAL fanout (LS/INJ/IGN/CAN/DIN/AN).

**Limitation:** DRC was run on the pre-merge `microcore.kicad_pcb` frame+modules file with KiCad 9 against Hellen tooling that historically targets KiCad 6. Treat absolute counts as upper bound; still, GND↔SGND and J8 unconnected are concrete leftovers called out by Boss brief.

## Keepout / zones / SGND

| Check | Result |
|---|---|
| AMPSEAL `J1` TE_776231 @ (45, 51) | Courtyard ~±38.5 × ±16.0 mm → body south edge ~y=35 |
| Q5/Q6 @ y=29, Q7 @ (24,26) | Clear of AMPSEAL courtyard (south of body); matches rev-f/g keepout work |
| F.Cu + B.Cu GND zones | Present, filled, thermal_gap 0.25 / thermal_bridge 0.3 (board outline 0.4–89.6 × 0.4–59.6) |
| SGND vs GND (schematic nets) | Distinct nets; **DRC reports copper shorts** — do **not** treat as clean until cleared |
| J8 USB Mini-B GND | Pad 6 GND flagged unconnected to F.Cu GND zone (zone-island / pour connectivity) |

## BOM health vs `docs/SPEC.md`

| SPEC item | Status |
|---|---|
| USB Mini-B vertical (`J8`, C13453) | Present |
| SW_BOOT / SW_RESET (C115357 BTN) | Present (also mega S100/S101) |
| Hellen modules mega-mcu100 + power_12and5V + vr-max9924 | Present in BOM (MCU, LMR14020 rail, MAX9924, etc.) |
| 4× DPAK N-FET inj + 3× LS (`Q1–Q7`, VND14NV04-E) | In misc BOM **without LCSC**; **absent from JLC BOM** |
| Gate 12 Ω (`R1–R4` etc.) | Present on INJ4/LS3 sheets; empty LCSC |
| **SMBJ33A TVS + UF flyback per channel** | **Missing** — INJ4/LS3 text still says “flyback/TVS TBD next pass” |
| ANALOG conditioning (TPS/MAP/CLT/IAT/AN) | **Stub sheet** — hierarchy labels only, no dividers/filters/ESD |
| HALL conditioning | **Stub sheet** — passthrough; “Pull-ups / dividers / ESD TBD” |
| LCSC dup warnings | Known: 100n C0402 C307331 vs C1525; BAT54S C408389 vs C47546 |

## CI / artifact health

- Latest Create Board on `main` for “Rev g: add F.Cu and B.Cu GND copper pours”: **success** (~6m37s).
- Artifacts under `boards/microcore-g/` match expected Hellen layout (board/ + frame/).
- README previously pointed at stale `boards/microcore-e/` and “spec freeze” — corrected in docs pass (this commit).

## Leftovers — **fab-ready** (must)

1. Resolve or waive **GND ↔ SGND** DRC shorts (and other AMPSEAL fanout shorts) with a real copper review; refill zones after edits.
2. Fix **J8 GND ↔ zone** unconnected / island so USB shield/GND ties to pour intentionally.
3. Add **SMBJ33A + UF flyback** (and 2×12 Ω high-Z where still incomplete) on INJ4 + LS3; assign LCSC / `bom_replace`.
4. Populate **ANALOG** and **HALL** conditioning (or explicitly accept mega-module-only input lite and delete stubs from critical path).
5. Get **Q1–Q7 + gate Rs** onto JLC BOM with valid LCSC (or document hand-stuff / alternate house).
6. Re-run Create Board after PCB content changes; bump `BOARD_REVISION` only when PCB content changes.

## Leftovers — nice-to-have

1. Silence LCSC duplicate-partnumber warnings (align 100n / BAT54S comments).
2. Silk cleanup (SW_BOOT/J8/Q ref overlaps).
3. Update schematic title-block comments still saying “rev E”.
4. Diff-pair rules for VR_P/VR_N (or disable bogus diff-pair check).
5. Starved thermal cleanup after zone refill.

## Quick safe fixes done this pass

- Committed Boss-canonical `MICROCORE_BRIEF.md`.
- README status + artifact path → rev **g** / `boards/microcore-g/`.
- This status document.

**No PCB content change** → revision stays **g**.

## Incident: empty PCB on main (ce63db4)

Commit `ce63db4` (“Fix drill origin…”) **wiped** `microcore.kicad_pcb` to ~49 bytes (16063 lines → 1). Cause: an edit that replaced the whole file instead of only changing `aux_axis_origin` / `grid_origin`. Restored from `298ebd5` (rev h content) and set drill/place origin to Edge.Cuts bottom-left `(107.5, 148.0872)` (Hellen practice: Y grows downward → bottom-left = `(min_x, max_y)`). Guard: `bin/check-pcb-not-empty.sh` + Create Board job `guard-pcb-not-empty`.
