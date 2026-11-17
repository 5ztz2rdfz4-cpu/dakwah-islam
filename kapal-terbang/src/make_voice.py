"""Build assets/audio/voice.wav: cut per edit.py, clean, add mosque/surau hall reverb.

usage: python3 make_voice.py <source.MOV> <workdir>
"""
import os, subprocess, sys, wave
import numpy as np

sys.path.insert(0, os.path.dirname(__file__))
from edit import CUTS, SRC_END  # noqa: E402

SR = 48000
src, work = sys.argv[1], sys.argv[2]
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.makedirs(work, exist_ok=True)


def ff(*args):
    subprocess.run(["ffmpeg", "-v", "error", "-y", *args], check=True)


def read(p):
    with wave.open(p) as w:
        x = np.frombuffer(w.readframes(w.getnframes()), np.int16).astype(np.float64) / 32768
        return x.reshape(-1, w.getnchannels())


def write(p, x):
    x = np.clip(x, -1, 1)
    with wave.open(p, "wb") as w:
        w.setnchannels(x.shape[1]); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((x * 32767).astype(np.int16).tobytes())


# 1) raw 48k stereo
raw = os.path.join(work, "raw.wav")
ff("-i", src, "-vn", "-ac", "2", "-ar", str(SR), raw)
x = read(raw)

# 2) keep segments with short equal-power crossfades
keep, t = [], 0.0
for a, b in CUTS:
    keep.append((t, a)); t = b
keep.append((t, SRC_END))
XF = int(0.02 * SR)
out = None
for a, b in keep:
    seg = x[int(a * SR):int(b * SR)].copy()
    if out is None:
        out = seg; continue
    fo = np.cos(np.linspace(0, np.pi / 2, XF))[:, None]
    fi = np.sin(np.linspace(0, np.pi / 2, XF))[:, None]
    out[-XF:] = out[-XF:] * fo + seg[:XF] * fi
    out = np.concatenate([out, seg[XF:]])
n = int(0.35 * SR)
out[-n:] *= np.linspace(1, 0, n)[:, None]
cut = os.path.join(work, "cut.wav")
write(cut, out)

# 3) clean + PA-speaker colour (masjid mic)
clean = os.path.join(work, "clean.wav")
ff("-i", cut, "-af",
   "highpass=f=110,lowpass=f=11000,afftdn=nf=-30,"
   "equalizer=f=250:t=q:w=1:g=-2,equalizer=f=2800:t=q:w=1.2:g=3,"
   "acompressor=threshold=-20dB:ratio=3:attack=8:release=150:makeup=2,"
   "loudnorm=I=-16:TP=-2:LRA=8", "-ar", str(SR), clean)
dry = read(clean)

# 4) synthetic hall IR: pre-delay, discrete early reflections, ~2.2 s darkening tail
rng = np.random.default_rng(11)
RT = 2.2
L = int(RT * 1.15 * SR)
tt = np.arange(L) / SR
ir = np.zeros((L, 2))
pre = int(0.024 * SR)
for ch in range(2):
    noise = rng.standard_normal(L) * np.exp(-tt * 6.91 / RT)
    # progressively darker tail: blend of low-passed and raw noise
    k = np.exp(-tt * 3.0)
    lp = np.convolve(noise, np.ones(12) / 12, mode="same")
    tail = noise * k + lp * (1 - k)
    tail[: pre] = 0
    ramp = int(0.03 * SR)
    tail[pre:pre + ramp] *= np.linspace(0, 1, ramp)
    ir[:, ch] = tail
    for d, g in [(0.013, 0.55), (0.021, 0.45), (0.034, 0.38), (0.047, 0.32), (0.061, 0.26), (0.083, 0.2)]:
        i = int((d + ch * 0.0031) * SR)
        ir[i, ch] += g * (1 if rng.random() > 0.5 else -1)
ir /= np.sqrt((ir ** 2).sum(0, keepdims=True))

N = len(dry) + L
mono = dry.mean(1)
F = np.fft.rfft(mono, N)
wet = np.stack([np.fft.irfft(F * np.fft.rfft(ir[:, c], N), N) for c in range(2)], 1)
wet = wet[: len(dry) + int(1.8 * SR)]
dry_p = np.concatenate([dry, np.zeros((len(wet) - len(dry), 2))])
# wet level relative to dry (RMS based), ~ -9 dB: clearly "in a hall" yet intelligible
g = 10 ** (-9 / 20) * np.sqrt((dry ** 2).mean()) / (np.sqrt((wet ** 2).mean()) + 1e-12)
mix = dry_p + wet * g
verb = os.path.join(work, "verb.wav")
write(verb, mix / (np.abs(mix).max() + 1e-9) * 0.7)

# 5) final loudness
ff("-i", verb, "-af", "loudnorm=I=-15:TP=-1.5:LRA=9", "-ar", str(SR), os.path.join(root, "assets/audio/voice.wav"))
print("voice.wav", round(len(mix) / SR, 3), "s")
