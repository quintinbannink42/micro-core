# Micro Core — Boss brief (locked)

**Product:** Micro Core (Core EFI Hellen-One rusEFI ECU)  
**Repo:** `/workspace/micro-core` (GitHub main)  
**Owner (orchestration):** Boss  
**Assigned agent:** Researcher  
**Separate from:** PowerCore (Jeoff / Code Jeoff) — do not mix streams  

**Locked:** 2026-09-16 (Quintin)

## Mission

Finish Micro Core **hardware**, then **start firmware compilation** for board `coreefi_micro`.

## What it is

- Microsquirt-class sealed-box 4-cyl sequential wire-in ECU  
- Hellen-One / STM32F4, 35-way AMPSEAL **vertical** header (TE 776231-1 / plug 776164-1)  
- KiCad basename `microcore`, rev **g** (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`)  
- Firmware board name: `coreefi_micro`  
- Spec: `docs/SPEC.md`

## Current state (as of Boss review)

- Hardware repo on `main` with rev g GND pours, AMPSEAL keepout work, Create Board outputs under `boards/microcore-g/`, gerbers present  
- README still says “spec freeze in progress”  
- **No firmware overlay repo found yet** under `/workspace` — firmware still to bootstrap for `coreefi_micro`  
- Do not confuse with PowerCore / hellen-pdm-razor

## Priorities for Researcher

1. **Hardware finish** — audit open copper/DRC/BOM/CI Create Board health on rev g; close remaining gaps to fab-ready; report concrete leftover list + DRC.  
2. **Firmware start** — bootstrap rusEFI custom board / overlay for `coreefi_micro` matching Micro Core pinout/spec; get a **green compile** (first flashable image).  
3. Keep reports to Boss; do not pull Jeoff or Code Jeoff unless Boss asks.

## Out of scope for this track

PowerCore PDM work, hellen-pdm-razor, TunerStudio PDM INI.
