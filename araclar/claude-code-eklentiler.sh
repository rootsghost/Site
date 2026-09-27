#!/usr/bin/env bash
# Claude Code eklentileri: kurulum / kaldırma — Linux Mint / Ubuntu
#
# Token maliyetleri "claude plugin details" ile ölçüldü (2026-09-27): her oturuma
# baştan eklenen bağlam. Dil sunucuları ve hook'lar Claude Code'un dışında çalışır,
# modelin bağlamına bir şey eklemez.
#
#   1) Ponytail          ~983 tok  — en az kodu yazdırır (/ponytail, /ponytail-review…)
#   2) Caveman           ~1830 tok — kısa cevaplar, daha az çıktı tokenı (/caveman…)
#   3) clangd-lsp        ~0 tok    — C/C++ için tanıma git, referanslar (clangd gerekir)
#   4) kotlin-lsp        ~0 tok    — Kotlin/Android için aynısı (kotlin-lsp gerekir)
#   5) code-simplifier   ~64 tok   — yazılan kodu sadeleştiren ajan
#   6) commit-commands   ~103 tok  — /commit, /commit-push-pr
#   7) snip              ~0 tok    — Bash çıktısını (git, make, gcc…) modele gitmeden süzer
#   8) Kaldır                      — yukarıdakilerin hepsini kaldırır
#
# Kullanım:
#   bash claude-code-eklentiler.sh               # menü
#   bash claude-code-eklentiler.sh --onerilen    # 1 3 7: az token + C için LSP
#   bash claude-code-eklentiler.sh --proje       # kullanıcı yerine bu projeye kur (.claude/settings.json)
#   bash claude-code-eklentiler.sh --kaldir      # hepsini kaldır

set -euo pipefail

bilgi()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
tamam()  { printf '\033[1;32m✓\033[0m   %s\n' "$*"; }
uyari()  { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
hata()   { printf '\033[1;31mHATA:\033[0m %s\n' "$*" >&2; exit 1; }
evet()   { local c; read -rp "$1 [e/H]: " c; [[ ${c,,} == e* ]]; }

[[ $EUID -eq 0 ]] && hata "Root olarak değil, kendi kullanıcınla çalıştır."

KAPSAM="user"; EYLEM=""
for a in "$@"; do
  case $a in
    --onerilen) EYLEM="onerilen" ;;
    --kaldir)   EYLEM="kaldir" ;;
    --proje)    KAPSAM="project" ;;
    -h|--help)  sed -n '2,23p' "$0"; exit 0 ;;
    *) hata "Bilinmeyen seçenek: $a" ;;
  esac
done

# ── Claude Code ─────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/.claude/local:$PATH"
if ! command -v claude >/dev/null 2>&1; then
  uyari "Claude Code bulunamadı."
  if evet "Resmi kurucuyla kurulsun mu? (curl -fsSL https://claude.ai/install.sh | bash)"; then
    curl -fsSL https://claude.ai/install.sh | bash
    export PATH="$HOME/.local/bin:$PATH"
  fi
  command -v claude >/dev/null 2>&1 || hata "claude komutu yok. Kurulum: https://code.claude.com/docs"
fi
tamam "Claude Code: $(claude --version 2>/dev/null | head -1)"
[[ $KAPSAM == project ]] && bilgi "Kapsam: bu proje ($PWD/.claude/settings.json)" || bilgi "Kapsam: kullanıcı (tüm projeler)"

# ── Yardımcılar ─────────────────────────────────────────────────────────────
declare -A PAZAR_EKLENDI=()
pazar_ekle() {   # pazar_ekle <github-deposu> — aynı çalıştırmada bir kez
  [[ -n ${PAZAR_EKLENDI[$1]:-} ]] && return 0
  bilgi "Eklenti kataloğu ekleniyor: $1"
  claude plugin marketplace add "$1" --scope "$KAPSAM" >/dev/null 2>&1 \
    || claude plugin marketplace update >/dev/null 2>&1 || true
  PAZAR_EKLENDI[$1]=1
}
eklenti_kur() {  # eklenti_kur <eklenti@katalog> <github-deposu>
  pazar_ekle "$2"
  bilgi "$1 kuruluyor"
  if claude plugin install "$1" --scope "$KAPSAM"; then
    local maliyet
    maliyet=$(claude plugin details "$1" 2>/dev/null | grep -E 'Always-on' | sed 's/^ *//') || true
    tamam "$1 kuruldu${maliyet:+ — $maliyet}"
  else
    uyari "$1 kurulamadı."
    return 1
  fi
}
eklenti_kaldir() {
  if claude plugin list 2>/dev/null | grep -q "${1%@*}@"; then
    claude plugin uninstall "$1" --scope "$KAPSAM" >/dev/null 2>&1 && tamam "$1 kaldırıldı" \
      || uyari "$1 kaldırılamadı (başka kapsamda kurulu olabilir: --proje ile dene)"
  fi
}
apt_kur() { dpkg -s "$1" >/dev/null 2>&1 || sudo apt-get install -y "$1"; }

# ── Eklentiler ──────────────────────────────────────────────────────────────
RESMI="anthropics/claude-plugins-official"

kur_clangd() {
  command -v clangd >/dev/null 2>&1 || { bilgi "clangd kuruluyor"; sudo apt-get update -qq; apt_kur clangd; }
  eklenti_kur clangd-lsp@claude-plugins-official "$RESMI"
  echo "  İpucu: clangd derleme bayraklarını compile_commands.json'dan okur."
  echo "  Meson bunu build/ içinde üretir; proje köküne bağla: ln -s build/compile_commands.json ."
}

kur_kotlin() {
  if ! command -v kotlin-lsp >/dev/null 2>&1; then
    uyari "kotlin-lsp komutu bulunamadı. Eklenti kurulacak ama çalışması için kotlin-lsp'nin PATH'te olması gerekir:"
    uyari "  https://github.com/Kotlin/kotlin-lsp (sürüm arşivini indir, kotlin-lsp.sh'yi PATH'e bağla)"
  fi
  eklenti_kur kotlin-lsp@claude-plugins-official "$RESMI"
}

kur_snip() {
  if ! command -v snip >/dev/null 2>&1; then
    bilgi "snip kuruluyor (https://github.com/edouard-claude/snip)"
    curl -fsSL https://raw.githubusercontent.com/edouard-claude/snip/master/install.sh | sh
    export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
  fi
  command -v snip >/dev/null 2>&1 || { uyari "snip kurulamadı."; return 1; }
  bilgi "snip Claude Code'a bağlanıyor (snip init — Bash için PreToolUse hook'u)"
  snip init && tamam "snip etkin. Yalnız Bash komutlarını süzer; Read/Grep gibi araçları etkilemez."
  uyari "snip ile RTK'yı birlikte kurma: ikisi de aynı Bash hook'unu kullanır."
}

kaldir_hepsi() {
  bilgi "Eklentiler kaldırılıyor"
  local p
  for p in ponytail@ponytail caveman@caveman clangd-lsp@claude-plugins-official kotlin-lsp@claude-plugins-official \
           code-simplifier@claude-plugins-official commit-commands@claude-plugins-official; do
    eklenti_kaldir "$p"
  done
  if command -v snip >/dev/null 2>&1; then
    uyari "snip hook'u otomatik kaldırılmadı. Claude Code'da /hooks ile PreToolUse altındaki snip girdisini sil"
    uyari "ya da 'snip --help' ile kaldırma komutuna bak."
  fi
}

# ── Menü ────────────────────────────────────────────────────────────────────
if [[ -z $EYLEM ]]; then
  cat <<'MENU'

Hangi eklentiler kurulsun? (her oturuma eklenen yaklaşık token)
  1) Ponytail          ~983 tok   en az kodu yazdırır
  2) Caveman           ~1830 tok  kısa cevaplar, daha az çıktı tokenı
  3) clangd-lsp        ~0 tok     C/C++ tanıma git, referanslar (az dosya okuma)
  4) kotlin-lsp        ~0 tok     Kotlin/Android için aynısı
  5) code-simplifier   ~64 tok    kodu sadeleştiren ajan
  6) commit-commands   ~103 tok   /commit, /commit-push-pr
  7) snip              ~0 tok     Bash çıktısını süzer (git, make, gcc…)
  8) Kaldır                       hepsini kaldır

MENU
  read -rp "Numaralar (boşlukla ayır) [1 3 7]: " SECIM
  SECIM=${SECIM:-1 3 7}
else
  case $EYLEM in
    onerilen) SECIM="1 3 7" ;;
    kaldir)   SECIM="8" ;;
  esac
fi

basarisiz=0
for s in $SECIM; do
  case $s in
    1) eklenti_kur ponytail@ponytail DietrichGebert/ponytail || basarisiz=1 ;;
    2) eklenti_kur caveman@caveman JuliusBrussee/caveman || basarisiz=1 ;;
    3) kur_clangd || basarisiz=1 ;;
    4) kur_kotlin || basarisiz=1 ;;
    5) eklenti_kur code-simplifier@claude-plugins-official "$RESMI" || basarisiz=1 ;;
    6) eklenti_kur commit-commands@claude-plugins-official "$RESMI" || basarisiz=1 ;;
    7) kur_snip || basarisiz=1 ;;
    8) kaldir_hepsi ;;
    *) uyari "Bilinmeyen seçim: $s" ;;
  esac
done

echo
bilgi "Kurulu eklentiler:"
claude plugin list 2>/dev/null | sed 's/^/  /' || true
cat <<'NOT'

Notlar:
  • Claude Code'u yeniden başlat; eklentiler yeni oturumda yüklenir.
  • Bir eklentinin bağlam maliyetini görmek için: claude plugin details <ad@katalog>
  • Ponytail ile Caveman birlikte ~2800 token ekler; ikisini birden her zaman açık tutma.
    Geçici kapatmak için: claude plugin disable <ad@katalog>  (açmak: enable)
NOT
exit $basarisiz
