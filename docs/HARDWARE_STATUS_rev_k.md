> **Superseded for current work:** see [HARDWARE_STATUS_rev_l.md](HARDWARE_STATUS_rev_l.md) (rev l: GND pour refill + Core EFI silk).

# Micro Core hardware status — rev k

**Date:** 2026-09-21  
**Repo:** `quintinbannink42/micro-core`  
**KiCad basename:** `microcore` (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`)  
**BOARD_REVISION:** **k** (fab-affecting: D1–D8 flipped to B.Cu beside J1; frame SW_BOOT/SW_RESET removed)  
**Create Board artifacts:** last packages on main include `boards/microcore-j/`. **`boards/microcore-k/` after this rev is merged to `main`** (or Create Board on `main`). A PR-branch push may *run* Create Board but fab files land on `main` only.

## Verdict

Injector protection diodes are on the **bottom copper** next to the AMPSEAL, outside the TE_776231 silk/body keepout. Frame boot/reset buttons are gone from schematic and PCB (mega-mcu100 internal S100/S101 unchanged). **Not a fab order yet** until Create Board produces `boards/microcore-k/` and a human copper pass reviews B.Cu diode alley vs AMPSEAL pins / NPTH.

`microcore.kicad_pcb` remains substantial (zones present, 31 footprints after dropping two buttons). Drill origin unchanged: Edge.Cuts bottom-left `(107.5, 148.0872)`.

## What landed (rev k)

### 1. D1–D8 on B.Cu, nearer J1

| Ref | Function | Side | Placement |
|---|---|---|---|
| D1–D4 | US1M UF flyback (`/INJn` anode, `/V12_RAW` cathode) | **B.Cu** | West flank of J1, x=110.7, y=118.0–137.8, rot 90 |
| D5–D8 | SMAJ33A TVS (`/INJn` cathode, GND anode) | **B.Cu** | East flank of J1, x=194.0, y=118.0–137.8, rot 270 |

J1 TE_776231 @ `(152.2024, 129.9892)`, silk ±38.45 × ±16.05 → body box x=113.75–190.65, y=113.94–146.04. Diode courtyards stay **west of x=113.75** and **east of x=190.65**. Old F.Cu alley / pocket-C footprints and 0.4 mm wrap tracks to those pockets were removed. 1.5 mm FET→AMPSEAL injector fanout unchanged.

New B.Cu 0.5 mm collectors in the gap north of the INJ pin row stitch diode pads to J1 thru-hole pins; `/V12_RAW` west spine vias onto existing In2 at `(117.10, 124.90)`. GND vias sit beside D5–D8 anodes (B.Cu pour still needs KiCad refill).

### 2. Frame SW_BOOT / SW_RESET removed

Removed from `microcore.kicad_sch` and `microcore.kicad_pcb`, including silk and the frame-only BOOT0 / nReset / V33 / button-GND tracks and vias. MCU module pads `/BOOT0`, `/nReset`, `/V33` remain (internal mega buttons). `bom_replace_microcore-k.csv` has no SW_BOOT/SW_RESET rows.

## DRC leftovers (KiCad 10)

This environment has **no `kicad-cli`**. Last counted DRC was rev i (kicad-cli **10.0.6**): **425** total, mostly Hellen keepout / padstack / silk. Rev j/k add expected extra noise until zone refill:

- B.Cu SMD pads in the GND pour (thermals appear after fill)
- Courtyard tightness on the 6.25 mm west strip / 6.85 mm east strip beside AMPSEAL
- Residual empty-net module pad G shorts (rev i leftover)

Not claimed clean. Human copper eye still required on AMPSEAL fanout and the new B.Cu diode collectors vs NPTH / pin pads.

## Create Board / fab path

Workflow: `.github/workflows/create-board.yaml`

1. `on: push` and `workflow_dispatch`
2. Job `guard-pcb-not-empty` runs `bin/check-pcb-not-empty.sh microcore.kicad_pcb`
3. Reuses `andreika-git/hellen-one/.github/workflows/create-board.yaml@master`

**Exact next step for CI artifacts:** merge this branch to default **`main`**. Fab files are committed by that reusable workflow **on `main` only**. A PR-branch push may *run* the workflow but will not populate `boards/microcore-k/` on `main`.

`bom_replace_microcore-k.csv` is named for `BOARD_PREFIX`+`BOARD_SUFFIX`+`BOARD_REVISION` = `microcore-k`. ASCII-only comments (no ohm-symbol).

## Leftovers — before ordering boards

1. Green Create Board `boards/microcore-k/` with D1–D8 on bottom CPL / JLC BOM and no frame SW_BOOT/SW_RESET.  
2. Human copper pass: B.Cu diode flanks, collectors vs AMPSEAL NPTH, V12 spine, zone refill.  
3. KiCad 10 DRC + zone refill.  
4. LS flyback/TVS only if product later requires it.

## Incident guard

Do not whole-file-replace `microcore.kicad_pcb`. Guard: `bin/check-pcb-not-empty.sh` (min 10 kB + `(zone` present). Drill origin must stay Edge.Cuts bottom-left.
