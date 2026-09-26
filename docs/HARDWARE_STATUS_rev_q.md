# Micro Core hardware status — rev q

**Date:** 2026-09-26
**Repo:** `quintinbannink42/micro-core`
**KiCad basename:** `microcore` (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`)
**BOARD_REVISION:** **q** (fab-affecting: Q1–Q7 back to NCE4080K; four SLM27524 gate drivers on `/V12_RAW`)
**Create Board artifacts:** `boards/microcore-p/` is the last fab pack on main. **`boards/microcore-q/` after this rev is merged to `main`**. This PR does not commit a fab pack.

## Verdict

**Not production-ready. Do not order boards** until Create Board on `main` produces `boards/microcore-q/`. The electrical change is the one rev p left open: the MCU no longer drives the FET gates at 3.3 V. Each used channel is MCU GPIO to a SLM27524 input, driver output through the existing 12 ohm resistor, then the NCE4080K gate. Driver VDD is the vehicle `/V12_RAW` rail already on the board. No boost converter was added.

LS clamps from rev p are unchanged (D9–D11 US1M, D12–D14 SMAJ33A, injector D1–D8, ballast R8–R11). Frame short fixes from rev p are unchanged. Hellen module internals (M1/M2/M3) were not edited. Drill origin is still Edge.Cuts bottom-left `(107.5, 148.0872)`. `U105` stays STM32F407VGT6 on mega-mcu100.

## What landed (rev q)

### 1. Power FET: AOD4184A back to NCE4080K

Q1–Q7 are **NCE4080K**, LCSC **C191380**, footprint `microcore-fp:DPAK` (same land as rev p). Pinout stays gate, drain tab, source. AOD4184A / C99124 rows are gone from `bom_replace_microcore-q.csv`.

NCE4080K publishes RDS(on) at VGS = 10 V, not at 3.3 V. Rev q does not ask the 3.3 V GPIO to make that rating. The gate driver does.

### 2. Gate drivers

Four **Sillumin SLM27524CA-DG**, LCSC **C2921387**, SOIC-8, UCC27524 / UCC27524A class. Dual non-inverting low-side MOSFET drivers. Datasheet class: 4.5–20 V VDD, TTL/CMOS inputs (3.3 V is a valid high), about 4.5 A / 5.5 A peak. JLCPCB/LCSC had stock, so the TI UCC27524ADR alternate was not used.

Footprints are vendored as `microcore-fp:SOIC-8` and `microcore-fp:C0603` (3D models stripped). Drivers sit on **B.Cu**, next to the gate resistors. The front copper between the M1 keepout and the DPAKs does not have room for a SOIC.

| Driver | Channel | MCU net | Input | Output | Gate R | FET |
|---|---|---|---|---|---|---|
| U1 | B | `/OUT_INJ1` | pin 4 INB | pin 5 OUTB | R1 | Q1 |
| U1 | A | `/OUT_INJ2` | pin 2 INA | pin 7 OUTA | R2 | Q2 |
| U2 | B | `/OUT_INJ3` | pin 4 INB | pin 5 OUTB | R3 | Q3 |
| U2 | A | `/OUT_INJ4` | pin 2 INA | pin 7 OUTA | R4 | Q4 |
| U3 | B | `/OUT_LS1` | pin 4 INB | pin 5 OUTB | R5 | Q5 |
| U3 | A | `/OUT_LS2` | pin 2 INA | pin 7 OUTA | R6 | Q6 |
| U4 | B | `/OUT_LS3` | pin 4 INB | pin 5 OUTB | R7 | Q7 |
| U4 | A | unused | pin 2 INA tied to GND | pin 7 OUTA no-connect | — | — |

**7 of 8 channels used.** The unused input is tied low. It is not left floating.

ENA and ENB (pins 1 and 8) and VDD (pin 6) are on **`/V12_RAW`**. Driver GND (pin 3) is the same `GND` net as the FET sources. No new ground island.

Local ceramics at each VDD pin, to GND:

| Refs | Value | LCSC | Note |
|---|---|---|---|
| C1, C3, C5, C7 | 100 nF | C14663 | YAGEO CC0603KRX7R9BB104, already used on this board |
| C2, C4, C6, C8 | 1 uF 50 V X7R | **C559769** | YAGEO CC0603KRX7R9BB105. Samsung CL10A105KB8NNNC / C15849 was out of stock |

### 3. Kept from rev p

- D9–D11 US1M C112545, D12–D14 SMAJ33A C143131 on Q5–Q7. Injector D1–D8 and ballast R8–R11 unchanged.
- Frame copper short fixes (INJ3 / VR_OUT, VR_N vs drains, Q4/R9, and the rest of that pass).
- Drill origin `(107.5, 148.0872)`. Empty-PCB CI guard. ASCII-only `bom_replace` comments.
- U105 STM32F407VGT6 / mega-mcu100.

## DRC summary (kicad-cli 10.0.6)

Command: `kicad-cli pcb drc --format json --severity-all --units mm --schematic-parity`

Compared with the rev p board measured the same way on 2026-09-26 (473 violations, 207 error / 266 warning, 2 unconnected, 222 schematic-parity issues).

| Category | rev p | rev q | Delta |
|---|---:|---:|---|
| Total violations | 473 | 473 | 0 |
| Errors | 207 | 207 | 0 |
| shorting_items | 4 | 4 | 0 (still the Hellen pad-G pairs) |
| unconnected_items | 2 | 2 | 0 (M2 pad S1 vs F.Cu GND, plus the F.Cu GND island) |
| schematic_parity | 222 | 222 | 0 |
| tracks_crossing | 0 | 0 | 0 |
| clearance | 2 | 2 | 0 |
| items_not_allowed | 199 | 199 | 0 count. One identity moved: see below |
| padstack | 159 | 159 | 0 |
| silk_over_copper | 81 | 81 | 0 |
| silk_overlap | 20 | 20 | 0 |

The single items_not_allowed identity that changed is the `/OUT_INJ1` inner track. Rev p ended that trace on a via sitting on R1. Rev q removed that via (it would short the new driver-output net on the resistor pad) and shortened the trace from 3.6 mm to 2.125 mm. The remaining segment still enters the M1 keepout, which the old trace already did. Count stays 199. Hellen `items_not_allowed`, padstack, and pad-G shorts were not chased.

New copper was checked for shorts before save. The router refuses to write the board if a driver input, a driver output, or `/V12_RAW` does not join.

## Layout caveats

- Drivers and bypass caps are on B.Cu. A front SOIC does not fit between the M1 east pins and the gate resistors without sitting in the Hellen keepout.
- `/V12_RAW` is the B.Cu rail already at `(154.8, 110.4)`. A spine at x = 167.75 feeds U1–U3. That spine splits the back GND pour, so a stitch via at `(158.6, 113.0)` ties the pocket south of the spine back to the front GND zone.
- U4 is southeast of the `/INJ2` diagonal. Its VDD crosses on F.Cu between two vias, then drops back to B.Cu at the driver. Enables are tied to VDD on the chip.
- R6 (U3 OUTA) cannot cross Q3's drain on F.Cu or `/VR_N` on B.Cu. It leaves on B.Cu just west of the drain, runs In1 north of the `/VR_N` south via, and returns to F.Cu at R6.
- Inner-layer MCU tracks for the old direct gate nets were kept. The through-vias that sat on R1, R2, R4, R6, and R7 were deleted so they would not short the driver outputs. The stubs past the new taps were trimmed.
- Reference silk for U1–U3 and C1–C8 was moved so the new parts do not add silk_over_copper or silk_overlap.

## Create Board / fab path

Workflow: `.github/workflows/create-board.yaml` runs on push to `main`, then `bin/check-pcb-not-empty.sh`, then `andreika-git/hellen-one` Create Board. It applies `bom_replace_microcore-q.csv` from `revision.txt`.

**Next step for fab files:** merge to `main`. Do not commit `boards/microcore-q/` from this branch.

## Leftovers — before ordering boards

1. Green Create Board `boards/microcore-q/` and confirm the JLC BOM shows NCE4080K / C191380 on Q1–Q7, SLM27524CA-DG / C2921387 on U1–U4, C14663 and C559769 on the bypass caps, STM32F407VGT6 / C12345 on U105, and the rev p clamps still present.
2. Residual Hellen keepout / padstack / module pad-G / edge noise, same counts as rev p. Owner table and the one frame fix: [DRC_TRIAGE_rev_q.md](DRC_TRIAGE_rev_q.md). The F.Cu GND island in the unconnected pair above is stitched at `(131.3, 82)` there. M2 pad S1 stays unconnected (inside the M2 keepout). Violation counts in the table above did not change. Frame follow-up in that note: duplicate `/INJ1` via removed, frame `silk_over_copper` 53→0 and frame `silk_overlap` 19→0 (M2 silk and Q2 vs M3 silk stay).
3. Firmware `coreefi_micro` F407 target in the sibling tree (not this PR).

## Incident guard

Do not whole-file-replace `microcore.kicad_pcb`. Guard: `bin/check-pcb-not-empty.sh` (min 10 kB + `(zone` present). Drill origin must stay Edge.Cuts bottom-left `(107.5, 148.0872)`.
