# Faw Builder web sitesi

fawlibs.org için statik tanıtım sitesi. Derleme adımı yok: düz HTML, CSS ve JavaScript.

## Yerelde çalıştırma

```sh
python3 -m http.server 8000
```

Sonra tarayıcıda <http://localhost:8000/> aç. Karşılaştırma tabloları `data/compare.json`'dan
`fetch` ile yüklendiği için dosyayı doğrudan (`file://`) açmak yerine bir sunucu kullan.

## Yapı

| Dosya | İçerik |
|---|---|
| `index.html` | Ana sayfa |
| `android.html`, `designer.html`, `debugger.html` | Ürün alt sayfaları |
| `circuit.html`, `ses-asistani.html` | Ekosistem: Faw Circuit ve Faw Voice Assistant |
| `baslangic.html` | İlk GTK ve Android uygulaması rehberi |
| `surumler.html`, `feed.xml` | Sürüm notları ve RSS |
| `gizlilik.html`, `kullanim-sartlari.html` | Yasal sayfalar (taslak) |
| `404.html` | Bulunamadı sayfası (yollar köke göre, `/assets/…`) |
| `sitemap.xml`, `robots.txt`, `og-image.png` | Arama motorları ve paylaşım görseli |
| `assets/ayarlar.js` | Tema, görünüm ve dil ayarı; her sayfanın `<head>`'inde yüklenir |
| `assets/site.js` | Etkileşimler ve İngilizce çeviriler (`EN`) |
| `assets/site.css` | Stiller: yazı tipleri, renk tokenları, 4 tema, bileşenler |
| `assets/fonts/` | Bricolage Grotesque, Cantarell, JetBrains Mono (SIL OFL; lisanslar klasörde) |
| `assets/icons/`, `site.webmanifest` | Tarayıcı, iPhone ve Android simgeleri |
| `data/compare.json` | Karşılaştırma tablolarının verisi, kaynak ve kontrol tarihleriyle |
| `scripts/kontrol.py` | Statik kontroller: bağlantılar, çeviriler, JSON, sitemap, sürüm |
| `scripts/surum.sh` | Örnek sürüm numarasını tek komutla değiştirir |
| `.github/workflows/` | Her push'ta kontrol; varsayılan dalda GitHub Pages'e yayın |
| `araclar/` | OpenCode / Claude Code kurulum betikleri ve yapay zekâ kılavuzu (siteden bağımsız) |

## Kontrol ve yayın

```sh
python3 scripts/kontrol.py        # bağlantı, çeviri, JSON, sitemap kontrolü
bash scripts/surum.sh 0.2.0       # örnek sürüm numarasını değiştir
```

GitHub'da her push'ta `Kontrol` iş akışı çalışır. `Yayınla` iş akışı varsayılan dala gelen her
push'ta siteyi GitHub Pages'e yükler. Bir kez yapılacak ayarlar (depo sahibi yapar):

1. Settings → Pages → Source: **GitHub Actions**
2. Özel alan adı için Settings → Pages → Custom domain: `fawlibs.org`, ardından alan adının DNS'inde
   GitHub Pages kayıtları

## Kurallar

- **Ayarlar tüm sayfalarda ortak.** Tema (`faw-skin`), görünüm (`faw-mode`) ve dil (`faw-lang`)
  `localStorage`'da saklanır; açık başka sekmeler de anında güncellenir.
- **Çeviri:** Türkçe metin HTML'de, `data-i18n="anahtar"` ile işaretli. İngilizcesi ortak
  anahtarlar için `assets/site.js` içindeki `EN` nesnesinde, sayfaya özel anahtarlar için o
  sayfanın sonundaki `window.FAW_PAGE_EN` içinde. Yeni metin eklerken ikisini birlikte ekle.
- **Başlık ve altbilgi her sayfada kopya.** Menüye ya da altbilgiye bağlantı eklerken tüm
  sayfaları (404 dahil) güncelle.
- **Dış kaynak yok.** Yazı tipleri, simgeler ve betikler siteyle birlikte sunulur; gizlilik sayfası
  buna dayanıyor. Başka bir sunucudan kaynak eklersen `gizlilik.html`'i de güncelle.
- **Erişilebilirlik:** Renkler WCAG AA kontrastını karşılıyor (axe ile 5 temada denetlendi).
  Yeni renk eklerken normal metin için en az 4.5:1 kontrast tut.
- **Doğrulanmamış bilgi yazılmaz.** Ölçülmemiş performans rakamı, denenmemiş özellik ya da
  kaynaksız rakip bilgisi eklenmez; emin olunmayan şey "doğrulanmadı" diye işaretlenir.
  Ayrıntılar: `WEBSITE_PROMPT.md`.

## Lisans

Faw Builder GNU GPL sürüm 3 ya da daha sonraki bir sürümü (GPL-3.0-or-later) ile dağıtılır. Sitedeki lisans bağlantıları
<https://www.gnu.org/licenses/gpl-3.0.html> adresine, tam metin bağlantısı depodaki `COPYING` dosyasına gider.

## Örnek bağlantılar

Gerçek adresler belli olana kadar aşağıdaki **örnek** adresler kullanılıyor. Hepsinin önünde
`<!-- ÖRNEK: … -->` yorumu var; `ÖRNEK` diye aratıp gerçekleriyle değiştir.

| Ne | Örnek adres |
|---|---|
| Kaynak kodu | `https://github.com/fawlibs/faw-builder` |
| Sorun bildir / açık işler / test listesi | `…/issues/new/choose`, `…/issues?q=…good first issue`, `…/issues?q=…needs-testing` |
| Tartışma | `…/discussions` |
| Matrix | `https://matrix.to/#/#faw-builder:matrix.org` |
| Çeviri | `https://hosted.weblate.org/projects/faw-builder/` |
| Bağış | `https://github.com/sponsors/fawlibs`, `https://opencollective.com/fawlibs`, `https://ko-fi.com/fawlibs` |
| İletişim e-postası | `iletisim@fawlibs.org` |
| İndirme dosyaları | `https://fawlibs.org/download/…` ve Flathub sayfası |

## Açık yer tutucular

`TODO` diye aratınca çıkar:

- Galeri görselleri (`assets/shots/`) ve performans ölçümleri
- Barındırma sağlayıcısı ve sunucu kaydı süresi (`gizlilik.html`)
