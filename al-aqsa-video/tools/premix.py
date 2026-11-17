"""Pre-mix voice + ducked music + every SFX placed in index.html into one track."""
import re, wave, numpy as np
html = open("tools/audio_layout.html").read()
total_html = open("index.html").read()
def rd(p):
    w = wave.open(p); x = np.frombuffer(w.readframes(w.getnframes()), "<i2").astype(float) / 32768
    return x.reshape(-1, w.getnchannels())
SR = 48000
total = float(re.search(r'data-composition-id="main"[^>]*data-duration="([\d.]+)"', total_html).group(1))
mix = np.zeros((int(total * SR) + 1, 2))
for tag in re.findall(r"<audio [^>]*>", html):
    src = re.search(r'src="([^"]+)"', tag).group(1)
    st = float(re.search(r'data-start="([\d.]+)"', tag).group(1))
    vol = float(re.search(r'data-volume="([\d.]+)"', tag).group(1))
    x = rd(src) * vol
    fo = re.search(r'data-fade-out="([\d.]+)"', tag)
    if fo:
        n = int(float(fo.group(1)) * SR); x[-n:] *= np.linspace(1, 0, n)[:, None]
    i = int(st * SR); x = x[: len(mix) - i]; mix[i : i + len(x)] += x
peak = np.max(np.abs(mix)); mix *= min(1.0, 0.95 / peak)
with wave.open("assets/mix.wav", "wb") as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((mix * 32767).astype("<i2").tobytes())
print("peak", round(peak, 3))
