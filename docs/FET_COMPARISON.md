# DPAK FET comparison — 3.3 V gate, rev o land

**Date:** 2026-09-24  
**Repo:** `quintinbannink42/micro-core`  
**Board:** rev o, Q1–Q7 on `microcore-fp:DPAK` (`footprints/DPAK.kicad_mod`)  
**Written against rev o.** It compared parts and recommended keeping NCE4080K. It did not edit the BOM.

**Quintin override (2026-09-25):** Q1–Q7 on rev p are **AOD4184A / LCSC C99124**, chosen for budget and reliability. That call replaces the recommendation below. Current parts are in `docs/HARDWARE_STATUS_rev_p.md`.

## Recommendation

**This note recommended keeping NCE4080K** and not swapping to DMTH4004LK3. Quintin later chose AOD4184A instead. The numbers below are unchanged.

DMTH4004LK3 publishes 5 mΩ at VGS = 4.5 V, and this board never makes 4.5 V. Its VGS(th) maximum is 3.0 V. An STM32F407 GPIO high is about 3.3 V, so a worst-case DMTH is only 0.3 V above threshold. That is less overdrive than the NCE (VGS(th) max 2.5 V). The 5 mΩ line is the wrong number for this gate.

The part worth building as a later prototype, if Quintin wants a logic-level drop-in and still no gate driver, is **Infineon IPD90N04S4L-04 / LCSC C536903**. It is the only part in this set with both a VGS(th) max of 2.2 V and a guaranteed RDS(on) at 4.5 V (5.5 mΩ max) that is tighter than the NCE’s 7 mΩ at 10 V. RDS(on) at 3.3 V is still not guaranteed. Measure the drain-source drop on a fuel-pump load at VGS = 3.3 V, cold and hot, before any BOM edit.

AOD4184A is stocked and cheap. It is not a stronger choice here: VGS(th) max is 2.6 V, and 9.5 mΩ is only guaranteed at 4.5 V.

A gate driver to about 10 V would make the existing NCE 7 mΩ rating real. That is a schematic change, and it is outside this note.

None of these parts put back the VND14NV04-E protections (current limit, thermal shutdown, internal clamp).

## What the board actually drives

MCU is STM32F407VGT6, 3.3 V GPIO, through the existing 12 Ω series resistors R1–R7. No gate driver, charge pump, or extra transistor.

Steady gate current is leakage. The 12 Ω resistor does not drop a meaningful DC voltage, so VGS sits at the GPIO high, about 3.3 V. Suitability is the RDS(on) curve at that voltage, not the pin’s milliamp rating. Gate charge on these parts is tens of nanocoulombs. An STM32 pin sourcing on the order of 20 mA charges that in a few microseconds, which is enough for injector pulses and for idle or boost PWM.

| Channel | Parts | Load the FET sees |
|---|---|---|
| Q1–Q4 injectors | gate R1–R4, ballast R8–R11 (12 Ω), US1M D1–D4, SMAJ33A D5–D8 | High-Z injectors. The 12 Ω ballast alone limits a shorted output to about 14 V / 12 Ω ≈ 1.2 A. One 12 Ω injector plus the ballast is about 0.6 A. Two 12 Ω injectors in parallel plus the ballast is still about 1 A. Pulsed. |
| Q5 fuel-pump LS | gate R5 only | No ballast, no flyback, no TVS. Continuous while the pump runs. In-tank pumps are commonly several amps up to the mid-teens. |
| Q6 idle / VVT, Q7 boost | gate R6, R7 only | No clamp. Usually around an amp, PWM. |

Package ID of 50–100 A is the rating with the case held at 25 °C. It is not the current a 90 × 60 mm board can sink. The fuel-pump FET is the one that cares about RDS(on) at 3.3 V. Injector loss stays small even if RDS(on) is several times the headline number, as long as the FET is actually enhanced and not dropping volts out of the pulse.

## LCSC prices (2026-09-24)

USD, LCSC ladder, “ships now” stock on that date. Prices move.

| Part | LCSC | Stock | 1 pc | 100 pc | Package on LCSC |
|---|---|---:|---:|---:|---|
| NCE4080K | **C191380** | 21,822 | $0.283 | $0.155 | TO-252-2L |
| DMTH4004LK3-13 | **C260930** | 9,514 | $0.598 | $0.367 | TO-252 |
| IPD90N04S4L-04 | **C536903** | 927 | $1.008 | $0.620 | TO-252-3 |
| AOD4184A | **C99124** | 17,795 | $0.347 (min 5) | $0.233 at 150 | TO-252 |

Seven FETs is one ECU. At 100 pieces (about 14 boards) the IPD is about four times the NCE. IPD stock of 927 is about 130 boards, and it is thin next to the NCE.

NCE4080K is a JLCPCB **extended** part (same C191380), not a basic/zero-loading-fee part.

## Comparison

Datasheet maxima unless noted. VGS(th) is at ID = 250 µA (Infineon: ID = 35 µA). No part below guarantees RDS(on) at 3.3 V or at 2.5 V.

| | NCE4080K | DMTH4004LK3-13 | IPD90N04S4L-04 | AOD4184A |
|---|---|---|---|---|
| Maker | NCE | Diodes Inc. | Infineon OptiMOS-T2 | AOS |
| LCSC | C191380 | C260930 | C536903 | C99124 |
| VDS | 40 V | 40 V | 40 V | 40 V |
| ID (package, Tc = 25 °C) | 80 A (56 A at 100 °C) | 100 A (also 100 A at 100 °C) | 90 A at VGS = 10 V (84 A at 100 °C) | 50 A (13 A at Ta) |
| Package | TO-252-2L | TO-252 (DPAK, 2 leads + tab) | PG-TO252-3 | TO-252 |
| RDS(on) max at ≤ 4.5 V | not specified | **5 mΩ** at 4.5 V, 50 A (typ 4 mΩ) | **5.5 mΩ** at 4.5 V, 45 A (typ 4.6 mΩ) | **9.5 mΩ** at 4.5 V, 15 A |
| RDS(on) max at 10 V | **7 mΩ** at 20 A (LCSC PDF; a second NCE PDF prints 6.6 mΩ max / 5.4 mΩ typ) | 3 mΩ at 50 A (typ 2.4 mΩ) | 3.8 mΩ at 90 A (typ 3.2 mΩ) | 7 mΩ at 20 A |
| VGS(th) min / typ / max | 1.2 / 1.8 / **2.5 V** | 1 / — / **3 V** | 1.2 / 1.7 / **2.2 V** | 1.7 / 2.1 / **2.6 V** |
| Overdrive at 3.3 V above Vth max | 0.8 V | 0.3 V | 1.1 V | 0.7 V |
| RDS guaranteed at 3.3 V? | No. Only 10 V. | No. Only 4.5 V and 10 V. | No. Only 4.5 V and 10 V. | No. Only 4.5 V and 10 V. |
| 3.3 V GPIO, no driver | Turns on (Vth max 2.5 V). On-resistance in the car is unknown, and it gets worse cold (high Vth) and hot (RDS rises). Fine for ~1 A injectors if it is actually enhanced. Fuel-pump current needs a measurement. | Worst-case part is barely on at 3.3 V, and it is off if the rail sags to 3.0 V. The 5 mΩ spec does not apply. | Best overdrive in this set, and the 4.5 V spec is at least in the direction of a 3.3 V gate. Still a bench measurement before a fuel pump. | Slightly less overdrive than the NCE, and a higher 4.5 V RDS than the NCE’s 10 V number. |
| DPAK land | The footprint was drawn for this TO-252-2L. Pitch 4.56 mm vs LCSC P4.57. | Same JEDEC DPAK pitch (e = 2.286 mm). Drop-in. | Same outer-lead pitch. Middle lead is drain and sits in the gap; see below. | Same TO-252 land. Drop-in. |
| Single-pulse EAS | 750 mJ (LCSC PDF; another NCE PDF prints 670 mJ) | 90 mJ (L = 0.2 mH) | 95 mJ (ID = 45 A) | not used for the pick |
| Other | Discrete FET. Qg listed by LCSC as 61 nC. PD 80 W at Tc = 25 °C. No PCB RthJA on the short sheet. | AEC-Q101. Qg typ 35 nC at 4.5 V, 83 nC max at 10 V. PD 3.9 W (Ta) / 180 W (Tc). | AEC-Q101. Qg 46 nC at 10 V. RthJC 2.1 K/W. VGS +20 / −16 V. | Industrial. Qg 14 nC typ at 4.5 V, 27 nC typ at 10 V. PD 2.3 W (Ta) / 50 W (Tc). |

Sources: NCE PDF linked from LCSC C191380 (the sheet already cited in `docs/HARDWARE_STATUS_rev_o.md`); Diodes DMTH4004LK3 datasheet (DS37792); Infineon IPD90N04S4L-04 datasheet and the Infineon product page (VGS(th) 1.2–2.2 V, RDS 5.5 mΩ at 4.5 V, EAS 95 mJ, RthJC 2.1 K/W); AOS AOD4184A datasheet.

Also checked and not carried as candidates:

- **onsemi FDD8447L / LCSC C247783** (about 3,500 in stock, about $0.71 / $0.48 at 1 / 100). LCSC quotes the datasheet bullets: 8.5 mΩ max at 10 V, 11 mΩ max at 4.5 V, and lists VGS(th) as 3 V. Higher 4.5 V resistance than the IPD or the DMTH, and the same 3 V threshold problem as the DMTH.
- **Taiwan Semi TSM051N04LCP.** Datasheet: VGS(th) max 2.5 V (same as the NCE), RDS(on) 7 mΩ max at 4.5 V and 5.1 mΩ max at 10 V. The JLCPCB line showed no stock. Threshold max does not beat the NCE.

No TO-252 / DPAK part turned up on LCSC with RDS(on) actually guaranteed at 2.5 V in the 40 V class. Parts that do publish 2.5 V RDS (for example some AON PowerPAKs) are a different land.

## Footprint

`footprints/DPAK.kicad_mod` is a 2-lead + tab pattern, Infineon PG-TO252 style:

| | `microcore-fp:DPAK` |
|---|---|
| Gate pad 1 | (−3.1, −2.28) mm, 2.2 × 1.2 mm |
| Source pad 3 | (−3.1, +2.28) mm, 2.2 × 1.2 mm |
| Lead pitch | **4.56 mm** center to center |
| Drain tab pad 2 | (3.2, 0) mm, **6.4 × 5.8 mm** |
| Gap between gate and source pads | 3.36 mm (inner edges at y = ±1.68 mm) |

JEDEC TO-252 basic pitch is e ≈ 2.29 mm, so the outer leads (gate and source) are about 4.58 mm apart. NCE’s own drawing is e = 2.186–2.386 mm, lead width 0.66–0.86 mm. DMTH’s drawing is e = 2.286 mm, lead width 0.64–0.88 mm. The 1.2 mm pad is wider than the lead. Pitch and tab match the land already accepted for the NCE in rev o. No footprint redraw is required for any part in the table.

TO-252-3 (IPD, AOD, DMTH) still has a middle lead. On a DPAK that lead is drain, tied to the tab inside the package. There is no middle pad on this footprint. The lead is about 1 mm wide and sits in the 3.36 mm gap, so it does not land on the gate or source pad. It is not soldered. The drain connection remains the tab. Pinout stays pin 1 gate, pin 2 drain, pin 3 source, which is the symbol Q1–Q7 already use.

TO-252-2L (NCE) is the same body with that middle lead omitted.

## Thermal and current

Headline ID assumes the tab is held at 25 °C. Infineon’s note on this DPAK: continuous current is bond-wire limited, and with RthJC = 2.1 K/W the die could carry more than the package lead. The PG-TO252 PCB footnote on the OptiMOS-T2 DPAK series (printed on the sibling IPD90N04S4-04 sheet; the L sheet itself confirms RthJC and EAS) is about **62 K/W** on a minimal footprint and about **40 K/W** with 6 cm² of drain copper (40 × 40 × 1.5 mm FR4, 70 µm, one layer, still air). NCE does not publish an RthJA. The DPAK body is the same order.

Those 6 cm² are on the **drain** tab. Source is the GND pour. Each drain is its own net (injector or LS), so the tab does not heat-sink into the ground plane. Seven FETs share a board of about 90 × 60 mm. A full 6 cm² island per drain is optimistic.

SPEC already calls for the FETs on the lid-facing copper with a gap-pad. The tab is live (it is the load), so that pad has to be electrically insulating. The stack is not sized in this repo. Until someone measures it, treat the PCB figures as the pessimistic limit and the gap-pad as an unquantified improvement.

Illustration only, not a measured board temperature: ambient 85 °C, junction kept to 150 °C, RthJA 40 K/W gives about **1.6 W**. At 62 K/W the budget is about **1.0 W**.

| If the real RDS(on) at 3.3 V, hot, is | Continuous current at 1.6 W |
|---|---:|
| 5 mΩ (IPD’s 4.5 V max, if you actually get it) | ~18 A |
| 7 mΩ (NCE’s 10 V max, if you actually get it) | ~15 A |
| 15 mΩ | ~10 A |
| 30 mΩ | ~7 A |
| 50 mΩ | ~6 A |

A fuel pump in the mid-teens only fits that budget if RDS(on) really is down around the 5–10 mΩ datasheet lines **and** the copper or the gap-pad is at least as good as the 40 K/W example. A part sitting a few hundred millivolts above threshold can be tens or hundreds of milliohms. At 100 mΩ a 10 A pump is 10 W in the package, which a DPAK on this board will not shed. That is the failure mode of a high VGS(th) max on Q5, and it is why the DMTH’s 5 mΩ at 4.5 V is not a reason to swap.

Injector channels, at about 1 A, dissipate under 0.1 W even at 50 mΩ. They are a gate-drive question only in the sense of pulse-voltage drop, not a copper question.

Q5–Q7 have no flyback diode and no TVS. Turn-off energy goes into the FET as avalanche. NCE’s single-pulse EAS on the LCSC PDF is 750 mJ. DMTH is 90 mJ and the IPD is 95 mJ. A small solenoid at 1 A is only a few millijoules; a pump or a stubborn solenoid can be more, and repetitive avalanche is a separate rating. Swapping to the DMTH or the IPD does not make the unclamped low-sides safer. The missing diode is still leftover 3 in `docs/HARDWARE_STATUS_rev_o.md`.

## 40 V and the SMAJ33A

All four parts are 40 V, which matches the injector clamp already on the board (SMAJ33A, LCSC C143131, D5–D8). SMAJ33A standoff is 33 V. Breakdown for that type is about 36.7–40.6 V, and the 10/1000 µs clamping voltage is **53.3 V**. That is above 40 V. US1M (D1–D4) is the flyback that should catch a normal injector spike near the 12 V rail. The TVS is the second line. A hard clamp event can still put the drain above the FET’s DC rating. That is true for the NCE, the DMTH, and the IPD alike, so it does not pick a winner. A 60 V FET would sit above that clamp voltage and would be a different design than the 40 V class this note was asked to stay in.

Low-side drains have neither diode nor TVS. Their voltage limit is the FET itself.

## What would change the recommendation

1. A measured RDS(on) of the stuffed NCE at VGS = 3.3 V, at room temperature and hot, at a few amps. If that number stays low enough for the pump Quintin actually uses, the NCE can stay with no driver.
2. The same measurement on an IPD90N04S4L-04 before putting C536903 in `bom_replace_microcore-o.csv`.
3. A gate driver to ~10 V, if the measurement says the NCE is not enhanced. That is new schematic parts, not a FET swap.
4. Flyback diodes on Q5–Q7, whatever FET is fitted. Separate from this comparison.
