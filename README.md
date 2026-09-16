# Micro Core

Core EFI Hellen-One rusEFI ECU. Microsquirt-class sealed box, 35-way AMPSEAL, **vertical header**.

4-cylinder sequential wire-in. STM32F4. Discrete DPAK injector drivers (2× high-Z per channel).

## Status

Spec locked in [docs/SPEC.md](docs/SPEC.md). Hardware rev **g** on `main`: F.Cu+B.Cu GND pours; AMPSEAL keepout clear (DPAKs at y=15/22/29, Q7 in M2–M1 corridor). Create Board artifacts under `boards/microcore-g/`. See [docs/HARDWARE_STATUS_rev_g.md](docs/HARDWARE_STATUS_rev_g.md) for fab-ready leftovers.

- Header: TE **776231-1** (straight / vertical)
- Plug: TE **776164-1** black, key A
- Not 776163-1 (right-angle)
- USB: vertical Mini-B on the frame (`hellen-one-common:USB_B_Mini` / `USB-MINI-B-VERTICAL`), gasketed flap or pigtail — not on the 35-way AMPSEAL

## Spec

See [docs/SPEC.md](docs/SPEC.md). Boss brief: [MICROCORE_BRIEF.md](MICROCORE_BRIEF.md).

Hellen tips: [docs/HELLEN-FAQ.md](docs/HELLEN-FAQ.md).

Firmware board name: `coreefi_micro` (sibling tree `/workspace/fw-coreefi-micro`, not in this repo).

KiCad board basename: `microcore` (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`, rev `g`).

## Hellen tooling

- Submodules: `hellen-one` (andreika-git/hellen-one), `kicad6-libraries` (rusefi/kicad6-libraries)
- CI: Create Board on push; daily submodule update workflows
- Fab outputs land under `boards/microcore-g/` after a successful CI run on `main`

## License

Hardware and docs in this repo: use for Core EFI product development.
Firmware will track rusEFI (GPL) when the board config lands.
