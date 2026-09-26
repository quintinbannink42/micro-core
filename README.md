# Micro Core

Core EFI Hellen-One rusEFI ECU. Microsquirt-class sealed box, 35-way AMPSEAL, **vertical header**.

4-cylinder sequential wire-in. **STM32F407VGT6** on Hellen `mega-mcu100/0.3` (not mega-mcu64). Seven NCE4080K power FETs: 4 injector channels (2× high-Z each) plus fuel-pump, idle, and boost low-sides with US1M flyback and SMAJ33A. Gates are driven from `/V12_RAW` by SLM27524CA-DG low-side drivers, not directly from the 3.3 V GPIO.

## Status

Spec locked in [docs/SPEC.md](docs/SPEC.md). Hardware on this branch: **rev q**. Q1–Q7 are NCE4080K (LCSC C191380) on the existing DPAK land. Four SLM27524CA-DG drivers (LCSC C2921387) take the mega-mcu100 GPIO and drive the gates from `/V12_RAW` through the 12 ohm series resistors. Seven of eight channels are used; the spare input is tied to GND. Q5–Q7 (AMPSEAL pins 8/9/10, FP / Idle / Boost) keep the US1M flyback and SMAJ33A from rev p. F407VGT6 on mega-mcu100 stays. `boards/microcore-q/` lands when Create Board succeeds on `main` after merge. See [docs/HARDWARE_STATUS_rev_q.md](docs/HARDWARE_STATUS_rev_q.md). **Not production-ready.** The earlier FET comparison is in [docs/FET_COMPARISON.md](docs/FET_COMPARISON.md).

- Header: TE **776231-1** (straight / vertical)
- Plug: TE **776164-1** black, key A
- Not 776163-1 (right-angle)
- USB: vertical Mini-B on the frame (`hellen-one-common:USB_B_Mini` / `USB-MINI-B-VERTICAL`), gasketed flap or pigtail — not on the 35-way AMPSEAL

## Spec

See [docs/SPEC.md](docs/SPEC.md). Boss brief: [MICROCORE_BRIEF.md](MICROCORE_BRIEF.md).

Hellen tips: [docs/HELLEN-FAQ.md](docs/HELLEN-FAQ.md).

Firmware board name: `coreefi_micro` (sibling tree `/workspace/fw-coreefi-micro`, not in this repo). The MCU is the F407 from rev n; that firmware tree will need an F407 target later. This repo does not publish a firmware remote.

KiCad board basename: `microcore` (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`, rev `q`).

## Hellen tooling

- Submodules: `hellen-one` (andreika-git/hellen-one), `kicad6-libraries` (rusefi/kicad6-libraries)
- CI: Create Board on push to `main`; daily submodule update workflows
- Fab outputs on main include `boards/microcore-p/`. After merge, Create Board writes `boards/microcore-q/`
- Local DRC needs **KiCad 10** (`kicad-cli`); board file is generator_version 10.0
- Empty-PCB guard: `bin/check-pcb-not-empty.sh` (Create Board job `guard-pcb-not-empty`)

## License

Hardware and docs in this repo: use for Core EFI product development.
Firmware will track rusEFI (GPL) when the board config lands.
