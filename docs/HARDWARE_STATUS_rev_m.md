# Micro Core hardware status — rev m

**Date:** 2026-09-21  
**Repo:** `quintinbannink42/micro-core`  
**KiCad basename:** `microcore` (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`)  
**BOARD_REVISION:** **m** (fab-affecting: re-route D1–D8 collectors; refill F.Cu+B.Cu GND pours)  
**Create Board artifacts:** last packages on main include `boards/microcore-j/`. **`boards/microcore-m/` after this rev is merged to `main`** (Create Board on a PR branch may run but fab files land on `main` only).

## Verdict

**Not production-ready.** The rev-k B.Cu diode-collector shorts and unconnected SMA pads are closed. Do not order boards until Create Board produces `boards/microcore-m/` and a human reviews remaining Hellen-merge DRC (keepout / padstack / leftover In1 `/INJ3`↔`/VR_OUT`).

`microcore.kicad_pcb` remains substantial (~686 kB, filled F.Cu+B.Cu GND zones). Drill origin unchanged: Edge.Cuts bottom-left `(107.5, 148.0872)`. D1–D8 stay on **B.Cu** beside J1, outside the AMPSEAL silk/body keepout.

## What landed (rev m)

### 1. D1–D8 collectors (human copper pass)

Rev-k 0.5 mm B.Cu east–west spines at y≈121.65–124.05 (through AMPSEAL fanout) and 1.5 mm stubs on the wrong SMA pad (B.Cu X-mirror) are **deleted**.

Replacement (B.Cu pad stubs + F–B vias at diode bodies; buses south of J1 where all layers were empty):

| Net | West / east | Around J1 | Join |
|---|---|---|---|
| `/V12_RAW` | B.Cu spine x=108.40 on **true cathode Y** 120.05/126.65/133.25/139.85 | — | existing via `(109.3, 124.9)` |
| GND (D5–D8) | B.Cu stubs x=194→195.10 on anode Y | — | B.Cu GND pour |
| `/INJ1` | vias `(110.7, 118)` / `(194, 118)` | In1 south y=146.55; In2 at y=118 | via `(166.0, 112.3)` |
| `/INJ2` | vias `(110.7, 123.15)` / `(194, 124.6)` | In1 south y=147.25; B.Cu y=114.9 | existing B.Cu 1.5 mm `(165.3, 114.9)` |
| `/INJ3` | vias `(110.7, 131.2)` / `(194, 131.2)` | In2 south y=146.55, peel x=191.50 | existing In2 1.5 mm `(162.0, 122.7)` |
| `/INJ4` | vias `(110.7, 137.8)` / `(194, 137.8)` | In2 south y=147.25, peel x=196.40; westbound y=120.80 | via `(162.8, 112.3)` |

INJ pad Y after B.Cu X-mirror: 115.95 / 122.55 / 129.15 / 135.75. Two nets per inner layer on the south strip so buses stay parallel and do not T-cross. D1–D4 remain x=110.7 rot 90; D5–D8 x=194 rot −90.

F.Cu+B.Cu GND zones refilled after the copper edit (`kicad-cli --refill-zones --save-board`).

### 2. Silkscreen / title (ASCII, preserved from rev l with letter bump)

Primary **F.SilkS** at `x=168.8`, `y=74.5–80.6`; **B.SilkS** at `x=173.1`. Strings: `Core EFI`, `Micro Core`, `coreefi.co.za`, `microcore`, `coreefi_micro`, **`rev M`**. Title block rev **M**.

## DRC summary (kicad-cli **10.0.6**)

Command: `kicad-cli pcb drc --format json --severity-all --units mm --refill-zones --save-board`

| Category | Count | Triage |
|---|---:|---|
| **Total violations** | **469** | 219 error / 250 warning |
| items_not_allowed | 199 | Hellen module keepout (M1/M2/M3) — merge noise |
| padstack | 159 | Hellen merge noise |
| silk_over_copper | 65 | Mostly module silk; diode silk vs copper |
| silk_overlap | 20 | Cosmetic / module |
| **shorting_items** | **12** | **0 new diode-collector shorts** — see below |
| clearance | 5 | FET cluster / merge; not D1–D8 collectors |
| lib_footprint_issues | 5 | Vendored / Hellen |
| solder_mask_bridge | 2 | Q4/R9 front; M3 pad G / `/V5_REF` rear — not diodes |
| copper_edge_clearance | 1 | Edge |
| holes_co_located | 1 | Duplicate `/INJ1` via @ `(174.2, 90.35)` (Hellen leftover) |
| **unconnected_items** | **2** | M2 S1 keepout; F.Cu GND island. **0 diode pads** |
| GND ↔ `/SGND` shorts | **0** | Pour did not bridge sensor ground |
| tracks_crossing | **0** | Was 7 on rev l |
| via_dangling | **0** | Was 4 east INJ vias on rev l |

### Shorts — real vs Hellen noise

**Closed this pass (rev-k collectors):**

- SMA pads vs same-x 1.5 mm stubs: `/INJn`↔`/V12_RAW` (D1–D4), `/INJn`↔GND (D5–D8).
- B.Cu INJ collectors vs AMPSEAL fanout vias: `/INJ3`↔`/HALL_CAM`/`/IGN2`, `/INJ4`↔`/IGN4`/`/IAT`, `/INJ1`↔`/DIN2`, `/INJ2`↔`/INJ3`.
- Diode pad unconnected / solder-mask bridge on D1–D8 / dangling east INJ vias.

**Still present (not introduced by this pass):**

- `/INJ3`↔`/VR_OUT` on **In1** near `(174.2, 98.4)` / `(174.3, 104.0)` — Hellen leftover 1.5 mm fanout vs VR. Out of this B.Cu diode pass.
- GND or `/VR_OUT` vs empty M1/M3 pad G; `/VR_N` vs Q1/Q3 drain tracks; Q4 pad vs R9 pad.

**Keepout unconnected:** F.Cu GND zone ↔ M2 pad S1 (copperpour not allowed in module keepout). One F.Cu GND island remains (`island_removal_mode 0`).

## Create Board / fab path

Workflow: `.github/workflows/create-board.yaml`

1. `on: push` and `workflow_dispatch`
2. Job `guard-pcb-not-empty` runs `bin/check-pcb-not-empty.sh microcore.kicad_pcb`
3. Reuses `andreika-git/hellen-one/.github/workflows/create-board.yaml@master`

**Exact next step for CI artifacts:** merge this branch to default **`main`**. Fab files are committed by that reusable workflow **on `main` only**.

`bom_replace_microcore-m.csv` is named for `BOARD_PREFIX`+`BOARD_SUFFIX`+`BOARD_REVISION` = `microcore-m`. ASCII-only comments (no ohm-symbol). LCSC rows unchanged from rev k/j.

## Leftovers — before ordering boards

1. Green Create Board `boards/microcore-m/` (CPL/JLC BOM with diodes on bottom).
2. Residual Hellen keepout / padstack / empty-net pad G noise (waive as merge artifact, or clean if copper review wants it).
3. Preexisting In1 `/INJ3`↔`/VR_OUT` near the VR module (not part of the D1–D8 alley).
4. LS channels still lack flyback/TVS (SPEC was injector-focused; not closed this pass).
5. ANALOG/HALL frame stubs remain mega-module-only (already waived in SPEC).

## Incident guard

Do not whole-file-replace `microcore.kicad_pcb`. Guard: `bin/check-pcb-not-empty.sh` (min 10 kB + `(zone` present). Drill origin must stay Edge.Cuts bottom-left `(107.5, 148.0872)`.
