#!/usr/bin/env python3
"""Genera i PNG (primo piano) delle icone launcher dei temi GTA 6 (scuro/chiaro).

Parte da ic_launcher_bus.png di ogni densità (bus rosso), ricolora corpo e finestrini
e aggiunge sole a strisce, palma e stelle. Uso: python3 tools/gen_theme_icons.py
Poi servono: alias nel manifest, mipmap-anydpi-v26/ic_launcher_<nome>.xml, colore
ic_bg_<nome> e la riga in MainActivity.iconAliases (vedi altri temi).
"""
import math, os
from PIL import Image, ImageDraw

RES = os.path.join(os.path.dirname(__file__), '..', 'android/app/src/main/res')
DENS = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']

THEMES = {
    # nome: (corpo chiaro, corpo scuro, finestrini, stelle/palma, sole alto, sole basso)
    'gta6': dict(body=(255, 46, 147), win=(45, 226, 230), star=(255, 213, 79),
                 palm=(45, 226, 230), sun=((255, 154, 60), (255, 46, 147)), stars=True),
    'gta6light': dict(body=(0, 166, 166), win=(255, 244, 214), star=(255, 255, 255),
                      palm=(230, 25, 122), sun=((255, 170, 70), (230, 25, 122)), stars=False),
}

def recolor(base, t):
    im = base.convert('RGBA')
    px = im.load()
    br, bg_, bb = t['body']
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            if r > 100 and g < 90 and b < 90:          # rosso: corpo (192,32,26) / ombra (139,21,18)
                k = r / 192.0
                px[x, y] = (min(255, int(br * k)), min(255, int(bg_ * k)), min(255, int(bb * k)), a)
            elif r > 220 and g > 180 and b < 120:      # giallo: finestrini e fari
                px[x, y] = (*t['win'], a)
    return im

def decorate(im, t):
    S = 4
    w = im.width
    big = Image.new('RGBA', (w * S, w * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(big)
    # sole a strisce dietro il tetto (zona sicura: centro 66%)
    cx, cy, r = int(w * .70 * S), int(w * .24 * S), int(w * .10 * S)
    sun = Image.new('RGBA', big.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(sun)
    for i in range(r * 2):
        k = i / (r * 2)
        c = tuple(int(t['sun'][0][j] + (t['sun'][1][j] - t['sun'][0][j]) * k) for j in range(3))
        sd.line([(cx - r, cy - r + i), (cx + r, cy - r + i)], fill=(*c, 255))
    mask = Image.new('L', big.size, 0)
    ImageDraw.Draw(mask).ellipse([cx - r, cy - r, cx + r, cy + r], fill=255)
    md = ImageDraw.Draw(mask)
    for i in range(4):                                  # tagli orizzontali nella metà bassa
        y = cy + int(r * (.15 + i * .21))
        md.rectangle([cx - r, y, cx + r, y + int(S * (1.5 + i * .9))], fill=0)
    big.paste(sun, (0, 0), mask)
    # palma sopra il tetto, a sinistra
    px0, py0 = int(w * .27 * S), int(w * .34 * S)
    top = (int(w * .285 * S), int(w * .15 * S))
    d.line([(px0, py0), (int(w * .265 * S), int(w * .24 * S)), top],
           fill=(*t['palm'], 255), width=int(w * .014 * S), joint='curve')
    for ang in (-170, -135, -100, -60, -25, 10):
        rad = math.radians(ang)
        tip = (top[0] + math.cos(rad) * w * .085 * S, top[1] + math.sin(rad) * w * .05 * S + w * .035 * S)
        mid = (top[0] + math.cos(rad) * w * .05 * S, top[1] + math.sin(rad) * w * .05 * S - w * .02 * S)
        d.line([top, mid, tip], fill=(*t['palm'], 255), width=int(w * .011 * S), joint='curve')
    if t['stars']:
        for sx, sy, sr in [(.22, .20, .018), (.36, .13, .012), (.55, .17, .014), (.84, .45, .012)]:
            c = (int(sx * w * S), int(sy * w * S)); rr = int(sr * w * S)
            d.polygon([(c[0], c[1] - rr), (c[0] + rr * .3, c[1] - rr * .3), (c[0] + rr, c[1]),
                       (c[0] + rr * .3, c[1] + rr * .3), (c[0], c[1] + rr), (c[0] - rr * .3, c[1] + rr * .3),
                       (c[0] - rr, c[1]), (c[0] - rr * .3, c[1] - rr * .3)], fill=(*t['star'], 255))
    big = big.resize(im.size, Image.LANCZOS)
    out = Image.new('RGBA', im.size, (0, 0, 0, 0))
    out.alpha_composite(big)
    out.alpha_composite(im)   # il bus sopra le decorazioni
    return out

for name, t in THEMES.items():
    for dn in DENS:
        base = Image.open(f'{RES}/drawable-{dn}/ic_launcher_bus.png')
        decorate(recolor(base, t), t).save(f'{RES}/drawable-{dn}/ic_launcher_bus_{name}.png', optimize=True)
print('ok')
