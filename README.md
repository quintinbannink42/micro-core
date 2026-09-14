# Micro Core

Core EFI Hellen-One rusEFI ECU. Microsquirt-class sealed box, 35-way AMPSEAL, **vertical header**.

4-cylinder sequential wire-in. STM32F4. Discrete DPAK injector drivers (2× high-Z per channel).

## Status

Spec freeze in progress. Hellen Create Board scaffolding imported (`hellen-import` branch). First real module content on `modules-v1` (mega-mcu100/0.3, power_12and5V/0.3, vr-max9924/0.3, USB Mini-B frame, TE 776231-1, sheets INJ4/LS3/ANALOG/HALL).

- Header: TE **776231-1** (straight / vertical)
- Plug: TE **776164-1** black, key A
- Not 776163-1 (right-angle)
- USB: vertical Mini-B on the frame (`hellen-one-common:USB_B_Mini` / `USB-MINI-B-VERTICAL`), gasketed flap or pigtail — not on the 35-way AMPSEAL

## Spec

See [docs/SPEC.md](docs/SPEC.md).

Hellen tips: [docs/HELLEN-FAQ.md](docs/HELLEN-FAQ.md).

Firmware board name: `coreefi_micro`.

KiCad board basename: `microcore` (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`, rev `c`).

## Hellen tooling

- Submodules: `hellen-one` (andreika-git/hellen-one), `kicad6-libraries` (rusefi/kicad6-libraries)
- CI: Create Board on push; daily submodule update workflows
- Fab outputs land under `boards/microcore-c/` after a successful CI run on `main`

## License

Hardware and docs in this repo: use for Core EFI product development.
Firmware will track rusEFI (GPL) when the board config lands.
