#!/usr/bin/env python3
"""Sitenin statik kontrolleri. Ek paket gerekmez:  python3 scripts/kontrol.py

Kontrol edilenler:
  • yerel bağlantılar ve dosyalar (href/src) gerçekten var mı
  • boş bağlantı (href="#") kalmış mı
  • her data-i18n anahtarının İngilizcesi var mı (site.js EN ya da sayfanın FAW_PAGE_EN'i)
  • JSON-LD, FAW_PAGE_EN, data/compare.json ve site.webmanifest geçerli JSON mu
  • sitemap.xml'deki sayfalar var mı, 404 dışındaki her sayfa sitemap'te mi
  • sürüm numarası yalnız index.html'de mi (tek kaynak: <html data-surum>)
Sorun bulursa listeler ve 1 ile çıkar.
"""
import json, pathlib, re, sys
from html.parser import HTMLParser

KOK = pathlib.Path(__file__).resolve().parent.parent
hatalar = []

def hata(dosya, mesaj):
    hatalar.append(f"{dosya}: {mesaj}")

class Toplayici(HTMLParser):
    def __init__(self):
        super().__init__()
        self.baglantilar, self.anahtarlar, self.idler = [], set(), set()
    def handle_starttag(self, etiket, nitelikler):
        n = dict(nitelikler)
        for ad in ("href", "src"):
            if n.get(ad) is not None:
                self.baglantilar.append((etiket, ad, n[ad]))
        if "data-i18n" in n:
            self.anahtarlar.add(n["data-i18n"])
        if "data-i18n-attr" in n:
            self.anahtarlar.add(n["data-i18n-attr"].split(":", 1)[1])
        if "id" in n:
            self.idler.add(n["id"])

site_js = (KOK / "assets/site.js").read_text(encoding="utf-8")
en_blok = site_js[site_js.index("var EN"):]
EN = set(re.findall(r'"([\w.\-]+)"\s*:', en_blok))

sayfalar = sorted(KOK.glob("*.html"))
idler = {}
for sayfa in sayfalar:
    metin = sayfa.read_text(encoding="utf-8")
    t = Toplayici(); t.feed(metin)
    idler[sayfa.name] = t.idler

    for ld in re.findall(r'<script type="application/ld\+json">(.*?)</script>', metin, re.S):
        try: json.loads(ld)
        except ValueError as e: hata(sayfa.name, f"JSON-LD geçersiz: {e}")
    sayfa_en = set()
    m = re.search(r"window\.FAW_PAGE_EN = (\{.*?\});</script>", metin, re.S)
    if m:
        try: sayfa_en = set(json.loads(m.group(1)))
        except ValueError as e: hata(sayfa.name, f"FAW_PAGE_EN geçersiz: {e}")
    eksik = sorted(k for k in t.anahtarlar if k not in EN and k not in sayfa_en)
    if eksik:
        hata(sayfa.name, "İngilizcesi eksik anahtarlar: " + ", ".join(eksik))

    for etiket, ad, deger in t.baglantilar:
        if deger == "#":
            hata(sayfa.name, f"boş bağlantı <{etiket} {ad}=\"#\">")
            continue
        if re.match(r"^(https?:|mailto:|data:|tel:)", deger) or deger.startswith("#"):
            continue
        yol = deger.split("#")[0].split("?")[0]
        if not yol:
            continue
        hedef = KOK / yol.lstrip("/")
        if yol.endswith("/"):
            hedef = hedef / "index.html"
        if not hedef.exists():
            hata(sayfa.name, f"bulunamayan dosya: {deger}")

# Sayfalar arası çapalar (ör. index.html#kurulum)
for sayfa in sayfalar:
    metin = sayfa.read_text(encoding="utf-8")
    for dosya, capa in re.findall(r'href="/?([\w-]+\.html)#([\w-]+)"', metin):
        if dosya in idler and capa not in idler[dosya] and capa != "en":
            hata(sayfa.name, f"{dosya} içinde #{capa} yok")

for json_dosya in ("data/compare.json", "site.webmanifest"):
    try: json.loads((KOK / json_dosya).read_text(encoding="utf-8"))
    except (ValueError, OSError) as e: hata(json_dosya, f"geçersiz: {e}")

harita = (KOK / "sitemap.xml").read_text(encoding="utf-8")
listelenen = set()
for adres in re.findall(r"<loc>https://fawlibs\.org/([^<]*)</loc>", harita):
    ad = adres or "index.html"
    listelenen.add(ad)
    if not (KOK / ad).exists():
        hata("sitemap.xml", f"olmayan sayfa: {adres}")
for sayfa in sayfalar:
    if sayfa.name != "404.html" and sayfa.name not in listelenen:
        hata("sitemap.xml", f"eksik sayfa: {sayfa.name}")

m = re.search(r'<html[^>]*data-surum="([^"]+)"', (KOK / "index.html").read_text(encoding="utf-8"))
if not m:
    hata("index.html", "<html data-surum> yok")
elif m.group(1) in site_js:
    hata("assets/site.js", f"sürüm {m.group(1)} elle yazılmış; data-surum'dan okunmalı")

if hatalar:
    print(f"{len(hatalar)} sorun bulundu:")
    for h in hatalar: print("  •", h)
    sys.exit(1)
print(f"Tamam: {len(sayfalar)} sayfa, sorun yok.")
