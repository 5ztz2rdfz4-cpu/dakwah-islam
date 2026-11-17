"""Synthesise original background music + SFX (no external samples).

usage: make_audio.py OUT_DIR TOTAL HOOK_END TITLE_END OUTRO_START
"""
import os
import sys
import wave

import numpy as np
from numpy.fft import irfft, rfft
from scipy.signal import butter, lfilter, sosfilt

SR = 48000
OUT = sys.argv[1]
DUR, HOOK_END, TITLE_END, OUTRO = [float(v) for v in sys.argv[2:6]]
rng = np.random.default_rng(7)


def save(name, x, peak=0.89):
    x = np.asarray(x, dtype=np.float64)
    if x.ndim == 1:
        x = np.stack([x, x], 1)
    x = x / (np.max(np.abs(x)) + 1e-9) * peak
    with wave.open(os.path.join(OUT, name), "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((x * 32767).astype("<i2").tobytes())


def t_(d):
    return np.arange(int(d * SR)) / SR


def env(n, a, r):
    e = np.ones(n)
    A, R = int(a * SR), int(r * SR)
    if A:
        e[:A] = np.linspace(0, 1, A)
    if R:
        e[-R:] *= np.linspace(1, 0, R)
    return e


def lp(x, fc, order=2):
    return sosfilt(butter(order, fc, "low", fs=SR, output="sos"), x)


def bp(x, lo, hi):
    return sosfilt(butter(2, [lo, hi], "band", fs=SR, output="sos"), x)


def st(x):
    return np.stack([x, x], 1) if x.ndim == 1 else x


def reverb(x, secs=2.8, mix=0.35, seed=1):
    x = st(x)
    r = np.random.default_rng(seed)
    n = int(secs * SR)
    out = []
    for ch in range(2):
        ir = r.standard_normal(n) * np.exp(-np.linspace(0, 7, n))
        ir[: int(0.012 * SR)] = 0
        L = len(x) + n
        N = 1 << (L - 1).bit_length()
        w = irfft(rfft(x[:, ch], N) * rfft(ir, N), N)[: len(x)]
        out.append(w / (np.max(np.abs(w)) + 1e-9) * (np.max(np.abs(x[:, ch])) + 1e-9))
    return x * (1 - mix) + np.stack(out, 1) * mix * 1.3


def hz(m):
    return 440 * 2 ** ((m - 69) / 12)


# ---------------- SFX ----------------
def whoosh(d=0.9, up=True):
    t = t_(d)
    n = rng.standard_normal(len(t))
    # sweep: blend of low and high band noise crossfaded over time
    lo, hi = bp(n, 250, 900), bp(n, 1800, 7000)
    k = np.linspace(0, 1, len(t))
    if not up:
        k = k[::-1]
    x = lo * (1 - k) + hi * k * 1.4
    x *= np.sin(np.pi * np.linspace(0, 1, len(t))) ** 2
    pan = np.linspace(-0.7, 0.7, len(t))
    return reverb(np.stack([x * (1 - pan), x * (1 + pan)], 1), 1.0, 0.25)


def impact(d=2.6):
    t = t_(d)
    f = 95 * np.exp(-t * 6) + 36
    sub = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 2.0)
    click = rng.standard_normal(len(t)) * np.exp(-t * 70) * 0.5
    body = lp(rng.standard_normal(len(t)), 400) * np.exp(-t * 6) * 1.5
    return reverb(sub + click + body, 2.6, 0.3)


def riser(d=1.6):
    t = t_(d)
    f = 180 * (2 ** (t / d * 3))
    tone = sum(np.sin(2 * np.pi * np.cumsum(f * k) / SR) / k for k in (1, 1.5, 2))
    noise = bp(rng.standard_normal(len(t)), 800, 6000)
    x = (tone * 0.35 + noise * 0.65) * (t / d) ** 2.4
    x[-int(0.02 * SR):] *= np.linspace(1, 0, int(0.02 * SR))
    return reverb(x, 1.4, 0.3)


def chime(d=3.2, notes=(86, 89, 93, 98)):
    t = t_(d)
    x = np.zeros(len(t))
    for i, m in enumerate(notes):
        o = int(i * 0.08 * SR)
        tt = t[: len(t) - o]
        f = hz(m)
        v = np.sin(2 * np.pi * f * tt) + 0.35 * np.sin(2 * np.pi * f * 2.76 * tt) * np.exp(-tt * 6)
        x[o:] += v * np.exp(-tt * 1.6)
    return reverb(x, 3.0, 0.45)


def pop(f0=900, d=0.18, dec=28):
    t = t_(d)
    f = f0 * np.exp(-t * 18) + 220
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * dec)


def heartbeat(d=1.0):
    t = t_(d)
    x = np.zeros(len(t))
    for o, a in ((0, 1.0), (0.27, 0.7)):
        i = int(o * SR)
        tt = t[: len(t) - i]
        x[i:] += a * np.sin(2 * np.pi * (55 * np.exp(-tt * 8) + 36) * tt) * np.exp(-tt * 13)
    return x


save("whoosh.wav", whoosh())
save("whoosh_soft.wav", whoosh(0.6, False), 0.5)
save("impact.wav", impact())
save("riser.wav", riser())
save("shimmer.wav", chime())
save("pop.wav", pop())
save("tick.wav", pop(2600, 0.06, 60), 0.6)
save("heartbeat.wav", heartbeat())

# ---------------- MUSIC ----------------
BPM = 76
beat = 60 / BPM
N = int(DUR * SR)
mus = np.zeros((N, 2))


def add(x, at, gain=1.0, pan=0.0):
    i = int(at * SR)
    if i >= N:
        return
    x = x[: N - i]
    if x.ndim == 1:
        x = np.stack([x * (1 - pan), x * (1 + pan)], 1)
    mus[i: i + len(x)] += x * gain


D = 50  # D3; maqam Hijaz on D: D Eb F# G A Bb C
SCALE = [0, 1, 4, 5, 7, 8, 10]


def sc(deg, octv=0):
    return D + 12 * (octv + deg // 7) + SCALE[deg % 7]


def pad(midis, d, cutoff):
    t = t_(d)
    x = np.zeros(len(t))
    for m in midis:
        for det in (-0.1, 0.0, 0.09):
            f = hz(m + det)
            x += 2 * ((t * f + rng.random()) % 1) - 1
    x = lp(x, cutoff, 4)
    return x * env(len(t), d * 0.4, d * 0.4)


PROG = [[D - 12, D - 5, D + 4], [D - 12, D - 5, D + 3], [D - 14, D - 7, D + 1], [D - 12, D - 5, D + 4]]
s, i = 0.0, 0
while s < DUR:
    d = 8 * beat
    cut = 500 if s < HOOK_END else (900 if s < OUTRO - 2 else 1400)
    add(pad(PROG[i % 4], d + 2.5, cut), max(0.0, s - 1.2), 0.20)
    s += d
    i += 1


def pluck(m, d=1.8):
    """Karplus-Strong oud-like pluck (vectorised per period)."""
    f = hz(m)
    n = int(SR / f)
    buf = rng.uniform(-1, 1, n)
    total = int(d * SR)
    out = np.empty(total + n)
    out[:n] = buf
    i = n
    while i < total + n:
        prev = out[i - n: i]
        nxt = np.empty(n)
        nxt[:-1] = 0.4975 * (prev[:-1] + prev[1:])
        nxt[-1] = 0.4975 * (prev[-1] + out[i - n])
        k = min(n, total + n - i)
        out[i: i + k] = nxt[:k]
        i += k
    out = out[:total]
    out = lfilter([1, -0.6], [1], out)  # body / brightness
    return out * env(total, 0.002, 0.4)


MOTIF = [0, 1, 2, 1, 0, 4, 3, 2, 1, 2, 3, 4, 5, 4, 3, 1, 2, 1, 0, -1, 0, 1, 2, 0]
cache = {}
k, t0 = 0, TITLE_END - 0.2
while t0 < DUR - 2.5:
    deg = MOTIF[k % len(MOTIF)]
    m = sc(deg % 7, 1 + (deg // 7))
    if m not in cache:
        cache[m] = pluck(m)
    g = 0.34 if k % 4 == 0 else 0.20
    add(cache[m], t0, g * (1.25 if t0 > OUTRO else 1.0), 0.3 if k % 2 else -0.3)
    t0 += beat / 2 if (k % 8) in (2, 3, 6) else beat
    k += 1


def daf_low(d=0.6):
    t = t_(d)
    return np.sin(2 * np.pi * (75 * np.exp(-t * 12) + 55) * t) * np.exp(-t * 8)


def daf_slap(d=0.25):
    t = t_(d)
    return bp(rng.standard_normal(len(t)), 1500, 6000) * np.exp(-t * 32) * 0.7


Lw, Sw = daf_low(), daf_slap()
bt, b = TITLE_END, 0
while bt < DUR - 2.5:
    pos = b % 8
    if pos in (0, 3, 6):
        add(Lw, bt, 0.55)
    if pos in (2, 5, 7):
        add(Sw, bt, 0.30, 0.15)
    if pos == 4:
        add(Sw, bt, 0.15, -0.15)
    bt += beat / 2
    b += 1

hb = heartbeat()
for ti in np.arange(0.3, HOOK_END, 1.2):
    add(hb, ti, 0.55)

mus = reverb(mus, 3.2, 0.3, 3)
g = np.ones(N)
fi = int(0.4 * SR)
g[:fi] = np.linspace(0, 1, fi)
fo = int(3.0 * SR)
g[-fo:] *= np.linspace(1, 0, fo) ** 1.5
mus *= g[:, None]
save("bgm.wav", mus)
print("ok")
