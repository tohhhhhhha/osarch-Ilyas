#!/usr/bin/env bash
# Lab 5 — convert staff-broken.csv to UTF-8
set -euo pipefail
SRC_ENC="RK1048"
IN=evidence/staff-broken.csv
OUT=evidence/staff-fixed.csv

# 1. decode from RK1048, encode as UTF-8
# 2. line endings: CRLF -> LF            (sed 's/\r$//')
# 3. BOM: add one — Excel needs it to recognise UTF-8 on a double-click
{
  printf '\xEF\xBB\xBF'
  iconv -f "$SRC_ENC" -t UTF-8 "$IN" | sed 's/\r$//'
} > "$OUT"

file -e csv "$OUT"
xxd -l 16 "$OUT"
