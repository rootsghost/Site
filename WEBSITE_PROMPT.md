# Prompt — Faw Builder Tanıtım Web Sitesi

> Bu prompt'u bir kodlama ajanına (Claude Code vb.) olduğu gibi ver. Proje
> dokümanları (`IDE_AGENTS.md`, `ANDROID_AGENTS.md`, `ANDROID_PLAN.md`,
> `FEATURE_ROADMAP.md`, `UI_DESIGNER_PLAN.md`, `PACKAGING.md`) aynı
> oturumda bağlam olarak verilmeli.

---

## ROL

Sen deneyimli bir front-end geliştirici ve teknik ürün yazarısın.
**Faw Builder** (`org.fawlibs.builder`) adlı açık kaynak IDE için bir
tanıtım web sitesi yazacaksın. Ben karar veririm, sen uygularsın.
Belirsiz bir şey varsa **tahmin etme, sor**.

## ÜRÜN ÖZETİ (kaynak: ekli dokümanlar)

Faw Builder, **C11 + GTK4 + libadwaita + GtkSourceView 5** ile yazılmış,
KDevelop / GNOME Builder benzeri, Linux öncelikli bir masaüstü IDE.
C/GTK projelerine odaklıdır. Native **Android (Kotlin)** desteği vardır.
Yanında ayrı bir binary olarak **Faw Designer** gelir: bir GTK4 +
Android arayüz editörü.

Sitenin anlatacağı ana hikâye:
**"Tek, hafif, native bir GTK IDE'de C/GTK masaüstü uygulamaları ve
Android Kotlin uygulamaları geliştir, görsel olarak tasarla, paketle."**

## İÇERİK — BÖLÜMLER

Her bölümdeki iddia dokümanlarda geçen bir özelliğe dayanmalı. Doküman
dışı özellik uydurma.

1. **Hero**
   - Başlık, tek cümlelik değer önerisi, "İndir" ve "GitHub" butonları
   - Arka planda ürün ekran görüntüsü (şimdilik yer tutucu, bkz. açık sorular)

2. **Neden Faw Builder?**: 3–4 kart
   - Native GTK4/libadwaita: hızlı ve hafif, Electron değil
   - C/GTK odaklı: GIR tabanlı tamamlama, clangd LSP
   - Android Studio alternatifi hafif bir Kotlin iş akışı
   - Entegre görsel arayüz tasarımcısı (Faw Designer)

3. **Editör ve IDE özellikleri** (IDE_AGENTS özellik envanteri + ROADMAP §7/§8)
   - clangd LSP: tanıma git (F12), hover, outline, rename (F2), call hierarchy, symbol browser
   - Kotlin Language Server (opsiyonel)
   - Çoklu imleç, code folding, snippet'ler (GUI editörlü), Vim modu
   - Proje genelinde regex arama + replace-all, komut paleti (Ctrl+Shift+P)
   - Git durum/diff, patch review aracı
   - Build sistemleri: Meson / Make / CMake / Gradle / Flatpak. Çoklu run target, build-on-save, Sorunlar paneli
   - Debugger: GDB (MI) + LLDB, VTE terminal
   - Devhelp tarzı offline API dokümanları, Sysprof profiling, yazdırma/PDF
   - Plugin API (GModule `.so`), Custom Tools menüsü, session yönetimi

4. **Android geliştirme** (ANDROID_AGENTS özellik matrisi + ROADMAP §6)
   - XML View ve Compose proje şablonları, Gradle Wrapper, Maven Central kütüphane arama
   - SDK Kur / SDK Yönetimi (sdkmanager paketlerini kur/kaldır)
   - USB + kablosuz ADB, AVD/emülatör, Device Mirroring
   - Logcat (paket/etiket/seviye filtresi), Gradle sync → Sorunlar paneli
   - JDWP breakpoint debugger (`jdb`)
   - Profiler, Layout Inspector, Database Inspector, Network Inspector, Lint, Baseline Profile
   - Release imzalama sihirbazı, `.aab` bundle, APK analyzer
   - Burada bir **"Android Studio vs Faw Builder" karşılaştırma tablosu** olsun

5. **Faw Designer** (UI_DESIGNER_PLAN)
   - GIR'den otomatik üretilen palet (Gtk4 + Adwaita, arama kutulu)
   - Sürükle-bırak canvas: Box/Grid placeholder'ları, Fixed mutlak konum, snapping
   - Hiyerarşi paneli, özellik / packing / sinyal / a11y denetçisi, undo/redo
   - `.ui` + otomatik `.blp` (Blueprint) çıktısı, canlı önizleme penceresi
   - Çoklu ekran, template/composite widget, GMenu editörü, `Adw.Breakpoint`, CSS önizleme, hedef GTK sürümü deprecation uyarıları
   - Android XML görsel tasarımcı + Compose tasarımcı (dar MVP)
   - **Cambalache / Glade karşılaştırma tablosu**: UI_DESIGNER_PLAN'daki 19 maddelik tablodan türet

6. **İndir / Kurulum** (PACKAGING)
   - Sekmeler: `.deb`, AppImage, Flatpak (GNOME 46 runtime), Windows `.exe` (MinGW)
   - Her sekmede kısa komut bloğu ve kopyala butonu
   - Kaynaktan derleme: `meson setup build && meson compile -C build`

7. **Mimari** (geliştiriciler için)
   - Mermaid ya da inline SVG diyagram. ANDROID_PLAN ve UI_DESIGNER_PLAN'daki akış şemalarını temel al.
   - Modül listesi: `faw-lsp-client`, `faw-gradle-runner`, `faw-adb`, `faw-jdwp`, `faw-designer-*` …

8. **Yol haritası ve durum**
   - Tamamlanan fazlar ve bilinçli kapsam dışı maddeler (Play Console, Google Maven sürüm çözümleme, sandbox'lı render)

9. **Footer**: lisans, GitHub, dil seçici, iletişim

## DÜRÜSTLÜK KURALI (zorunlu)

Dokümanlarda şöyle notlar geçiyor: "elle doğrulanmadı", "kısmi",
"gerçek cihazla hiç denenmedi" (Network Inspector, QR eşleştirme, Flatpak
sandbox, Spellcheck: gspell GTK3-only olduğu için devre dışı). Bu
özellikleri:

- sitede "tam destek" diye **sunma**
- ya "Önizleme / Deneysel" rozetiyle göster ya da hiç gösterme. Hangisini seçeceğini sor.

Test sayısı, sınıf sayısı gibi rakamları dokümandan birebir al. Emin
değilsen rakam yazma.

## TEKNİK GEREKSİNİMLER

- **Stack (varsayılan, onayla):** Astro ya da saf HTML/CSS/JS ile statik site, GitHub Pages'e deploy edilir. Framework seçmeden önce sor.
- **İki dil:** Türkçe (varsayılan) + İngilizce. Metinler ayrı JSON/MD dosyalarında dursun, i18n anahtarlarıyla.
- **Tasarım dili:** GNOME / libadwaita estetiği: yuvarlak köşeler, Adwaita mavi vurgu rengi, Cantarell/Inter tipografi. Açık ve koyu tema (`prefers-color-scheme` + manuel geçiş).
- **Duyarlı:** 360px'ten 4K'ya kadar yatay scroll olmadan çalışmalı. Mobilde hamburger menü.
- **Erişilebilirlik:** WCAG 2.2 AA, semantik HTML, klavyeyle gezinme, `prefers-reduced-motion`'a saygı.
- **Performans:** Lighthouse'ta dört kategoride de 95+. Görseller WebP/AVIF ve lazy-load. JS minimum.
- **Etkileşim (ölçülü):** Özellik kartlarında hover efekti, kopyala butonları, karşılaştırma tablolarında filtre, scroll'da ince giriş animasyonları.
- **SEO:** meta/OG etiketleri, `sitemap.xml`, `hreflang` (tr/en), yapısal veri (`SoftwareApplication`).
- **Kod kalitesi:** lint + format (Prettier, ESLint/Stylelint). README'de nasıl çalıştırılacağı ve deploy edileceği yazsın.
- **CI:** GitHub Actions ile build + Pages'e deploy workflow'u.

## ÇALIŞMA DÖNGÜSÜ

1. Önce site haritasını ve bölüm başlıklarını öner, onay bekle.
2. Onaydan sonra iskelet → içerik → stil → etkileşim sırasıyla ilerle.
3. Her adımdan sonra build al, Lighthouse/axe ile kontrol et, sonucu raporla.
4. Build geçmeden "bitti" deme.
5. Commit'lerde Conventional Commits kullan. Commit'i yalnız ben istediğimde yap.

## AÇIK SORULAR (başlamadan bana sor)

1. Lisans nedir (GPL-3.0? MIT?)
2. GitHub deposunun URL'si ve indirme (release) linkleri nedir?
3. Ekran görüntüleri / demo GIF'leri var mı, yoksa yer tutucu mu kullanılsın?
4. Logo var mı? (`data/icons/.../org.fawlibs.builder.svg` kullanılabilir mi?)
5. Alan adı (custom domain) olacak mı?
6. Deneysel özellikler rozetle mi gösterilsin, gizlensin mi?
7. Stack: Astro mu, saf HTML mi?
