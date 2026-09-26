# Copper look — rev q

**Date:** 2026-09-26
**Board:** `microcore.kicad_pcb`
**Tip:** `1881d92a4f4177e305fe7676f20a1317a34590b1` (rev Q title block, after PR #13)
**Drill origin:** `(aux_axis_origin 107.5 148.0872)`
**Scope:** gate-driver copper (U1–U4, C1–C8, R1–R7, Q1–Q7 gates) and the GND stitch at `(131.3, 82)`. Hellen M1/M2/M3 were not edited and were not re-routed.

## Verdict

**PASS with notes.** No frame short or unconnected driver net showed up in this look. Leftover #3 in `docs/HARDWARE_STATUS_rev_q.md` can be cleared after Quintin eyeballs the pours listed at the bottom.

This review does not order boards. Create Board, the JLC BOM, and a look at the B.Cu pours in KiCad are still required before an order.

## How this was checked

The board file at the tip above was parsed directly: footprints, pad nets, tracks, vias, keepout rectangles, and the stored GND fills.

Pad centers use KiCad's Y-down rotation. Two centers were checked against the rev q interactive BOM (`boards/microcore-q`, generated at `da9c606`, before the stitch via): C1 pin 1 and R7 pin 1. Later commits on this tip are the stitch via, a duplicate `/INJ1` via removal, and silk. Driver copper is the same file the BOM was plotted from, plus that stitch.

`kicad-cli` is not in this environment, so DRC was not re-run. The counts below are the ones `docs/HARDWARE_STATUS_rev_q.md` records for this same tip. This look did not change the board, so those counts still belong to this file.

Default netclass clearance in `microcore.kicad_pro` is 0.1 mm. GND zone `connect_pads` clearance is 0.2 mm. Distances below were measured edge to edge on the stored geometry (track width and via diameter included). Roundrect pad corners were modeled as full rectangles, so pad-to-pour numbers from that model are not used as pass/fail.

## Checklist

| Item | Result | Note |
|---|---|---|
| U1–U4 placement and nets | Pass | All four SLM27524CA-DG, LCSC C2921387, `microcore-fp:SOIC-8`, layer B.Cu. Pin map matches the rev q status table. |
| ENA / ENB / VDD on `/V12_RAW` | Pass | U1–U4 pins 1, 6, and 8. One track/via island with the bypass caps, D1–D4, D9–D11, J1 pin 1, and M2 V3. |
| Driver GND | Pass | Pin 3 on U1–U4 is `GND`. U4 pin 2 (INA) is also `GND`. |
| U4 channel A | Pass | INA tied to `GND`. OUTA net is `unconnected-(U4-OUTA-Pad7)` with zero tracks. |
| Bypass C1–C8 | Pass | B.Cu. C1/C3/C5/C7 are 100 nF C14663. C2/C4/C6/C8 are 1 uF C559769. Each has one GND pad and one `/V12_RAW` pad, and the V12 pads sit on the same island as the drivers. |
| Gate path R1–R7 to Q1–Q7 | Pass | Each used OUT net is its own island: driver OUT pad, tracks, one resistor pad. Each gate net is its own island: the other resistor pad to the DPAK gate. MCU nets are not on those pads. |
| MCU net vs driver OUT copper | Pass | No shared copper. Closest measured gap is 0.134 mm (see notes). |
| `/V12_RAW` spine and stitches | Pass | B.Cu spine at x = 167.75. Stitch via at `(158.6, 113.0)`. U4 VDD uses the F.Cu hop. |
| R6 / U3 OUTA detour | Pass | Leaves B.Cu west of Q3, crosses on In1.Cu, returns to F.Cu at R6. No overlap with `/VR_N`. |
| Island stitch `(131.3, 82)` | Pass | GND, 0.8 / 0.4, F.Cu–B.Cu. Inside the small F.Cu GND island and the main B.Cu GND pour. Outside M1, M2, and M3 keepouts. No foreign-net fill hit. |
| DRC electrical on frame nets | Attention | Not re-run here. Recorded for this tip: 399 violations (207 error / 192 warning), 1 unconnected (M2 pad S1), `silk_overlap` 0. Recorded `shorting_items` are the four Hellen pad-G pairs. This look found 0 overlaps among the driver nets, `/V12_RAW`, `/VR_N`, and the GND fills. |

## Driver map (measured)

SLM27524 pinout used: 1 ENA, 2 INA, 3 GND, 4 INB, 5 OUTB, 6 VDD, 7 OUTA, 8 ENB.

| Ref | At (mm) | Channel | MCU pad | OUT pad | Resistor | FET gate |
|---|---|---|---|---|---|---|
| U1 | (171.5, 84.2) | B | pin 4 `/OUT_INJ1` (M1 E17) | pin 5 `Net-(U1-OUTB)` | R1 | Q1 |
| U1 | | A | pin 2 `/OUT_INJ2` (M1 E16) | pin 7 `Net-(U1-OUTA)` | R2 | Q2 |
| U2 | (173.4, 90.0) | B | pin 4 `/OUT_INJ3` (M1 E15) | pin 5 `Net-(U2-OUTB)` | R3 | Q3 |
| U2 | | A | pin 2 `/OUT_INJ4` (M1 E14) | pin 7 `Net-(U2-OUTA)` | R4 | Q4 |
| U3 | (173.8, 96.1) | B | pin 4 `/OUT_LS1` (M1 E18) | pin 5 `Net-(U3-OUTB)` | R5 | Q5 |
| U3 | | A | pin 2 `/OUT_LS2` (M1 E19) | pin 7 `Net-(U3-OUTA)` | R6 | Q6 |
| U4 | (184.0, 106.0) | B | pin 4 `/OUT_LS3` (M1 E20) | pin 5 `Net-(U4-OUTB)` | R7 | Q7 |
| U4 | | A | pin 2 `GND` | pin 7 no track | — | — |

R1–R7 are 12 ohm on F.Cu. Q1–Q7 are NCE4080K on F.Cu, gate on pad 1. Local caps sit east of each driver: C1+C2 at U1, C3+C4 at U2, C5+C6 at U3, C7+C8 at U4.

MCU copper for `/OUT_INJ1`–`/OUT_INJ4` and `/OUT_LS1`–`/OUT_LS3` joins the M1 edge pad to the driver input (inner layer, one via, short B.Cu into the pin). It does not land on R1–R7 or on a FET gate. The old through-vias that used to sit on those resistors are gone (no co-located via pair anywhere on the board).

## `/V12_RAW` spine, hop, and the south stitch

- Existing B.Cu rail includes the segment `(154.8, 110.4)` → `(167.75, 110.4)`.
- Spine is the B.Cu track at x = 167.75 from y = 110.4 up to y = 83.5, with taps to U1–U3 and the nearby caps.
- U4 VDD does not stay on that spine. A via at `(168.8, 88.4)` takes `/V12_RAW` to F.Cu, runs `(168.8, 83.2)` → `(182.4, 83.2)` → `(182.4, 104.0)` → `(184.5, 104.0)`, then a via back to B.Cu and into U4 pin 6 at `(186.475, 105.365)`. Enables are the same net on the chip.
- In the window x = 165–190, y = 80–112, the closest foreign F.Cu copper to that hop is `/OUT_INJ1` at 0.150 mm. Next is Q1 drain copper at 0.250 mm. Both are above the 0.1 mm default clearance.
- Stitch via `(158.6, 113.0)`, uuid `9e514094-7125-4cbe-82d1-8ea222a04ee1`, 0.8 / 0.4, F.Cu–B.Cu, net `GND`. The via center is inside the main F.Cu GND fill and inside a B.Cu GND polygon of about 33.9 mm2 (the pocket south of the spine).

Reviewed tracks in the driver window (x roughly 150–200) stay at least 0.200 mm off the stored GND fill. The minimum hits that 0.200 mm value on several `/V12_RAW`, gate, and OUT segments, which matches the zone clearance parameter.

## R6

`Net-(U3-OUTA)` path:

1. B.Cu from U3 pin 7 `(176.275, 96.735)` to `(174.8, 96.735)` to `(174.8, 97.1)`.
2. Via `(174.8, 97.1)`.
3. In1.Cu `(174.8, 97.1)` → `(180.0, 97.1)` → `(180.0, 101.2)` → `(183.3, 101.2)`.
4. Via `(183.3, 101.2)`, then F.Cu into R6 pad 2 at `(184.7, 101.2)`.

x = 174.8 is west of the Q3 drain tab. The In1 run at y = 97.1 is north of the `/VR_N` via at `(178.3, 98.5)`. `/VR_N` is one island (J1 pin 29, M3 W1, vias at `(178.3, 119.2)`, `(178.3, 98.5)`, `(179.1, 90.0)`) and does not overlap this net. R6 pad 1 continues on F.Cu to Q6 gate.

## Island stitch `(131.3, 82)`

| | |
|---|---|
| Via | One via, uuid `a7c3e1d4-6b28-4f05-9c71-2e8d4b6a91f0` |
| At | `(131.3, 82.0)` |
| Size / drill | 0.8 / 0.4 |
| Layers | F.Cu – B.Cu |
| Net | `GND` |

- F.Cu: via center is inside the small GND fill, area 27.14 mm2, bbox `(129.115, 74.541)`–`(133.681, 87.157)`. That is the island west of the M1 keepout.
- B.Cu: via center is inside the main GND pour.
- In1.Cu and In2.Cu: no GND fill covers the point, and no foreign fill covers the via disk.
- Keepouts (same rectangle copied at board level and inside the module): M2 `(109.750, 82.200)`–`(126.550, 102.790)`, M1 `(133.681, 74.126)`–`(167.481, 109.926)`, M3 `(178.768, 72.840)`–`(193.668, 82.240)`. The via disk is outside all three. Gap from the via copper to the M1 keepout edge is 1.981 mm. Gap to the M2 keepout edge is 4.355 mm.
- Nearest foreign copper, measured from the 0.8 mm via disk: `/VIGN_SENSE` F.Cu track `(128.3, 81.85)`–`(132.4, 85.95)` at 1.465 mm. Next is `/VBAT` F.Cu at 1.501 mm. No foreign pad or track intersects the via.

## DRC electrical (this tip, not re-run)

From `docs/HARDWARE_STATUS_rev_q.md` for `1881d92`:

| Counter | Value |
|---|---|
| Violations | 399 (207 error / 192 warning) |
| Unconnected | 1 (M2 pad S1 vs F.Cu GND) |
| `shorting_items` | 4 (Hellen pad-G pairs) |
| `clearance` | 2 (Hellen M3) |
| `silk_overlap` | 0 |
| `tracks_crossing` | 0 |

Owner table: `docs/DRC_TRIAGE_rev_q.md`. Nothing in that error set is a frame driver net. This look's overlap pass (driver nets, `/V12_RAW`, `/VR_N`, GND fills, same layer) found 0 intersecting pairs.

## What Quintin should still eyeball in KiCad

These are visual checks. The geometry pass did not flag them as shorts.

1. B.Cu pours around U1–U4. Several OUT nets are stair-stepped in 0.2 mm jogs (U1 OUTA/OUTB, U2 OUTB, U3 OUTB, U4 OUTB). Confirm the GND pour still has a real neck around those stairs and around the x = 167.75 spine.
2. West side of U1 on B.Cu. `/OUT_INJ2` and `Net-(U1-OUTB)` come within 0.134 mm near `(171.53, 85.52)` to `(171.66, 85.56)`. Their through-via copper is 0.143 mm apart near `(170.91, 85.75)` to `(170.82, 85.87)`. Default clearance is 0.1 mm.
3. U3 input via `(173.25, 95.5)` vs the `Net-(U3-OUTB)` B.Cu stair. Gap measured 0.152 mm at x = 173.25, y about 95.90 to 96.05.
4. F.Cu `/V12_RAW` hop from `(168.8, 83.2)` to `(184.5, 104.0)`, especially the vertical at x = 182.4 between the two DPAK columns, and the 0.150 mm approach to `/OUT_INJ1`.
5. R6 on In1.Cu at y = 97.1 where it passes the Q3 drain (F.Cu) and the `/VR_N` via at `(178.3, 98.5)`.
6. R7, vertical on F.Cu at x = 184.16. Gate net and OUT net are 0.145 mm apart, which is the resistor gap. Confirm the stair from U4 does not nick the gate track.
7. U4 pin 7, the floating OUTA pad at `(186.475, 106.635)` on B.Cu. It has no track. Confirm the B.Cu GND pour is pulled back from that pad and from the other SOIC pads (the pour is close; a rectangle model of the roundrect is not a reliable clearance).
8. Stitch `(131.3, 82)` on the F.Cu island edge, and stitch `(158.6, 113.0)` in the B.Cu pocket south of the spine. Keepout edges are clear on the numbers above; the pour outline is the part to see.

## Order

No fab order from this review alone. The board file was not modified.
