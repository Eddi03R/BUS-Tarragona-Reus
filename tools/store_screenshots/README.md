# Immagini per la pagina dello store (iPhone, in inglese)

1. Font dei test: servono Roboto e MaterialIcons dell'SDK Flutter (`bin/cache/artifacts/material_fonts`,
   variabile `FONT_DIR`) e due copie di Roboto con il peso cambiato (600 e 800) in `/tmp/fonts_extra`
   (variabile `FONT_EXTRA_DIR`): con `pip install fonttools`, apri `Roboto-Bold.ttf` e `Roboto-Black.ttf`,
   imposta `font['OS/2'].usWeightClass` a 600 e 800 e salva come `Roboto-W600.ttf` / `Roboto-W800.ttf`.
2. `flutter test tools/store_screenshots/shots_test.dart --update-goldens` → schermate grezze in `/tmp/shots`
   (1320x2868, lingua inglese, 12 inquadrature).
3. `python3 tools/store_screenshots/compose.py` → `store/iphone-6.9/*.png` con titoli in inglese e cornice,
   più `store/header-3840x1646.png` e `store/search-results-3840x2560.png` (asset creativi).
