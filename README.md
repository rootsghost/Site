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
| `baslangic.html` | İlk GTK ve Android uygulaması rehberi |
| `surumler.html`, `feed.xml` | Sürüm notları ve RSS |
| `gizlilik.html`, `kullanim-sartlari.html` | Yasal sayfalar (taslak) |
| `404.html` | Bulunamadı sayfası (yollar köke göre, `/assets/…`) |
| `sitemap.xml`, `robots.txt`, `og-image.png` | Arama motorları ve paylaşım görseli |
| `assets/ayarlar.js` | Tema, görünüm ve dil ayarı; her sayfanın `<head>`'inde yüklenir |
| `assets/site.js` | Etkileşimler ve İngilizce çeviriler (`EN`) |
| `assets/site.css` | Stiller: renk tokenları, 4 tema, bileşenler |
| `data/compare.json` | Karşılaştırma tablolarının verisi, kaynak ve kontrol tarihleriyle |
| `araclar/` | OpenCode / Claude Code kurulum betikleri ve yapay zekâ kılavuzu (siteden bağımsız) |

## Kurallar

- **Ayarlar tüm sayfalarda ortak.** Tema (`faw-skin`), görünüm (`faw-mode`) ve dil (`faw-lang`)
  `localStorage`'da saklanır; açık başka sekmeler de anında güncellenir.
- **Çeviri:** Türkçe metin HTML'de, `data-i18n="anahtar"` ile işaretli. İngilizcesi ortak
  anahtarlar için `assets/site.js` içindeki `EN` nesnesinde, sayfaya özel anahtarlar için o
  sayfanın sonundaki `window.FAW_PAGE_EN` içinde. Yeni metin eklerken ikisini birlikte ekle.
- **Başlık ve altbilgi her sayfada kopya.** Menüye ya da altbilgiye bağlantı eklerken tüm
  sayfaları (404 dahil) güncelle.
- **Doğrulanmamış bilgi yazılmaz.** Ölçülmemiş performans rakamı, denenmemiş özellik ya da
  kaynaksız rakip bilgisi eklenmez; emin olunmayan şey "doğrulanmadı" diye işaretlenir.
  Ayrıntılar: `WEBSITE_PROMPT.md`.

## Açık yer tutucular

`TODO` diye aratınca hepsi çıkar. Özetle:

- GitHub deposu, Issues, Discussions, Matrix ve çeviri platformu adresleri
- Bağış bağlantıları (GitHub Sponsors, Open Collective, Ko-fi)
- Lisans ve iletişim adresi; barındırma sağlayıcısı ve sunucu kaydı süresi (`gizlilik.html`)
- Galeri görselleri (`assets/shots/`) ve performans ölçümleri
- İndirme dosyaları (`https://fawlibs.org/download/…`) şimdilik örnek adres
