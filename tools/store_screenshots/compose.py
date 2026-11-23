#!/usr/bin/env python3
"""Impagina le immagini dello store (tutto in inglese) a partire dalle schermate grezze.

Prima:  flutter test tools/store_screenshots/shots_test.dart --update-goldens   (scrive /tmp/shots)
Poi:    python3 tools/store_screenshots/compose.py
Scrive in store/: iphone-6.9/*.png (1320x2868), iphone-6.3/*.png (1206x2622), header-3840x1646.png, search-results-3840x2560.png
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..')
SHOTS = '/tmp/shots'
OUT = os.path.join(ROOT, 'store')
FD = '/usr/share/fonts/opentype/inter/'
bold = lambda s: ImageFont.truetype(FD + 'InterDisplay-Bold.otf', s)
semi = lambda s: ImageFont.truetype(FD + 'Inter-SemiBold.otf', s)
reg = lambda s: ImageFont.truetype(FD + 'Inter-Medium.otf', s)

W, H = 1320, 2868

# (file raw, titolo in inglese, colore alto, colore basso, barra di stato: 'light' = scritte bianche)
SLIDES = [
    ('02_home_ready', 'Plan your bus between\nReus and Tarragona', '#0F8A70', '#07463A', 'light'),
    ('03_results', 'Every departure,\nat a glance', '#1565C0', '#0A2E63', 'dark'),
    ('04_trip', 'See every stop\non the way', '#0F8A70', '#07463A', 'dark'),
    ('05_night_picker', 'Night buses to\nyour favourite clubs', '#4527A0', '#1A0F44', 'dark'),
    ('07_arcade', 'Beat the wait with\n22 mini games', '#E91E63', '#6A0F36', 'dark'),
    ('08_briscola', 'Play Briscola\nagainst your phone', '#C62828', '#5A0E0E', 'dark'),
    ('10_race_night', 'Race the minibus\nday or night', '#4527A0', '#1A0F44', 'dark'),
    ('11_home_dark', 'Pick your colours,\nlight or dark', '#7E57C2', '#2A1B5B', 'light'),
]


def hexc(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def vgrad(w, h, top, bottom):
    t, b = hexc(top), hexc(bottom)
    col = Image.new('RGB', (1, h))
    for y in range(h):
        k = y / (h - 1)
        col.putpixel((0, y), tuple(int(t[i] + (b[i] - t[i]) * k) for i in range(3)))
    return col.resize((w, h))


def fix_blocks(img):
    """Nei test il testo dei pulsanti pieni esce come blocchi bianchi (font mancante): li sostituisce
    con le parole vere ("Go", "New game"). Serve scipy (pip install scipy)."""
    import numpy as np
    from scipy import ndimage
    a = np.asarray(img.convert('RGB')).astype(int)
    white = (a[:, :, 0] >= 250) & (a[:, :, 1] >= 250) & (a[:, :, 2] >= 250)
    lab, _ = ndimage.label(white)
    boxes = []
    for i, sl in enumerate(ndimage.find_objects(lab)):
        h, w = sl[0].stop - sl[0].start, sl[1].stop - sl[1].start
        if 40 <= h <= 60 and 60 <= w <= 230 and (lab[sl] == i + 1).sum() / (h * w) > 0.97:
            y, x = sl[0].start, sl[1].start
            if not white[y + h // 2, max(0, x - 10)] and not white[max(0, y - 12), x]:  # dentro a un pulsante colorato
                boxes.append([y, x, y + h, x + w])
    boxes.sort()
    groups = []
    for b in boxes:
        if groups and abs(groups[-1][0] - b[0]) <= 4 and b[1] - groups[-1][3] < 80:
            groups[-1][3] = b[3]
        else:
            groups.append(b[:])
    d = ImageDraw.Draw(img)
    for y0, x0, y1, x1 in groups:
        bg = tuple(int(v) for v in a[y0 - 12, x0])
        d.rectangle((x0 - 6, y0 - 8, x1 + 6, y1 + 8), fill=bg)
        word = 'Go' if (x1 - x0) < 140 else 'New game'
        d.text(((x0 + x1) / 2, (y0 + y1) / 2 + 2), word, font=semi(54 if word == 'Go' else 50), fill=(255, 255, 255), anchor='mm')
    return img


def status_bar(img, light):
    """Ora, isola dinamica, segnale, wifi e batteria disegnati sulla schermata grezza."""
    d = ImageDraw.Draw(img)
    ink = (255, 255, 255) if light else (20, 20, 20)
    d.rounded_rectangle((475, 36, 845, 147), 56, fill=(0, 0, 0))  # isola dinamica
    f = ImageFont.truetype(FD + 'Inter-Bold.otf', 54)
    d.text((140, 92), '9:41', font=f, fill=ink, anchor='lm')
    for i in range(4):  # segnale
        h = 18 + i * 10
        d.rounded_rectangle((1000 + i * 22, 112 - h, 1013 + i * 22, 112), 4, fill=ink)
    cx, cy = 1135, 112  # wifi
    for r in (38, 26, 14):
        d.arc((cx - r, cy - r, cx + r, cy + r), 225, 315, fill=ink, width=8)
    d.ellipse((cx - 6, cy - 12, cx + 6, cy), fill=ink)
    d.rounded_rectangle((1185, 70, 1275, 112), 12, outline=ink, width=4)  # batteria
    d.rounded_rectangle((1192, 77, 1262, 105), 6, fill=ink)
    d.rounded_rectangle((1279, 82, 1285, 100), 3, fill=ink)
    return img


def rounded(img, r):
    m = Image.new('L', img.size, 0)
    ImageDraw.Draw(m).rounded_rectangle((0, 0, img.size[0], img.size[1]), r, fill=255)
    out = img.convert('RGBA')
    out.putalpha(m)
    return out


def slide(raw, title, top, bottom, bar, n):
    bg = vgrad(W, H, top, bottom).convert('RGBA')
    d = ImageDraw.Draw(bg)
    # titolo
    lines = title.split('\n')
    f = bold(118)
    y = 96
    for ln in lines:
        d.text((W / 2, y), ln, font=f, fill=(255, 255, 255), anchor='ma')
        y += 140
    # telefono
    shot = Image.open(os.path.join(SHOTS, raw + '.png')).convert('RGB')
    fix_blocks(shot)
    status_bar(shot, bar == 'light')
    pw = 1000
    ph = int(pw * H / W)
    shot = rounded(shot.resize((pw, ph), Image.LANCZOS), 96)
    bez = 18
    frame = Image.new('RGBA', (pw + 2 * bez, ph + 2 * bez), (0, 0, 0, 0))
    ImageDraw.Draw(frame).rounded_rectangle((0, 0, frame.size[0], frame.size[1]), 96 + bez, fill=(14, 14, 16, 255))
    frame.alpha_composite(shot, (bez, bez))
    x, y0 = (W - frame.size[0]) // 2, 470
    sh = Image.new('RGBA', bg.size, (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle((x, y0 + 30, x + frame.size[0], y0 + 30 + frame.size[1]), 110, fill=(0, 0, 0, 120))
    bg.alpha_composite(sh.filter(ImageFilter.GaussianBlur(36)))
    bg.alpha_composite(frame, (x, y0))
    return bg.convert('RGB')  # niente canale alfa: Apple non lo accetta


def tile_icon(size):
    ic = Image.open(os.path.join(ROOT, 'ios_config', 'AppIcon-1024.png')).convert('RGB').resize((size, size), Image.LANCZOS)
    return rounded(ic, int(size * 0.22))


def backdrop(w, h):
    """Sfondo verde con strada in prospettiva (decorazione, può uscire dall'area sicura)."""
    bg = vgrad(w, h, '#0C6B58', '#052F27').convert('RGBA')
    ov = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    hy = int(h * 0.62)
    d.polygon([(w * 0.46, hy), (w * 0.54, hy), (w * 0.86, h), (w * 0.14, h)], fill=(255, 255, 255, 22))
    for k in range(8):
        t0, t1 = k / 8, (k + 0.45) / 8
        y0, y1 = hy + (h - hy) * t0 ** 1.6, hy + (h - hy) * t1 ** 1.6
        wd0, wd1 = 4 + 40 * t0 ** 1.6, 4 + 40 * t1 ** 1.6
        d.polygon([(w / 2 - wd0, y0), (w / 2 + wd0, y0), (w / 2 + wd1, y1), (w / 2 - wd1, y1)], fill=(255, 255, 255, 60))
    d.ellipse((w * 0.80, h * 0.06, w * 0.80 + h * 0.34, h * 0.06 + h * 0.34), fill=(255, 193, 7, 36))
    bg.alpha_composite(ov)
    return bg


def banner(w, h, safe, tile):
    """safe = (x, y, larghezza, altezza) dell'area sicura: tutto il contenuto resta lì dentro."""
    bg = backdrop(w, h)
    d = ImageDraw.Draw(bg)
    sx, sy, sw, sh = safe
    gap = int(tile * 0.12)
    avail = sw - tile - gap
    big = int(tile * 0.36)
    while d.textlength('Tarragona', font=bold(big)) > avail * 0.92:
        big -= 4
    l1, l2 = 'Bus times for Reus, Tarragona & Salou', 'Night buses and mini games'
    sub_size = int(big * 0.30)
    while max(d.textlength(l1, font=reg(sub_size)), d.textlength(l2, font=reg(sub_size))) > avail:
        sub_size -= 2
    text_w = max(d.textlength('Tarragona', font=bold(big)), d.textlength(l1, font=reg(sub_size)))
    lh, slh = int(big * 1.04), int(sub_size * 1.4)
    block_h = 2 * lh + int(big * 0.12) + 2 * slh
    group_w, group_h = tile + gap + int(text_w), max(tile, block_h)
    gx, gy = sx + (sw - group_w) // 2, sy + (sh - group_h) // 2
    bg.alpha_composite(tile_icon(tile), (gx, gy + (group_h - tile) // 2))
    tx, y = gx + tile + gap, gy + (group_h - block_h) // 2
    d.text((tx, y), 'ErasBus', font=bold(big), fill=(255, 255, 255))
    d.text((tx, y + lh), 'Tarragona', font=bold(big), fill=(255, 202, 40))
    y += 2 * lh + int(big * 0.12)
    d.text((tx, y), l1, font=reg(sub_size), fill=(255, 255, 255))
    d.text((tx, y + slh), l2, font=reg(sub_size), fill=(255, 255, 255, 215))
    return bg.convert('RGB')


def main():
    os.makedirs(os.path.join(OUT, 'iphone-6.9'), exist_ok=True)
    for i, (raw, title, top, bottom, bar) in enumerate(SLIDES, 1):
        img = slide(raw, title, top, bottom, bar, i)
        p = os.path.join(OUT, 'iphone-6.9', f'{i:02d}_{raw.split("_", 1)[1]}.png')
        img.save(p, optimize=True)
        print(p, img.size)
        # display medio (iPhone da 6,3"): App Store Connect lo chiede nella sua scheda, 1206x2622
        os.makedirs(os.path.join(OUT, 'iphone-6.3'), exist_ok=True)
        img.resize((1206, 2622), Image.LANCZOS).save(os.path.join(OUT, 'iphone-6.3', os.path.basename(p)), optimize=True)
    # intestazione 21:9, area sicura 1646x661 (x 1097, y 493)
    hdr = banner(3840, 1646, (1097, 493, 1646, 661), 520)
    hdr.save(os.path.join(OUT, 'header-3840x1646.png'), optimize=True)
    # risultati di ricerca 3:2, area sicura 2168x1030 (x 836, y 765)
    srch = banner(3840, 2560, (836, 765, 2168, 1030), 760)
    srch.save(os.path.join(OUT, 'search-results-3840x2560.png'), optimize=True)
    print('ok')


if __name__ == '__main__':
    main()
