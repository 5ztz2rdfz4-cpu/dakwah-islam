"""Expand index.src.html -> index.html (plane icons, SFX clips, gauge ticks, corners, captions)."""
import json, pathlib, re, sys, wave

HERE = pathlib.Path(__file__).parent.parent
sys.path.insert(0, str(HERE / "src"))
from edit import CUTS, M, src_to_new  # noqa: E402

src = (HERE / "src/index.tpl").read_text()

PLANE_D = ("M50 4 C54 4 56 10 56 16 L56 38 L95 60 L95 68 L56 57 L56 80 L67 89 L67 95 "
           "L50 90 L33 95 L33 89 L44 80 L44 57 L5 68 L5 60 L44 38 L44 16 C44 10 46 4 50 4 Z")
plane = (f'<svg width="100%" height="100%" viewBox="0 0 100 100"><path d="{PLANE_D}" fill="#f7dc8e" '
         'stroke="#a9822c" stroke-width="1.5"/></svg>')
plane_r = (f'<svg width="100%" height="100%" viewBox="0 0 100 100"><g transform="rotate(90 50 50)">'
           f'<path d="{PLANE_D}" fill="#f7dc8e" stroke="#a9822c" stroke-width="1.5"/></g></svg>')

# (file, start, volume)
SFX = [
    ("impact", 0.28, 0.55), ("whoosh", 0.0, 0.35), ("whoosh", 1.0, 0.3), ("shimmer", 1.7, 0.22),
    ("riser", 1.05, 0.3), ("impact", 3.0, 0.3), ("shimmer", 3.05, 0.25), ("flyby", 4.6, 0.32),
    ("whoosh", 8.3, 0.3), ("pop", 9.46, 0.4), ("pop", 10.71, 0.4), ("whoosh_down", 11.6, 0.3),
    ("whoosh_down", 13.7, 0.25), ("tick", 14.4, 0.45), ("whoosh", 16.9, 0.3), ("shimmer", 17.7, 0.28),
    ("impact", 20.38, 0.45), ("pop", 21.0, 0.4), ("whoosh", 21.6, 0.3), ("tick", 22.2, 0.35),
    ("tick", 22.75, 0.35), ("tick", 23.3, 0.35), ("tick", 23.85, 0.35), ("bell", 25.9, 0.35),
    ("shimmer", 26.0, 0.25), ("whoosh", 28.85, 0.32), ("tick", 29.6, 0.4), ("tick", 30.8, 0.4),
    ("tick", 32.5, 0.4), ("impact", 33.15, 0.35), ("pop", 34.2, 0.35), ("pop", 35.4, 0.35),
    ("whoosh", 36.8, 0.32), ("pop", 37.7, 0.4), ("shimmer", 38.0, 0.22), ("pop", 40.9, 0.4),
    ("shimmer", 41.2, 0.22), ("impact", 44.38, 0.45), ("whoosh", 45.9, 0.3), ("whoosh_down", 46.6, 0.25),
    ("tick", 49.2, 0.45), ("ding", 50.3, 0.28), ("pop", 52.9, 0.4), ("whoosh", 54.65, 0.3),
    ("flyby", 55.6, 0.28), ("riser", 55.4, 0.25), ("impact", 57.5, 0.45), ("bell", 59.5, 0.4),
    ("shimmer", 59.55, 0.3), ("whoosh", 63.1, 0.3), ("shimmer", 63.4, 0.25), ("pop", 65.0, 0.3),
    ("pop", 65.18, 0.3), ("pop", 65.36, 0.3),
]


def dur(name):
    with wave.open(str(HERE / "assets/audio" / f"{name}.wav")) as w:
        return round(w.getnframes() / w.getframerate(), 3)


sfx_html = "\n      ".join(
    f'<audio id="sfx-{i}" src="assets/audio/{n}.wav" data-start="{s}" data-duration="{dur(n)}" data-volume="{v}"></audio>'
    for i, (n, s, v) in enumerate(SFX))

ticks = "".join(
    f'<div class="abs" style="left: {0 if i % 2 == 0 else 20}px; top: {i * 70 - 1}px; width: {50 if i % 2 == 0 else 30}px; height: 3px; background: rgba(247,220,142,0.55)"></div>'
    for i in range(11))

corner_svg = ('<svg width="90" height="90" viewBox="0 0 90 90"><g fill="none" stroke="#e2bd5b" stroke-width="3">'
              '<path d="M4 60 V4 H60"/><path d="M14 40 V14 H40" stroke-opacity="0.6"/></g>'
              '<rect x="26" y="26" width="12" height="12" fill="#e2bd5b" transform="rotate(45 32 32)"/></svg>')
corners = "".join(
    f'<div class="corner" style="{pos}; transform: {tr}">{corner_svg}</div>'
    for pos, tr in [("left: 26px; top: 26px", "none"), ("right: 26px; top: 26px", "scaleX(-1)"),
                    ("left: 26px; bottom: 26px", "scaleY(-1)"), ("right: 26px; bottom: 26px", "scale(-1,-1)")])

# ---------------- captions from the raw transcript, mapped through the edit
FIX = {"redor": "redha", "nyamat": "nikmat", "taqnata": "taqnaṭū", "La": "Lā"}
HL = {"kapal", "terbang", "atas", "bawah", "titik", "terendah", "puncak", "kejayaan", "Allah", "SWT", "takdir",
      "terbaik", "redha", "bersyukur", "nikmat", "Syukur", "syukur", "sikap", "putus", "asa", "Lā", "taqnaṭū",
      "min", "raḥmatillāh", "diatur", "aturkan", "benda", "bukan", "posisi", "ingat"}
PLAN = (HERE / "src/caption_lines.txt").read_text().strip().split("\n")
raw = json.loads((HERE / "src/transcript_raw.json").read_text())
words = []
for seg in raw["segments"]:
    for w in seg["words"]:
        t, a, b = w["word"].strip(), w["start"], w["end"]
        mid = (a + b) / 2
        if any(x <= mid < y and a >= x - 0.05 for x, y in CUTS):
            continue
        a2, b2 = src_to_new(max(a, 0)), src_to_new(b)
        if t.startswith("-") and words:
            words[-1][0] += t; words[-1][2] = b2; continue
        if t == "mirrahmatillah.":
            words += [["min", a2, a2 + 0.25], ["raḥmatillāh.", a2 + 0.25, b2]]; continue
        words.append([FIX.get(t, t), a2, b2])
caps, i = [], 0
for line in PLAN:
    n = len(line.split()); ws = words[i:i + n]; i += n
    got = [w[0].rstrip(".,") for w in ws]
    assert got == line.split(), (line, got)
    caps.append({"s": round(ws[0][1], 2), "e": round(ws[-1][2], 2),
                 "w": [[w[0].rstrip(".,"), round(w[1], 2), round(w[2], 2), int(w[0].rstrip(".,") in HL)] for w in ws]})
assert i == len(words), (i, len(words))
for k in range(len(caps) - 1):
    caps[k]["e"] = min(round(caps[k + 1]["s"] - 0.02, 2), round(caps[k]["e"] + 0.7, 2))
caps[-1]["e"] = round(caps[-1]["e"] + 0.4, 2)

# ---------------- remap authored (old) times to the edited timeline
src = re.sub(r'data-start="([\d.]+)" data-duration="([\d.]+)"',
             lambda m: (lambda a, d: f'data-start="{M(a):g}" data-duration="{round(M(a + d) - M(a), 3):g}"')(float(m[1]), float(m[2])), src)
src = re.sub(r"\}, ([\d.]+)\);", lambda m: f"}}, {M(float(m[1])):g});", src)
src = re.sub(r"([\d.]+) \+ i \* ", lambda m: f"{M(float(m[1])):g} + i * ", src)
SFX = [(n, M(t), v) for n, t, v in SFX]

out = (src.replace("__PLANE_R__", plane_r).replace("__PLANE__", plane).replace("__SFX__", sfx_html)
       .replace("__TICKS__", ticks).replace("__CORNERS__", corners)
       .replace("__CAPS__", json.dumps(caps, ensure_ascii=False, separators=(",", ":"))))
out = re.sub(r'(id="a-voice" src="assets/audio/voice.wav" data-start="3" data-duration=")[\d.]+"', lambda m: m[1] + f'{dur("voice")}"', out)
(HERE / "index.html").write_text(out)
print("index.html written", len(out))
