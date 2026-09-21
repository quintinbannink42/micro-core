# Hellen One tips for Micro Core

Copied/adapted from [rusefi/hellen-example](https://github.com/rusefi/hellen-example) FAQ. Firmware board name remains `coreefi_micro`; KiCad project/board file basename is `microcore` (no `-` or `_`).

## Create Board CI

On push to default branch `main`, `.github/workflows/create-board.yaml` calls `andreika-git/hellen-one` Create Board:

1. Checkout with submodules
2. Install KiCad 10
3. `hellen-one/kicad/bin/export.sh` — gerbers, drill, pos, BOM, schematic PDF, VRML from `microcore.kicad_pcb` / `microcore.kicad_sch`
4. Docker build + gerber merge into `boards/microcore-l/` (revision letter from `revision.txt`)
5. Commit/push fab outputs when on `main`

A pull-request branch may *run* Create Board; **fab files are only pushed when the workflow runs on `main`**. After merging rev **l**, the next green run on `main` should create `boards/microcore-l/`. Manual path: GitHub → Actions → **Create Board** → Run workflow (on `main`).

Daily workflows bump `hellen-one` and `kicad6-libraries` submodule pointers.

## Naming and origin rules

- **No dashes or underscores** in `.kicad_pcb` filenames (`microcore.kicad_pcb`, not `micro_core` / `micro-core`).
- `revision.txt`: `BOARD_PREFIX` + `BOARD_SUFFIX` must equal the KiCad basename (`micro` + `core` → `microcore`).
- `bom_replace_${PREFIX}${SUFFIX}-${REVISION}.csv` → `bom_replace_microcore-a.csv`.
- **`aux_axis_origin` required** in the PCB (drill/place origin).
- Origin at **bottom-left** in KiCad Y-down (`aux_axis_origin 0 60` for 90×60 board); **no negative place coordinates** after drill-origin export (hellen-one/gerbmerge limitation).
- Default branch must be **`main`** or CI will not push fab results.

## Intended Hellen modules (from SPEC)

Locked modules-v1: `mega-mcu100/0.3` (Value `Module:mega-mcu100/0.3`), `power_12and5V/0.3`, `vr-max9924/0.3`, USB Mini-B (`USB_B_Mini` / `USB-MINI-B-VERTICAL`), TE `776231-1`; frame sheets INJ4/LS3/ANALOG/HALL with DPAKs. Skip mcu/0.7, output/0.3, input/0.1, wbo, knock, motor-driver, ign8, optional can.

## Firmware

See https://github.com/rusefi/fw-custom-hellen144-f4 and https://github.com/rusefi/rusefi/wiki/Custom-Firmware
