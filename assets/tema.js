/* Faw Builder sitesi — tema ayarı.
 * Tüm sayfalar temayı buradan alır. <head> içinde, CSS'ten hemen sonra ve
 * sayfa çizilmeden önce çalışır; böylece hiçbir sayfa önce yanlış temayla açılmaz.
 *   faw-skin: ""(Varsayılan) | "ide" | "gradient" | "hacker"
 *   faw-mode: ""(Sistem)     | "light" | "dark"   (yalnız Varsayılan temayı etkiler)
 * Açık başka bir sekmede tema değişince bu sekme de hemen güncellenir. */
(function () {
  "use strict";
  var root = document.documentElement;
  var SKINS = ["", "ide", "gradient", "hacker"];
  var MODES = ["", "light", "dark"];

  function oku(anahtar, gecerli) {
    var v = "";
    try { v = localStorage.getItem(anahtar) || ""; } catch (e) { v = ""; }
    return gecerli.indexOf(v) > -1 ? v : "";
  }
  function yaz(anahtar, deger) {
    try { localStorage.setItem(anahtar, deger); } catch (e) { /* depolama kapalı: yalnız bu sayfa değişir */ }
  }
  function nitelik(ad, deger) {
    if (deger) root.setAttribute(ad, deger); else root.removeAttribute(ad);
  }
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
  function uygula() {
    nitelik("data-skin", oku("faw-skin", SKINS));
    nitelik("data-mode", oku("faw-mode", MODES));
    dugmeleriGuncelle();
  }

  window.FawTema = {
    temaSec: function (s) { if (SKINS.indexOf(s) < 0) s = ""; yaz("faw-skin", s); nitelik("data-skin", s); dugmeleriGuncelle(); },
    modSec:  function (m) { if (MODES.indexOf(m) < 0) m = ""; yaz("faw-mode", m); nitelik("data-mode", m); dugmeleriGuncelle(); },
    guncelle: dugmeleriGuncelle
  };

  uygula();
  window.addEventListener("storage", function (e) {
    if (e.key === "faw-skin" || e.key === "faw-mode" || e.key === null) uygula();
  });
  document.addEventListener("click", function (e) {
    var b = e.target.closest ? e.target.closest("[data-skin-sec],[data-mode-sec]") : null;
    if (!b) return;
    if (b.hasAttribute("data-skin-sec")) window.FawTema.temaSec(b.getAttribute("data-skin-sec"));
    else window.FawTema.modSec(b.getAttribute("data-mode-sec"));
  });
  document.addEventListener("DOMContentLoaded", dugmeleriGuncelle);
})();
