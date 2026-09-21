> **Superseded for current work:** see [HARDWARE_STATUS_rev_m.md](HARDWARE_STATUS_rev_m.md) (rev m: D1–D8 collector re-route).

# Micro Core hardware status — rev l

**Date:** 2026-09-21  
**Repo:** `quintinbannink42/micro-core`  
**KiCad basename:** `microcore` (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`)  
**BOARD_REVISION:** **l** (fab-affecting: refill F.Cu+B.Cu GND pours after rev-k diode move; Core EFI silkscreen)  
**Create Board artifacts:** last packages on main include `boards/microcore-j/`. **`boards/microcore-l/` after this rev is merged to `main`** (Create Board on a PR branch may run but fab files land on `main` only).

## Verdict

**Not production-ready.** GND pours are real filled copper on both outer layers, and Core EFI branding is on F.SilkS and B.SilkS. Do not order boards until a human copper pass fixes the rev-k B.Cu diode collectors (true shorts + unconnected diode pads) and Create Board produces `boards/microcore-l/`.

`microcore.kicad_pcb` remains substantial (~666 kB, 4 top-level zones, filled F.Cu+B.Cu GND). Drill origin unchanged: Edge.Cuts bottom-left `(107.5, 148.0872)`. D1–D8 stay on **B.Cu** beside J1, outside the AMPSEAL silk/body keepout.

## What landed (rev l)

### 1. F.Cu + B.Cu GND pours refilled

| Item | Value |
|---|---|
| Nets | **GND** only (not `/SGND`) |
| Layers | `F.Cu` and `B.Cu` (separate zones) |
| Outline | Edge.Cuts inset 0.4 mm: `(107.9, 71.9)`–`(197.1, 147.6872)` |
| Fill | `fill yes`; KiCad 10.0.6 `--refill-zones --save-board` |
| Clearance | `connect_pads` 0.2 mm |
| Thermal | `thermal_gap` 0.25 / `thermal_bridge_width` 0.3 |
| Islands | `island_removal_mode 0` (keep); F.Cu has a leftover island (see DRC) |

Filled-polygon bbox after refill matches the zone outline on both outer layers, including the west/east B.Cu diode flanks. AMPSEAL / module keepouts still forbid copperpour inside those courtyards.

`kicad-cli pcb drc` reports **0 GND ↔ `/SGND` short pairs**. Sensor ground stays a separate net.

### 2. Silkscreen branding (ASCII only)

Primary **F.SilkS** stack in the empty pocket east of mega-mcu100 / west of vr-max9924 / north of the FET cluster (`x=168.8`, `y=74.5–80.6`), plus the same strings on **B.SilkS** (`x=173.1`, mirrored). Avoids J1 courtyard, diode flanks, pads, and vias.

| String | Role |
|---|---|
| `Core EFI` | Brand |
| `Micro Core` | Model |
| `coreefi.co.za` | Company site |
| `microcore` | KiCad / fab basename |
| `coreefi_micro` | Firmware board id |
| `rev L` | Board revision |

All silk ≥ 0.8 mm (board min text height). Comments-layer note also says rev L.

## DRC summary (kicad-cli **10.0.6**)

Command: `kicad-cli pcb drc --format report --severity-all --units mm --refill-zones --output … microcore.kicad_pcb`

| Category | Count | Triage |
|---|---:|---|
| **Total violations** | **509** | 255 error / 254 warning |
| items_not_allowed | 199 | Hellen module keepout (M1 81 / M2 31 / M3 20 + other) — merge noise |
| padstack | 159 | Hellen merge noise |
| silk_over_copper | 65 | Mostly module silk clipped by mask/pads |
| **shorting_items** | **28** | **Must triage** — see below |
| silk_overlap | 20 | Cosmetic / module |
| solder_mask_bridge | 14 | Mostly B.Cu diode pad vs opposite-net stub |
| tracks_crossing | 7 | B.Cu INJ collectors overlapping each other |
| clearance | 6 | Includes B.Cu INJ vs AMPSEAL vias; FET cluster 0.05 mm |
| lib_footprint_issues | 5 | Vendored / Hellen |
| via_dangling | 4 | East INJ vias @ x=195.4 (D5–D8 alley) |
| copper_edge_clearance | 1 | Edge |
| holes_co_located | 1 | Merge |
| **unconnected_items** | **14** | 12 diode pad/track; 1 F.Cu island; 1 M2 S1 keepout |
| GND ↔ `/SGND` shorts | **0** | Pour did not bridge sensor ground |

### Shorts — real vs Hellen noise

**True / layout-blocking (rev k B.Cu diode collectors, not introduced by the pour):**

- SMA pads vs same-x 1.5 mm stubs: `/INJn` ↔ `/V12_RAW` on D1–D4, `/INJn` ↔ GND on D5–D8 (track lands on the opposite pad of the same diode).
- B.Cu INJ collectors vs AMPSEAL fanout vias: `/INJ3`↔`/HALL_CAM`, `/INJ3`↔`/IGN2`, `/INJ4`↔`/IGN4`, `/INJ4`↔`/IAT`, `/INJ1`↔`/DIN2`, `/INJ2`↔`/INJ3`.
- Related: `tracks_crossing` among B.Cu INJ spines; `via_dangling` on east INJ vias.

**Hellen-merge / empty-net (same class as rev i):**

- GND or `/VR_OUT` vs empty M1/M3 pad G (3 + 1).
- `/VR_N` vs Q1/Q3 drain tracks near VR keepout; Q4 pad vs R9 pad; `/INJ3`↔`/VR_OUT` on In1 (3).

**Keepout unconnected:** F.Cu GND zone ↔ M2 pad S1 (copperpour not allowed in module keepout) — treat as false positive unless copper review says otherwise. One F.Cu GND island remains (`island_removal_mode 0`).

## Create Board / fab path

Workflow: `.github/workflows/create-board.yaml`

1. `on: push` and `workflow_dispatch`
2. Job `guard-pcb-not-empty` runs `bin/check-pcb-not-empty.sh microcore.kicad_pcb`
3. Reuses `andreika-git/hellen-one/.github/workflows/create-board.yaml@master`

**Exact next step for CI artifacts:** merge this branch to default **`main`**. Fab files are committed by that reusable workflow **on `main` only**.

`bom_replace_microcore-l.csv` is named for `BOARD_PREFIX`+`BOARD_SUFFIX`+`BOARD_REVISION` = `microcore-l`. ASCII-only comments (no ohm-symbol). LCSC rows unchanged from rev k/j.

## Leftovers — before ordering boards

1. **Human copper pass on D1–D8 B.Cu placement** — collectors must not cross AMPSEAL NPTH/vias or the opposite SMA pad; diode pads must connect to their nets. This is a **true blocking leftover**.
2. Green Create Board `boards/microcore-l/` (CPL/JLC BOM with diodes on bottom).
3. Residual Hellen keepout / padstack / empty-net pad G noise (waive as merge artifact after the diode pass, or clean if copper review wants it).
4. LS channels still lack flyback/TVS (SPEC was injector-focused; not closed this pass).
5. ANALOG/HALL frame stubs remain mega-module-only (already waived in SPEC).

## Incident guard

Do not whole-file-replace `microcore.kicad_pcb`. Guard: `bin/check-pcb-not-empty.sh` (min 10 kB + `(zone` present). Drill origin must stay Edge.Cuts bottom-left `(107.5, 148.0872)`.
