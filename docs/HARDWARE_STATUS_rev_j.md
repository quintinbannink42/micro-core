> **Superseded for current work:** see [HARDWARE_STATUS_rev_l.md](HARDWARE_STATUS_rev_l.md) (rev l: GND pour refill + Core EFI silk).

# Micro Core hardware status — rev j

**Date:** 2026-09-21  
**Repo:** `quintinbannink42/micro-core`  
**KiCad basename:** `microcore` (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`)  
**BOARD_REVISION:** **j** (fab-affecting: injector TVS + UF flyback + 2nd 12 Ω per INJ channel on sch+PCB)  
**Create Board artifacts:** last green `boards/microcore-h/`; `boards/microcore-i/` may appear from CI on `main`; **`boards/microcore-j/` after this rev is merged to `main`**.

## Verdict

Injector SPEC power-stage protection is now on schematic and PCB (real `DO214AC` footprints). **Not a fab order yet** until Create Board produces `boards/microcore-j/` and a human copper pass reviews the new alley / pocket-C parts against AMPSEAL keepout. Residual DRC is still expected Hellen keepout / empty-net module-pad merge (same class as rev i).

`microcore.kicad_pcb` remains substantial (~673 kB, 4 zones, 33 footprints). Drill origin unchanged: Edge.Cuts bottom-left `(107.5, 148.0872)`.

## What landed (rev j)

Per injector channel 1–4 (`INJ4.kicad_sch` + PCB):

| Ref | Function | Package | LCSC (`bom_replace_microcore-j.csv`) |
|---|---|---|---|
| R1–R4 | existing 12 Ω gate | R0603 | C22783 |
| R8–R11 | **2nd 12 Ω high-Z ballast** (FET drain → AMPSEAL `/INJn`) | R0603 | C22783 |
| D1–D4 | **US1M UF flyback** (anode `/INJn`, cathode `/V12_RAW`) | DO-214AC / SMA | C112545 |
| D5–D8 | **SMAJ33A** 33 V unidirectional TVS (cathode `/INJn`, anode GND) — DO-214 equivalent of SMBJ33A | DO-214AC / SMA | C143131 |

SMAJ33A is the SMA (DO-214AC) equivalent of SMBJ33A (SMB / DO-214AA), chosen so the FET cluster did not have to grow into the AMPSEAL courtyard. Electrical clamp is the same 33 V unidirectional TVS family.

LS3 (Q5–Q7) still has gate 12 Ω only. SPEC power-stage text is **4× injector** DPAK + TVS + UF + 2×12 Ω; LS flyback was not added.

### PCB placement (FET cluster not exploded)

Moving Q1–Q7 south/east would enter AMPSEAL courtyard (`J1` TE_776231 @ `(152.2, 129.99)`, silk ±38.45 × ±16.05 → north ~y=113.94) or the board edge. Cluster left in place; new parts use empty pockets:

- **R8–R11** at the SW corner of Q1–Q4; existing drain vias nudged off the DPAK tab so the ballast is the only drain↔`/INJ` link (`Net-(Qn-D)` vs `/INJn`).
- **D1–D4 (US1M)** in the power–MCU alley (~x=130, y=86.5–104.5), west of mega-mcu100, east of `power_12and5V` keepout.
- **D5–D8 (SMAJ33A)** in pocket C east of MCU / west of VR keepout (~x=170–175, y=76.8–80.2).
- `/V12_RAW` spine in the alley to the existing In2 via at `(111.4, 105.2)`.
- AMPSEAL keepout zones and F.Cu/B.Cu GND pour polygons were **not** rewritten (filled polygons unchanged). New tracks wrap **south of MCU** (~y=110.6–112.7), north of AMPSEAL.

Vendored footprint: `footprints/DO214AC.kicad_mod`.

## DRC leftovers (KiCad 10)

This environment has **no `kicad-cli`**. Last counted DRC was rev i (kicad-cli **10.0.6**): **425** total, mostly:

- padstack 159 (Hellen merge)
- items_not_allowed 199 (module keepout tracks)
- silk_* 43
- clearance 12
- shorting_items 4 (empty-net module pad G)
- unconnected_items 1 (F.Cu GND zone ↔ M2 pad S1 inside keepout)

**Expected new noise after rev j (not re-run here):**

- Courtyard tightness: SMA vs MCU east edge / VR west keepout; 0603 vs DPAK courtyards at Q1–Q4 SW corners.
- Extra `items_not_allowed` if any wrap track clips a module keepout.
- Zone fills are stale until KiCad refills F.Cu/B.Cu GND (Create Board / pcbnew fill). Thermal relief around new GND vias for D5–D8 should appear after refill.

Not claimed clean. Human copper eye still required on AMPSEAL fanout and empty-net module pad G shorts (rev i leftover).

## Create Board / fab path

Workflow: `.github/workflows/create-board.yaml`

1. `on: push` and `workflow_dispatch`
2. Job `guard-pcb-not-empty` runs `bin/check-pcb-not-empty.sh microcore.kicad_pcb`
3. Reuses `andreika-git/hellen-one/.github/workflows/create-board.yaml@master` (`hellen-one/kicad/bin/export.sh` → gerber/BOM/CPL/ibom under `boards/microcore-${BOARD_REVISION}/`)

**Exact next step for CI artifacts:** merge this branch to default **`main`** (or run **Actions → Create Board → Run workflow** on `main` after merge). Fab files are committed by that reusable workflow **on `main` only**. A PR-branch push may *run* the workflow but will not populate `boards/microcore-j/` on `main`.

`bom_replace_microcore-j.csv` is named for `BOARD_PREFIX`+`BOARD_SUFFIX`+`BOARD_REVISION` = `microcore-j`.

## Must-list vs `docs/SPEC.md`

| # | Item | Status |
|---|---|---|
| 1 | GND↔SGND / AMPSEAL fanout | Unchanged from rev i (K10: 0 GND↔SGND short pairs; empty-net pad G leftovers) |
| 2 | J8 GND stitch | Still present (rev i) |
| 3 | SMBJ33A + UF flyback + 2×12 Ω on INJ | **Done on sch+PCB** (SMAJ33A DO-214AC + US1M + R8–R11) |
| 4 | ANALOG + HALL | Still waived (mega-module-only) |
| 5 | Q1–Q7 + gate Rs LCSC | Still in bom_replace |
| 6 | Create Board after PCB change | **Needs `main` merge** → `boards/microcore-j/` |

## Leftovers — before ordering boards

1. Green Create Board `boards/microcore-j/` with D1–D8 / R8–R11 on JLC BOM.  
2. Human copper pass: pocket C TVS, alley UF, ballast at FET SW, AMPSEAL fanout.  
3. KiCad 10 DRC + zone refill.  
4. LS flyback/TVS only if product later requires it (not in SPEC 4-ch injector power-stage).

## Incident guard

Do not whole-file-replace `microcore.kicad_pcb`. Guard: `bin/check-pcb-not-empty.sh` (min 10 kB + `(zone` present). This pass only appended footprints/segments and retargeted existing INJ drain stubs/vias.
