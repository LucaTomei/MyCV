#!/usr/bin/env bash
# Parser-friendliness checks for a compiled CV.
#
#   scripts/check-cv.sh <file.pdf> <en|it>
#
# The checks mirror what applicant tracking systems do with a PDF: extract
# the text and look for the contact details, then make sure nothing came out
# garbled. Requires poppler-utils (pdftotext, pdfinfo).
set -euo pipefail

pdf="${1:?usage: check-cv.sh <file.pdf> <en|it>}"
lang="${2:?usage: check-cv.sh <file.pdf> <en|it>}"
max_pages=2
fail=0

say() { printf '  %s\n' "$*"; }
bad() { printf '  FAIL: %s\n' "$*"; fail=1; }

echo "== $pdf ($lang)"

# --- page geometry and count ---------------------------------------------
pages=$(pdfinfo "$pdf" | awk '/^Pages:/ {print $2}')
size=$(pdfinfo "$pdf" | awk -F': *' '/^Page size:/ {print $2}')
say "pages: $pages | page size: $size"
[ "$pages" -le "$max_pages" ] || bad "more than $max_pages pages"
case "$size" in *A4*|*595*x*842*|*595.276*) ;; *) bad "page size is not A4" ;; esac

# --- metadata -------------------------------------------------------------
author=$(pdfinfo "$pdf" | awk -F': *' '/^Author:/ {print $2}')
title=$(pdfinfo "$pdf" | awk -F': *' '/^Title:/ {print $2}')
say "author: '$author' | title: '$title'"
[ "$author" = "Luca Tomei" ] || bad "PDF Author metadata is not 'Luca Tomei'"
[ -n "$title" ] || bad "PDF Title metadata is empty"

# --- text extraction ------------------------------------------------------
text=$(pdftotext -layout "$pdf" - )
first=$(printf '%s\n' "$text" | sed -n '1p' | tr -s ' ')
say "first line: $first"
[[ "$first" == *"Luca Tomei"* ]] || bad "name is not on the first line"

for needle in "luca.tom1995@gmail.com" "+39 350 561 3338" "linkedin.com/in/tomeiluca" "github.com/LucaTomei" "lucasmac.xyz"; do
  grep -qF -- "$needle" <<<"$text" || bad "missing contact detail: $needle"
done

case "$lang" in
  en) for h in "Professional Summary" "Technical Skills" "Work Experience" "Education" "Projects" "Certifications" "Languages"; do
        grep -qF -- "$h" <<<"$text" || bad "missing section heading: $h"; done ;;
  it) for h in "Profilo professionale" "Competenze tecniche" "Esperienza professionale" "Istruzione e formazione" "Progetti" "Certificazioni" "Lingue"; do
        grep -qF -- "$h" <<<"$text" || bad "missing section heading: $h"; done ;;
esac

# Accents must be single precomposed characters, not "letter + combining"
# or a stray backtick/acute (what happens without T1 font encoding).
if grep -qE "[a-zA-Z][\`´]|[\`´][a-zA-Z]" <<<"$text"; then bad "found detached accent marks"; fi
# Private-use / notdef glyphs mean an icon font or missing ToUnicode map.
if grep -qP "[\x{E000}-\x{F8FF}\x{FFFD}]" <<<"$text"; then bad "found private-use or replacement glyphs"; fi
# Skill labels must not be glued to their values.
if grep -qE "^(Languages|Linguaggi)[A-Z]" <<<"$text"; then bad "skill label glued to value"; fi

[ "$fail" -eq 0 ] && say "OK" || { echo "== checks failed"; exit 1; }
