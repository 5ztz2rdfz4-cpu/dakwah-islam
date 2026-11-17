"""Sidechain-duck the music under the voice so speech stays clear."""
import sys, numpy as np, wave
from scipy.ndimage import maximum_filter1d, uniform_filter1d
def rd(p):
    w = wave.open(p); n = w.getnframes(); x = np.frombuffer(w.readframes(n), "<i2").astype(float) / 32768
    return x.reshape(-1, w.getnchannels()), w.getframerate()
v, sr = rd(sys.argv[1]); m, _ = rd(sys.argv[2])
n = min(len(v), len(m)); v, m = v[:n], m[:n]
e = np.abs(v).mean(1); hop = sr // 100
e = e[: len(e) // hop * hop].reshape(-1, hop).max(1)
act = (e > 0.02).astype(float)
act = maximum_filter1d(act, 40)          # hold 0.4s
act = uniform_filter1d(act, 30)          # smooth ~0.3s
g = 1 - 0.62 * act
g = np.repeat(g, hop); g = np.pad(g, (0, n - len(g)), "edge")
out = m * g[:, None]
with wave.open(sys.argv[3], "wb") as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(sr)
    w.writeframes((np.clip(out, -1, 1) * 32767).astype("<i2").tobytes())
