# Micro Core — product spec (rev O, 2026-09-22)

First Core EFI Hellen-One ECU.

**Name:** Micro Core  
**Form:** Microsquirt-class sealed box  
**Connector:** 35-way AMPSEAL, **vertical header**  
**Brain:** rusEFI Hellen-One / **STM32F407VGT6** on `mega-mcu100/0.3` (not mega-mcu64)  
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
4 inj, 8 logic coils (IGN1–8), 3 PGND, 2 SGND, +12, 5 V, CLT, IAT, MAP, TPS, VR crank ±, Hall cam, CAN H/L, 2× DIN, 2× analog spare. Pins 8/9/10 are the low-side outputs (fuel pump, idle / VVT, boost / spare).

No ETB and no onboard LSU on this connector.

### Draft pin map
| Pin | Function |
|---|---|
| 1 | +12 V switched |
| 2 | CAN H |
| 3 | CAN L |
| 4–7 | Injector 1–4 |
| 8 | Fuel pump LS (Q5) |
| 9 | Idle / VVT LS (Q6) |
| 10 | Boost / spare LS (Q7) |
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
7× DPAK-class N-FET, all **NCE4080K** (TO-252-2L, LCSC **C191380**) on the existing `microcore-fp:DPAK` land (pad pitch 4.56 mm; LCSC land is P4.57).

4× injector (Q1–Q4) + SMAJ33A + UF flyback. Two 12 ohm high-Z per channel (gate R1–R4 + ballast R8–R11). FETs on the lid-facing copper, gap-pad, clear of the AMPSEAL well.

3× low-side (Q5 fuel pump, Q6 idle / VVT, Q7 boost / spare) with gate R5–R7 at 12 ohm. LS channels have no flyback and no TVS (same as before rev n). Pins 8/9/10 are those drains.

NCE4080K is a discrete MOSFET, not a protected smart FET. RDS(on) is specified at Vgs = 10 V only. The gate is driven from the 3.3 V MCU through 12 ohm. See `docs/HARDWARE_STATUS_rev_o.md` before treating the 7 mohm figure as the on-resistance in the car.

## Hellen modules
MCU **STM32F407VGT6** (LQFP100, LCSC **C12345**) inside Hellen `mega-mcu100/0.3`. Do not switch to `mega-mcu64`. Input lite (1× VR + Hall + analog), 4-ch Core injectors, 4-ch 5 V ign, power, 3× LS. Knock / WBO as pads or CAN.

`bom_replace_microcore-o.csv` keeps `U105` `STM32F407VGT6` / `C12345` and sets Q1–Q7 to `NCE4080K` / `C191380`. C15815 and C2252 are not this MCU (op-amp and 22.1184 MHz crystal).

Firmware board: `coreefi_micro` (sibling tree `/workspace/fw-coreefi-micro`, not published from this hardware repo). That tree will need an **F407** target later; this rev does not add a firmware remote.

## Frame controls (rev K)

mega-mcu100 already has internal tactile switches (S100 nReset, S101 BOOT0). **Frame SW_BOOT / SW_RESET were removed in rev k** (schematic + PCB) so they no longer parallel those module buttons. Boot/reset on the sealed box is module-only unless a later rev adds external switches again.

## Analog / Hall conditioning (waiver — rev H)

Frame sheets `ANALOG.kicad_sch` / `HALL.kicad_sch` remain hierarchy passthrough stubs.

**Accepted for Micro Core v1:** sensor conditioning is **mega-module-only** via Hellen `mega-mcu100` input lite (1× VR + Hall + analog paths on the module). No additional frame dividers / pull-ups / ESD required for fab of the first sealed-box rev, unless a later product change reopens this.

Firmware pin freeze still follows this SPEC + `fw-coreefi-micro/connectors/main.yaml`.
