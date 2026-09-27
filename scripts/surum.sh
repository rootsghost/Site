#!/usr/bin/env bash
# Sitedeki örnek sürüm numarasını tek komutla değiştirir.
#   bash scripts/surum.sh 0.2.0
# Kaynak index.html'deki <html data-surum="…">. assets/site.js sürümü oradan okur;
# index.html'deki indirme satırlarındaki dosya adları ve yazılar da bu betikle güncellenir.
set -euo pipefail
cd "$(dirname "$0")/.."
yeni=${1:-}
[[ $yeni =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]] || { echo "Kullanım: bash scripts/surum.sh 1.2.3" >&2; exit 1; }
eski=$(sed -n 's/.*<html[^>]*data-surum="\([^"]*\)".*/\1/p' index.html | head -1)
[[ -n $eski ]] || { echo "index.html'de data-surum bulunamadı." >&2; exit 1; }
[[ $eski == "$yeni" ]] && { echo "Sürüm zaten $yeni."; exit 0; }
esc=${eski//./\\.}
once=$(grep -o "$esc" index.html | wc -l)
sed -i "s/$esc/$yeni/g" index.html
echo "index.html: $eski → $yeni ($once yer)"
if grep -q "$esc" assets/site.js; then
  echo "Uyarı: assets/site.js içinde hâlâ $eski geçiyor; sürüm oradan data-surum ile okunmalı." >&2
fi
