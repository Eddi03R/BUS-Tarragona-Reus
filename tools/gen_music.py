#!/usr/bin/env python3
"""Genera da zero le musiche di sottofondo dei giochi (assets/sounds/music_*.mp3).

Una canzoncina (loop di 8 battute) per gioco, ognuna con tempo, scala,
accordi, strumenti e ritmo diversi. Tutto è sintetizzato da onde: nessuna
registrazione di terzi, quindi nessun problema di diritti. La melodia è
generata da un seme fisso (stessa canzone a ogni rigenerazione).

Uso:  python3 tools/gen_music.py            # tutte
      python3 tools/gen_music.py chess snake  # solo alcune
Serve numpy e ffmpeg (con libmp3lame).
"""
import os
import subprocess
import sys
import tempfile
import wave

import numpy as np

import gen_sounds as g

SR = g.SR
OUT = g.OUT

SCALES = {
    'major': [0, 2, 4, 5, 7, 9, 11],
    'minor': [0, 2, 3, 5, 7, 8, 10],
    'dorian': [0, 2, 3, 5, 7, 9, 10],
    'mixo': [0, 2, 4, 5, 7, 9, 10],
}
PENTA = {'major': [0, 2, 4, 7, 9], 'minor': [0, 3, 5, 7, 10]}
ROOTS = {'C': 0, 'C#': 1, 'D': 2, 'Eb': 3, 'E': 4, 'F': 5, 'F#': 6, 'G': 7, 'Ab': 8, 'A': 9, 'Bb': 10, 'B': 11}


def midi_hz(m):
    return 440.0 * 2 ** ((m - 69) / 12)


# ------------------------------------------------------------------ strumenti
def _e(n, attack, decay, release=0.02):
    return g.env(n, attack=attack, decay=decay, sustain=0.0, release=release)


def pluck(f, d):
    w = g.osc(f, d, 'tri') + 0.35 * g.osc(2 * f, d, 'sine')
    return w * _e(len(w), 0.003, min(d, 0.35) * 0.8)


def marimba(f, d):
    d = min(d, 0.5)
    w = g.osc(f, d, 'sine') + 0.28 * g.osc(4 * f, d, 'sine') * np.exp(-np.arange(int(SR * d)) / SR / 0.04)
    return w * _e(len(w), 0.002, 0.16, 0.03)


def bell(f, d):
    d = max(d, 0.9)
    t = np.arange(int(SR * d)) / SR
    w = (np.sin(2 * np.pi * f * t) * np.exp(-t / 0.7)
         + 0.4 * np.sin(2 * np.pi * f * 2.76 * t) * np.exp(-t / 0.3)
         + 0.2 * np.sin(2 * np.pi * f * 5.4 * t) * np.exp(-t / 0.12))
    return w * np.minimum(t / 0.003, 1.0) * np.minimum((d - t) / 0.05, 1.0)


def epiano(f, d):
    d = max(d, 0.25)
    t = np.arange(int(SR * d)) / SR
    w = (np.sin(2 * np.pi * f * t) + 0.35 * np.sin(4 * np.pi * f * t) * np.exp(-t / 0.25)
         + 0.15 * np.sin(6 * np.pi * f * t) * np.exp(-t / 0.1))
    w *= 1 + 0.12 * np.sin(2 * np.pi * 5 * t)
    return w * np.exp(-t / 0.9) * np.minimum(t / 0.004, 1.0) * np.minimum((d - t) / 0.06, 1.0)


def pad(f, d):
    parts = [g.osc(f * k, d, 'tri') for k in (0.997, 1.0, 1.004)]
    w = sum(parts) / 3
    return w * g.env(len(w), attack=0.35, decay=1e6, sustain=1.0, release=0.4)


def bass(f, d):
    d = min(d, 0.6)
    w = g.osc(f, d, 'sine') + 0.4 * g.osc(2 * f, d, 'tri')
    return w * _e(len(w), 0.004, 0.3, 0.04)


def fatbass(f, d):
    d = min(d, 0.5)
    w = 0.6 * g.osc(f, d, 'saw') + g.osc(f, d, 'sine')
    return w * _e(len(w), 0.004, 0.22, 0.03) * 0.7


def pulse(f, d, duty=0.25):
    t = np.arange(int(SR * d))
    ph = (f * t / SR) % 1.0
    w = np.where(ph < duty, 1.0, -1.0) * 0.6
    return w * g.env(len(w), attack=0.003, decay=d * 0.9, sustain=0.2, release=0.03)


def brass(f, d):
    d = max(d, 0.12)
    t = np.arange(int(SR * d)) / SR
    w = sum(np.sin(2 * np.pi * f * k * t) / k for k in range(1, 7))
    return w * np.minimum(t / 0.03, 1.0) * np.minimum((d - t) / 0.05, 1.0) * np.exp(-t / 1.5)


def flute(f, d):
    t = np.arange(int(SR * d)) / SR
    vib = 1 + 0.006 * np.sin(2 * np.pi * 5.2 * t) * np.minimum(t / 0.3, 1.0)
    w = np.sin(2 * np.pi * f * t * vib) + 0.12 * np.sin(4 * np.pi * f * t * vib)
    return w * np.minimum(t / 0.05, 1.0) * np.minimum((d - t) / 0.06, 1.0)


def harpsi(f, d):
    d = min(d, 0.5)
    t = np.arange(int(SR * d)) / SR
    w = sum(np.sin(2 * np.pi * f * k * t) / k ** 0.8 for k in range(1, 8))
    return w * np.exp(-t / 0.18) * np.minimum(t / 0.001, 1.0) * np.minimum((d - t) / 0.02, 1.0)


def musicbox(f, d):
    d = 0.7
    t = np.arange(int(SR * d)) / SR
    w = np.sin(2 * np.pi * f * t) + 0.3 * np.sin(2 * np.pi * f * 3 * t) * np.exp(-t / 0.08)
    return w * np.exp(-t / 0.28) * np.minimum(t / 0.002, 1.0) * np.minimum((d - t) / 0.05, 1.0)


INSTR = dict(pluck=pluck, marimba=marimba, bell=bell, epiano=epiano, pad=pad, bass=bass, fatbass=fatbass,
             pulse=pulse, brass=brass, flute=flute, harpsi=harpsi, musicbox=musicbox)

_drums = {}


def drum(name):
    if name not in _drums:
        _drums[name] = dict(kick=g.kick, snare=g.snare, hat=g.hat)[name]()
    return _drums[name]


# ------------------------------------------------------------------ composizione
class Song:
    def __init__(self, spec):
        self.s = spec
        self.rng = np.random.default_rng(spec['seed'])
        beats, steps = spec.get('ts', (4, 16))
        self.beats, self.steps = beats, steps
        self.bar_s = beats * 60.0 / spec['bpm']
        self.step_s = self.bar_s / steps
        self.bars = spec.get('bars', 8)
        self.n = int(self.bars * self.bar_s * SR)
        self.buf = np.zeros(self.n + SR * 3)
        mode = spec['mode']
        self.root = ROOTS[spec['key']]
        self.scale = SCALES[mode]
        self.mel_scale = PENTA['major' if mode in ('major', 'mixo') else 'minor'] if spec.get('penta') else self.scale

    # nota MIDI dal grado (anche oltre l'ottava)
    def deg(self, d, octave=4, scale=None):
        sc = scale or self.scale
        o, i = divmod(d, len(sc))
        return 12 * (octave + 1) + self.root + sc[i] + 12 * o

    def chord(self, d, octave=3):
        return [self.deg(d + k, octave) for k in (0, 2, 4)]

    def put(self, sig, t):
        i = int(t * SR)
        end = min(i + len(sig), len(self.buf))
        self.buf[i:end] += sig[:end - i]

    def render(self):
        s = self.s
        prog = s['prog']
        assert len(prog) == self.bars
        self._comp(prog)
        self._bass(prog)
        self._melody(prog)
        self._drums()
        out = self.buf[:self.n].copy()
        out[:len(self.buf) - self.n] += self.buf[self.n:]  # le code tornano all'inizio: loop senza stacchi
        return out

    # accordi
    def _comp(self, prog):
        s = self.s
        kind, inst = s['comp'], INSTR[s['comp_inst']]
        vol = s.get('comp_vol', 0.28)
        for b, d in enumerate(prog):
            t0 = b * self.bar_s
            ch = self.chord(d, s.get('comp_oct', 3))
            if kind == 'pad':
                for m in ch:
                    self.put(inst(midi_hz(m), self.bar_s) * vol * 0.5, t0)
            elif kind == 'block':
                for beat in range(self.beats):
                    if beat % 2 == 0:
                        for m in ch:
                            self.put(inst(midi_hz(m), self.bar_s / self.beats * 1.8) * vol, t0 + beat * self.bar_s / self.beats)
            elif kind == 'offbeat':
                for beat in range(self.beats):
                    for m in ch:
                        self.put(inst(midi_hz(m), 0.2) * vol, t0 + (beat + 0.5) * self.bar_s / self.beats)
            elif kind == 'arp':
                pat = s.get('arp', [0, 1, 2, 1])
                every = s.get('arp_every', 2)  # una nota ogni N passi
                for k, st in enumerate(range(0, self.steps, every)):
                    m = ch[pat[k % len(pat)] % 3] + 12 * (pat[k % len(pat)] // 3)
                    self.put(inst(midi_hz(m), every * self.step_s * 1.6) * vol, t0 + st * self.step_s)
            elif kind == 'waltz':
                per = self.bar_s / self.beats
                for beat in range(self.beats):
                    for m in (ch[1:] if beat else ch[:1]):
                        self.put(inst(midi_hz(m), per * 0.9) * vol, t0 + beat * per)

    # basso
    def _bass(self, prog):
        s = self.s
        inst = INSTR[s.get('bass_inst', 'bass')]
        vol = s.get('bass_vol', 0.5)
        pat = s['bass']
        per = self.bar_s / self.beats
        for b, d in enumerate(prog):
            t0 = b * self.bar_s
            ch = self.chord(d, 2)
            root, fifth = ch[0], ch[2]
            if pat == 'root':
                for beat in range(0, self.beats, 2):
                    self.put(inst(midi_hz(root), per * 1.8) * vol, t0 + beat * per)
            elif pat == 'whole':
                self.put(inst(midi_hz(root), self.bar_s) * vol, t0)
            elif pat == 'walk':
                nxt = self.chord(prog[(b + 1) % self.bars], 2)[0]
                seq = [root, ch[1], fifth, nxt - 1 if self.rng.random() < .5 else nxt + 1]
                for beat in range(self.beats):
                    self.put(inst(midi_hz(seq[beat % 4]), per * 0.9) * vol, t0 + beat * per)
            elif pat == 'octave':
                for k in range(self.beats * 2):
                    m = root + (12 if k % 2 else 0)
                    self.put(inst(midi_hz(m), per * 0.45) * vol, t0 + k * per / 2)
            elif pat == 'pump':
                for beat in range(self.beats):
                    self.put(inst(midi_hz(root), per * 0.5) * vol, t0 + beat * per)
                    self.put(inst(midi_hz(root + 12), per * 0.3) * vol * 0.7, t0 + (beat + 0.5) * per)
            elif pat == 'fifths':
                for beat in range(self.beats):
                    self.put(inst(midi_hz(root if beat % 2 == 0 else fifth), per * 0.8) * vol, t0 + beat * per)
            elif pat == 'tarantella':
                for k in range(self.beats):
                    self.put(inst(midi_hz(root if k % 2 == 0 else fifth), per * 0.6) * vol, t0 + k * per)

    # melodia: tono d'accordo sui tempi forti, passi di scala negli altri; finale sulla tonica
    def _melody(self, prog):
        s = self.s
        inst = INSTR[s['lead']]
        vol = s.get('lead_vol', 0.4)
        sc = self.mel_scale
        dens = s.get('density', 0.5)
        lo, hi = s.get('range', (0, 9))  # gradi sopra la tonica a ottava 4
        spb = self.steps // self.beats
        motif = {}
        cur = s.get('start', 2)
        for b, d in enumerate(prog):
            form = b % 4  # frase di 4 battute: A, A', B, chiusura
            t0 = b * self.bar_s
            chord_degs = {(d + k) % 7 for k in (0, 2, 4)}
            step = 0
            while step < self.steps:
                strong = step % spb == 0
                p = dens * (1.0 if strong else 0.45)
                if b % 4 == 3 and step >= self.steps - spb * 2:  # chiusura
                    p = dens * 0.6
                key = (form % 2, step)
                if key in motif and form in (0, 1, 3) and self.rng.random() < 0.7:
                    play, move = motif[key]
                else:
                    play = self.rng.random() < p
                    move = int(self.rng.choice([-2, -1, -1, 0, 1, 1, 2]))
                    motif[key] = (play, move)
                if play:
                    nxt = cur + move
                    nxt = min(max(nxt, lo), hi)
                    if strong:  # avvicina a un tono dell'accordo
                        for off in (0, 1, -1, 2, -2):
                            if (nxt + off) % 7 in chord_degs and lo <= nxt + off <= hi:
                                nxt += off
                                break
                    cur = nxt
                    length = int(self.rng.choice([1, 2, 2, 3, 4])) * (2 if spb >= 4 else 1)
                    length = min(length, self.steps - step)
                    m = self.deg(self._sc_deg(cur, sc), 4)
                    self.put(inst(midi_hz(m), length * self.step_s * 0.95) * vol, t0 + step * self.step_s)
                    step += length
                else:
                    step += 1
            if b == self.bars - 1:  # ultima battuta: nota lunga sulla tonica
                m = self.deg(0, 4)
                self.put(inst(midi_hz(m), self.bar_s * 0.7) * vol, t0 + self.bar_s * 0.25)

    def _sc_deg(self, cur, sc):
        # converte un grado della scala usata dalla melodia in grado della scala base (7 note)
        if sc is self.scale:
            return cur
        o, i = divmod(cur, len(sc))
        semis = sc[i]
        base = min(range(7), key=lambda k: abs(self.scale[k] - semis))
        return base + 7 * o

    # batteria
    def _drums(self):
        pat = self.s.get('drums', 'none')
        if pat == 'none':
            return
        vol = self.s.get('drum_vol', 0.35)
        per = self.bar_s / self.beats
        for b in range(self.bars):
            t0 = b * self.bar_s
            for beat in range(self.beats):
                tb = t0 + beat * per
                if pat == 'four':
                    self.put(drum('kick') * vol * 0.9, tb)
                    self.put(drum('hat') * vol, tb + per / 2)
                    if beat % 2 == 1:
                        self.put(drum('snare') * vol * 0.6, tb)
                elif pat == 'soft':
                    if beat % 2 == 0:
                        self.put(drum('kick') * vol * 0.7, tb)
                    self.put(drum('hat') * vol * 0.8, tb + per / 2)
                elif pat == 'lofi':
                    if beat == 0 or (beat == 2 and b % 2):
                        self.put(drum('kick') * vol * 0.8, tb)
                    if beat % 2 == 1:
                        self.put(drum('snare') * vol * 0.5, tb)
                    self.put(drum('hat') * vol * 0.6, tb + per / 2 + per * 0.08)
                elif pat == 'swing':
                    self.put(drum('hat') * vol, tb)
                    self.put(drum('hat') * vol * 0.6, tb + per * 0.66)
                    if beat == 0:
                        self.put(drum('kick') * vol * 0.5, tb)
                elif pat == 'march':
                    if beat % 2 == 0:
                        self.put(drum('kick') * vol * 0.9, tb)
                    else:
                        self.put(drum('snare') * vol * 0.8, tb)
                        self.put(drum('snare') * vol * 0.4, tb + per * 0.75)
                elif pat == 'chip':
                    self.put(drum('hat') * vol * 1.2, tb)
                    self.put(drum('hat') * vol * 0.8, tb + per / 2)
                    if beat % 2 == 0:
                        self.put(drum('kick') * vol * 0.7, tb)
                    else:
                        self.put(drum('snare') * vol * 0.5, tb)
                elif pat == 'waltz':
                    if beat == 0:
                        self.put(drum('kick') * vol * 0.8, tb)
                    else:
                        self.put(drum('hat') * vol * 1.0, tb)
                elif pat == 'tarantella':
                    self.put(drum('kick') * vol * 0.8, tb)
                    for k in range(3):
                        self.put(drum('hat') * vol * (0.9 if k == 0 else 0.5), tb + k * per / 3)


# ------------------------------------------------------------------ le canzoncine
# prog: grado di ciascuna battuta (0 = tonica). Una per gioco, tutte diverse.
SONGS = {
    'busjam': dict(seed=1, bpm=108, key='C', mode='major', prog=[0, 5, 3, 4, 0, 5, 1, 4], comp='offbeat', comp_inst='epiano',
                   bass='walk', lead='marimba', density=0.55, drums='swing', range=(0, 9)),
    'sudoku': dict(seed=2, bpm=76, key='A', mode='minor', prog=[0, 5, 3, 4, 0, 5, 3, 4], comp='arp', comp_inst='epiano', arp=[0, 1, 2, 4, 2, 1],
                   arp_every=2, bass='root', lead='epiano', density=0.35, drums='lofi', range=(0, 7)),
    'maze': dict(seed=3, bpm=92, key='D', mode='dorian', prog=[0, 0, 3, 3, 0, 0, 6, 4], comp='pad', comp_inst='pad', bass='whole',
                 lead='pluck', density=0.4, drums='none', range=(0, 8)),
    'battleship': dict(seed=4, bpm=112, key='E', mode='minor', prog=[0, 5, 6, 4, 0, 5, 6, 0], comp='block', comp_inst='brass', comp_vol=.2,
                       bass='fifths', bass_inst='fatbass', lead='brass', lead_vol=.3, density=0.5, drums='march', range=(0, 7)),
    'tictactoe': dict(seed=5, bpm=120, key='G', mode='major', prog=[0, 3, 0, 4, 0, 3, 4, 0], comp='offbeat', comp_inst='pluck', bass='octave',
                      lead='marimba', density=0.6, drums='chip', drum_vol=.25, range=(0, 9)),
    'blocks': dict(seed=6, bpm=100, key='F', mode='major', prog=[0, 4, 5, 3, 0, 4, 1, 4], comp='arp', comp_inst='pulse', arp=[0, 1, 2, 1], arp_every=2,
                   comp_vol=.14, bass='pump', bass_inst='fatbass', lead='pulse', lead_vol=.25, density=0.5, drums='chip', range=(0, 9)),
    'g2048': dict(seed=7, bpm=84, key='C', mode='major', penta=True, prog=[0, 5, 3, 4, 0, 5, 3, 0], comp='pad', comp_inst='pad', bass='whole',
                  lead='bell', lead_vol=.45, density=0.28, drums='none', range=(0, 9)),
    'memory': dict(seed=8, bpm=96, key='D', mode='major', penta=True, ts=(3, 12), prog=[0, 3, 4, 0, 0, 3, 4, 0], comp='waltz', comp_inst='musicbox',
                   bass='root', lead='musicbox', lead_vol=.45, density=0.5, drums='none', range=(0, 9)),
    'wordle': dict(seed=9, bpm=88, key='G', mode='major', prog=[0, 4, 5, 3, 0, 4, 3, 0], comp='arp', comp_inst='pluck', arp=[0, 2, 1, 2, 3, 2, 1, 2],
                   arp_every=2, bass='root', lead='flute', lead_vol=.3, density=0.3, drums='soft', range=(1, 9)),
    'flow': dict(seed=10, bpm=100, key='A', mode='minor', penta=True, prog=[0, 2, 5, 4, 0, 2, 5, 4], comp='arp', comp_inst='bell', arp=[0, 1, 2, 3, 2, 1],
                 arp_every=2, comp_vol=.3, bass='whole', lead='flute', lead_vol=.35, density=0.3, drums='none', range=(1, 9)),
    'snake': dict(seed=11, bpm=132, key='E', mode='minor', prog=[0, 0, 5, 6, 0, 0, 3, 4], comp='arp', comp_inst='pulse', arp=[0, 2, 1, 2], arp_every=1,
                  comp_vol=.1, bass='octave', bass_inst='fatbass', lead='pulse', lead_vol=.25, density=0.6, drums='chip', range=(0, 9)),
    'minesweeper': dict(seed=12, bpm=100, key='C', mode='minor', prog=[0, 0, 5, 4, 0, 0, 1, 4], comp='pad', comp_inst='pad', bass='pump', bass_inst='bass',
                        lead='pluck', lead_vol=.3, density=0.22, drums='soft', drum_vol=.2, range=(0, 6)),
    'solitaire': dict(seed=13, bpm=72, key='F', mode='major', prog=[0, 3, 1, 4, 0, 3, 4, 0], comp='arp', comp_inst='epiano', arp=[0, 1, 2, 4, 2, 1],
                      arp_every=2, bass='whole', lead='epiano', density=0.3, drums='none', range=(0, 8)),
    'slide': dict(seed=14, bpm=116, key='Bb', mode='major', prog=[0, 4, 5, 3, 0, 4, 3, 4], comp='offbeat', comp_inst='marimba', bass='octave', lead='pluck',
                  density=0.55, drums='soft', range=(0, 9)),
    'connections': dict(seed=15, bpm=104, key='D', mode='minor', prog=[0, 5, 2, 6, 0, 5, 3, 4], comp='offbeat', comp_inst='pluck', bass='walk', lead='marimba',
                        density=0.45, drums='swing', range=(0, 8)),
    'flappy': dict(seed=16, bpm=140, key='C', mode='major', prog=[0, 4, 5, 3, 0, 4, 3, 4], comp='arp', comp_inst='pulse', arp=[0, 1, 2, 1], arp_every=2,
                   comp_vol=.1, bass='octave', bass_inst='fatbass', lead='pulse', lead_vol=.25, density=0.65, drums='chip', range=(0, 10)),
    'quiz': dict(seed=17, bpm=120, key='F', mode='major', prog=[0, 3, 0, 4, 0, 3, 4, 0], comp='block', comp_inst='brass', comp_vol=.22, bass='fifths',
                 lead='brass', lead_vol=.3, density=0.5, drums='four', drum_vol=.3, range=(0, 9)),
    'checkers': dict(seed=18, bpm=96, key='D', mode='mixo', prog=[0, 6, 0, 4, 0, 6, 3, 0], comp='offbeat', comp_inst='pluck', bass='fifths', lead='flute',
                     lead_vol=.3, density=0.5, drums='soft', range=(0, 8)),
    'chess': dict(seed=19, bpm=80, key='A', mode='minor', prog=[0, 3, 4, 0, 5, 3, 4, 0], comp='arp', comp_inst='harpsi', arp=[0, 1, 2, 4, 2, 1, 2, 1],
                  arp_every=2, bass='root', lead='harpsi', lead_vol=.35, density=0.35, drums='none', range=(0, 9)),
    'arrows': dict(seed=20, bpm=124, key='F#', mode='minor', prog=[0, 0, 5, 6, 0, 0, 3, 4], comp='arp', comp_inst='bell', arp=[0, 2, 1, 2, 0, 1], arp_every=1,
                   comp_vol=.1, bass='pump', bass_inst='fatbass', lead='pluck', lead_vol=.3, density=0.4, drums='four', drum_vol=.28, range=(0, 9)),
    'briscola': dict(seed=21, bpm=150, key='A', mode='minor', ts=(2, 12), bars=16, prog=[0, 0, 4, 0, 0, 5, 4, 0, 0, 0, 3, 0, 5, 5, 4, 0], comp='offbeat', comp_inst='pluck', bass='tarantella',
                     lead='flute', lead_vol=.35, density=0.55, drums='tarantella', drum_vol=.3, range=(0, 9)),
    'mastermind': dict(seed=22, bpm=96, key='A', mode='minor', prog=[0, 5, 3, 4, 0, 6, 3, 4], comp='offbeat', comp_inst='pluck', bass='walk', lead='marimba',
                       lead_vol=.35, density=0.4, drums='soft', drum_vol=.25, range=(0, 8)),
    'hangman': dict(seed=23, bpm=104, key='D', mode='minor', ts=(3, 12), bars=16, prog=[0, 0, 5, 4, 0, 3, 4, 0, 0, 0, 3, 4, 5, 3, 4, 0], comp='waltz', comp_inst='harpsi', bass='root',
                    lead='flute', lead_vol=.3, density=0.45, drums='none', range=(0, 8)),
    'watersort': dict(seed=24, bpm=82, key='F', mode='major', penta=True, prog=[0, 3, 4, 0, 5, 3, 4, 0], comp='arp', comp_inst='bell', arp=[0, 1, 2, 1], arp_every=2,
                      comp_vol=.25, bass='whole', lead='epiano', lead_vol=.35, density=0.3, drums='none', range=(1, 9)),
}


def save_mp3(name, x):
    x = x - np.mean(x)
    x = x / np.max(np.abs(x)) * 0.8
    pcm = (x * 32767).astype(np.int16)
    with tempfile.TemporaryDirectory() as tmp:
        wav = os.path.join(tmp, name + '.wav')
        with wave.open(wav, 'wb') as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(SR)
            w.writeframes(pcm.tobytes())
        out = os.path.join(OUT, f'music_{name}.mp3')
        subprocess.run(['ffmpeg', '-loglevel', 'error', '-y', '-i', wav, '-codec:a', 'libmp3lame', '-b:a', '48k', '-ac', '1', out], check=True)
    print(f'music_{name:12s} {len(x) / SR:5.1f}s  {os.path.getsize(out) / 1024:5.0f} KB')


if __name__ == '__main__':
    only = sys.argv[1:]
    for name, spec in SONGS.items():
        if not only or name in only:
            save_mp3(name, Song(spec).render())
