// Pubblicità del sito (Google AdSense): banner fisso in fondo alla pagina.
//
// Resta SPENTA finché non compili i due valori qui sotto (dopo l'approvazione
// AdSense). Il consenso GDPR/TCF lo gestisce il messaggio di Google
// (AdSense → Privacy e messaggi → Messaggi europei): senza consenso Google
// non mostra annunci personalizzati.
//
// Nota: l'app Flutter legge `window.erasbusAdsActive` per lasciare libero
// lo spazio del banner (50 px) in fondo allo schermo.
(function () {
  var CFG = {
    client: '', // ID editore, es. 'ca-pub-1234567890123456'
    slot: '',   // ID blocco annunci 320x50, es. '1234567890'
  };

  var BAR_HEIGHT = 50;
  var active = /^ca-pub-\d{10,}$/.test(CFG.client) && /^\d{6,}$/.test(CFG.slot);
  window.erasbusAdsActive = active;
  window.erasbusAdsHeight = BAR_HEIGHT;
  if (!active) return;

  var style = document.createElement('style');
  style.textContent =
    '#ad-bar{position:fixed;left:0;right:0;bottom:0;height:' + BAR_HEIGHT + 'px;' +
    'z-index:10;display:flex;align-items:center;justify-content:center;' +
    'overflow:hidden;background:#f4f4f4}' +
    '@media (prefers-color-scheme:dark){#ad-bar{background:#1c1c1c}}';
  document.head.appendChild(style);

  var lib = document.createElement('script');
  lib.async = true;
  lib.crossOrigin = 'anonymous';
  lib.src = 'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=' +
    encodeURIComponent(CFG.client);
  document.head.appendChild(lib);

  function mount() {
    var bar = document.createElement('div');
    bar.id = 'ad-bar';
    var ins = document.createElement('ins');
    ins.className = 'adsbygoogle';
    ins.style.cssText = 'display:inline-block;width:320px;height:' + BAR_HEIGHT + 'px';
    ins.setAttribute('data-ad-client', CFG.client);
    ins.setAttribute('data-ad-slot', CFG.slot);
    bar.appendChild(ins);
    document.body.appendChild(bar);
    try {
      (window.adsbygoogle = window.adsbygoogle || []).push({});
    } catch (e) {}
  }
  if (document.body) mount();
  else document.addEventListener('DOMContentLoaded', mount);
})();
