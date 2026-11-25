#!/usr/bin/env python3
"""Genera da zero i suoni dei giochi (assets/sounds/*.wav).

Tutti i suoni sono sintetizzati qui (onde + rumore + inviluppi): nessuna
registrazione di terzi, quindi nessun problema di diritti.
Uso:  python3 tools/gen_sounds.py
"""
import os
import wave

import numpy as np

SR = 22050
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'sounds')
rng = np.random.default_rng(7)


def t_of(dur):
    return np.arange(int(SR * dur)) / SR


def osc(freq, dur, kind='sine'):
    """freq: numero oppure array (glissando). Restituisce l'onda."""
    t = t_of(dur)
    f = np.full_like(t, freq) if np.isscalar(freq) else np.asarray(freq, dtype=float)
    phase = 2 * np.pi * np.cumsum(f) / SR
    if kind == 'sine':
        return np.sin(phase)
    if kind == 'tri':
        return 2 / np.pi * np.arcsin(np.sin(phase))
    if kind == 'square':
        return np.sign(np.sin(phase))
    if kind == 'saw':
        return 2 * ((phase / (2 * np.pi)) % 1) - 1
    raise ValueError(kind)


def glide(f0, f1, dur, curve=1.0):
    x = np.linspace(0, 1, int(SR * dur)) ** curve
    return f0 + (f1 - f0) * x


def env(n, attack=0.004, decay=0.1, sustain=0.0, release=0.0, length=None):
    """Inviluppo: attacco lineare, decadimento esponenziale verso 'sustain'."""
    t = np.arange(n) / SR
    a = np.minimum(t / max(attack, 1e-4), 1.0)
    d = sustain + (1 - sustain) * np.exp(-t / max(decay, 1e-4))
    e = a * d
    if release > 0:
        r = np.minimum((n / SR - t) / release, 1.0)
        e = e * np.clip(r, 0, 1)
    return e


def lowpass(x, cutoff):
    """Passa-basso a un polo; cutoff può essere un array (filtro che si muove)."""
    c = np.full(len(x), cutoff, dtype=float) if np.isscalar(cutoff) else np.asarray(cutoff, dtype=float)
    a = 1 - np.exp(-2 * np.pi * c / SR)
    y = np.empty_like(x)
    acc = 0.0
    for i in range(len(x)):
        acc += a[i] * (x[i] - acc)
        y[i] = acc
    return y


def highpass(x, cutoff):
    return x - lowpass(x, cutoff)


def noise(dur):
    return rng.uniform(-1, 1, int(SR * dur))


def mix(*parts):
    n = max(len(p[0]) + p[1] for p in parts)
    out = np.zeros(n)
    for sig, start in parts:
        out[start:start + len(sig)] += sig
    return out


def at(sec):
    return int(sec * SR)


def note(freq, dur, kind='sine', decay=None, attack=0.006, release=0.03, vib=0.0, vib_rate=5.5):
    t = t_of(dur)
    f = np.full_like(t, freq) if np.isscalar(freq) else np.asarray(freq, dtype=float)
    if vib:
        f = f * (1 + vib * np.sin(2 * np.pi * vib_rate * t))
    w = osc(f, dur, kind)
    return w * env(len(w), attack=attack, decay=decay or dur, sustain=0.0, release=release)


def fade(x, ms=6):
    n = min(int(SR * ms / 1000), len(x) // 2)
    x = x.copy()
    x[:n] *= np.linspace(0, 1, n)
    x[-n:] *= np.linspace(1, 0, n)
    return x


def save(name, x, peak=0.85):
    x = fade(x - np.mean(x))
    m = np.max(np.abs(x))
    x = x / m * peak if m > 0 else x
    pcm = (x * 32767).astype(np.int16)
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, name + '.wav')
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    print(f'{name:10s} {len(x) / SR:5.2f}s  {os.path.getsize(path) / 1024:5.1f} KB')


# Frequenze (Hz)
C4, D4, E4, F4, G4, A4, B4 = 261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88
C5, D5, E5, F5, G5, A5, B5 = 523.25, 587.33, 659.25, 698.46, 783.99, 880.00, 987.77
C6, E6, G6, A6, B6, C7 = 1046.5, 1318.5, 1568.0, 1760.0, 1975.5, 2093.0


def bright(freq, dur, decay=None, attack=0.006, release=0.04):
    """Timbro 'tromba allegra': tri + un po' di ottava."""
    a = note(freq, dur, 'tri', decay, attack, release)
    b = note(freq * 2, dur, 'sine', decay, attack, release) * 0.35
    c = note(freq * 3, dur, 'sine', decay, attack, release) * 0.12
    return a + b + c


# ------------------------------------------------------------------ vittoria
def win():
    # Fanfara: do-mi-sol veloci, poi accordo di do maggiore tenuto.
    parts = []
    t = 0.0
    for f in (C5, E5, G5):
        parts.append((bright(f, 0.14, decay=0.5), at(t)))
        t += 0.12
    t += 0.04
    for f in (C5, E5, G5, C6):
        parts.append((bright(f, 0.85, decay=0.9, release=0.25) * (0.9 if f < C6 else 1.0), at(t)))
    # piccola scintilla finale
    for i, f in enumerate((C7, G6, C7)):
        parts.append((note(f, 0.18, 'sine', 0.1) * 0.25, at(t + 0.1 + 0.07 * i)))
    return mix(*parts)


# ------------------------------------------------------------------ sconfitta
def lose():
    """Il 'trombone triste' (versione originale): quattro note che scendono,
    'wah wah wah waaah', con un filtro che si apre e si chiude su ogni nota."""
    seq = [(B4 * 0.5 * 1.0, 0.32), (A4 * 0.5, 0.32), (G4 * 0.5 * 0.944, 0.32), (G4 * 0.5 * 0.89, 1.05)]
    # Bb3, A3, Ab3, G3
    seq = [(233.08, 0.30), (220.00, 0.30), (207.65, 0.30), (196.00, 1.05)]
    parts = []
    t = 0.0
    for i, (f, d) in enumerate(seq):
        last = i == len(seq) - 1
        n = int(SR * d)
        x = np.linspace(0, 1, n)
        # l'ultima nota scivola verso il basso con vibrato
        freq = f * (1 - 0.06 * np.clip((x - 0.35) / 0.65, 0, 1) ** 1.5) if last else f * np.ones(n)
        if last:
            freq = freq * (1 + 0.012 * np.sin(2 * np.pi * 5.5 * np.arange(n) / SR) * np.clip(x * 2, 0, 1))
        w = osc(freq, d, 'saw') * 0.7 + osc(freq * 1.005, d, 'saw') * 0.3
        # 'wah': il filtro si apre (attacco) e si richiude
        wah = 350 + 1900 * np.sin(np.pi * np.clip(x * (1.0 if not last else 0.8), 0, 1)) ** 1.5
        w = lowpass(w, wah)
        e = env(n, attack=0.03, decay=d * 2.2, sustain=0.2, release=0.12 if not last else 0.45)
        parts.append((w * e, at(t)))
        t += d
    return mix(*parts)


def draw():
    # Pareggio: due note neutre, la seconda un po' più bassa.
    return mix((bright(G4, 0.22, 0.2), 0), (bright(E4, 0.40, 0.3, release=0.15), at(0.2)))


# -------------------------------------------------------------- interazione
def tap():
    return note(1500, 0.05, 'sine', 0.012, attack=0.001) + note(900, 0.05, 'sine', 0.015, attack=0.001) * 0.5


def step():
    return note(620, 0.035, 'sine', 0.01, attack=0.001) * 0.7


def place():
    # 'tok' di un pezzo di legno su legno
    body = note(glide(330, 210, 0.11), 0.11, 'sine', 0.035, attack=0.001) * 1.0
    over = note(glide(900, 600, 0.06), 0.06, 'sine', 0.02, attack=0.001) * 0.45
    click = highpass(noise(0.012), 1500) * env(at(0.012), 0.0008, 0.003) * 0.5
    return mix((body, 0), (over, 0), (click, 0))


def place2():
    body = note(glide(250, 160, 0.12), 0.12, 'sine', 0.04, attack=0.001)
    over = note(glide(640, 420, 0.06), 0.06, 'sine', 0.02, attack=0.001) * 0.45
    click = highpass(noise(0.012), 1200) * env(at(0.012), 0.0008, 0.003) * 0.45
    return mix((body, 0), (over, 0), (click, 0))


def capture():
    thump = note(glide(210, 90, 0.18), 0.18, 'sine', 0.06, attack=0.001) * 1.0
    clack = lowpass(noise(0.12), glide(5000, 900, 0.12)) * env(at(0.12), 0.0008, 0.03) * 0.9
    over = note(glide(1100, 700, 0.07), 0.07, 'sine', 0.02, attack=0.001) * 0.35
    return mix((thump, 0), (clack, 0), (over, 0))


def correct():
    return mix((bright(E5 * 1.0, 0.12, 0.08), 0), (bright(A5, 0.5, 0.18, release=0.18), at(0.09)))


def wrong():
    n = 0.3
    w = osc(glide(165, 120, n), n, 'saw') * 0.6 + osc(glide(170, 124, n), n, 'square') * 0.4
    w = lowpass(w, 900)
    return w * env(len(w), attack=0.005, decay=0.5, sustain=0.5, release=0.08)


def flip():
    n = 0.14
    x = lowpass(highpass(noise(n), 700), glide(1500, 5200, n)) * np.sin(np.linspace(0, np.pi, int(SR * n))) ** 1.3
    return x


def pop():
    n = 0.13
    a = note(glide(380, 900, n, 0.5), n, 'sine', 0.05, attack=0.002)
    b = note(glide(760, 1500, n, 0.5), n, 'sine', 0.03, attack=0.002) * 0.3
    return a + b


def clear():
    parts = []
    for i, f in enumerate((C6, E6, G6, C7)):
        parts.append((note(f, 0.30, 'sine', 0.12, attack=0.003), at(0.055 * i)))
        parts.append((note(f * 2, 0.2, 'sine', 0.06) * 0.15, at(0.055 * i)))
    return mix(*parts)


def splash():
    n = 0.5
    x = lowpass(noise(n), glide(5200, 500, n, 0.6)) * env(at(n), 0.01, 0.15, release=0.1)
    blip = note(glide(300, 700, 0.12, 0.7), 0.12, 'sine', 0.05) * 0.5
    blip2 = note(glide(250, 560, 0.1, 0.7), 0.1, 'sine', 0.04) * 0.35
    return mix((x * 0.9, 0), (blip, at(0.05)), (blip2, at(0.16)))


def explosion():
    n = 1.0
    boom = lowpass(noise(n), glide(2600, 160, n, 0.45)) * env(at(n), 0.002, 0.28, release=0.25)
    thump = note(glide(95, 38, 0.5, 0.5), 0.5, 'sine', 0.2, attack=0.002) * 1.2
    crack = highpass(noise(0.05), 1800) * env(at(0.05), 0.001, 0.015) * 0.6
    return mix((boom, 0), (thump, 0), (crack, 0))


def eat():
    return note(glide(520, 1050, 0.08, 0.6), 0.08, 'square', 0.04, attack=0.002) * 0.45 + \
        note(glide(520, 1050, 0.08, 0.6), 0.08, 'sine', 0.04, attack=0.002) * 0.4


def flap():
    n = 0.09
    return note(glide(330, 640, n, 0.6), n, 'sine', 0.04, attack=0.003) * 0.7


def ding():
    # moneta: due note brevi
    return mix((note(B5, 0.07, 'square', 0.05, attack=0.001) * 0.35 + note(B5, 0.07, 'sine', 0.05) * 0.5, 0),
               (note(E6, 0.28, 'square', 0.12, attack=0.001) * 0.3 + note(E6, 0.28, 'sine', 0.12) * 0.55, at(0.06)))


def thud():
    a = note(glide(130, 48, 0.22), 0.22, 'sine', 0.08, attack=0.001)
    b = lowpass(noise(0.08), 700) * env(at(0.08), 0.001, 0.02) * 0.6
    return mix((a, 0), (b, 0))


def flag():
    return mix((note(1000, 0.04, 'sine', 0.012, attack=0.001), 0), (note(1500, 0.06, 'sine', 0.02, attack=0.001), at(0.05)))


def pour():
    """Acqua che si versa: scroscio morbido + tante bollicine che salgono di tono."""
    dur = 0.95
    n = int(SR * dur)
    base = lowpass(noise(dur), glide(900, 1700, dur)) * 0.35
    out = base * np.sin(np.linspace(0, np.pi, n)) ** 0.6
    for _ in range(22):
        st = rng.uniform(0.02, 0.8)
        f0 = rng.uniform(320, 820)
        d = rng.uniform(0.05, 0.09)
        b = note(glide(f0, f0 * 1.9, d, 0.6), d, 'sine', 0.035, attack=0.002) * rng.uniform(0.25, 0.6)
        i = at(st)
        out[i:i + len(b)] += b[:max(0, n - i)]
    return out


def glass():
    """Tocco sul vetro (alzi la provetta)."""
    return mix((note(2300, 0.06, 'sine', 0.02, attack=0.001) * 0.6, 0), (note(3400, 0.04, 'sine', 0.012, attack=0.001) * 0.3, 0))


def tubedone():
    """Provetta completa: tre note di campanello che salgono."""
    return mix((bright(C6, 0.25, 0.1, release=0.1) * 0.8, 0), (bright(E6, 0.25, 0.1, release=0.1) * 0.8, at(0.08)),
               (bright(G6, 0.5, 0.2, release=0.2) * 0.8, at(0.16)))


def letter_ok():
    """Lettera giusta: 'plin' allegro."""
    return mix((bright(A5, 0.1, 0.06), 0), (bright(E6, 0.4, 0.16, release=0.15), at(0.07)))


def letter_no():
    """Lettera sbagliata: 'bzz' grave e colpo di legno."""
    n = 0.26
    w = lowpass(osc(glide(150, 105, n), n, 'saw') * 0.7 + osc(glide(75, 60, n), n, 'square') * 0.3, 700)
    w = w * env(len(w), attack=0.004, decay=0.1, sustain=0.2, release=0.07)
    k = lowpass(noise(0.07), 500) * env(at(0.07), 0.001, 0.02) * 0.9
    return mix((w, 0), (k, 0))



# ------------------------------------------------------------------ musica (loop)
NOTE_IDX = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11}


def hz(name):
    """'A4' -> 440 Hz; '#' per il diesis ('F#4')."""
    n = NOTE_IDX[name[0]] + (1 if '#' in name else 0)
    octave = int(name[-1])
    return 440.0 * 2 ** ((n + (octave - 4) * 12 - 9) / 12)


def loop_track(bpm, bars, layers):
    """layers: lista di (inizio_in_battute, segnale). Le code finali tornano
    all'inizio, così il loop non ha stacchi."""
    beat = 60.0 / bpm
    length = int(bars * 4 * beat * SR)
    out = np.zeros(length + SR * 2)
    for b, sig in layers:
        i = int(b * 4 * beat * SR)  # b è in battute (4 quarti)
        out[i:i + len(sig)] += sig[:len(out) - i]
    out[:SR * 2] += out[length:length + SR * 2]
    return out[:length]


def save_loop(name, x, peak=0.6):
    x = x - np.mean(x)
    x = x / np.max(np.abs(x)) * peak
    pcm = (x * 32767).astype(np.int16)
    path = os.path.join(OUT, name + '.wav')
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    print(f'{name:10s} {len(x) / SR:5.2f}s  {os.path.getsize(path) / 1024:5.1f} KB')


def kick(dur=0.22):
    f = glide(130, 42, dur, 0.4)
    return osc(f, dur, 'sine') * env(int(SR * dur), attack=0.002, decay=0.07)


def snare(dur=0.16):
    n = highpass(noise(dur), 1500) * env(int(SR * dur), attack=0.001, decay=0.05)
    t = note(190, dur, 'tri', 0.04, attack=0.001) * 0.5
    return n * 0.7 + t


def hat(dur=0.05, level=0.25):
    return highpass(noise(dur), 6000) * env(int(SR * dur), attack=0.001, decay=0.012) * level


def music_day():
    """Giorno: do maggiore, 140 bpm, allegra (Do-La-Fa-Sol). Composta da zero."""
    bpm, beat = 140, 60 / 140
    chords = [('C', ['C3', 'G3', 'C4', 'E4']), ('A', ['A2', 'E3', 'A3', 'C4']),
              ('F', ['F2', 'C3', 'F3', 'A3']), ('G', ['G2', 'D3', 'G3', 'B3'])]
    prog = [0, 1, 2, 3, 0, 1, 2, 3]
    layers = []
    for bar, ci in enumerate(prog):
        root, fifth, third_oct, third = chords[ci][1]
        # basso: ottavi radice-quinta
        for k in range(8):
            f = hz(root) if k % 2 == 0 else hz(fifth)
            layers.append((bar + k / 8, note(f, beat * 0.5, 'tri', beat * 0.45, release=0.02) * 0.9))
        # arpeggio in sedicesimi
        arp = [hz(root) * 4, hz(third_oct) * 2, hz(third) * 2, hz(third_oct) * 2]
        for k in range(16):
            layers.append((bar + k / 16, note(arp[k % 4], beat * 0.25, 'square', beat * 0.18, release=0.01) * 0.10))
        # batteria: cassa sul 1 e 3, rullante sul 2 e 4 (leggero), charleston sugli ottavi
        for k, d in enumerate([0, 1, 2, 3]):
            layers.append((bar + d / 4, kick() * 0.9 if k % 2 == 0 else snare() * 0.45))
        for k in range(8):
            layers.append((bar + k / 8, hat() * (1.0 if k % 2 else 0.6)))
    melody = [
        [(0, 'E5', .5), (.5, 'G5', .5), (1, 'C6', 1), (2, 'B5', .5), (2.5, 'G5', .5), (3, 'E5', 1)],
        [(0, 'C5', .5), (.5, 'E5', .5), (1, 'A5', 1), (2, 'G5', .5), (2.5, 'E5', .5), (3, 'C5', 1)],
        [(0, 'A5', .5), (.5, 'C6', .5), (1, 'A5', 1), (2, 'G5', .5), (2.5, 'F5', .5), (3, 'A5', 1)],
        [(0, 'B5', .5), (.5, 'D6', .5), (1, 'G5', 1), (2, 'F5', .5), (2.5, 'E5', .5), (3, 'D5', 1)],
        [(0, 'E5', .5), (.5, 'G5', .5), (1, 'C6', .5), (1.5, 'E6', .5), (2, 'D6', 1), (3, 'C6', 1)],
        [(0, 'A5', .5), (.5, 'C6', .5), (1, 'E6', 1), (2, 'D6', .5), (2.5, 'C6', .5), (3, 'B5', 1)],
        [(0, 'A5', .5), (.5, 'G5', .5), (1, 'F5', .5), (1.5, 'A5', .5), (2, 'C6', 1), (3, 'A5', 1)],
        [(0, 'D6', .5), (.5, 'B5', .5), (1, 'G5', .5), (1.5, 'B5', .5), (2, 'D6', 1), (3, 'G5', 1)],
    ]
    for bar, notes_ in enumerate(melody):
        for off, nm, dur in notes_:
            f = hz(nm)
            sig = note(f, dur * beat, 'square', dur * beat * 0.9, attack=0.004, release=0.03, vib=0.004) * 0.22
            sig += note(f * 2, dur * beat, 'sine', dur * beat * 0.5, release=0.02) * 0.05
            layers.append((bar + off / 4, sig))
    return loop_track(bpm, 8, layers)


def music_night():
    """Notte: la minore, 112 bpm, sintetizzatori morbidi (La-Fa-Do-Sol). Composta da zero."""
    bpm, beat = 112, 60 / 112
    chords = [('A2', ['A3', 'C4', 'E4']), ('F2', ['F3', 'A3', 'C4']),
              ('C3', ['C4', 'E4', 'G4']), ('G2', ['G3', 'B3', 'D4'])]
    prog = [0, 1, 2, 3, 0, 1, 2, 3]
    layers = []
    for bar, ci in enumerate(prog):
        root, pad = chords[ci]
        # basso saw filtrato, ottavi
        for k in range(8):
            w = note(hz(root), beat * 0.5, 'saw', beat * 0.4, release=0.02)
            layers.append((bar + k / 8, lowpass(w, 450) * 1.4))
        # pad lungo: tre note saw, filtro morbido
        dur = 4 * beat
        padsig = sum(note(hz(n_), dur, 'saw', dur, attack=0.25, release=0.3) for n_ in pad) / 3
        layers.append((bar, lowpass(padsig, 1100) * 0.45))
        # arpeggio a ottavi (tri), eco leggero
        for k in range(8):
            f = hz(pad[k % 3]) * 2
            a = note(f, beat * 0.4, 'tri', beat * 0.3, release=0.02) * 0.16
            layers.append((bar + k / 8, a))
        # batteria: cassa su ogni quarto, rullante sul 2 e 4, charleston sul levare
        for d in range(4):
            layers.append((bar + d / 4, kick() * 0.85))
            if d % 2 == 1:
                layers.append((bar + d / 4, snare() * 0.55))
            layers.append((bar + (d + 0.5) / 4, hat() * 0.8))
    melody = [
        [(0, 'E5', 1.5), (1.5, 'C5', .5), (2, 'D5', 1), (3, 'E5', 1)],
        [(0, 'F5', 1.5), (1.5, 'A5', .5), (2, 'G5', 1), (3, 'F5', 1)],
        [(0, 'G5', 1), (1, 'E5', 1), (2, 'C5', 1), (3, 'E5', 1)],
        [(0, 'D5', 1.5), (1.5, 'B4', .5), (2, 'D5', 2)],
        [(0, 'A5', 1), (1, 'G5', .5), (1.5, 'E5', .5), (2, 'C5', 1), (3, 'E5', 1)],
        [(0, 'A5', 1.5), (1.5, 'F5', .5), (2, 'A5', 1), (3, 'C6', 1)],
        [(0, 'E6', 1), (1, 'D6', 1), (2, 'C6', 1), (3, 'G5', 1)],
        [(0, 'B5', 1.5), (1.5, 'A5', .5), (2, 'G5', 2)],
    ]
    for bar, notes_ in enumerate(melody):
        for off, nm, dur in notes_:
            w = note(hz(nm), dur * beat, 'saw', dur * beat, attack=0.02, release=0.08, vib=0.006)
            layers.append((bar + off / 4, lowpass(w, 2200) * 0.25))
    return loop_track(bpm, 8, layers)


# nome -> (generatore, picco). Il picco regola i volumi relativi.
SOUNDS = {
    'win': (win, 0.90),
    'lose': (lose, 0.90),
    'draw': (draw, 0.80),
    'tap': (tap, 0.55),
    'step': (step, 0.40),
    'place': (place, 0.85),
    'place2': (place2, 0.85),
    'capture': (capture, 0.90),
    'correct': (correct, 0.80),
    'wrong': (wrong, 0.65),
    'flip': (flip, 0.50),
    'pop': (pop, 0.75),
    'clear': (clear, 0.80),
    'splash': (splash, 0.80),
    'explosion': (explosion, 0.95),
    'eat': (eat, 0.70),
    'flap': (flap, 0.55),
    'ding': (ding, 0.75),
    'thud': (thud, 0.90),
    'flag': (flag, 0.65),
    'pour': (pour, 0.80),
    'glass': (glass, 0.55),
    'tubedone': (tubedone, 0.80),
    'letter_ok': (letter_ok, 0.75),
    'letter_no': (letter_no, 0.75),
}

LOOPS = {'race_day': music_day, 'race_night': music_night}

if __name__ == '__main__':
    import sys
    only = sys.argv[1:]  # es.: python3 tools/gen_sounds.py race_day (rigenera solo quelli)
    for name, (fn, peak) in SOUNDS.items():
        if not only or name in only:
            save(name, fn(), peak)
    for name, fn in LOOPS.items():
        if not only or name in only:
            save_loop(name, fn())
