import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Altezza da lasciare libera per il banner AdSense del sito (0 = nessuno).
/// Il banner vive nella pagina HTML (`web/ads.js`), fuori dal canvas Flutter;
/// `ads.js` imposta `erasbusAdsActive` solo se AdSense è configurato.
double webAdsHeight() {
  try {
    final active = globalContext.getProperty<JSAny?>('erasbusAdsActive'.toJS);
    if (active == null || !(active as JSBoolean).toDart) return 0;
    final h = globalContext.getProperty<JSAny?>('erasbusAdsHeight'.toJS);
    return h == null ? 50 : (h as JSNumber).toDartDouble;
  } catch (_) {
    return 0;
  }
}
