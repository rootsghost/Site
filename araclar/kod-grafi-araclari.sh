#!/usr/bin/env bash
# Kod grafı araçları: Claude Code ve OpenCode'a Graphify, CodeGraph ve Serena kurar — Linux Mint / Ubuntu
#
# Üçü de ajanın dosyaları baştan sona okumak yerine kodun yapısını (fonksiyonlar,
# çağrılar, struct'lar) sorgulamasını sağlar; böylece daha az token harcanır.
# Hepsi yerelde çalışır, kodunu bir sunucuya göndermez.
#
#   1) Graphify   — skill. Tree-sitter ile kod grafı çıkarır (C, C++, Kotlin dahil),
#                   graph.json + GRAPH_REPORT.md yazar. Kod için yapay zekâ çağrısı yapmaz.
#                   https://github.com/Graphify-Labs/graphify  (PyPI: graphifyy)
#   2) CodeGraph  — MCP sunucusu. Önceden indekslenmiş sembol/çağrı grafı; kod değişince eşitlenir.
#                   https://github.com/colbymchenry/codegraph  (npm: @colbymchenry/codegraph)
#   3) Serena     — MCP sunucusu. Dil sunucusu (clangd, Kotlin…) ile sembol seviyesinde okuma/düzenleme.
#                   https://github.com/oraios/serena  (PyPI: serena-agent)
#   4) Kaldır
#
# Kullanım:
#   bash kod-grafi-araclari.sh                       # menü, hem Claude Code hem OpenCode
#   bash kod-grafi-araclari.sh --claude              # yalnız Claude Code
#   bash kod-grafi-araclari.sh --opencode            # yalnız OpenCode
#   bash kod-grafi-araclari.sh --kaldir              # hepsini kaldır
#
# Birden çok grafik aracını aynı anda açma: her MCP sunucusu araç tanımlarını her isteğe
# ekler. Yerel küçük modellerde (16K bağlam) Graphify en hafif seçenektir.

set -euo pipefail

bilgi()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
tamam()  { printf '\033[1;32m✓\033[0m   %s\n' "$*"; }
uyari()  { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
hata()   { printf '\033[1;31mHATA:\033[0m %s\n' "$*" >&2; exit 1; }
evet()   { local c; read -rp "$1 [e/H]: " c; [[ ${c,,} == e* ]]; }

[[ $EUID -eq 0 ]] && hata "Root olarak değil, kendi kullanıcınla çalıştır."

CLAUDE=1; OPENCODE=1; EYLEM=""
for a in "$@"; do
  case $a in
    --claude)   OPENCODE=0 ;;
    --opencode) CLAUDE=0 ;;
    --kaldir)   EYLEM="kaldir" ;;
    -h|--help)  sed -n '2,25p' "$0"; exit 0 ;;
    *) hata "Bilinmeyen seçenek: $a" ;;
  esac
done

export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"
(( CLAUDE ))   && ! command -v claude   >/dev/null 2>&1 && { uyari "Claude Code bulunamadı; atlanıyor."; CLAUDE=0; }
(( OPENCODE )) && ! command -v opencode >/dev/null 2>&1 && { uyari "OpenCode bulunamadı; atlanıyor."; OPENCODE=0; }
(( CLAUDE || OPENCODE )) || hata "Ne Claude Code ne OpenCode bulundu."
hedefler=(); (( CLAUDE )) && hedefler+=("Claude Code"); (( OPENCODE )) && hedefler+=("OpenCode")
bilgi "Hedef: ${hedefler[*]}"

command -v jq >/dev/null 2>&1 || sudo apt-get install -y jq

# ── OpenCode config yardımcıları (opencode-eklentiler.sh ile aynı yöntem) ──
OC_CONFIG="$HOME/.config/opencode/opencode.json"
oc_hazirla() {
  mkdir -p "$(dirname "$OC_CONFIG")"
  [[ -f $OC_CONFIG ]] || echo '{"$schema": "https://opencode.ai/config.json"}' > "$OC_CONFIG"
  jq empty "$OC_CONFIG" 2>/dev/null || hata "$OC_CONFIG geçerli JSON değil."
  OC_YEDEK="$OC_CONFIG.yedek-$(date +%Y%m%d-%H%M%S)"; cp "$OC_CONFIG" "$OC_YEDEK"
}
oc_mcp_ekle() {   # oc_mcp_ekle <ad> <json>
  local t; t=$(mktemp)
  jq --arg a "$1" --argjson m "$2" '.mcp[$a] = $m' "$OC_CONFIG" > "$t" && mv "$t" "$OC_CONFIG"
  if (cd "$HOME" && timeout 180 opencode models >/dev/null 2>&1); then
    tamam "OpenCode: $1 eklendi"
  else
    cp "$OC_YEDEK" "$OC_CONFIG"; uyari "OpenCode $1 ile açılmadı; config yedekten geri yüklendi."; return 1
  fi
}
oc_mcp_sil() {
  [[ -f $OC_CONFIG ]] || return 0
  local t; t=$(mktemp)
  jq --arg a "$1" 'del(.mcp[$a]) | if .mcp == {} then del(.mcp) else . end' "$OC_CONFIG" > "$t" && mv "$t" "$OC_CONFIG"
}

# ── uv (Python araçları için; Mint'te pip ile sisteme kurmak engelli) ──
uv_hazirla() {
  command -v uv >/dev/null 2>&1 && return 0
  bilgi "uv kuruluyor (https://astral.sh/uv)"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
  command -v uv >/dev/null 2>&1 || hata "uv kurulamadı."
}

# ── 1) Graphify ─────────────────────────────────────────────────────────────
kur_graphify() {
  uv_hazirla
  bilgi "Graphify kuruluyor (graphifyy)"
  uv tool install --upgrade graphifyy >/dev/null
  (( CLAUDE ))   && graphify install --platform claude   && tamam "Claude Code: /graphify skill'i eklendi"
  (( OPENCODE )) && graphify install --platform opencode && tamam "OpenCode: /graphify skill'i eklendi"
  echo "  Bir projede grafı yapay zekâ çağırmadan çıkarmak için:  cd ~/projem && graphify update ."
  echo "  Sonra ajana: /graphify  (belge ve görseller için model kullanır, kod için kullanmaz)"
  echo "  Çıktı graphify-out/ klasörüne yazılır; .gitignore'a ekleyebilirsin."
}

# ── 2) CodeGraph ────────────────────────────────────────────────────────────
kur_codegraph() {
  if ! command -v codegraph >/dev/null 2>&1; then
    bilgi "CodeGraph kuruluyor (resmi kurulum betiği)"
    curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
    export PATH="$HOME/.local/bin:$HOME/.codegraph/bin:$PATH"
  fi
  command -v codegraph >/dev/null 2>&1 || { uyari "codegraph komutu bulunamadı; yeni terminalde tekrar dene."; return 1; }
  codegraph telemetry off >/dev/null 2>&1 && tamam "CodeGraph anonim kullanım istatistiği kapatıldı"
  if (( CLAUDE )); then
    codegraph install --target claude --location global --yes && tamam "Claude Code: codegraph MCP sunucusu eklendi"
  fi
  if (( OPENCODE )); then
    # CodeGraph OpenCode için opencode.jsonc'ye yazar; mevcut opencode.json ile karışmasın diye
    # aynı ayarı CodeGraph'ın kendi ürettiği örnekten alıp opencode.json'a ekliyoruz.
    local parca
    parca=$(codegraph install --print-config opencode 2>/dev/null | grep -v '^#' | jq -c '.mcp.codegraph') \
      || parca='{"type":"local","command":["codegraph","serve","--mcp"],"enabled":true}'
    oc_hazirla; oc_mcp_ekle codegraph "$parca" || true
  fi
  echo "  Her projede bir kez indeks oluştur:  cd ~/projem && codegraph init"
}

# ── 3) Serena ───────────────────────────────────────────────────────────────
kur_serena() {
  uv_hazirla
  bilgi "Serena kuruluyor (serena-agent, Python 3.13)"
  uv tool install --upgrade -p 3.13 serena-agent >/dev/null
  serena init </dev/null >/dev/null 2>&1 || true
  if (( CLAUDE )); then
    serena setup claude-code && tamam "Claude Code: serena MCP sunucusu eklendi"
  fi
  if (( OPENCODE )); then
    # OpenCode'un kendi dosya araçları var; Serena'nın "ide" bağlamı bu tür istemciler için.
    oc_hazirla
    oc_mcp_ekle serena '{"type":"local","command":["serena","start-mcp-server","--context=ide","--project-from-cwd"],"enabled":true}' || true
  fi
  command -v clangd >/dev/null 2>&1 || uyari "C/C++ için clangd gerekli: sudo apt install clangd"
  echo "  Serena projeyi bulunduğun klasörden (.git) tanır. İlk açılışta dil sunucusunu başlatır, biraz sürebilir."
}

# ── 4) Kaldır ───────────────────────────────────────────────────────────────
kaldir_hepsi() {
  bilgi "Kaldırılıyor"
  if command -v graphify >/dev/null 2>&1; then graphify uninstall >/dev/null 2>&1 || true; uv tool uninstall graphifyy >/dev/null 2>&1 || true; tamam "Graphify"; fi
  if (( CLAUDE )); then
    claude mcp remove codegraph --scope user >/dev/null 2>&1 || true
    claude mcp remove serena --scope user >/dev/null 2>&1 || true
  fi
  oc_mcp_sil codegraph; oc_mcp_sil serena
  command -v uv >/dev/null 2>&1 && uv tool uninstall serena-agent >/dev/null 2>&1 && tamam "Serena" || true
  if command -v codegraph >/dev/null 2>&1; then
    tamam "CodeGraph ajanlardan çıkarıldı. Programın kendisini silmek için: $(command -v codegraph) dosyasını sil"
    echo "  Projelerdeki indeksleri silmek için her projede: codegraph uninit"
  fi
}

# ── Menü ────────────────────────────────────────────────────────────────────
if [[ -z $EYLEM ]]; then
  cat <<'MENU'

Hangi araç kurulsun?
  1) Graphify    skill; en hafif, kod için yapay zekâ çağrısı yok (önerilen)
  2) CodeGraph   MCP; önceden indekslenmiş sembol ve çağrı grafı
  3) Serena      MCP; dil sunucusuyla sembol seviyesinde okuma ve düzenleme
  4) Kaldır      hepsini kaldır

Not: Genelde birini seçmek yeterli. 2 ve 3 her isteğe araç tanımı ekler.
MENU
  read -rp "Numaralar [1]: " SECIM; SECIM=${SECIM:-1}
else
  SECIM=4
fi

basarisiz=0
for s in $SECIM; do
  case $s in
    1) kur_graphify  || basarisiz=1 ;;
    2) kur_codegraph || basarisiz=1 ;;
    3) kur_serena    || basarisiz=1 ;;
    4) kaldir_hepsi ;;
    *) uyari "Bilinmeyen seçim: $s" ;;
  esac
done

echo
(( CLAUDE )) && { bilgi "Claude Code MCP sunucuları:"; claude mcp list 2>/dev/null | sed 's/^/  /' || true; }
(( OPENCODE )) && [[ -f $OC_CONFIG ]] && { bilgi "OpenCode MCP sunucuları:"; jq -r '(.mcp // {}) | keys | if length == 0 then "  (yok)" else map("  • " + .) | join("\n") end' "$OC_CONFIG"; }
echo "Ajanı yeniden başlat; yeni araçlar açılışta yüklenir."
exit $basarisiz
