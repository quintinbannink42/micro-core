# Hellen One tips for Micro Core

Copied/adapted from [rusefi/hellen-example](https://github.com/rusefi/hellen-example) FAQ. Firmware board name remains `coreefi_micro`; KiCad project/board file basename is `microcore` (no `-` or `_`).

## Create Board CI

On push to default branch `main`, `.github/workflows/create-board.yaml` calls `andreika-git/hellen-one` Create Board:

1. Checkout with submodules
2. Install KiCad 10
3. `hellen-one/kicad/bin/export.sh` — gerbers, drill, pos, BOM, schematic PDF, VRML from `microcore.kicad_pcb` / `microcore.kicad_sch`
4. Docker build + gerber merge into `boards/microcore-a/`
5. Commit/push fab outputs when on `main`

Daily workflows bump `hellen-one` and `kicad6-libraries` submodule pointers.

## Naming and origin rules

- **No dashes or underscores** in `.kicad_pcb` filenames (`microcore.kicad_pcb`, not `micro_core` / `micro-core`).
- `revision.txt`: `BOARD_PREFIX` + `BOARD_SUFFIX` must equal the KiCad basename (`micro` + `core` → `microcore`).
- `bom_replace_${PREFIX}${SUFFIX}-${REVISION}.csv` → `bom_replace_microcore-a.csv`.
- **`aux_axis_origin` required** in the PCB (drill/place origin).
- Origin at **bottom-left**; **no negative coordinates** (hellen-one parser limitation).
- Default branch must be **`main`** or CI will not push fab results.

## Intended Hellen modules (from SPEC)

MCU F4 (`modules/mcu`), input lite (1× VR + Hall + analog — `input` / `vr-discrete` / related), 4-ch injectors (frame + discrete or `output`), 4-ch 5 V ign (`ign8` or discrete), 3× LS, power (`power_12and5V` or `power5`+`power12`). Place module footprints from `hellen-one/modules/...` via `fp-lib-table`.

## Firmware

See https://github.com/rusefi/fw-custom-hellen144-f4 and https://github.com/rusefi/rusefi/wiki/Custom-Firmware
