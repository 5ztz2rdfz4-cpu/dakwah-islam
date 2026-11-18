import subprocess
segs=[(0.80,11.35),(11.35,12.78),(13.66,14.85),(14.85,16.20),(16.60,24.85),(28.25,42.55),(42.65,53.35),(55.10,58.60)]
v=[];a=[];fc=[]
pre="[0:v]fps=30,delogo=x=8:y=468:w=222:h=78:enable='lt(t,4.9)',crop=418:560:12:220,scale=720:964:flags=lanczos,unsharp=5:5:0.6,eq=contrast=1.05:saturation=1.08,split=%d"%len(segs)+''.join(f'[v{i}]' for i in range(len(segs)))
fc.append(pre)
fc.append("[0:a]highpass=f=80,afftdn=nf=-25,asplit=%d"%len(segs)+''.join(f'[a{i}]' for i in range(len(segs))))
for i,(s,e) in enumerate(segs):
    d=e-s
    fc.append(f"[v{i}]trim={s}:{e},setpts=PTS-STARTPTS[vv{i}]")
    fc.append(f"[a{i}]atrim={s}:{e},asetpts=PTS-STARTPTS,afade=t=in:d=0.02,afade=t=out:st={d-0.03:.3f}:d=0.03[aa{i}]")
fc.append(''.join(f'[vv{i}][aa{i}]' for i in range(len(segs)))+f"concat=n={len(segs)}:v=1:a=1[vo][ao0]")
fc.append("[ao0]loudnorm=I=-15:TP=-1.5:LRA=9,aresample=48000[ao]")
cmd=["ffmpeg","-v","error","-y","-i","src/video.mp4","-filter_complex",";".join(fc),"-map","[vo]","-map","[ao]","-c:v","libx264","-crf","14","-preset","slow","-pix_fmt","yuv420p","-g","30","-c:a","aac","-b:a","192k","proj/assets/ceramah.mp4"]
subprocess.run(cmd,check=True)
t=2.6
for s,e in segs: print(f"{t:.2f}", end=' '); t+=e-s
print("end",round(t,2))
