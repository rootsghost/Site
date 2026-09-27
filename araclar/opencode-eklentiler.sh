#!/usr/bin/env bash
# OpenCode için Ponytail ve Caveman eklentilerini kurar / kaldırır — Linux Mint / Ubuntu
#
#   Ponytail  — modele "işi çözen en az kodu yaz" kuralını her turda hatırlatır;
#               /ponytail, /ponytail-review, /ponytail-audit komutlarını ekler.
#               https://github.com/DietrichGebert/ponytail  (npm: @dietrichgebert/ponytail)
#   Caveman   — modeli kısa konuşturup token harcamasını azaltır.
#               Varsayılan: topluluk eklentisi caveman-opencode-plugin
#               https://github.com/dantesCode/caveman-opencode-plugin
#               İsteğe bağlı: resmi kurucu https://github.com/JuliusBrussee/caveman
#               (resmi kurucunun OpenCode'da bilinen sorunları var: #422, #482)
#
# Kullanım:
#   bash opencode-eklentiler.sh                  # menü
#   bash opencode-eklentiler.sh --hepsi          # ikisini de kur (global)
#   bash opencode-eklentiler.sh --proje          # global yerine bu klasörün opencode.json'una kur
#   bash opencode-eklentiler.sh --kaldir         # ikisini de kaldır
#
# Her değişiklikten önce config yedeklenir. Kurulumdan sonra OpenCode açılmazsa
# betik yedeği otomatik geri yükler.

set -euo pipefail

PONYTAIL_PAKET="@dietrichgebert/ponytail"
CAVEMAN_PAKET="caveman-opencode-plugin"

bilgi()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
tamam()  { printf '\033[1;32m✓\033[0m   %s\n' "$*"; }
uyari()  { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
hata()   { printf '\033[1;31mHATA:\033[0m %s\n' "$*" >&2; exit 1; }
evet()   { local c; read -rp "$1 [e/H]: " c; [[ ${c,,} == e* ]]; }

[[ $EUID -eq 0 ]] && hata "Root olarak değil, kendi kullanıcınla çalıştır."

# ── Bayraklar ───────────────────────────────────────────────────────────────
KAPSAM="global"; EYLEM=""
for a in "$@"; do
  case $a in
    --hepsi)  EYLEM="hepsi" ;;
    --kaldir) EYLEM="kaldir" ;;
    --proje)  KAPSAM="proje" ;;
    -h|--help) sed -n '2,21p' "$0"; exit 0 ;;
    *) hata "Bilinmeyen seçenek: $a" ;;
  esac
done

if [[ $KAPSAM == proje ]]; then
  CONFIG_FILE="$PWD/opencode.json"
else
  CONFIG_FILE="$HOME/.config/opencode/opencode.json"
fi

# ── Ön koşullar ─────────────────────────────────────────────────────────────
export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$PATH"
command -v opencode >/dev/null 2>&1 || hata "OpenCode bulunamadı. Önce araclar/opencode-kurulum.sh ile kur."
command -v jq >/dev/null 2>&1 || { bilgi "jq kuruluyor"; sudo apt-get install -y jq; }

mkdir -p "$(dirname "$CONFIG_FILE")"
[[ -f $CONFIG_FILE ]] || echo '{"$schema": "https://opencode.ai/config.json"}' > "$CONFIG_FILE"
jq empty "$CONFIG_FILE" 2>/dev/null || hata "$CONFIG_FILE geçerli JSON değil; önce düzelt."

YEDEK="$CONFIG_FILE.yedek-$(date +%Y%m%d-%H%M%S)"
cp "$CONFIG_FILE" "$YEDEK"
bilgi "Config: $CONFIG_FILE (yedek: $YEDEK)"

# ── Yardımcılar ─────────────────────────────────────────────────────────────
eklenti_ekle() {   # eklenti_ekle <paket> — "plugin" dizisine ekler, tekrar eklemez
  local t; t=$(mktemp)
  jq --arg p "$1" '.plugin = (((.plugin // []) + [$p]) | unique)' "$CONFIG_FILE" > "$t" && mv "$t" "$CONFIG_FILE"
}
eklenti_cikar() {  # eklenti_cikar <desen> — adı desenle eşleşen girdileri çıkarır
  local t; t=$(mktemp)
  jq --arg d "$1" 'if .plugin then .plugin |= map(select((if type == "array" then .[0] else . end | tostring | test($d)) | not)) else . end
                   | if (.plugin // []) == [] then del(.plugin) else . end' "$CONFIG_FILE" > "$t" && mv "$t" "$CONFIG_FILE"
}
opencode_calisiyor_mu() {
  # "opencode models" config'i ve eklentileri yükler; eklenti OpenCode'u bozarsa burada hata verir.
  # İlk çalıştırmada OpenCode eklentiyi npm'den indirir, bu yüzden süre uzun tutuldu.
  local cikti
  if cikti=$(cd "$(dirname "$CONFIG_FILE")" && timeout 180 opencode models 2>&1); then
    return 0
  fi
  printf '%s\n' "$cikti" | tail -5 >&2
  return 1
}
geri_al() {
  cp "$YEDEK" "$CONFIG_FILE"
  uyari "OpenCode bu ayarla açılmadı; config yedekten geri yüklendi."
}

# ── Kurulumlar ──────────────────────────────────────────────────────────────
kur_ponytail() {
  bilgi "Ponytail ekleniyor ($PONYTAIL_PAKET)"
  eklenti_ekle "$PONYTAIL_PAKET"
  if opencode_calisiyor_mu; then
    tamam "Ponytail etkin. OpenCode'da: /ponytail lite|full|ultra|off, /ponytail-review, /ponytail-audit"
  else
    geri_al; return 1
  fi
}

kur_caveman_topluluk() {
  bilgi "Caveman ekleniyor ($CAVEMAN_PAKET)"
  eklenti_ekle "$CAVEMAN_PAKET"
  if opencode_calisiyor_mu; then
    tamam "Caveman etkin."
    echo "  Projeye özel ayar istersen proje klasöründe:"
    echo "    echo '{\"enabled\":true,\"defaultMode\":\"full\"}' > caveman.json"
  else
    geri_al; return 1
  fi
}

kur_caveman_resmi() {
  command -v npx >/dev/null 2>&1 || { bilgi "Node.js kuruluyor"; sudo apt-get install -y nodejs npm; }
  uyari "Resmi kurucunun OpenCode'da bilinen sorunları var (#422: OpenCode açılmıyor, #482: eksik dosya)."
  bilgi "Resmi Caveman kurucusu çalışıyor"
  if ! npx -y github:JuliusBrussee/caveman -- --only opencode; then
    uyari "Resmi kurucu başarısız oldu. Topluluk eklentisini dene: menüde 2."
    return 1
  fi
  if opencode_calisiyor_mu; then
    tamam "Caveman (resmi) etkin."
  else
    uyari "OpenCode açılmıyor; resmi Caveman kaldırılıyor."
    npx -y github:JuliusBrussee/caveman -- --uninstall || true
    cp "$YEDEK" "$CONFIG_FILE"
    return 1
  fi
}

kaldir_hepsi() {
  bilgi "Ponytail ve Caveman kaldırılıyor"
  eklenti_cikar 'ponytail'
  eklenti_cikar 'caveman'
  if [[ -d $HOME/.config/opencode/plugins/caveman ]] && command -v npx >/dev/null 2>&1; then
    bilgi "Resmi Caveman kurulumu da bulundu, kaldırılıyor"
    npx -y github:JuliusBrussee/caveman -- --uninstall || uyari "Resmi kaldırıcı hata verdi; ~/.config/opencode/plugins/caveman'ı elle sil."
  fi
  tamam "Kaldırıldı."
}

# ── Menü ────────────────────────────────────────────────────────────────────
if [[ -z $EYLEM ]]; then
  cat <<'MENU'

Ne yapmak istersin?
  1) Ponytail kur          — daha az ve daha basit kod
  2) Caveman kur           — kısa cevaplar, daha az token (topluluk eklentisi, önerilen)
  3) Caveman kur (resmi)   — resmi kurucu; bilinen sorunları var
  4) Kaldır                — ikisini de kaldır

MENU
  read -rp "Numaralar (boşlukla ayır) [1 2]: " SECIM
  SECIM=${SECIM:-1 2}
else
  case $EYLEM in
    hepsi)  SECIM="1 2" ;;
    kaldir) SECIM="4" ;;
  esac
fi

basarisiz=0
for s in $SECIM; do
  case $s in
    1) kur_ponytail || basarisiz=1 ;;
    2) kur_caveman_topluluk || basarisiz=1 ;;
    3) kur_caveman_resmi || basarisiz=1 ;;
    4) kaldir_hepsi ;;
    *) uyari "Bilinmeyen seçim: $s" ;;
  esac
done

echo
bilgi "Etkin eklentiler ($CONFIG_FILE):"
jq -r '(.plugin // []) | if length == 0 then "  (yok)" else map("  • " + (if type == "array" then .[0] else . end | tostring)) | join("\n") end' "$CONFIG_FILE"
cat <<'NOT'

Notlar:
  • OpenCode'u yeniden başlat; eklentiler açılışta yüklenir (ilk seferde npm'den indirilir).
  • İkisi de her turda modele ek talimat gönderir. Yerel küçük modellerde (Ollama 16K bağlam)
    bu bağlamın bir kısmını kullanır; sorun olursa yerel modelde kapat: /ponytail off
  • Geri almak için: bash opencode-eklentiler.sh --kaldir  (ya da yedek dosyayı geri kopyala)
NOT
exit $basarisiz
