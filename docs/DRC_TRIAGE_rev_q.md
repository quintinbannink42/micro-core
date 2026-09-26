# DRC triage — rev q

**Date:** 2026-09-26
**Board:** `microcore.kicad_pcb` on `main` at `da9c606` (Create Board `boards/microcore-q/` already landed), plus one frame via.
**Checker:** `kicad-cli` 10.0.6

```
kicad-cli pcb drc --format json --severity-all --units mm --schematic-parity
```

`kicad-cli` prints three separate counters. The 473 violations are not the sum of the other two.

| Counter | Before | After | Delta |
|---|---:|---:|---:|
| Violations | 473 (207 error / 266 warning) | 473 (207 error / 266 warning) | 0 |
| Unconnected items | 2 | 1 | -1 |
| Schematic parity | 222 | 222 | 0 |

Every violation category count is unchanged. The only delta is the floating F.Cu GND island, which was an unconnected item, not one of the 473.

Drill origin is still `(aux_axis_origin 107.5 148.0872)`. Hellen modules M1/M2/M3 were not edited. No fab pack in this change.

## Triage

| Category | Count | Owner | Action |
|---|---:|---|---|
| `items_not_allowed` module pads | 132 | Hellen module. M1 81, M2 31, M3 20. Pads sit in the module keepout. | ignore |
| `items_not_allowed` tracks | 67 | Frame tracks clipped by the M1/M2/M3 keepouts (some hits are counted twice because a board-level keepout copies the module keepout). Includes the shortened `/OUT_INJ1` segment from rev q. | ignore |
| `padstack` | 159 | Hellen module. M2 111, M1 32, M3 16. | ignore |
| `silk_over_copper` | 53 | Frame silk on Q/R/D, including the D9–D14 back silk noted on rev p. | done (follow-up) |
| `silk_over_copper` | 28 | Hellen M2. | later |
| `silk_overlap` | 19 | Frame reference silk (injector FETs, ballast resistors, LS FETs). | done (follow-up) |
| `silk_overlap` | 1 | Hellen M3 vs Q2. | later |
| `lib_footprint_issues` | 5 | Tooling. See below. | ignore |
| `shorting_items` | 4 | Hellen pad G vs an empty-net pad, or vs one frame track. Exact pairs below. | ignore |
| `clearance` | 2 | Hellen M3. PTH E4 `/V5_REF` vs empty pad G on B.Cu and In1.Cu. | ignore |
| `solder_mask_bridge` | 1 | Hellen M3. Same E4 vs pad G pair, rear mask. | ignore |
| `copper_edge_clearance` | 1 | Hellen M3 pad G on In2.Cu touches Edge.Cuts. | ignore |
| `holes_co_located` | 1 | Frame. Two identical `/INJ1` vias. | done (follow-up) |
| Unconnected, M2 pad S1 | 1 | Hellen module. Pad is inside the M2 keepout, so the pour cannot reach it. | ignore |
| Unconnected, F.Cu GND island | 1 | Frame pour west of the M1 keepout. | fix-now (done) |
| Schematic `net_conflict` | 175 | Hellen module. All 175 name M1, M2, or M3. None name a frame ref (Q, U, R, D, C, J). | ignore |
| Schematic `footprint_symbol_mismatch` | 32 | Frame library-id string. Embedded name is `DPAK` / `R0603` / `DO214AC`; the symbol says `microcore-fp:...`. Same land. D1–D14, Q1–Q7, R1–R11. | left (see follow-up) |
| Schematic `footprint_symbol_field_mismatch` | 15 | Cosmetic. J8 datasheet `~` vs empty; M1/M2 description; LCSC field missing on D1–D8 and R8–R11. BOM is `bom_replace_microcore-q.csv`. | ignore |

132 + 67 + 159 + 53 + 28 + 19 + 1 + 5 + 4 + 2 + 1 + 1 + 1 = 473.

## Frame fix

One unconnected item was frame copper. The F.Cu GND fill had a 27.1 mm² island, bbox `(129.12, 74.54)`–`(133.68, 87.16)`. It sits west of the M1 keepout (keepout starts at x = 133.68119) and east of the M2 keepout (ends at x = 126.55). Nothing on that island was a stitch. B.Cu under it is the main GND pour.

Stitch via, same size as the other GND stitches:

| | |
|---|---|
| At | `(131.3, 82)` |
| Size / drill | 0.8 / 0.4 |
| Layers | F.Cu – B.Cu |
| Net | `GND` |

Nearest foreign copper is about 1.4 mm (`/VBAT`, `/VIGN_SENSE`, M1 pad G). The via is outside all three module keepouts. Both pours already covered that point, so the stored fill did not need a rewrite. After the via, unconnected items are 1. Violation counts stayed 473. No new short, clearance, keepout, or parity item.

## Hellen electrical noise (do not edit M1/M2/M3)

These are the same pairs `docs/HARDWARE_STATUS_rev_q.md` inherited from rev p. No project net or label on a frame part is wrong. The empty pad is `<no net>` copper inside the module.

**Shorts**

| Pair | Where |
|---|---|
| M3 pad G `<no net>` on F.Cu `(186.175, 82.265)` | Frame track `/VR_OUT` on F.Cu, length 2.6163 mm, start `(184.15, 83.622)` |
| M3 pad G `GND` `(178.725, 75.84)` | M3 pad G `<no net>` `(185.925, 72.64)`, both F.Cu |
| M1 pad G `GND` `(133.28119, 76.67602)` | M1 pad G `<no net>` `(133.28119, 79.72601)`, both F.Cu |
| M1 pad G `GND` `(133.28119, 76.67602)` | M1 pad G `<no net>` `(137.18119, 74.12602)`, both F.Cu |

**Clearance and mask (one pad pair, three reports)**

M3 PTH pad E4 `/V5_REF` `(193.425, 73.04)` against M3 pad G `<no net>` `(186.025, 72.7775)` on B.Cu and on In1.Cu. Actual clearance 0 mm, rule 0.1 mm. The B.Cu pair is also the rear solder-mask bridge.

**Edge**

M3 pad G `<no net>` on In2.Cu `(185.7875, 72.74)` touches the Edge.Cuts rectangle `(107.5, 71.5)`–`(197.5, 148.0872)`. Rule 0.2 mm, actual 0.

**Unconnected left in place**

M2 pad S1 `GND` `(109.850001, 87.15)` vs the F.Cu GND zone. The pad is inside the M2 keepout `(109.75, 82.2)`–`(126.55, 102.79)`. A via there would be another `items_not_allowed`.

**`lib_footprint_issues`**

| Ref | Report |
|---|---|
| M1 | Library `hellen-one-mega-mcu100-0.3` is not enabled in this KiCad config |
| M2 | Library `hellen-one-power_12and5V-0.3` is not enabled |
| M3 | Library `hellen-one-vr-max9924-0.3` is not enabled |
| J8 | Library `hellen-one-common` is not enabled |
| J1 | Footprint `TE_776231` not found in `kicad6-libraries` |

Create Board already produced `boards/microcore-q/` with this J1. Do not retarget the AMPSEAL footprint from this warning.

**Duplicate via**

Two board-level vias, both `/INJ1`, both `(174.2, 90.35)`, size 0.8, drill 0.4. UUIDs `7e5055f5-3e87-43d5-ba01-377e73eca3d2` and `bb928a49-411f-561d-bb74-63aa78d8f3f6`. Same net, so this was one extra drill mark, not a short. The follow-up below removed `bb928a49-411f-561d-bb74-63aa78d8f3f6` and kept `7e5055f5-3e87-43d5-ba01-377e73eca3d2`.

## What still blocks a fab order

Nothing beyond Hellen noise and a human copper review.

`boards/microcore-q/` is already on `main`. This pass did not add a short, a clearance error, or a frame unconnected item. The remaining DRC errors are module keepout hits, the four pad-G shorts, the M3 E4 clearance/mask pair, the M3 edge hit, and M2 pad S1. Frame silk warnings and the duplicate `/INJ1` via are cleared in the follow-up below. Library-id parity warnings remain. A person should still look at the rev q gate-driver copper and at this stitch before ordering.

## Frame silk and duplicate via

Follow-up on the frame rows above. Hellen M1/M2/M3 were not edited. Drill origin is still `(107.5, 148.0872)`. No fab pack. Same checker as the table above.

| Category | Before | After | Delta |
|---|---:|---:|---:|
| Violations | 473 (207 error / 266 warning) | 400 (207 error / 193 warning) | -73 |
| `silk_over_copper` | 81 | 28 | -53 (frame Q/R/D, including D9–D14 back silk) |
| `silk_overlap` | 20 | 1 | -19 (frame reference silk) |
| `holes_co_located` | 1 | 0 | -1 |
| Unconnected items | 1 | 1 | 0 |
| Schematic parity | 222 | 222 | 0 |

Errors stayed 207. `items_not_allowed`, `padstack`, `shorting_items`, `clearance`, the M3 mask/edge pair, and M2 pad S1 did not move. The one remaining `silk_overlap` is Q2's reference against M3 silk. The 28 `silk_over_copper` hits are all M2.

The extra `/INJ1` via `bb928a49-411f-561d-bb74-63aa78d8f3f6` is gone. The via kept at `(174.2, 90.35)` is `7e5055f5-3e87-43d5-ba01-377e73eca3d2` (0.8 / 0.4, F.Cu–B.Cu).

Silk edits are on the frame footprints only. Reference text for Q3–Q6 and R8–R11 moved off the pad or the neighboring outline. Q/R/D outline silk, including the D9–D14 back silk, was shortened or dropped where it crossed a pad or another frame outline. Parts still have silk. M2 graphics and the Q2 reference were not moved.

`footprint_symbol_mismatch` (32) was left. Writing `microcore-fp:DPAK` / `R0603` / `DO214AC` on the embedded footprint clears that parity warning, then KiCad diffs the copy against `footprints/*.kicad_mod` and adds `lib_footprint_mismatch` (19 on the untouched board, more after these silk trims). The lands were not redrawn to force that match.
