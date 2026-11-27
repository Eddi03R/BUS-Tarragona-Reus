#!/usr/bin/env python3
"""Prepara le schermate Android per il video: sostituisce i blocchi dei testi dei pulsanti (font mancante nei test)
con le parole vere e converte in webp.
Prima:  flutter test tools/store_screenshots/android_shots_test.dart --update-goldens   (scrive /tmp/shots-android)
Poi:    python3 tools/brag-video-android/prepare_shots.py
Serve:  pip install pillow numpy scipy
"""
import glob, os, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy import ndimage

SRC = '/tmp/shots-android'
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'assets', 'shots')
FONT = os.environ.get('FONT_DIR', '/tmp/fl/flutter/bin/cache/artifacts/material_fonts') + '/Roboto-Bold.ttf'
# etichette dei pulsanti, dall'alto in basso, per ogni schermata (le altre non ne hanno)
LABELS = {
    '01_home_ready': ['Go'],
    '05_night_home': ['Go'],
    '10_theme_dark': ['Go'],
    '11_theme_halloween': ['Go'],
    '12_theme_christmas': ['Go'],
    '13_theme_gta6': ['Go'],
    '07_briscola': ['New game'],
    '08_race_night': ['New game'],
    '09_watersort': ['Restart', 'New game'],
}


def fix(img, labels):
    a = np.asarray(img.convert('RGB')).astype(int)
    found = []
    # blocchi uniformi alti ~ una riga di testo (16 dp * 2.625 = 42 px) con sfondo diverso intorno
    key = a[:, :, 0] * 65536 + a[:, :, 1] * 256 + a[:, :, 2]
    for color in np.unique(key[::3, ::3]):
        mask = key == color
        if mask.sum() < 800:
            continue
        lab, n = ndimage.label(mask)
        for i, sl in enumerate(ndimage.find_objects(lab)):
            h, w = sl[0].stop - sl[0].start, sl[1].stop - sl[1].start
            if 30 <= h <= 46 and 60 <= w <= 320 and (lab[sl] == i + 1).sum() / (h * w) > 0.98:
                y, x = sl[0].start, sl[1].start
                if y < 120 or x < 20:
                    continue
                around = a[max(0, y - 14), x + w // 2], a[min(a.shape[0] - 1, y + h + 14), x + w // 2]
                if tuple(around[0]) == tuple(a[y, x]) or tuple(around[0]) != tuple(around[1]):
                    continue
                found.append((y, x, h, w, tuple(int(v) for v in a[y, x]), tuple(int(v) for v in around[0])))
    # tiene solo i blocchi dei pulsanti (non cuori, tessere...): quelli larghi quanto un'etichetta a destra/sinistra dell'icona
    found.sort()
    merged = []
    for f in found:
        if merged and abs(merged[-1][0] - f[0]) <= 4 and f[1] - (merged[-1][1] + merged[-1][3]) < 60:
            m = merged[-1]
            merged[-1] = (m[0], m[1], max(m[2], f[2]), f[1] + f[3] - m[1], m[4], m[5])
        else:
            merged.append(f)
    return merged


def main():
    for f in sorted(glob.glob(SRC + '/*.png')):
        name = os.path.basename(f)[:-4]
        img = Image.open(f).convert('RGB')
        labels = LABELS.get(name, [])
        if labels:
            boxes = fix(img, labels)
            print(name, 'blocchi:', [(b[0], b[1], b[3]) for b in boxes], 'etichette:', labels)
            d = ImageDraw.Draw(img)
            for (y, x, h, w, fg, bg), word in zip(boxes, labels):
                d.rectangle((x - 4, y - 4, x + w + 4, y + h + 4), fill=bg)
                d.text((x + w / 2, y + h / 2), word, font=ImageFont.truetype(FONT, 42), fill=fg, anchor='mm')
        if name == '09_watersort':
            # "Undo move" è disattivato (grigio chiaro) e il rilevamento non lo trova: si ridisegna a mano
            px = np.asarray(img.convert('RGB'))
            fg, bg = tuple(int(v) for v in px[1982, 420]), tuple(int(v) for v in px[1982, 372])
            d = ImageDraw.Draw(img)
            d.rectangle((384, 1950, 780, 2014), fill=bg)
            d.text((582, 1982), 'Undo move', font=ImageFont.truetype(FONT, 42), fill=fg, anchor='mm')
        img.save(os.path.join(OUT, name + '.webp'), quality=92, method=6)


main()
