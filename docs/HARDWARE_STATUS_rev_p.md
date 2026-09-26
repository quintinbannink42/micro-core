# Micro Core hardware status — rev p

**Superseded by rev q (2026-09-26).** Q1–Q7 are NCE4080K again, with SLM27524CA-DG gate drivers on `/V12_RAW`. See `docs/HARDWARE_STATUS_rev_q.md`.

**Date:** 2026-09-25  
**Repo:** `quintinbannink42/micro-core`  
**KiCad basename:** `microcore` (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`)  
**BOARD_REVISION:** **p** (fab-affecting: Q1–Q7 FET swap to AOD4184A; LS flyback + TVS; frame short fixes)  
**Create Board artifacts:** `boards/microcore-o/` is on main from rev o. **`boards/microcore-p/` after this rev is merged to `main`** (Create Board on a PR branch may run but fab files land on `main` only).

## Verdict

**Not production-ready. Do not order boards.** Quintin chose **AOD4184A** (LCSC **C99124**) and TVS on the low-side channels for budget and reliability. Rev p puts that FET on all seven DPAK lands, adds the existing cheap injector clamps to Q5–Q7, and clears the real injector / VR shorts on frame copper. Hellen module noise is still there and is listed below.

`microcore.kicad_pcb` stays substantial (F.Cu+B.Cu GND zones refilled after the diode routes and two GND stitch vias). Drill origin unchanged: Edge.Cuts bottom-left `(107.5, 148.0872)`. Core EFI silkscreen kept; letter bumped to **rev P**.

## What landed (rev p)

### 1. Power FET: NCE4080K → AOD4184A

All seven frame power FETs (Q1–Q7) are **AOD4184A**, LCSC **C99124**. Same footprint: `microcore-fp:DPAK` (TO-252 land, not redrawn). Pinout stays pin 1 gate, pin 2 drain tab, pin 3 source. Quintin picked this part for budget and reliability.

`bom_replace_microcore-p.csv` rows (ASCII comments, no ohm symbol):

`Q1`…`Q7,"AOD4184A","DPAK","C99124"`

`U105` stays `STM32F407VGT6` / `LQFP100` / `C12345` on `mega-mcu100/0.3`. Not switched to mega-mcu64.

### 2. 3.3 V gate caveat

AOD4184A is a discrete MOSFET, not a protected smart FET. No gate driver was added.

- RDS(on) max **9.5 mohm at Vgs = 4.5 V**, ID = 15 A. Not specified at 3.3 V.
- VGS(th) max **2.6 V**, so a 3.3 V MCU pin does turn the FET on.
- RDS(on) at 3.3 V is not guaranteed, especially hot and at injector or fuel-pump current.

Each gate is still the existing 12 ohm resistor (R1–R7) from the mega-mcu100 output.

### 3. Low-side flyback + TVS (Q5–Q7)

Same cheap injector-class parts already on the board. No premium clamps. No series ballast on the LS channels. Proven clamps, not extra copper protection.

| Ref | Channel | AMPSEAL | Flyback | TVS |
|---|---|---|---|---|
| Q5 | Fuel pump | pin 8 `LS1_FP` | D9 US1M C112545 | D12 SMAJ33A C143131 |
| Q6 | Idle / VVT | pin 9 `LS2_IDLE` | D10 US1M C112545 | D13 SMAJ33A C143131 |
| Q7 | Boost / spare | pin 10 `LS3_BOOST` | D11 US1M C112545 | D14 SMAJ33A C143131 |

Electrical match to Q1–Q4: flyback anode on the LS net, cathode on `/V12_RAW`; TVS cathode on the LS net, anode on GND. Parts are DO-214AC on B.Cu, north of J1. D11 is shifted to x = 152.75 so its +12 pad clears the `/VR_OUT` via at `(153.5, 111.9)`.

Two GND stitch vias, `(115.5, 105.8)` and `(144.0, 114.6)`, tie the back-side pour pockets under D12 and D13 into the front GND pour. After refill those pockets are not unconnected items.

Injector protection is unchanged: D1–D4 US1M, D5–D8 SMAJ33A, ballast R8–R11.

### 4. Frame copper shorts that this pass cleared

KiCad DRC no longer reports these rev o shorts:

- `/INJ3` on In1 jogged off `/VR_OUT` (1.0 mm track at x = 175.6; a wider jog shorted `/SGND`).
- `Net-(Q1-D)` and `Net-(Q3-D)` orthogonal segments that hit `/VR_N` removed; the drain diagonals stay.
- R9 moved to `(188, 90)` and the `/INJ2` via moved onto the new pad so `Net-(Q4-D)` no longer shorts `Net-(Q2-D)`. The Q4/R9 solder-mask bridge and the 0.05 mm clearance are gone.

## DRC summary (kicad-cli **10.0.6**)

Command: `kicad-cli pcb drc --format json --severity-all --units mm --refill-zones --save-board`

`schematic_parity` is empty (sheet and board agree). Zones were refilled after the track retarget and the stitch vias.

| Category | Count | Triage |
|---|---:|---|
| **Total violations** | **473** | 207 error / 266 warning (rev o was 467: 217 error / 250 warning) |
| items_not_allowed | 199 | Hellen module keepout (M1/M2/M3) — unchanged |
| padstack | 159 | Hellen merge noise — unchanged |
| silk_over_copper | 81 | Was 65. The extra marks are D9–D14 back silk. Not chased |
| silk_overlap | 20 | Cosmetic / module — unchanged |
| **shorting_items** | **4** | Was 10. All four left are Hellen pad G vs an empty-net pad. No injector, no `/LS*`, no new diode short |
| clearance | 2 | Both M3 pad E4 `/V5_REF` vs empty pad G. Q4/R9 clearance is gone (rev o had 5) |
| lib_footprint_issues | 5 | Vendored / Hellen |
| solder_mask_bridge | 1 | M3 pad G vs E4 only (rev o had 2; Q4/R9 bridge is gone) |
| copper_edge_clearance | 1 | M3 pad G on In2 touches Edge.Cuts |
| holes_co_located | 1 | Duplicate via leftover (Hellen) |
| **unconnected_items** | **2** | Same class as rev o: M2 pad S1 keepout vs F.Cu GND, and one F.Cu GND island. Not Q1–Q7, not D9–D14, not J1 pins 8/9/10 |
| tracks_crossing | **0** | |
| track_dangling | **0** | |
| starved_thermal | **0** | |
| courtyards_overlap | **0** | |

### Hellen noise still present (do not edit M1/M2/M3 for these)

- `/VR_OUT` F.Cu `(184.15, 83.622)`–`(186, 81.772)` vs M3 pad G `<no net>` `(186.175, 82.265)`.
- M3 pad G GND `(178.725, 75.84)` vs empty pad G `(185.925, 72.64)`.
- M1 pad G GND `(133.28119, 76.67602)` vs empty pads `(133.28119, 79.72601)` and `(137.18119, 74.12602)`.
- Clearance 0 mm: M3 PTH E4 `/V5_REF` `(193.425, 73.04)` vs empty pad G on B.Cu and In1 `(186.025, 72.7775)`. Same pair is the remaining solder-mask bridge.
- Copper edge: M3 pad G on In2 `(185.7875, 72.74)` touches Edge.Cuts.
- Unconnected: M2 pad S1 `(109.850001, 87.15)` vs F.Cu GND inside the keepout, plus one F.Cu GND island.
- items_not_allowed 199, padstack 159, lib_footprint_issues 5, holes_co_located 1.

**Not a fab order.** Create Board `boards/microcore-p/` is still required after merge. The 3.3 V gate vs 4.5 V RDS(on) caveat is still open; this rev does not add a gate driver.

## Create Board / fab path

Workflow: `.github/workflows/create-board.yaml`

1. `on: push` and `workflow_dispatch`
2. Job `guard-pcb-not-empty` runs `bin/check-pcb-not-empty.sh microcore.kicad_pcb`
3. Reuses `andreika-git/hellen-one/.github/workflows/create-board.yaml@master`, which applies `bom_replace_microcore-p.csv`

**Exact next step for CI artifacts:** merge this branch to default **`main`**. Fab files are committed by that reusable workflow **on `main` only**.

## Leftovers — before ordering boards

1. Green Create Board `boards/microcore-p/` and confirm the JLC BOM shows `AOD4184A` / `C99124` on Q1–Q7, `STM32F407VGT6` / `C12345` on `U105`, D9–D11 US1M, and D12–D14 SMAJ33A.
2. The 3.3 V gate does not have an RDS(on) spec. The datasheet number is at 4.5 V. A driver is not on this rev.
3. Residual Hellen keepout / padstack / module pad G / edge noise listed above.
4. Firmware `coreefi_micro` F407 target in the sibling tree (not this PR). This repo does not publish firmware.

## Incident guard

Do not whole-file-replace `microcore.kicad_pcb`. Guard: `bin/check-pcb-not-empty.sh` (min 10 kB + `(zone` present). Drill origin must stay Edge.Cuts bottom-left `(107.5, 148.0872)`.
