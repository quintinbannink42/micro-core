# Micro Core

Core EFI Hellen-One rusEFI ECU. Microsquirt-class sealed box, 35-way AMPSEAL, **vertical header**.

4-cylinder sequential wire-in. **STM32F407VGT6** on Hellen `mega-mcu100/0.3` (not mega-mcu64). Seven NCE4080K power FETs: 4 injector channels (2× high-Z each) plus fuel-pump, idle, and boost low-sides.

## Status

Spec locked in [docs/SPEC.md](docs/SPEC.md). Hardware on this branch: **rev o** (power FETs are NCE4080K / LCSC C191380; Q5–Q7 and R5–R7 restored; AMPSEAL pins 8/9/10 are FP / Idle / Boost). F407VGT6 on mega-mcu100, GND pours, and Core EFI silkscreen kept. `boards/microcore-o/` lands when Create Board succeeds on `main` after merge. See [docs/HARDWARE_STATUS_rev_o.md](docs/HARDWARE_STATUS_rev_o.md). **Not production-ready.** The NCE4080K RDS(on) rating is at 10 V; the gate is 3.3 V and there is no gate driver.

- Header: TE **776231-1** (straight / vertical)
- Plug: TE **776164-1** black, key A
- Not 776163-1 (right-angle)
- USB: vertical Mini-B on the frame (`hellen-one-common:USB_B_Mini` / `USB-MINI-B-VERTICAL`), gasketed flap or pigtail — not on the 35-way AMPSEAL

## Spec

See [docs/SPEC.md](docs/SPEC.md). Boss brief: [MICROCORE_BRIEF.md](MICROCORE_BRIEF.md).

Hellen tips: [docs/HELLEN-FAQ.md](docs/HELLEN-FAQ.md).

Firmware board name: `coreefi_micro` (sibling tree `/workspace/fw-coreefi-micro`, not in this repo). The MCU is the F407 from rev n; that firmware tree will need an F407 target later. This repo does not publish a firmware remote.

KiCad board basename: `microcore` (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`, rev `o`).

## Hellen tooling

- Submodules: `hellen-one` (andreika-git/hellen-one), `kicad6-libraries` (rusefi/kicad6-libraries)
- CI: Create Board on push to `main`; daily submodule update workflows
- Fab outputs on main include `boards/microcore-n/`. After merge, Create Board writes `boards/microcore-o/`
- Local DRC needs **KiCad 10** (`kicad-cli`); board file is generator_version 10.0
- Empty-PCB guard: `bin/check-pcb-not-empty.sh` (Create Board job `guard-pcb-not-empty`)

## License

Hardware and docs in this repo: use for Core EFI product development.
Firmware will track rusEFI (GPL) when the board config lands.
