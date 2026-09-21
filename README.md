# Micro Core

Core EFI Hellen-One rusEFI ECU. Microsquirt-class sealed box, 35-way AMPSEAL, **vertical header**.

4-cylinder sequential wire-in. STM32F4. Discrete DPAK injector drivers (2× high-Z per channel).

## Status

Spec locked in [docs/SPEC.md](docs/SPEC.md). Hardware on `main`: **rev i** (J8 GND stitch after rev h restore/origin). Last green Create Board package: `boards/microcore-i/`. See [docs/HARDWARE_STATUS_rev_h.md](docs/HARDWARE_STATUS_rev_h.md) for fab-ready leftovers — **not fab-ready**.

- Header: TE **776231-1** (straight / vertical)
- Plug: TE **776164-1** black, key A
- Not 776163-1 (right-angle)
- USB: vertical Mini-B on the frame (`hellen-one-common:USB_B_Mini` / `USB-MINI-B-VERTICAL`), gasketed flap or pigtail — not on the 35-way AMPSEAL

## Spec

See [docs/SPEC.md](docs/SPEC.md). Boss brief: [MICROCORE_BRIEF.md](MICROCORE_BRIEF.md).

Hellen tips: [docs/HELLEN-FAQ.md](docs/HELLEN-FAQ.md).

Firmware board name: `coreefi_micro` (sibling tree `/workspace/fw-coreefi-micro`, not in this repo).

KiCad board basename: `microcore` (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`, rev `i`).

## Hellen tooling

- Submodules: `hellen-one` (andreika-git/hellen-one), `kicad6-libraries` (rusefi/kicad6-libraries)
- CI: Create Board on push; daily submodule update workflows
- Fab outputs land under `boards/microcore-i/` after a successful Create Board on `main`
- Local DRC needs **KiCad 10** (`kicad-cli`); board file is generator_version 10.0

## License

Hardware and docs in this repo: use for Core EFI product development.
Firmware will track rusEFI (GPL) when the board config lands.
