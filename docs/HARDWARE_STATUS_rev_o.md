# Micro Core hardware status — rev o

**Superseded by rev p (2026-09-24).** Quintin chose AOD4184A (LCSC C99124) plus LS TVS for budget and reliability. See `docs/HARDWARE_STATUS_rev_p.md`.

**Date:** 2026-09-22  
**Repo:** `quintinbannink42/micro-core`  
**KiCad basename:** `microcore` (`BOARD_PREFIX=micro`, `BOARD_SUFFIX=core`)  
**BOARD_REVISION:** **o** (fab-affecting: power FET swap to NCE4080K; LS Q5–Q7 and R5–R7 restored)  
**Create Board artifacts:** `boards/microcore-n/` is on main from rev n. **`boards/microcore-o/` after this rev is merged to `main`** (Create Board on a PR branch may run but fab files land on `main` only).

## Verdict

**Not production-ready.** Rev o puts NCE4080K on all seven power FETs and brings the low-side stage back. Do not order boards until Create Board produces `boards/microcore-o/` and a human accepts the gate-drive caveat below.

`microcore.kicad_pcb` stays substantial (F.Cu+B.Cu GND zones kept; refill after the LS restore is recorded below). Drill origin unchanged: Edge.Cuts bottom-left `(107.5, 148.0872)`. Core EFI silkscreen kept; letter bumped to **rev O**.

## What landed (rev o)

### 1. Power FET: VND14NV04-E → NCE4080K

All seven frame power FETs (Q1–Q7) are **NCE4080K**, LCSC **C191380**.

LCSC check (2026-09-22), page https://www.lcsc.com/product-detail/C191380.html :

| ID | What LCSC lists | Used? |
|---|---|---|
| **C191380** | NCE **NCE4080K**, MOSFET N-CH 40 V 80 A, package **TO-252-2L**, in stock (page showed about 21,877) | **Yes** |

Datasheet (LCSC PDF, NCE V2.0): VDS 40 V, ID 80 A, VGS ±20 V, VGS(th) 1.2 / 1.8 / 2.5 V (min / typ / max) at ID = 250 µA, RDS(on) < 7 mΩ at VGS = 10 V and ID = 20 A. No RDS(on) row at 4.5 V or 2.5 V.

`bom_replace_microcore-o.csv` rows (ASCII comments, no ohm symbol):

`Q1`…`Q7,"NCE4080K","DPAK","C191380"`

`U105` stays `STM32F407VGT6` / `LQFP100` / `C12345` on `mega-mcu100/0.3`. Not switched to mega-mcu64.

### 2. Footprint: existing DPAK land fits TO-252-2L

PCB footprint is still `microcore-fp:DPAK` (file `footprints/DPAK.kicad_mod`). It is a 2-lead + tab pattern, not a 3-lead gullwing:

| | Existing `DPAK` | LCSC EasyEDA land for C191380 (`TO-252-2_L6.6-W6.1-P4.57-LS9.9-BR-CW`) |
|---|---|---|
| Lead pitch | 4.56 mm (pads at y = ±2.28 mm) | **P4.57** (4.57 mm) |
| Lead pads | 2.2 × 1.2 mm | about 3.0 × 1.6 mm |
| Tab (drain) | 6.4 × 5.8 mm | about 6.2 × 5.8 mm |

Package body from the NCE drawing: lead width b = 0.66–0.86 mm, basic pitch e = 2.186–2.386 mm (JEDEC; the 2L part keeps the outer leads, so the span is about 2×e). The datasheet note says the lead pitch follows JEDEC. Pinout on the LCSC symbol is pin 1 Gate, pin 2 Drain (tab), pin 3 Source. That matches the footprint pads and the schematic symbol pin numbers already used for the old smart FET (1 = input/gate, 2 = drain, 3 = source).

The lead is narrower than the 1.2 mm pad. The lead pad is smaller than LCSC’s recommended land, and the pitch and tab match, so the footprint was **not** redrawn. Routing that already landed on these pads stays put.

### 3. Seven FETs: Q5–Q7 and R5–R7 restored

Rev n deleted the low-side stage. Rev o puts it back from the pre-rev-n sheet and copper:

| Ref | Role | Gate | AMPSEAL |
|---|---|---|---|
| Q5 | Fuel-pump LS | R5, 12 ohm | pin 8 `LS1_FP` |
| Q6 | Idle / VVT LS | R6, 12 ohm | pin 9 `LS2_IDLE` |
| Q7 | Boost / spare LS | R7, 12 ohm | pin 10 `LS3_BOOST` |

`LS3.kicad_sch` is the three-channel sheet again (hierarchical IN1–IN3 / OUT1–OUT3). Root sheet name is `LS3` (not `LS3-NC`). MCU labels `OUT_LS1` / `OUT_LS2` / `OUT_LS3` connect to the gates through R5–R7. J1 pads 8/9/10 carry `/LS1_FP` `/LS2_IDLE` `/LS3_BOOST` again.

LS still has **no** flyback diode and **no** TVS. That matches the pre-rev-n sheet (the note there already said flyback/TVS were injector-only). Injector protection is unchanged: D1–D4 US1M, D5–D8 SMAJ33A, ballast R8–R11, all on Q1–Q4.

### 4. NCE4080K is not a protected smart FET — gate drive caveat

VND14NV04-E was a logic-level protected low-side (current limit, thermal shutdown, internal clamp) that a 3.3 V MCU can drive directly. NCE4080K is a plain trench MOSFET.

- **The schematic is complete without a gate driver.** VGS(th) max is 2.5 V, and the MCU pin is 3.3 V, so the FET does turn on. Each gate is the existing 12 ohm series resistor (R1–R7) from the mega-mcu100 output. No driver, charge pump, or extra transistor was added.
- **The 7 mΩ rating does need ~10 V if you want that RDS(on).** The datasheet gives RDS(on) only at VGS = 10 V. At 3.3 V the worst-case device is 0.8 V above threshold. On-resistance at 3.3 V is not specified and will be higher than 7 mΩ, especially hot and at injector or fuel-pump current. A gate driver to about 10 V, or a different MOSFET with RDS(on) rated at 4.5 V or below, is required before this is a reliable power stage. That driver is **not** on this rev.
- **No internal clamp.** Injector channels still have US1M flyback and SMAJ33A. The three LS channels do not. Fuel-pump, idle, and boost solenoids are inductive. The only voltage limit on those drains is the 40 V FET itself.

## DRC summary (kicad-cli **10.0.6**)

Command: `kicad-cli pcb drc --format json --severity-all --units mm --refill-zones --save-board`

F.Cu+B.Cu GND zones were refilled after Q5–Q7 and R5–R7 were put back, so the new gate and drain pads are cleared out of the pour and the source pads sit on GND. Fill diff is polygon geometry. Footprints, drill origin `(107.5, 148.0872)`, and zone outlines were not moved. `schematic_parity` is empty (sheet and board agree).

| Category | Count | Triage |
|---|---:|---|
| **Total violations** | **467** | 217 error / 250 warning (rev n was 456: 217 / 239; rev m was 469: 219 / 250) |
| items_not_allowed | 199 | Hellen module keepout (M1/M2/M3) — merge noise |
| padstack | 159 | Hellen merge noise |
| silk_over_copper | 65 | Back to the rev m count; LS ref silk is on the board again (rev n was 56) |
| silk_overlap | 20 | Cosmetic / module (rev n was 18) |
| **shorting_items** | **10** | Same count as rev n. **No LS net** (`/LS*`, `Net-(Q5-IN)` …) |
| clearance | 5 | FET cluster / merge; same class as rev n |
| lib_footprint_issues | 5 | Vendored / Hellen |
| solder_mask_bridge | 2 | Same class as rev n (Q4/R9 injector side, not the restored LS FETs) |
| copper_edge_clearance | 1 | Edge |
| holes_co_located | 1 | Duplicate via leftover (Hellen) |
| **unconnected_items** | **2** | M2 pad S1 keepout vs F.Cu GND; one F.Cu GND island. **Not** Q5–Q7 and **not** J1 pins 8/9/10 |
| tracks_crossing | **0** | |
| via_dangling | **0** | |

### Shorts still present (rev n / rev m leftovers, not this pass)

- `/INJ3`↔`/VR_OUT` on In1 (Hellen leftover fanout vs VR).
- `/VR_N`↔`Net-(Q1-D)` and `/VR_N`↔`Net-(Q3-D)`.
- `Net-(Q4-D)`↔`Net-(Q2-D)` (injector ballast, not Q5–Q7).
- GND or `/VR_OUT` vs an empty-net module pad.

No short names `/LS1_FP`, `/LS2_IDLE`, `/LS3_BOOST`, or `Net-(Q5-IN)` / `Q6` / `Q7`.

Q5 pads after refill: gate `Net-(Q5-IN)`, drain `/LS1_FP`, source `GND`. Q6/Q7 follow the same pattern (idle, boost).

**Not a fab order yet.** Create Board `boards/microcore-o/` and a human decision on 3.3 V gate drive vs the 10 V RDS(on) rating are still required. The DRC blockers above are the preexisting Hellen merge / injector-VR shorts, not the FET swap or the restored LS stage.

## Create Board / fab path

Workflow: `.github/workflows/create-board.yaml`

1. `on: push` and `workflow_dispatch`
2. Job `guard-pcb-not-empty` runs `bin/check-pcb-not-empty.sh microcore.kicad_pcb`
3. Reuses `andreika-git/hellen-one/.github/workflows/create-board.yaml@master`, which applies `bom_replace_microcore-o.csv`

**Exact next step for CI artifacts:** merge this branch to default **`main`**. Fab files are committed by that reusable workflow **on `main` only**.

## Leftovers — before ordering boards

1. Green Create Board `boards/microcore-o/` and confirm the JLC BOM shows `NCE4080K` / `C191380` on Q1–Q7, `STM32F407VGT6` / `C12345` on `U105`, and R5–R7 present.
2. Decide the 3.3 V gate vs 10 V RDS(on) question (driver, or a logic-level FET) before relying on injector or fuel-pump current.
3. LS inductive loads have no external clamp.
4. Residual Hellen keepout / padstack noise and the preexisting injector-VR shorts called out on rev n.
5. Firmware `coreefi_micro` F407 target in the sibling tree (not this PR). This repo does not publish firmware.

## Incident guard

Do not whole-file-replace `microcore.kicad_pcb`. Guard: `bin/check-pcb-not-empty.sh` (min 10 kB + `(zone` present). Drill origin must stay Edge.Cuts bottom-left `(107.5, 148.0872)`.
