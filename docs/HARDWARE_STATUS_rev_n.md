# Micro Core hardware status — rev n

**Date:** 2026-09-22  
**Repo:** `quintinbannink42/micro-core`  
**KiCad basename:** `microcore` (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`)  
**BOARD_REVISION:** **n** (fab-affecting: F407 BOM swap on mega-mcu100; remove LS FET stage)  
**Create Board artifacts:** last packages on main include `boards/microcore-m/`. **`boards/microcore-n/` after this rev is merged to `main`** (Create Board on a PR branch may run but fab files land on `main` only).

## Verdict

**Not production-ready.** Cost-down rev n keeps Hellen `mega-mcu100/0.3` and swaps the module MCU from STM32F429VIT6 to STM32F407VGT6. The frame low-side FET stage is removed. Do not order boards until Create Board produces `boards/microcore-n/` and a human reviews the JLC BOM line for `U105`.

`microcore.kicad_pcb` stays substantial (filled F.Cu+B.Cu GND zones still present). Drill origin unchanged: Edge.Cuts bottom-left `(107.5, 148.0872)`. Core EFI silkscreen kept; letter bumped to **rev N**.

## What landed (rev n)

### 1. MCU: F429 → F407, same mega-mcu100

Module symbol stays `Module:mega-mcu100/0.3` / footprint `hellen-one-mega-mcu100-0.3:mega-mcu100`. Not switched to mega-mcu64.

`bom_replace_microcore-n.csv` row:

`U105,"STM32F407VGT6","LQFP100","C12345"`

Replaces `STM32F429VIT6` / LCSC `C92002` (the `U105` line in `boards/microcore-m/board/microcore-m-BOM-JLC.csv`).

LCSC check (2026-09-22):

| ID | What LCSC/JLCPCB actually lists | Used? |
|---|---|---|
| **C12345** | ST **STM32F407VGT6**, LQFP-100(14x14), 1 MB flash, in stock (LCSC showed 1601) | **Yes** |
| C15815 | TI TLC2252CDR op-amp, SOP-8 | No |
| C2252 | YXC 22.1184 MHz crystal, HC-49S-SMD | No |

Firmware board name remains `coreefi_micro`. Sibling tree `/workspace/fw-coreefi-micro` will need an F407 target later. This hardware repo does not add a firmware remote.

### 2. Four injector FETs only

Kept: Q1–Q4, gate R1–R4, ballast R8–R11, flyback D1–D4 (US1M), TVS D5–D8 (SMAJ33A).

Removed from schematic (`LS3.kicad_sch` is now a stub, root sheet `LS3-NC` has no pins) and from the PCB (footprints, tracks, vias, ref silk):

| Was | Role | Gate resistor |
|---|---|---|
| Q5 | Fuel-pump LS | R5 |
| Q6 | Idle / VVT LS | R6 |
| Q7 | Boost / spare LS | R7 |

Copper deleted with those parts (no remaining segments or vias):

- `/LS1_FP`, `/LS2_IDLE`, `/LS3_BOOST` (drains to AMPSEAL)
- `Net-(Q5-IN)`, `Net-(Q6-IN)`, `Net-(Q7-IN)` (gate side of R5–R7)
- `/OUT_LS1`, `/OUT_LS2`, `/OUT_LS3` tracks and vias

mega-mcu100 pads E18/E19/E20 still carry nets `/OUT_LS1` `/OUT_LS2` `/OUT_LS3` (module pins OUT_PWM1/2/3). Those pads are the module footprint, not traces to the removed FETs. J1 pads 8/9/10 have the LS nets cleared (connector pin copper only, no tracks).

No explicit GND track ended on the Q5–Q7 source pads (sources were on the GND pour). Diode GND stubs at x=195.1 (rev m) were left in place.

`bom_replace_microcore-n.csv` drops the Q5–Q7 and R5–R7 rows. Comments are ASCII-only.

### 3. AMPSEAL pins 8/9/10

| Pin | rev m | rev n |
|---|---|---|
| 8 | Fuel pump LS | Reserved / NC (unstuffed LS — future option) |
| 9 | Idle / VVT LS | Reserved / NC (unstuffed LS — future option) |
| 10 | Boost / spare LS | Reserved / NC (unstuffed LS — future option) |

Schematic: local labels `LS1_FP` / `LS2_IDLE` / `LS3_BOOST` removed from J1; `no_connect` on those pins.

## DRC

Local `kicad-cli` 10 was not installed in this environment when the copper edit landed. Create Board on `main` is still the fab check. Known rev-m DRC (Hellen keepout / padstack, In1 `/INJ3`↔`/VR_OUT`) is unchanged by this pass except where LS copper was deleted.

Zone fill was **not** refilled here (needs `kicad-cli pcb drc --refill-zones` or `pcb export` refill). F.Cu and B.Cu GND zone outlines are unchanged, so the previous fill can still show thermal-relief voids where Q5–Q7 pads used to sit. That is pour geometry, not a track to a missing FET. Refill on the next KiCad 10 pass will close those voids.

## Create Board / fab path

Workflow: `.github/workflows/create-board.yaml`

1. `on: push` and `workflow_dispatch`
2. Job `guard-pcb-not-empty` runs `bin/check-pcb-not-empty.sh microcore.kicad_pcb`
3. Reuses `andreika-git/hellen-one/.github/workflows/create-board.yaml@master`, which applies `bom_replace_microcore-n.csv`

**Exact next step for CI artifacts:** merge this branch to default **`main`**. Fab files are committed by that reusable workflow **on `main` only**.

## Leftovers — before ordering boards

1. Green Create Board `boards/microcore-n/` and confirm JLC BOM shows `STM32F407VGT6` / `C12345` on `U105`, and that Q5–Q7 / R5–R7 are absent.
2. KiCad 10 zone refill + DRC after the LS deletion (thermal voids in the old FET courtyards).
3. Residual Hellen keepout / padstack noise and the preexisting In1 `/INJ3`↔`/VR_OUT` short (rev m leftover).
4. Firmware `coreefi_micro` F407 target in the sibling tree (not this PR).

## Incident guard

Do not whole-file-replace `microcore.kicad_pcb`. Guard: `bin/check-pcb-not-empty.sh` (min 10 kB + `(zone` present). Drill origin must stay Edge.Cuts bottom-left `(107.5, 148.0872)`.
