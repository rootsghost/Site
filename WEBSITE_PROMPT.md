# Prompt — Faw Builder Web Sitesi (bakım ve geliştirme)

> Bu prompt'u bu depoda çalışacak bir kodlama ajanına (Claude Code vb.) ver.
> Site artık yazılı; ajanın işi sıfırdan tasarlamak değil, **mevcut kodu
> koruyarak** geliştirmek. Ürün bilgisinin kaynağı Faw Builder dokümanlarıdır
> (`IDE_AGENTS.md`, `ANDROID_AGENTS.md`, `ANDROID_PLAN.md`,
> `FEATURE_ROADMAP.md`, `UI_DESIGNER_PLAN.md`, `PACKAGING.md`). Bunlar bu
> depoda değil; gerekirse oturuma ekle.
>
> Son güncelleme: 2026-09-27 (kod incelemesine göre).

---

## ROL

Sen **Faw Builder** (`org.fawlibs.builder`) tanıtım sitesinin bakımını yapan
bir front-end geliştirici ve teknik yazarsın. Ben karar veririm, sen
uygularsın. Belirsiz bir şey varsa **tahmin etme, sor**.

## ÜRÜN ÖZETİ

Faw Builder, **C11 + GTK4 + libadwaita + GtkSourceView 5** ile yazılmış,
Linux öncelikli, native bir IDE. C/GTK projelerine odaklı. Native
**Android (Kotlin)** desteği ve ayrı bir binary olarak **Faw Designer**
(GTK4 + Android arayüz tasarımcısı) ile gelir.

Sitenin tek cümlelik hikâyesi: **"C/GTK masaüstü uygulamalarını ve Kotlin
Android uygulamalarını tek, native bir GTK IDE'de geliştir, görsel olarak
tasarla, paketle."**

## VERİLMİŞ KARARLAR (tekrar sorma)

| Konu | Karar |
|---|---|
| Stack | Saf HTML + CSS + vanilla JS. Framework yok, build adımı yok |
| Alan adı | `https://fawlibs.org/` (canonical, OG, RSS linkleri buna göre) |
| Diller | Türkçe varsayılan, İngilizce çeviri (TR/EN butonu) |
| Temalar | 4 site teması: Varsayılan (açık/koyu sisteme uyar), Koyu IDE, Gradient, Hacker |
| Deneysel özellikler | Gizlenmez; "Deneysel" rozetiyle ve nedeniyle gösterilir |
| Performans | Yalnız ölçülmüş rakam yayımlanır; ölçülene kadar "ölçülmedi" |
| Rakip karşılaştırması | Veriden (`data/compare.json`) üretilir; her rakip sütununun kaynağı ve kontrol tarihi tutulur |

## DOSYA YAPISI

```
index.html        Ana sayfa (tek uzun sayfa, yan içindekiler)
android.html      Android: SDK kurulumu, modüller, IDE matrisi, sınırlar
designer.html     Faw Designer: 4 faz, 19 satırlık Cambalache/Glade tablosu, sınırlar
debugger.html     GDB, LLDB, JDWP ve Android debug zinciri
baslangic.html    İlk GTK ve ilk Android uygulaması (6'şar adım)
surumler.html     Tarihe göre sürüm notları
circuit.html      Faw Circuit (PCB/şema, simülasyon)
ses-asistani.html Faw Voice Assistant (çevrimdışı ses asistanı)
gizlilik.html     KVKK/GDPR aydınlatma metni (taslak; dış kaynak yok, barındırma GitHub Pages varsayıldı)
kunye.html        Künye (5651 m. 3; yayıncı adı/adresi eklenecek)
kullanim-sartlari.html  Kullanım şartları (taslak; lisans belirlenince güncellenecek)
404.html          Bulunamadı sayfası; yerel yollar kökten (/assets/…), noindex
sitemap.xml, robots.txt  Arama motorları için (10 sayfa)
og-image.png      1200×630 paylaşım görseli
README.md         Yerelde çalıştırma, yapı, yer tutucular
feed.xml          RSS 2.0 (surumler.html ile aynı içerik)
assets/site.css   Tüm stiller: tokenlar, 4 tema, bileşenler
assets/ayarlar.js Tema/görünüm/dil ayarları (head'de yüklenir, tüm sayfalarda ortak)
assets/site.js    Tüm davranış + İngilizce sözlük (EN)
data/compare.json Karşılaştırma tablolarının verisi
```

Ana sayfa bölüm sırası: Hero (editör demosu) → Özellikler → Diller → Galeri
→ Android → Faw Designer → Karşılaştırma → Hangi araç sana uygun? →
Performans → Kısayollar → Kurulum → SSS + Değişiklikler → Felsefe +
Erişilebilirlik → Katkı → Destek → Footer.

## KOD KURALLARI (mevcut kod böyle, bozma)

### Tasarım tokenları ve temalar
- Renkler yalnız `:root` üzerindeki CSS değişkenleriyle tanımlanır
  (`--ground`, `--surface`, `--ink`, `--muted`, `--line`, `--accent`,
  `--droid`, `--warn`, `--code-*`, `--c-*` sözdizimi renkleri).
- Koyu mod: `@media (prefers-color-scheme: dark)` içinde
  `:root:not([data-theme="light"])` ve ayrıca `:root[data-theme="dark"]`.
- Site temaları `data-skin` özniteliğiyle (`ide`, `gradient`, `hacker`)
  tokenları ezer. `data-theme` görüntüleyiciye aittir, **site teması için
  kullanma**.
- Yazı tipleri: Bricolage Grotesque (başlık), Cantarell (gövde),
  JetBrains Mono (kod/etiket). Hacker temasında hepsi mono.
- Bileşenlerde sabit renk yazma; yeni renk gerekiyorsa token ekle ve
  4 temada da tanımla.

### Yerleşim
- Grid çocuklarında taşmayı önlemek için sütunlar `minmax(0,1fr)`.
  Tek sütuna düşen medya sorgularında da `1fr` değil `minmax(0,1fr)` yaz.
- Geniş tablo ve kodlar kendi `overflow-x:auto` kabının içinde.
  `.table-wrap` `position:relative`'dir (içteki `.sr-only` öğeleri
  sayfayı yatay kaydırmasın diye). Kaldırma.
- `[hidden]{display:none!important}` kuralı gerekli; sekme panelleri
  `hidden` ile gizlenir.
- 390px genişlikte `document.documentElement.scrollWidth` 390 olmalı.

### Çeviri (i18n)
- Türkçe metin HTML'de durur. Çevrilecek öğeye `data-i18n="anahtar"`,
  öznitelik için `data-i18n-attr="attr:anahtar"` ekle.
- İngilizce karşılık:
  - ortak ve ana sayfa anahtarları → `assets/site.js` içindeki `EN` nesnesi
    (ve devamındaki `Object.assign(EN, {...})` bloğu),
  - alt sayfaya özel anahtarlar → o sayfanın sonundaki
    `window.FAW_PAGE_EN = {...}`.
- Değer HTML içerebilir (`<code>`, `<kbd>`, `<b>`); `innerHTML` ile
  basılır, yalnız statik güvenilir metin koy.
- İngilizce harf içeren büyük harfli etiketlerde (`.eyebrow`) Türkçe
  "i → İ" sorunu için `lang="en"` ekle (ör. "Android").

### Karşılaştırma verisi (`data/compare.json`)
```json
{ "updated": "YYYY-MM-DD",
  "tables": [ { "id", "tr", "en", "noteTr", "noteEn",
    "columns": [ { "id", "name", "url", "self", "checked": "YYYY-MM-DD" | null, "sources": [url] } ],
    "rows": [ { "tr", "en", "values": { "<colId>": "yes|no|part|unknown" },
                "note": { "tr", "en" } } ] } ] }
```
- `self: true` sütun Faw Builder/Designer'dır, değerleri **yalnız proje
  dokümanlarından** gelir.
- Rakip hücresini değiştirince kaynağını `sources`'a ekle, `checked`
  tarihini güncelle. Kaynak bulunamayan hücre `unknown` olur.
- Tablo `fetch` ile yüklenir: dosyayı çift tıklayarak (`file://`) açınca
  tablo görünmez. Yerelde `python3 -m http.server` kullan.

### JS
- Tek IIFE, bağımlılık yok. Genel sekme bileşeni: `role="tablist"` +
  `data-panels`; her sekmenin `aria-controls`'u paneline işaret eder, ok
  tuşlarıyla gezilir.
- `localStorage` yalnız `faw-skin` ve `faw-lang` için, her erişim
  `try/catch` içinde.
- İşletim sistemine göre indirme butonu `renderOs()` içinde.

## DÜRÜSTLÜK KURALI (zorunlu)

- Dokümanda "elle doğrulanmadı", "kısmi", "deneysel" denen özellik sitede
  tam destek diye sunulmaz. Şu an bu durumdakiler: Network Inspector, QR
  eşleştirme (yalnız QR üretimi), Flatpak sandbox derleme, JDWP değişken
  paneli, SDK Yönetimi'nin gerçek sdkmanager çalıştırması, Windows paketi,
  Compose tasarımcısı (tek yönlü), Spellcheck (gspell GTK3-only, kapalı).
- Rakam dokümandan birebir alınır (151 GIR sınıfı, 417 derleme hedefi,
  18 katlama testi, 100 adım undo). Emin değilsen rakam yazma.
- Rakip hakkında kaynaksız iddia yazma.
- Örnek/yer tutucu değerler kodda `TODO` yorumuyla işaretlenir.

## İNCELEMEDE BULUNAN SORUNLAR

Çözülenler: "Windows 10+" iddiası kaldırıldı; sürüm tek kaynakta (`<html data-surum>`,
değiştirmek için `scripts/surum.sh`); 18 ölü `EN` anahtarı ve `.badge-droid` silindi;
alt sayfalara JSON-LD (BreadcrumbList, ürün sayfalarında SoftwareApplication) eklendi;
README, `scripts/kontrol.py`, GitHub Actions kontrol ve Pages yayın iş akışları eklendi;
yazı tipleri `assets/fonts/` altında; axe denetimi 5 temada temiz (kontrast düzeltildi);
"İçeriğe atla" bağlantısı ve simgeler/manifest eklendi.

Açık kalanlar:
1. **Başlık ve footer her sayfada kopya.** HTML kaynak kabul edilir; menü ya da altbilgi
   değişince tüm sayfaları (404 dahil) güncelle. `scripts/kontrol.py` kırık bağlantıyı yakalar.
2. **İngilizce adres:** `hreflang="en"` `#en` adresine gidiyor; ayrı `/en/` sayfaları yok.
   Yapılacaksa önce yöntemi sor (elle kopya mı, derleme adımı mı).

## LİSANS VE ÖRNEK BAĞLANTILAR

- Lisans: **GPL-3.0-or-later** (footer, SSS, `kullanim-sartlari.html`, JSON-LD `license`).
- GitHub (`github.com/fawlibs/faw-builder` + issues/discussions), Matrix, Weblate,
  bağış (Sponsors, Open Collective, Ko-fi) ve `iletisim@fawlibs.org` **örnek** adreslerdir;
  her birinin önünde `<!-- ÖRNEK: … -->` var. Gerçekleri gelince değiştir, uydurma.

## AÇIK YER TUTUCULAR (`TODO` araması)

- Galeri görselleri: `assets/shots/{editor.webp, android.webm, designer.webm, debugger.webp, git.webp}`
- İndirme dosyaları `https://fawlibs.org/download/…` ve Flathub sayfası: şimdilik örnek
- Performans ölçümü (yöntem sayfada yazılı: hyperfine, 10 tekrar ortancası, 60 sn sonra VmRSS)
- Veri sorumlusu/yayıncı adı ve adresi, e-posta sağlayıcısı ve saklama süresi, yurt dışı aktarım
  güvencesi (`gizlilik.html`, `kunye.html`; sayfada `(eklenecek)` yazar). Uydurma; kullanıcıya sor.
- Karşılaştırmada doğrulanamayanlar: GNOME Builder LLDB, Cambalache placeholder, Workbench/Qt Designer sandbox
- `baslangic.html`'deki menü adları ("Yeni Proje penceresi", "SDK Kur") gerçek uygulamayla karşılaştırılmalı

## ÇALIŞMA DÖNGÜSÜ

1. Değişiklikten önce ilgili dosyayı oku; mevcut sınıfları ve tokenları kullan.
2. Yeni metin eklersen İngilizcesini aynı değişiklikte ekle. Kontrol:
   her `data-i18n` anahtarının `EN` ya da `FAW_PAGE_EN` içinde karşılığı olmalı.
3. `python3 scripts/kontrol.py` çalıştır, sonra `python3 -m http.server` ile sayfaları 1440px ve 390px'te aç:
   konsol hatası yok, yatay taşma yok, karşılaştırma tablosu yükleniyor,
   TR/EN ve 4 tema çalışıyor.
4. Test sayısını elle yazma: `bash scripts/test-durumu.sh <faw-builder dizini>` derleyip test eder ve
   ana sayfadaki ibareyi günceller.
5. Sürüm notu eklersen `surumler.html` ve `feed.xml`'i birlikte güncelle.
6. Commit'lerde Conventional Commits kullan. Commit'i yalnız ben istediğimde yap.

## BAŞLAMADAN SOR

1. Örnek GitHub, Matrix, bağış ve e-posta adreslerinin gerçekleri neler?
2. Gerçek bir sürüm yayımlandı mı? Dosya adları ve sürüm numarası ne?
3. Ekran görüntüleri/GIF'ler hazır mı?
