# Micro Core — product spec (rev H/I, 2026-09-21)

First Core EFI Hellen-One ECU.

**Name:** Micro Core  
**Form:** Microsquirt-class sealed box  
**Connector:** 35-way AMPSEAL, **vertical header**  
**Brain:** rusEFI Hellen-One / STM32F4  
**Job:** 4-cylinder sequential wire-in

## Header (locked)
**Vertical / straight pins.** Header stands off the PCB. Plug mates from above. Cable leaves the **top** of the case.

| | Part |
|---|---|
| PCB header | TE **776231-1** (35-pos AMPSEAL header, straight / vertical) |
| Mating plug | TE **776164-1** (black, key A) |
| Contacts | 1.3 mm, 17 A max |
| Orientation | AMPSEAL on the lid face, same language as V3 Microsquirt |

Do not use 776163-1 (right-angle). That puts the plug off the board edge.

Keepout: header body + plug + strain-relief is the tallest stack on the board. Route FETs and crystals away from that courtyard. Lid has a rectangular cut / well for the header flange and seal.

## Envelope
| | Target |
|---|---|
| Case L × W × H | ~120 × 80 × 42 mm including AMPSEAL height |
| Mounting | two tabs, ~107 × 54 mm centres, Ø5 mm |
| PCB | ~90 × 60 mm including header keepout |
| MAP | external |
| USB | gasketed flap or pigtail, not on the 35-way |

## AMPSEAL I/O (35 pins)
4 inj, 8 logic coils (IGN1–8), 3 PGND, 2 SGND, +12, 5 V, CLT, IAT, MAP, TPS, VR crank ±, Hall cam, CAN H/L, FP, 2× LS, 2× DIN, 2× analog spare.

No ETB and no onboard LSU on this connector.

### Draft pin map
| Pin | Function |
|---|---|
| 1 | +12 V switched |
| 2 | CAN H |
| 3 | CAN L |
| 4–7 | Injector 1–4 |
| 8 | Fuel pump LS |
| 9 | Idle / VVT LS |
| 10 | Boost / spare LS |
| 11 | DIN1 (IN_D1 / PE12) |
| 12–15 | Ignition 1–4 (5 V) |
| 16 | +5 V ref |
| 17 | TPS |
| 18 | MAP |
| 19 | Analog spare 1 |
| 20 | Sensor ground |
| 21 | Analog spare 2 |
| 22–23 | Power ground |
| 24 | CLT |
| 25 | IAT |
| 26 | DIN2 (IN_D2 / PE13) |
| 27 | Hall cam |
| 28 | VR crank + |
| 29 | VR crank − |
| 30 | IGN5 (PE2) |
| 31 | IGN6 (PB8) |
| 32 | IGN7 (PB9) |
| 33 | IGN8 (PE6) |
| 34 | SGND |
| 35 | PGND |

Core pinout, not a Microsquirt copy.

## Power stage
4× DPAK N-FET + SMBJ33A + UF flyback. Two 12 Ω high-Z per channel. FETs on the lid-facing copper, gap-pad, clear of the AMPSEAL well.

## Hellen modules
MCU F4, input lite (1× VR + Hall + analog), 4-ch Core injectors, 4-ch 5 V ign, 3× LS, power. Knock / WBO as pads or CAN.

Firmware board: `coreefi_micro`.

## Frame controls (rev G+)
Gasketed tactile switches near USB Mini-B (north edge), paralleling mega-mcu100 internal buttons:
| Ref | Net | Polarity |
|---|---|---|
| SW_BOOT | BOOT0 ↔ V33 | BOOT0 pulled down on mega; button pulls to V33 (bootloader) |
| SW_RESET | nReset ↔ GND | Active-low; button pulls nReset to GND |

## Analog / Hall conditioning (waiver — rev H)

Frame sheets `ANALOG.kicad_sch` / `HALL.kicad_sch` remain hierarchy passthrough stubs.

**Accepted for Micro Core v1:** sensor conditioning is **mega-module-only** via Hellen `mega-mcu100` input lite (1× VR + Hall + analog paths on the module). No additional frame dividers / pull-ups / ESD required for fab of the first sealed-box rev, unless a later product change reopens this.

Firmware pin freeze still follows this SPEC + `fw-coreefi-micro/connectors/main.yaml`.
