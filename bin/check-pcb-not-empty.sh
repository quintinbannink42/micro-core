#!/usr/bin/env bash
# Refuse near-empty KiCad PCB files (guards against accidental wipe like ce63db4).
set -euo pipefail
PCB="${1:-microcore.kicad_pcb}"
MIN_BYTES="${MIN_PCB_BYTES:-10000}"
if [[ ! -f "$PCB" ]]; then
  echo "ERROR: missing $PCB" >&2
  exit 1
fi
SIZE=$(wc -c < "$PCB" | tr -d ' ')
if (( SIZE < MIN_BYTES )); then
  echo "ERROR: $PCB is only ${SIZE} bytes (min ${MIN_BYTES}). Refusing empty/wiped board." >&2
  echo "Hint: restore with: git show <good-rev>:${PCB} > ${PCB}" >&2
  exit 1
fi
if ! grep -q '(zone' "$PCB"; then
  echo "ERROR: $PCB has no (zone …) — likely truncated or wrong file." >&2
  exit 1
fi
echo "OK: $PCB size=${SIZE} bytes, zones present"
