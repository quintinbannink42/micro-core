# Micro Core

Core EFI Hellen-One rusEFI ECU. Microsquirt-class sealed box, 35-way AMPSEAL, **vertical header**.

4-cylinder sequential wire-in. STM32F4. Discrete DPAK injector drivers (2× high-Z per channel).

## Status

Spec freeze in progress. No gerbers yet.

- Header: TE **776231-1** (straight / vertical)
- Plug: TE **776164-1** black, key A
- Not 776163-1 (right-angle)

## Spec

See [docs/SPEC.md](docs/SPEC.md).

Firmware board name: `coreefi_micro`.

## License

Hardware and docs in this repo: use for Core EFI product development.
Firmware will track rusEFI (GPL) when the board config lands.
