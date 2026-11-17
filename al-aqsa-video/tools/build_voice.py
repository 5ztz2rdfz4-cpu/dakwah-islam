"""Cut the ceramah audio into the edited voice track + caption timings."""
import json, subprocess, sys
SRC, TR, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
# (src_start, src_end, gap_before_in_output)
SEGS = [
    ("H", 57.95, 62.93, 0.25),   # hook: "Ini bukan soal agama. Ini soal kemanusiaan."
    ("B1a", 3.60, 5.05, 3.35),   # title card plays in this gap
    ("B1b", 5.55, 8.85, 0.05),   # (long pause after "faham" removed)
    ("B2", 9.55, 13.30, 0.20),
    ("B3", 18.10, 22.10, 0.70),
    ("B4", 22.75, 29.95, 0.30),
    ("B5", 30.55, 31.78, 0.70),
    ("B6", 32.35, 37.56, 0.15),  # "Masjid Al-Aqsa itulah ... bersejarah bagi umat Islam"
    ("B6b", 39.70, 45.60, 0.35), # "peristiwa Israk dan Mikraj Baginda Nabi Muhammad" (repeat removed)
    ("B7", 50.40, 57.40, 0.70),
]
OUTRO = 7.0
FIX = {"palestine": "Palestin", "palestine?": "Palestin?", "lalaksa": "Al-Aqsa", "masih": "Masjid",
       "iswad": "Israk", "ditangguh": "ditanggung", "disitulah": "Di situlah", "lama?": "lama?"}
words = json.load(open(TR))
t = 0.0; filt = []; inputs = []; caps = []; marks = {}
for i, (name, a, b, gap) in enumerate(SEGS):
    t += gap
    marks[name] = [round(t, 3), round(t + b - a, 3)]
    d = b - a
    filt.append(f"[0:a]atrim={a}:{b},asetpts=PTS-STARTPTS,afade=t=in:d=0.04,afade=t=out:st={d-0.06}:d=0.06,adelay={int(t*1000)}|{int(t*1000)}[s{i}]")
    for w in words:
        if w["start"] >= a - 0.05 and w["end"] <= b + 0.3:
            txt = w["word"].strip()
            txt = FIX.get(txt.lower(), txt)
            caps.append({"w": txt, "s": round(w["start"] - a + t, 3), "e": round(min(w["end"], b) - a + t, 3), "seg": name})
    t += d
total = t + OUTRO
marks["OUTRO"] = [round(t, 3), round(total, 3)]
mix = "".join(f"[s{i}]" for i in range(len(SEGS)))
filt.append(f"{mix}amix=inputs={len(SEGS)}:normalize=0,apad=whole_dur={total},highpass=f=80,loudnorm=I=-15:TP=-1.5:LRA=9[out]")
subprocess.run(["ffmpeg", "-y", "-v", "error", "-i", SRC, "-filter_complex", ";".join(filt), "-map", "[out]", "-ar", "48000", "-ac", "2", OUT], check=True)
json.dump({"total": round(total, 3), "marks": marks, "caps": caps}, open(OUT.rsplit("/", 1)[0] + "/timing.json", "w"), indent=1, ensure_ascii=False)
print(json.dumps(marks), total)
