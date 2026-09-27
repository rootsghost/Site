#!/usr/bin/env bash
# Faw Builder'ı derler, testlerini çalıştırır ve sitedeki test ibaresini günceller:
#   index.html          ✓ 103/103 test geçiyor (GLib GTest, 2026-09-26)
#   assets/site.js      103/103 tests passing (GLib GTest, 2026-09-26)   (İngilizcesi)
#
# Kullanım:
#   bash scripts/test-durumu.sh ~/faw-builder                 # derle, test et, siteyi güncelle
#   bash scripts/test-durumu.sh ~/faw-builder --kuru          # yalnız göster, dosyalara yazma
#   bash scripts/test-durumu.sh ~/faw-builder --surum-notu    # sürüm notlarına ve RSS'e de ekle
#   bash scripts/test-durumu.sh ~/faw-builder --suite ide     # yalnız bir meson test suite'i
#
# Seçenekler:
#   --build DIZIN     Meson derleme klasörü (varsayılan: <proje>/build)
#   --suite AD        meson test --suite AD (birden çok kez verilebilir)
#   --etiket METIN    Parantez içindeki test altyapısı adı (varsayılan: "GLib GTest")
#   --surum-notu      surumler.html ve feed.xml'e bugünün tarihiyle bir satır ekler
#   --kuru            Hiçbir dosyayı değiştirmez, yalnız yeni ibareyi yazdırır
#
# Sonuçlar meson'un kendi kaydından (build/meson-logs/testlog.json) okunur; ekrandaki çıktı
# ayrıştırılmaz. Ekran yoksa (SSH, CI) GTK testleri için xvfb-run kullanılır.
# Testlerden biri bile başarısız olursa ibare yine gerçeği yazar (ör. 98/103) ve betik 1 ile çıkar.

set -euo pipefail

bilgi()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
tamam()  { printf '\033[1;32m✓\033[0m   %s\n' "$*"; }
uyari()  { printf '\033[1;33m!!\033[0m  %s\n' "$*" >&2; }
hata()   { printf '\033[1;31mHATA:\033[0m %s\n' "$*" >&2; exit 2; }

SITE=$(cd "$(dirname "$0")/.." && pwd)
PROJE=""; BUILD=""; ETIKET="GLib GTest"; KURU=0; NOT=0; SUITES=()

while (( $# )); do
  case $1 in
    --build)       BUILD=${2:?--build bir dizin ister}; shift ;;
    --suite)       SUITES+=("--suite" "${2:?--suite bir ad ister}"); shift ;;
    --etiket)      ETIKET=${2:?--etiket bir metin ister}; shift ;;
    --surum-notu)  NOT=1 ;;
    --kuru)        KURU=1 ;;
    -h|--help)     sed -n '2,23p' "$0"; exit 0 ;;
    -*)            hata "Bilinmeyen seçenek: $1" ;;
    *)             [[ -z $PROJE ]] || hata "Birden çok proje dizini verildi."; PROJE=$1 ;;
  esac
  shift
done

[[ -n $PROJE ]] || hata "Faw Builder kaynak dizinini ver. Örnek: bash scripts/test-durumu.sh ~/faw-builder"
PROJE=$(cd "$PROJE" && pwd) || hata "Dizin bulunamadı: $PROJE"
[[ -f $PROJE/meson.build ]] || hata "$PROJE içinde meson.build yok; Faw Builder'ın kök dizini mi?"
BUILD=${BUILD:-$PROJE/build}

for arac in meson ninja python3; do
  command -v "$arac" >/dev/null 2>&1 || hata "$arac bulunamadı. Kur: sudo apt install meson ninja-build python3"
done

# ── 1) Derle ────────────────────────────────────────────────────────────────
if [[ ! -f $BUILD/build.ninja ]]; then
  bilgi "Meson yapılandırılıyor: $BUILD"
  meson setup "$BUILD" "$PROJE"
else
  bilgi "Mevcut derleme klasörü kullanılıyor: $BUILD"
fi
if [[ -d $PROJE/.git ]]; then
  bilgi "Kod: $(git -C "$PROJE" log -1 --format='%h · %cd · %s' --date=short)"
  [[ -z $(git -C "$PROJE" status --porcelain --untracked-files=no) ]] || uyari "Projede commit edilmemiş değişiklikler var; sonuç bunları da içerir."
fi
bilgi "Derleniyor"
meson compile -C "$BUILD"

# ── 2) Test et ──────────────────────────────────────────────────────────────
SARMA=()
if [[ -z ${DISPLAY:-} && -z ${WAYLAND_DISPLAY:-} ]]; then
  if command -v xvfb-run >/dev/null 2>&1; then
    SARMA=(xvfb-run -a); bilgi "Ekran yok; testler xvfb-run ile sanal ekranda çalışacak"
  else
    uyari "Ekran yok ve xvfb-run kurulu değil; GTK testleri başarısız olabilir (sudo apt install xvfb)."
  fi
fi
LOG=$BUILD/meson-logs/testlog.json
rm -f "$LOG"
bilgi "Testler çalışıyor"
set +e
"${SARMA[@]}" meson test -C "$BUILD" --print-errorlogs "${SUITES[@]}"
TEST_KODU=$?
set -e
[[ -s $LOG ]] || hata "Test kaydı oluşmadı ($LOG). meson test hiç çalışmamış olabilir (kod $TEST_KODU)."

# ── 3) Sonucu say ───────────────────────────────────────────────────────────
read -r GECEN TOPLAM ATLANAN BASARISIZ < <(python3 - "$LOG" <<'PY'
import json, sys
sayac = {}
for satir in open(sys.argv[1], encoding="utf-8"):
    satir = satir.strip()
    if satir:
        s = json.loads(satir).get("result", "")
        sayac[s] = sayac.get(s, 0) + 1
gecen = sayac.get("OK", 0) + sayac.get("EXPECTEDFAIL", 0)
atlanan = sayac.get("SKIP", 0)
toplam = sum(sayac.values()) - atlanan
print(gecen, toplam, atlanan, toplam - gecen)
PY
)
(( TOPLAM > 0 )) || hata "Hiç test çalışmadı."
TARIH=$(date +%F)
TR="$GECEN/$TOPLAM test geçiyor ($ETIKET, $TARIH)"
EN="$GECEN/$TOPLAM tests passing ($ETIKET, $TARIH)"
(( ATLANAN )) && uyari "$ATLANAN test atlandı (SKIP); toplama katılmadı."
if (( BASARISIZ )); then
  uyari "$BASARISIZ test başarısız. İbare yine gerçeği yazacak: $TR"
else
  tamam "Tüm testler geçti: $GECEN/$TOPLAM"
fi

if (( KURU )); then
  echo; echo "Yeni ibare (dosyalara yazılmadı):"; echo "  TR: $TR"; echo "  EN: $EN"
  exit $(( BASARISIZ ? 1 : 0 ))
fi

# ── 4) Siteyi güncelle ──────────────────────────────────────────────────────
python3 - "$SITE" "$TR" "$EN" "$GECEN" "$TOPLAM" "$TARIH" "$NOT" "$ETIKET" <<'PY'
import json, pathlib, re, sys
site, tr, en, gecen, toplam, tarih, not_ekle, etiket = sys.argv[1:]
site = pathlib.Path(site); hepsi = gecen == toplam

def degistir(dosya, desen, yeni, ad):
    yol = site / dosya; metin = yol.read_text(encoding="utf-8")
    metin2, n = re.subn(desen, yeni, metin, count=1, flags=re.S)
    if n != 1:
        sys.exit(f"{dosya}: {ad} bulunamadı; site yapısı değişmiş olabilir.")
    yol.write_text(metin2, encoding="utf-8")

isaret = "✓" if hepsi else "!"
degistir("index.html",
         r'(<p class="hero-status"><span aria-hidden="true">)[^<]*(</span> <span data-i18n="hero\.tests">)[^<]*(</span>)',
         lambda m: m.group(1) + isaret + m.group(2) + tr + m.group(3), "hero.tests (index.html)")
degistir("assets/site.js", r'("hero\.tests":")[^"]*(")', lambda m: m.group(1) + en + m.group(2), "hero.tests (site.js)")
print(f"index.html ve assets/site.js güncellendi: {tr}")

if not_ekle == "1":
    tr_not = f"Test paketi: {toplam} testin {gecen} tanesi geçiyor ({etiket})."
    en_not = f"Test suite: {gecen} of {toplam} tests pass ({etiket})."
    anahtar = f"r.{tarih}.test"
    s = (site / "surumler.html").read_text(encoding="utf-8")
    if f'data-i18n="{anahtar}"' in s:
        s = re.sub(rf'(<li data-i18n="{re.escape(anahtar)}">)[^<]*(</li>)', lambda m: m.group(1) + tr_not + m.group(2), s)
    elif f'<article class="release" id="d-{tarih}">' in s:
        s = s.replace(f'<time datetime="{tarih}">{tarih}</time>\n      <ul>\n',
                      f'<time datetime="{tarih}">{tarih}</time>\n      <ul>\n        <li data-i18n="{anahtar}">{tr_not}</li>\n', 1)
    else:
        yeni = (f'    <article class="release" id="d-{tarih}">\n      <time datetime="{tarih}">{tarih}</time>\n      <ul>\n'
                f'        <li data-i18n="{anahtar}">{tr_not}</li>\n      </ul>\n    </article>\n')
        s, n = re.subn(r'(\n)(    <article class="release")', lambda m: m.group(1) + yeni + m.group(2), s, count=1)
        if n != 1: sys.exit("surumler.html: sürüm listesi bulunamadı.")
    m = re.search(r"window\.FAW_PAGE_EN = (\{.*?\});</script>", s, re.S)
    sozluk = json.loads(m.group(1)); sozluk[anahtar] = en_not
    s = s[:m.start(1)] + json.dumps(sozluk, ensure_ascii=False, indent=1) + s[m.end(1):]
    (site / "surumler.html").write_text(s, encoding="utf-8")

    f = (site / "feed.xml").read_text(encoding="utf-8")
    link = f"https://fawlibs.org/surumler.html#d-{tarih}"
    guid = f"fawlibs-test-durumu-{tarih}"          # aynı günün diğer notlarından ayrı tutulur
    from email.utils import format_datetime
    from datetime import datetime, timezone
    tarih_rss = format_datetime(datetime.strptime(tarih, "%Y-%m-%d").replace(tzinfo=timezone.utc))
    oge = (f"  <item>\n    <title>{tarih} · {gecen}/{toplam} test geçiyor</title>\n    <link>{link}</link>\n"
           f"    <guid isPermaLink=\"false\">{guid}</guid>\n    <pubDate>{tarih_rss}</pubDate>\n"
           f"    <description>{tr_not}</description>\n  </item>\n")
    if f"<guid isPermaLink=\"false\">{guid}</guid>" in f:
        f = re.sub(rf"  <item>\n(?:(?!</item>).)*?<guid isPermaLink=\"false\">{re.escape(guid)}</guid>.*?</item>\n", lambda m: oge, f, count=1, flags=re.S)
    else:
        f, n = re.subn(r"(\n)(  <item>)", lambda m: m.group(1) + oge + m.group(2), f, count=1)
        if n != 1: sys.exit("feed.xml: öğe listesi bulunamadı.")
    (site / "feed.xml").write_text(f, encoding="utf-8")
    print(f"surumler.html ve feed.xml'e {tarih} notu eklendi.")
PY

python3 "$SITE/scripts/kontrol.py"
echo
echo "Değişiklikleri gözden geçir ve gönder:"
echo "  cd $SITE && git diff && git commit -am \"Test durumu: $GECEN/$TOPLAM ($TARIH)\" && git push"
exit $(( BASARISIZ ? 1 : 0 ))
