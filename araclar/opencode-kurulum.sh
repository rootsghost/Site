#!/usr/bin/env bash
# OpenCode + ücretsiz yapay zekâ sağlayıcıları kurulumu — Linux Mint / Ubuntu
#
# Seçebileceğin sağlayıcılar:
#   1) OpenCode Zen      — OpenCode'un kendi ücretsiz modelleri
#   2) NVIDIA NIM        — build.nvidia.com, açık modeller, ücretsiz (rate limit)
#   3) Google Gemini     — aistudio.google.com, ücretsiz katman
#   4) Groq              — console.groq.com, ücretsiz katman, çok hızlı
#   5) OpenRouter        — openrouter.ai, ":free" etiketli modeller
#   6) Mistral           — console.mistral.ai, ücretsiz "Experiment" planı
#   7) Cerebras          — cloud.cerebras.ai (son durumda kart isteyebilir)
#   8) Hugging Face      — huggingface.co, aylık küçük ücretsiz kredi
#   9) GitHub Copilot    — Copilot Free planı, tarayıcıdan giriş
#  10) Ollama (yerel)    — tamamen ücretsiz ve çevrimdışı, kendi bilgisayarında
#  11) Anthropic Claude  — ÜCRETLİ, gerçek Claude modelleri
#  12) llama.cpp         — en hafif yerel çalıştırıcı, Vulkan ile ekran kartı
#  13) LM Studio         — grafik arayüzlü yerel model uygulaması
#  14) Jan               — açık kaynak yerel sohbet uygulaması
#
# Kullanım:  bash opencode-kurulum.sh              (menü)
#            bash opencode-kurulum.sh --ollama     (yalnız Ollama + yerel C modelleri)
#            bash opencode-kurulum.sh --llamacpp   (yalnız llama.cpp)
#            bash opencode-kurulum.sh --lmstudio   (yalnız LM Studio)
#            bash opencode-kurulum.sh --jan        (yalnız Jan)
#            bash opencode-kurulum.sh --esitle     (çalışan yerel sunuculardaki modelleri OpenCode'a ekle)
# Anahtarlar ekrana basılmaz; yalnız ~/.local/share/opencode/auth.json'a (izin 600) yazılır.
#
# DİKKAT: Ücretsiz katmanların çoğu gönderdiğin kodu modeli eğitmek için
# kullanabilir. Şifre, müşteri verisi ya da gizli kod gönderme.

set -euo pipefail

CONFIG_DIR="$HOME/.config/opencode"
CONFIG_FILE="$CONFIG_DIR/opencode.json"
AUTH_DIR="$HOME/.local/share/opencode"
AUTH_FILE="$AUTH_DIR/auth.json"

bilgi()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
tamam()  { printf '\033[1;32m✓\033[0m   %s\n' "$*"; }
uyari()  { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
hata()   { printf '\033[1;31mHATA:\033[0m %s\n' "$*" >&2; exit 1; }
evet()   { local c; read -rp "$1 [e/H]: " c; [[ ${c,,} == e* ]]; }

[[ $EUID -eq 0 ]] && hata "Bu betiği root olarak değil, kendi kullanıcınla çalıştır (gerektiğinde sudo sorar)."

# ── Ortak: config ve auth.json güncelleme ───────────────────────────────────
CONFIG='{}'
AUTH='{}'
VARSAYILAN=""          # ilk seçilen model varsayılan olur
EKLENENLER=()          # özet için

auth_ekle() {          # auth_ekle <saglayici-id> <anahtar>
  AUTH=$(jq --arg id "$1" --arg k "$2" '.[$id] = {"type": "api", "key": $k}' <<<"$AUTH")
}
config_saglayici() {   # config_saglayici <id> <json-nesnesi>  (mevcutla birleştirir)
  CONFIG=$(jq --arg id "$1" --argjson p "$2" '.provider[$id] = ((.provider[$id] // {}) * $p)' <<<"$CONFIG")
}
modeller_json() {      # stdin: satır başına model id → {"id": {}, ...}
  jq -R . | jq -s 'map(select(length > 0) | {(.): {}}) | add // {}'
}
varsayilan_ayarla() { [[ -z $VARSAYILAN ]] && VARSAYILAN="$1"; return 0; }

anahtar_sor() {        # anahtar_sor <açıklama> → ANAHTAR değişkeni
  ANAHTAR=""
  read -rsp "$1 (görünmez, boş bırakırsan atlanır): " ANAHTAR; echo
}
dogrula() {            # dogrula <url> <header...> → 0/1
  local url=$1; shift
  local args=()
  for h in "$@"; do args+=(-H "$h"); done
  curl -fsS -o /dev/null --max-time 20 "${args[@]}" "$url"
}
listeden_sec() {       # listeden_sec <başlık> <max> ; stdin: seçenekler → SECILEN dizisi
  local baslik=$1 max=$2 secim n
  mapfile -t _liste
  SECILEN=()
  ((${#_liste[@]})) || { uyari "Liste boş."; return 0; }
  echo; bilgi "$baslik (${#_liste[@]} model):"
  local goster=${#_liste[@]}; (( goster > max )) && goster=$max
  for ((i=0; i<goster; i++)); do printf '  %2d) %s\n' "$((i+1))" "${_liste[$i]}"; done
  (( ${#_liste[@]} > max )) && echo "  … ilk $max gösterildi"
  read -rp "Eklenecek numaralar (boşlukla ayır) [1]: " secim </dev/tty
  for n in ${secim:-1}; do
    [[ $n =~ ^[0-9]+$ ]] && (( n>=1 && n<=goster )) && SECILEN+=("${_liste[$((n-1))]}") \
      || uyari "Geçersiz seçim atlandı: $n"
  done
}

# ── 1. Paketler ve OpenCode ─────────────────────────────────────────────────
bilgi "Gerekli paketler kontrol ediliyor"
eksik=()
for p in curl jq git ca-certificates; do dpkg -s "$p" >/dev/null 2>&1 || eksik+=("$p"); done
if ((${#eksik[@]})); then
  bilgi "Kuruluyor: ${eksik[*]}"
  sudo apt-get update -qq && sudo apt-get install -y "${eksik[@]}"
fi

export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$PATH"
if command -v opencode >/dev/null 2>&1; then
  tamam "OpenCode zaten kurulu: $(opencode --version 2>/dev/null || echo '?')"
else
  bilgi "OpenCode kuruluyor (https://opencode.ai/install)"
  curl -fsSL https://opencode.ai/install | bash
  export PATH="$HOME/.opencode/bin:$PATH"
  command -v opencode >/dev/null 2>&1 || hata "opencode PATH'te bulunamadı. Yeni bir terminal açıp tekrar dene."
fi
grep -q '.opencode/bin' "$HOME/.bashrc" 2>/dev/null || echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> "$HOME/.bashrc"

mkdir -p "$CONFIG_DIR" "$AUTH_DIR"
[[ -f $CONFIG_FILE ]] && CONFIG=$(cat "$CONFIG_FILE")
[[ -f $AUTH_FILE ]] && AUTH=$(cat "$AUTH_FILE")

# ── 2. Sağlayıcı seçimi ─────────────────────────────────────────────────────
cat <<'EOF'

Hangi sağlayıcıları kurmak istiyorsun?
   1) OpenCode Zen      ücretsiz modeller, OpenCode hesabı
   2) NVIDIA NIM        ücretsiz, açık modeller (Qwen, Kimi, GLM, DeepSeek…)
   3) Google Gemini     ücretsiz katman
   4) Groq              ücretsiz katman, çok hızlı
   5) OpenRouter        ":free" modeller (günlük istek sınırı düşük)
   6) Mistral           ücretsiz "Experiment" planı
   7) Cerebras          deneme; kart isteyebilir
   8) Hugging Face      aylık küçük ücretsiz kredi
   9) GitHub Copilot    Copilot Free, tarayıcıdan giriş
  10) Ollama (yerel)    tamamen ücretsiz, internetsiz, GPU/RAM ister
  11) Anthropic Claude  ÜCRETLİ, gerçek Claude
  ── başka yerel çalıştırıcılar (Ollama yerine ya da yanında) ──
  12) llama.cpp         en hafif; ekran kartını Vulkan ile kullanır
  13) LM Studio         grafik arayüz, model mağazası, sohbet
  14) Jan               açık kaynak masaüstü sohbet uygulaması

EOF
case ${1:-} in
  --ollama)   SECIM=10 ;;
  --llamacpp) SECIM=12 ;;
  --lmstudio) SECIM=13 ;;
  --jan)      SECIM=14 ;;
  --esitle)   SECIM=esitle ;;
  "")         read -rp "Numaralar (boşlukla ayır) [2 10]: " SECIM; SECIM=${SECIM:-2 10} ;;
  *)          hata "Bilinmeyen seçenek: $1 (geçerli: --ollama --llamacpp --lmstudio --jan --esitle)" ;;
esac

# ── Sağlayıcılar ────────────────────────────────────────────────────────────
kur_zen() {
  echo; bilgi "OpenCode Zen — anahtar: https://opencode.ai/zen (oturum aç → API key)"
  anahtar_sor "OpenCode Zen API anahtarı"; [[ -z $ANAHTAR ]] && return
  auth_ekle opencode "$ANAHTAR"
  EKLENENLER+=("OpenCode Zen (güncel ücretsiz modeller: opencode models opencode)")
}

kur_nvidia() {
  local url="https://integrate.api.nvidia.com/v1"
  echo; bilgi "NVIDIA NIM — anahtar: https://build.nvidia.com → bir model → Get API Key (nvapi-…)"
  anahtar_sor "NVIDIA API anahtarı"; [[ -z $ANAHTAR ]] && return
  local yanit
  yanit=$(curl -fsS --max-time 30 -H "Authorization: Bearer $ANAHTAR" "$url/models") \
    || { uyari "NVIDIA anahtarı doğrulanamadı, atlanıyor."; return; }
  listeden_sec "NVIDIA'da kod için aday modeller" 40 < <(
    jq -r '.data[].id' <<<"$yanit" | sort \
      | grep -Ei 'coder|qwen3|kimi|glm|minimax|deepseek|gpt-oss|devstral|codestral|nemotron' \
      | grep -Eiv 'embed|safety|guard|reward|parse|rerank|starcoder' || true)
  ((${#SECILEN[@]})) || return

  # NVIDIA kapattığı modelleri listede göstermeye devam ediyor; bunlara istek
  # gönderilince HTTP 410 döner. Her modele 1 tokenlık bir deneme isteği gönder,
  # çalışmayanları config'e ekleme.
  local m kod govde calisan=()
  govde=$(mktemp)
  for m in "${SECILEN[@]}"; do
    kod=$(curl -s -o "$govde" -w '%{http_code}' --max-time 60 "$url/chat/completions" \
      -H "Authorization: Bearer $ANAHTAR" -H 'Content-Type: application/json' \
      -d "$(jq -n --arg m "$m" '{model: $m, messages: [{role: "user", content: "hi"}], max_tokens: 1}')") || kod=000
    case $kod in
      200) tamam "$m çalışıyor"; calisan+=("$m") ;;
      410) uyari "$m kapatılmış (HTTP 410), eklenmedi: $(head -c 160 "$govde")" ;;
      429) uyari "$m şu an yoğun (HTTP 429); yine de eklendi"; calisan+=("$m") ;;
      *)   uyari "$m denenemedi (HTTP $kod): $(head -c 160 "$govde")" ;;
    esac
  done
  rm -f "$govde"
  if ((${#calisan[@]} == 0)); then
    uyari "Seçilen NVIDIA modellerinin hiçbiri çalışmadı. Hepsi 410 veriyorsa hesabında API erişimi"
    uyari "kapalı olabilir: build.nvidia.com hesap ayarlarını kontrol et."
    return
  fi
  SECILEN=("${calisan[@]}")
  config_saglayici nvidia "$(jq -n --arg u "$url" --argjson m "$(printf '%s\n' "${SECILEN[@]}" | modeller_json)" \
    '{"npm": "@ai-sdk/openai-compatible", "name": "NVIDIA NIM", "options": {"baseURL": $u}, "models": $m}')"
  auth_ekle nvidia "$ANAHTAR"
  varsayilan_ayarla "nvidia/${SECILEN[0]}"
  EKLENENLER+=("NVIDIA NIM: ${SECILEN[*]}")
}

kur_basit() {          # kur_basit <id> <ad> <anahtar-adresi> <doğrulama-url> <header-şablonu>
  local id=$1 ad=$2 adres=$3 durl=$4 hsablon=$5
  echo; bilgi "$ad — anahtar: $adres"
  anahtar_sor "$ad API anahtarı"; [[ -z $ANAHTAR ]] && return
  if dogrula "$durl" "${hsablon//KEY/$ANAHTAR}"; then tamam "$ad anahtarı geçerli"
  else uyari "$ad anahtarı doğrulanamadı; yine de kaydediliyor."; fi
  auth_ekle "$id" "$ANAHTAR"
  EKLENENLER+=("$ad (modeller OpenCode'da /models listesinde)")
}

kur_openrouter() {
  echo; bilgi "OpenRouter — anahtar: https://openrouter.ai/keys"
  anahtar_sor "OpenRouter API anahtarı"; [[ -z $ANAHTAR ]] && return
  dogrula "https://openrouter.ai/api/v1/key" "Authorization: Bearer $ANAHTAR" \
    && tamam "OpenRouter anahtarı geçerli" || uyari "OpenRouter anahtarı doğrulanamadı; yine de kaydediliyor."
  auth_ekle openrouter "$ANAHTAR"
  local yanit
  if yanit=$(curl -fsS --max-time 30 "https://openrouter.ai/api/v1/models"); then
    # Şu an ücretsiz VE araç çağırmayı destekleyen modeller (OpenCode'un ajanı araç kullanır)
    listeden_sec "OpenRouter'da şu an ücretsiz ve araç destekli modeller" 40 < <(
      jq -r '.data[] | select(.pricing.prompt == "0" and .pricing.completion == "0")
                     | select((.supported_parameters // []) | index("tools")) | .id' <<<"$yanit" | sort)
    if ((${#SECILEN[@]})); then
      config_saglayici openrouter "$(jq -n --argjson m "$(printf '%s\n' "${SECILEN[@]}" | modeller_json)" '{"models": $m}')"
      varsayilan_ayarla "openrouter/${SECILEN[0]}"
      EKLENENLER+=("OpenRouter: ${SECILEN[*]}")
      return
    fi
  fi
  EKLENENLER+=("OpenRouter (model seçilmedi)")
}

kur_copilot() {
  echo; bilgi "GitHub Copilot — tarayıcıdan giriş gerekir"
  echo "  Şimdi 'opencode auth login' açılacak: listeden 'GitHub Copilot'u seç ve ekrandaki kodu"
  echo "  https://github.com/login/device adresine gir. (Copilot Free planı yeterli.)"
  if evet "Şimdi giriş yapılsın mı?"; then
    opencode auth login || uyari "Giriş tamamlanmadı; sonra 'opencode auth login' ile tekrar dene."
    AUTH=$(cat "$AUTH_FILE" 2>/dev/null || echo "$AUTH")   # opencode'un yazdığını al
  else
    echo "  Sonra: opencode auth login → GitHub Copilot"
  fi
  EKLENENLER+=("GitHub Copilot")
}

kur_ollama() {
  echo; bilgi "Ollama — modeller kendi bilgisayarında, internetsiz çalışır"

  # ── Donanım ve sürücü kontrolü ──
  local ram_gb vram_mb=0 vram_gb=0 surucu="" cc="" gpu=""
  ram_gb=$(( $(awk '/MemTotal/ {print $2}' /proc/meminfo) / 1024 / 1024 ))
  if command -v nvidia-smi >/dev/null 2>&1; then
    IFS=',' read -r gpu vram_mb surucu cc < <(nvidia-smi --query-gpu=name,memory.total,driver_version,compute_cap \
      --format=csv,noheader,nounits 2>/dev/null | head -1 | sed 's/, */,/g') || true
    [[ $vram_mb =~ ^[0-9]+$ ]] && vram_gb=$(( vram_mb / 1024 )) || vram_mb=0
  fi
  echo "  RAM: ${ram_gb} GB"
  if [[ -n $gpu ]]; then
    echo "  Ekran kartı: $gpu · ${vram_mb} MB · sürücü $surucu · compute $cc"
    local ana=${surucu%%.*}
    [[ $ana =~ ^[0-9]+$ ]] && (( ana < 570 )) && \
      uyari "Ollama bu kart için sürücü 570+ ister. Sürücü Yöneticisi'nden 570/580 serisini kur."
    if [[ $cc =~ ^[0-9]+\.[0-9]+$ ]] && (( ${cc%%.*} < 5 )); then
      uyari "Kart compute $cc (Kepler): Ollama desteklemiyor, modeller yalnız işlemcide çalışacak."
    fi
  else
    uyari "NVIDIA kartı ya da nvidia-smi bulunamadı; modeller işlemcide çalışacak."
  fi

  # ── Kurulum ──
  if ! command -v ollama >/dev/null 2>&1; then
    evet "Ollama kurulsun mu? (https://ollama.com/install.sh, sudo ister)" || return
    curl -fsSL https://ollama.com/install.sh | sh
  fi
  tamam "Ollama kurulu: $(ollama --version 2>/dev/null | tail -1)"

  # ── Sunucu ayarları (systemd) ──
  # Ollama, 23 GB'tan az ekran kartı belleğinde varsayılan bağlamı 4096 token yapar.
  # OpenCode'un sistem talimatı ve araç tanımları buna sığmaz, sessizce kesilir.
  # Küçük bellekte 16K yeterli ve RAM'i korur. Tek istek + tek model belleği korur.
  local baglam=32768
  (( vram_gb < 6 && ram_gb <= 16 )) && baglam=16384
  if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files ollama.service >/dev/null 2>&1; then
    bilgi "Ollama sunucu ayarları yazılıyor (bağlam $baglam, tek model, 30 dk bellekte kal)"
    sudo mkdir -p /etc/systemd/system/ollama.service.d
    sudo tee /etc/systemd/system/ollama.service.d/faw-ayarlar.conf >/dev/null <<AYAR
[Service]
Environment="OLLAMA_CONTEXT_LENGTH=$baglam"
Environment="OLLAMA_NUM_PARALLEL=1"
Environment="OLLAMA_MAX_LOADED_MODELS=1"
Environment="OLLAMA_KEEP_ALIVE=30m"
AYAR
    sudo systemctl daemon-reload
    sudo systemctl restart ollama
    sleep 2
  else
    uyari "systemd servisi bulunamadı; bağlam ayarı model kopyalarıyla yapılacak."
  fi

  # ── Model menüsü (16 GB RAM, 2-4 GB ekran kartı için) ──
  local -a M_AD=(  "qwen2.5-coder:1.5b" "qwen2.5-coder:3b" "qwen3:4b" "qwen2.5-coder:7b"
                   "phi4-mini" "llama3.2:3b" "granite3.3:2b" "deepseek-coder:1.3b"
                   "deepseek-coder-v2:16b" "codegemma:2b" "starcoder2:3b" )
  local -a M_BOY=( "~1 GB" "~1.9 GB" "~2.5 GB" "~4.7 GB"
                   "~2.5 GB" "~2 GB" "~1.5 GB" "~0.8 GB"
                   "~9 GB" "~1.6 GB" "~1.7 GB" )
  local -a M_NOT=(
    "çok hızlı; kısa fonksiyonlar, açıklama"
    "ÖNERİLEN; C için hız/kalite dengesi"
    "araç çağırma güçlü; OpenCode ajanı için en iyi küçük model"
    "en iyi C kalitesi; işlemcide yavaş"
    "Microsoft; mantık ve matematikte güçlü"
    "Meta; genel sohbet"
    "IBM; küçük ve hızlı"
    "çok küçük eski kod modeli; yalnız basit işler"
    "MoE: her adımda ~2.4B çalışır, boyutuna göre hızlı; 16 GB RAM'i zorlar"
    "YALNIZ editör tamamlaması (Continue gibi); sohbet/ajan değil"
    "YALNIZ editör tamamlaması; sohbet/ajan değil"
  )
  local varsayilan_secim="2 3"
  if (( vram_gb >= 8 || ram_gb >= 24 )); then
    M_AD+=("qwen2.5-coder:14b"); M_BOY+=("~9 GB"); M_NOT+=("güçlü makineler için")
    varsayilan_secim="4"
  fi
  echo; bilgi "C kodu için modeller (boyutlar yaklaşık, Q4 sıkıştırma):"
  for i in "${!M_AD[@]}"; do
    printf '  %d) %-20s %-8s %s\n' "$((i+1))" "${M_AD[$i]}" "${M_BOY[$i]}" "${M_NOT[$i]}"
  done
  echo "  Başka bir model adı da yazabilirsin (ör. deepseek-coder:6.7b). Liste: https://ollama.com/library"
  local secim n; read -rp "İndirilecekler [$varsayilan_secim]: " secim; secim=${secim:-$varsayilan_secim}

  local -a indirilecek=() kurulan=()
  for n in $secim; do
    if [[ $n =~ ^[0-9]+$ ]] && (( n>=1 && n<=${#M_AD[@]} )); then indirilecek+=("${M_AD[$((n-1))]}")
    elif [[ $n == *:* || $n =~ ^[a-z0-9._/-]+$ ]]; then indirilecek+=("$n")
    else uyari "Geçersiz seçim atlandı: $n"; fi
  done

  local m ad tmp
  for m in "${indirilecek[@]}"; do
    bilgi "$m indiriliyor"
    ollama pull "$m" || { uyari "İndirilemedi: $m"; continue; }
    # OpenCode dosya okuma/yazma için araç çağırır; desteklemeyen model ajan olarak çalışmaz.
    if ollama show "$m" 2>/dev/null | grep -qiw tools; then tamam "$m araç çağırmayı destekliyor"
    else uyari "$m araç çağırmayı desteklemiyor: OpenCode'da yalnız sohbet için kullan (build modunda dosya değiştiremez)."; fi
    ad=$m
    if ! systemctl is-active --quiet ollama 2>/dev/null; then
      ad="${m//[:\/]/-}-${baglam}"
      tmp=$(mktemp); printf 'FROM %s\nPARAMETER num_ctx %s\n' "$m" "$baglam" > "$tmp"
      ollama create "$ad" -f "$tmp" >/dev/null && tamam "Bağlamı $baglam olan kopya: $ad"; rm -f "$tmp"
    fi
    kurulan+=("$ad")
  done
  ((${#kurulan[@]})) || { uyari "Hiç model kurulmadı."; return; }

  config_saglayici ollama "$(jq -n --argjson m "$(printf '%s\n' "${kurulan[@]}" | modeller_json)" \
    '{"npm": "@ai-sdk/openai-compatible", "name": "Ollama (yerel)",
      "options": {"baseURL": "http://127.0.0.1:11434/v1"}, "models": $m}')"
  varsayilan_ayarla "ollama/${kurulan[0]}"
  EKLENENLER+=("Ollama: ${kurulan[*]}")

  # ── İsteğe bağlı hız ve C derleme testi ──
  evet "Kurulan ilk modelle hız ve C derleme testi yapılsın mı?" || return 0
  command -v gcc >/dev/null 2>&1 || sudo apt-get install -y build-essential
  local test_dir cikti
  test_dir=$(mktemp -d)
  bilgi "${kurulan[0]} bir C programı yazıyor (ilk yükleme birkaç dakika sürebilir)"
  cikti=$(ollama run "${kurulan[0]}" --verbose \
    "Write a complete C11 program that reverses a singly linked list of the integers 1..5 and prints it. Free all memory. Reply with only one \`\`\`c code block." \
    2>"$test_dir/istatistik.txt") || true
  awk '/^```/{f=!f; next} f' <<<"$cikti" > "$test_dir/test.c"
  grep -E 'eval rate|total duration' "$test_dir/istatistik.txt" | sed 's/^/  /' || true
  echo "  Kartın kullanımı:"; ollama ps | sed 's/^/  /'
  if [[ -s $test_dir/test.c ]] && gcc -std=c11 -Wall -Wextra -o "$test_dir/test" "$test_dir/test.c" 2>"$test_dir/gcc.txt"; then
    tamam "Model C kodu yazdı ve gcc uyarısız derledi. Çıktı: $("$test_dir/test" | tr '\n' ' ')"
  else
    uyari "Üretilen kod derlenmedi (küçük modellerde olabilir). Ayrıntı: $test_dir/gcc.txt, kod: $test_dir/test.c"
  fi
  echo "  Test dosyaları: $test_dir"
}

# ── Yerel sunucular: llama.cpp, LM Studio, Jan ──────────────────────────────
# Hepsi OpenAI uyumlu bir /v1 adresi açar; OpenCode'a aynı şekilde bağlanır.
# Aynı anda yalnız birini çalıştır: 16 GB RAM'de iki model birden sığmaz.
YEREL_SUNUCULAR=(
  "ollama|Ollama (yerel)|http://127.0.0.1:11434/v1"
  "llamacpp|llama.cpp (yerel)|http://127.0.0.1:8080/v1"
  "lmstudio|LM Studio (yerel)|http://127.0.0.1:1234/v1"
  "jan|Jan (yerel)|http://127.0.0.1:1337/v1"
)

yerel_saglayici_yaz() {   # yerel_saglayici_yaz <id> <ad> <url> <modeller-json>
  config_saglayici "$1" "$(jq -n --arg ad "$2" --arg u "$3" --argjson m "$4" \
    '{"npm": "@ai-sdk/openai-compatible", "name": $ad, "options": {"baseURL": $u}, "models": $m}')"
}

esitle() {   # çalışan yerel sunuculardaki modelleri OpenCode config'ine ekler
  echo; bilgi "Çalışan yerel sunucular taranıyor"
  local satir id ad url anahtar yanit json bulundu=0
  for satir in "${YEREL_SUNUCULAR[@]}"; do
    IFS='|' read -r id ad url <<<"$satir"
    anahtar=$(jq -r --arg id "$id" '.[$id].key // empty' <<<"$AUTH")
    if yanit=$(curl -fsS --max-time 5 ${anahtar:+-H "Authorization: Bearer $anahtar"} "$url/models" 2>/dev/null); then
      json=$(jq -r '.data[].id' <<<"$yanit" | modeller_json)
      yerel_saglayici_yaz "$id" "$ad" "$url" "$json"
      tamam "$ad: $(jq -r 'keys | join(", ")' <<<"$json")"
      EKLENENLER+=("$ad eşitlendi"); bulundu=1
    else
      echo "  $ad kapalı ($url)"
    fi
  done
  (( bulundu )) || uyari "Çalışan yerel sunucu bulunamadı. Önce birini başlat, sonra --esitle ile tekrar çalıştır."
}

vram_olc() {   # VRAM_MB değişkenini doldurur (kart yoksa 0)
  VRAM_MB=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ' || true)
  [[ $VRAM_MB =~ ^[0-9]+$ ]] || VRAM_MB=0
}

kur_llamacpp() {
  echo; bilgi "llama.cpp — en hafif yerel çalıştırıcı; ekran kartını Vulkan ile kullanır"
  local eksikler=() p
  for p in libvulkan1 vulkan-tools unzip libgomp1; do dpkg -s "$p" >/dev/null 2>&1 || eksikler+=("$p"); done
  ((${#eksikler[@]})) && sudo apt-get install -y "${eksikler[@]}"
  if vulkaninfo --summary 2>/dev/null | grep -qi nvidia; then tamam "Vulkan NVIDIA kartını görüyor"
  else uyari "Vulkan NVIDIA kartını görmüyor; llama.cpp işlemcide çalışacak."; fi

  # En son resmi sürümden Ubuntu Vulkan derlemesini al (yoksa işlemci derlemesi)
  local surum url hedef="$HOME/.local/opt/llama.cpp"
  surum=$(curl -fsSL --max-time 30 https://api.github.com/repos/ggml-org/llama.cpp/releases/latest) \
    || { uyari "GitHub'a ulaşılamadı."; return; }
  url=$(jq -r '[.assets[] | select(.name | test("bin-ubuntu-vulkan-x64"))][0].browser_download_url // empty' <<<"$surum")
  [[ -z $url ]] && url=$(jq -r '[.assets[] | select(.name | test("bin-ubuntu-x64"))][0].browser_download_url // empty' <<<"$surum")
  [[ -z $url ]] && { uyari "Uygun llama.cpp derlemesi bulunamadı: https://github.com/ggml-org/llama.cpp/releases"; return; }
  bilgi "İndiriliyor: ${url##*/} ($(jq -r .tag_name <<<"$surum"))"
  rm -rf "$hedef" && mkdir -p "$hedef" "$HOME/.local/bin"
  local arsiv="$hedef/${url##*/}"
  curl -fL --progress-bar "$url" -o "$arsiv"
  case $arsiv in
    *.zip)    unzip -q "$arsiv" -d "$hedef" ;;
    *.tar.gz) tar -xzf "$arsiv" -C "$hedef" ;;
  esac
  rm -f "$arsiv"
  local ikili; ikili=$(find "$hedef" -type f -name llama-server | head -1)
  [[ -x $ikili ]] || { uyari "llama-server bulunamadı."; return; }
  printf '#!/bin/sh\nexec "%s" "$@"\n' "$ikili" > "$HOME/.local/bin/llama-server"
  chmod +x "$HOME/.local/bin/llama-server"
  tamam "llama-server kuruldu: $ikili"

  # Model (Hugging Face'ten GGUF; ilk çalıştırmada indirilir, ~/.cache/llama.cpp)
  local -a G_AD=(  "Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF:Q4_K_M" "Qwen/Qwen2.5-Coder-3B-Instruct-GGUF:Q4_K_M"
                   "Qwen/Qwen2.5-Coder-7B-Instruct-GGUF:Q4_K_M"   "Qwen/Qwen3-4B-GGUF:Q4_K_M" )
  local -a G_NOT=( "~1 GB, çok hızlı" "~2 GB, ÖNERİLEN" "~4.7 GB, en iyi kalite, yavaş" "~2.5 GB, araç çağırma güçlü" )
  echo; bilgi "llama.cpp için model (aynı anda tek model çalışır):"
  for i in "${!G_AD[@]}"; do printf '  %d) %-46s %s\n' "$((i+1))" "${G_AD[$i]}" "${G_NOT[$i]}"; done
  echo "  Ya da Hugging Face'ten 'kullanıcı/depo-GGUF:Q4_K_M' biçiminde başka bir GGUF yaz."
  local secim model; read -rp "Seçim [2]: " secim; secim=${secim:-2}
  if [[ $secim =~ ^[0-9]+$ ]] && (( secim>=1 && secim<=${#G_AD[@]} )); then model=${G_AD[$((secim-1))]}; else model=$secim; fi
  local takma; takma=$(sed 's#.*/##; s#-GGUF##; s#:.*##' <<<"$model" | tr '[:upper:]' '[:lower:]')

  # Ekran kartına kaç katman yükleneceği: 2 GB'ta az, 4 GB'ta orta, fazlasında tamamı.
  vram_olc
  local ngl=0
  (( VRAM_MB >= 1800 )) && ngl=12
  (( VRAM_MB >= 3800 )) && ngl=24
  (( VRAM_MB >= 7800 )) && ngl=99
  local ram_gb baglam=32768
  ram_gb=$(( $(awk '/MemTotal/ {print $2}' /proc/meminfo) / 1024 / 1024 ))
  (( VRAM_MB < 6000 && ram_gb <= 16 )) && baglam=16384
  echo "  Ekran kartına $ngl katman, bağlam $baglam token. Değiştirmek için servis dosyasını düzenle."

  # Kullanıcı servisi: oturum açınca başlar; --jinja araç çağırma için gerekli.
  local servis="$HOME/.config/systemd/user/llama-server.service"
  mkdir -p "${servis%/*}"
  cat > "$servis" <<SERVIS
[Unit]
Description=llama.cpp sunucusu ($model)

[Service]
ExecStart=$HOME/.local/bin/llama-server -hf $model --alias $takma --jinja -c $baglam -ngl $ngl --host 127.0.0.1 --port 8080
Restart=on-failure

[Install]
WantedBy=default.target
SERVIS
  systemctl --user daemon-reload
  systemctl --user enable --now llama-server.service
  bilgi "Model indiriliyor ve yükleniyor (ilk seferde birkaç dakika). İlerleme: journalctl --user -fu llama-server"
  local t
  for ((t=0; t<120; t++)); do
    curl -fs --max-time 3 http://127.0.0.1:8080/health >/dev/null 2>&1 && break
    sleep 5
  done
  if curl -fs --max-time 3 http://127.0.0.1:8080/health >/dev/null 2>&1; then tamam "llama.cpp hazır: http://127.0.0.1:8080"
  else uyari "Sunucu 10 dakikada hazır olmadı; indirme sürüyor olabilir. Sonra: bash $0 --esitle"; fi

  yerel_saglayici_yaz llamacpp "llama.cpp (yerel)" "http://127.0.0.1:8080/v1" "{\"$takma\": {}}"
  varsayilan_ayarla "llamacpp/$takma"
  EKLENENLER+=("llama.cpp: $takma (servis: systemctl --user {start|stop} llama-server)")
}

kur_lmstudio() {
  echo; bilgi "LM Studio — grafik arayüzlü; model arama/indirme ve sohbet penceresi var"
  dpkg -s libfuse2t64 >/dev/null 2>&1 || dpkg -s libfuse2 >/dev/null 2>&1 \
    || sudo apt-get install -y libfuse2t64 2>/dev/null || sudo apt-get install -y libfuse2
  local dizin="$HOME/Applications" dosya="$HOME/Applications/LM-Studio.AppImage"
  mkdir -p "$dizin" "$HOME/.local/share/applications"
  bilgi "LM Studio indiriliyor (~1 GB)"
  curl -fL --progress-bar "https://lmstudio.ai/download/latest/linux/x64?format=AppImage" -o "$dosya" \
    || { uyari "İndirilemedi. Elle indir: https://lmstudio.ai/download"; return; }
  chmod +x "$dosya"
  cat > "$HOME/.local/share/applications/lmstudio.desktop" <<MASAUSTU
[Desktop Entry]
Name=LM Studio
Exec=$dosya
Type=Application
Categories=Development;
MASAUSTU
  tamam "LM Studio kuruldu (Menü → Geliştirme → LM Studio)"
  yerel_saglayici_yaz lmstudio "LM Studio (yerel)" "http://127.0.0.1:1234/v1" '{}'
  cat <<'NOT'
  Sonraki adımlar:
    1. LM Studio'yu aç → Discover → "qwen2.5-coder-3b-instruct" ara → indir (Q4_K_M)
    2. Developer sekmesi → "Start Server" (port 1234)
       ya da terminalde:  ~/.lmstudio/bin/lms server start
    3. Modelleri OpenCode'a aktar:  bash opencode-kurulum.sh --esitle
NOT
  EKLENENLER+=("LM Studio (modeller için sonra --esitle)")
}

kur_jan() {
  echo; bilgi "Jan — açık kaynak, ChatGPT benzeri masaüstü uygulaması"
  local deb; deb=$(mktemp --suffix=.deb)
  curl -fL --progress-bar "https://app.jan.ai/download/latest/linux-amd64-deb" -o "$deb" \
    || { uyari "İndirilemedi. Elle indir: https://jan.ai"; rm -f "$deb"; return; }
  sudo apt-get install -y "$deb"; rm -f "$deb"
  tamam "Jan kuruldu (Menü → Jan)"
  yerel_saglayici_yaz jan "Jan (yerel)" "http://127.0.0.1:1337/v1" '{}'
  cat <<'NOT'
  Sonraki adımlar:
    1. Jan'ı aç → Hub → "Qwen2.5 Coder 3B" gibi bir model indir
    2. Settings → Local API Server → bir API anahtarı belirle → Start Server (port 1337)
    3. Anahtarı ve modelleri OpenCode'a aktar:  bash opencode-kurulum.sh --esitle
NOT
  anahtar_sor "Jan'da belirlediğin API anahtarı (henüz yoksa boş bırak)"
  [[ -n $ANAHTAR ]] && auth_ekle jan "$ANAHTAR"
  EKLENENLER+=("Jan (modeller için sonra --esitle)")
}

kur_anthropic() {
  echo; bilgi "Anthropic Claude — ÜCRETLİ. Anahtar: https://console.anthropic.com → API Keys"
  anahtar_sor "Anthropic API anahtarı (sk-ant-…)"; [[ -z $ANAHTAR ]] && return
  dogrula "https://api.anthropic.com/v1/models" "x-api-key: $ANAHTAR" "anthropic-version: 2023-06-01" \
    && tamam "Anthropic anahtarı geçerli" || uyari "Anthropic anahtarı doğrulanamadı; yine de kaydediliyor."
  auth_ekle anthropic "$ANAHTAR"
  EKLENENLER+=("Anthropic Claude (ücretli)")
}

for s in $SECIM; do
  case $s in
    1)  kur_zen ;;
    2)  kur_nvidia ;;
    3)  kur_basit google "Google Gemini" "https://aistudio.google.com/apikey" \
          "https://generativelanguage.googleapis.com/v1beta/models" "x-goog-api-key: KEY" ;;
    4)  kur_basit groq "Groq" "https://console.groq.com/keys" \
          "https://api.groq.com/openai/v1/models" "Authorization: Bearer KEY" ;;
    5)  kur_openrouter ;;
    6)  kur_basit mistral "Mistral" "https://console.mistral.ai/api-keys" \
          "https://api.mistral.ai/v1/models" "Authorization: Bearer KEY" ;;
    7)  kur_basit cerebras "Cerebras" "https://cloud.cerebras.ai" \
          "https://api.cerebras.ai/v1/models" "Authorization: Bearer KEY" ;;
    8)  kur_basit huggingface "Hugging Face" "https://huggingface.co/settings/tokens" \
          "https://huggingface.co/api/whoami-v2" "Authorization: Bearer KEY" ;;
    9)  kur_copilot ;;
    10) kur_ollama ;;
    11) kur_anthropic ;;
    12) kur_llamacpp ;;
    13) kur_lmstudio ;;
    14) kur_jan ;;
    esitle) esitle ;;
    *)  uyari "Bilinmeyen seçim: $s" ;;
  esac
done
unset ANAHTAR

# ── 3. Dosyaları yaz ────────────────────────────────────────────────────────
if [[ -f $CONFIG_FILE ]]; then
  yedek="$CONFIG_FILE.yedek-$(date +%Y%m%d-%H%M%S)"; cp "$CONFIG_FILE" "$yedek"
  bilgi "Eski config yedeklendi: $yedek"
fi
CONFIG=$(jq '. + {"$schema": "https://opencode.ai/config.json"}' <<<"$CONFIG")
[[ -n $VARSAYILAN ]] && CONFIG=$(jq --arg d "$VARSAYILAN" '.model = $d' <<<"$CONFIG")
printf '%s\n' "$CONFIG" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

( umask 077; printf '%s\n' "$AUTH" > "$AUTH_FILE.tmp" ) && mv "$AUTH_FILE.tmp" "$AUTH_FILE"
chmod 600 "$AUTH_FILE"
AUTH='{}'

# ── Özet ────────────────────────────────────────────────────────────────────
echo
bilgi "Kurulum tamam."
if ((${#EKLENENLER[@]})); then printf '  • %s\n' "${EKLENENLER[@]}"; else uyari "Hiç sağlayıcı eklenmedi."; fi
echo "  Config : $CONFIG_FILE"
echo "  Anahtar: $AUTH_FILE (izin 600)"
[[ -n $VARSAYILAN ]] && echo "  Varsayılan model: $VARSAYILAN"
cat <<'EOF'

Kullanım:
  source ~/.bashrc          # ya da yeni bir terminal aç
  cd ~/projem
  opencode

OpenCode içinde:
  /init     projeyi tarar, AGENTS.md oluşturur (bir kez)
  /models   sağlayıcı ve model değiştir
  /connect  sonradan yeni bir sağlayıcı anahtarı ekle
  Tab       plan (yalnız öneri) ↔ build (dosyaları değiştirir)
  @dosya    dosyayı bağlama ekle

Yararlı komutlar:
  opencode models                 # tüm kullanılabilir modeller
  opencode models opencode        # OpenCode Zen'deki güncel (ücretsiz) modeller
  opencode run "…görev…"          # arayüz açmadan tek görev

İpucu: Bir sağlayıcının günlük sınırı dolunca /models ile ötekine geç.
EOF
