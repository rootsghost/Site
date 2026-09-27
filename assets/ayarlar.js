/* Faw Builder sitesi — tüm sayfalar için ortak ayarlar.
 * Her sayfanın <head> bölümünde, CSS'ten hemen sonra ve sayfa çizilmeden önce çalışır.
 * Ayarlar tarayıcıda bir kez saklanır ve bütün sayfalar aynı değeri kullanır:
 *   faw-skin: ""(Varsayılan) | "ide" | "gradient" | "hacker"
 *   faw-mode: ""(Sistem)     | "light" | "dark"   (yalnız Varsayılan temayı etkiler)
 *   faw-lang: "tr" | "en"                          (adresin sonunda #en varsa İngilizce)
 * Açık başka bir sekmede bir ayar değişince bu sekme de hemen güncellenir. */
(function () {
  "use strict";
  var root = document.documentElement;
  var SECENEK = { "faw-skin": ["", "ide", "gradient", "hacker"], "faw-mode": ["", "light", "dark"], "faw-lang": ["tr", "en"] };
  var dilDinleyicileri = [];

  function oku(anahtar) {
    var v = "";
    try { v = localStorage.getItem(anahtar) || ""; } catch (e) { v = ""; }
    var gecerli = SECENEK[anahtar];
    return gecerli.indexOf(v) > -1 ? v : gecerli[0];
  }
  function yaz(anahtar, deger) {
    try { localStorage.setItem(anahtar, deger); } catch (e) { /* depolama kapalı: yalnız bu sayfa değişir */ }
  }
  function nitelik(ad, deger) {
    if (deger) root.setAttribute(ad, deger); else root.removeAttribute(ad);
  }

  /* ── Tema ve görünüm ── */
  function dugmeleriGuncelle() {
    var skin = root.getAttribute("data-skin") || "";
    var mode = root.getAttribute("data-mode") || "";
    var i, b, liste = document.querySelectorAll("[data-skin-sec]");
    for (i = 0; i < liste.length; i++) { b = liste[i]; b.setAttribute("aria-pressed", String(b.getAttribute("data-skin-sec") === skin)); }
    liste = document.querySelectorAll("[data-mode-sec]");
    for (i = 0; i < liste.length; i++) {
      b = liste[i];
      b.setAttribute("aria-pressed", String(b.getAttribute("data-mode-sec") === mode));
      b.disabled = skin !== "";   /* diğer temalar sabit koyu */
    }
  }
  function temaUygula() {
    nitelik("data-skin", oku("faw-skin"));
    nitelik("data-mode", oku("faw-mode"));
    dugmeleriGuncelle();
  }

  /* ── Dil ──
   * Çeviriler assets/site.js'te; o sayfanın sonunda yüklenir. İngilizce seçiliyse sayfa,
   * Türkçe metin bir an görünmesin diye çeviri uygulanana kadar gizli tutulur (en fazla 1,5 sn). */
  var dil = oku("faw-lang");
  if (location.hash === "#en") { dil = "en"; yaz("faw-lang", "en"); }
  root.lang = dil;
  if (dil === "en") {
    root.classList.add("dil-bekliyor");
    setTimeout(function () { root.classList.remove("dil-bekliyor"); }, 1500);
  }
  function dilBildir(l) {
    for (var i = 0; i < dilDinleyicileri.length; i++) dilDinleyicileri[i](l);
  }

  window.FawAyar = {
    dil: function () { return dil; },
    dilSec: function (l) {
      if (SECENEK["faw-lang"].indexOf(l) < 0) l = "tr";
      dil = l; yaz("faw-lang", l); dilBildir(l);
    },
    /* site.js çevirileri uygulayan fonksiyonu burada kaydeder */
    dilDinle: function (fn) { dilDinleyicileri.push(fn); },
    ceviriHazir: function () { root.classList.remove("dil-bekliyor"); },
    temaSec: function (s) { if (SECENEK["faw-skin"].indexOf(s) < 0) s = ""; yaz("faw-skin", s); nitelik("data-skin", s); dugmeleriGuncelle(); },
    modSec: function (m) { if (SECENEK["faw-mode"].indexOf(m) < 0) m = ""; yaz("faw-mode", m); nitelik("data-mode", m); dugmeleriGuncelle(); }
  };

  temaUygula();

  /* Başka sekmede değişen ayarı bu sekmeye uygula */
  window.addEventListener("storage", function (e) {
    if (e.key === "faw-skin" || e.key === "faw-mode" || e.key === null) temaUygula();
    if (e.key === "faw-lang" || e.key === null) {
      var yeni = oku("faw-lang");
      if (yeni !== dil) { dil = yeni; dilBildir(yeni); }
    }
  });

  /* Tema ve görünüm düğmeleri */
  document.addEventListener("click", function (e) {
    var b = e.target.closest ? e.target.closest("[data-skin-sec],[data-mode-sec]") : null;
    if (!b) return;
    if (b.hasAttribute("data-skin-sec")) window.FawAyar.temaSec(b.getAttribute("data-skin-sec"));
    else window.FawAyar.modSec(b.getAttribute("data-mode-sec"));
  });
  document.addEventListener("DOMContentLoaded", dugmeleriGuncelle);
})();
