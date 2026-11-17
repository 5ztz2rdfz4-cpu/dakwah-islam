import re, wave
p='index.html'; s=open(p).read()
n=[0]
def dur(f):
    w=wave.open(f); return w.getnframes()/w.getframerate()
def addid(m):
    n[0]+=1
    tag=m.group(0); f=re.search(r'src="([^"]+)"',tag).group(1)
    name=re.search(r'sfx/(\w+)\.wav',f).group(1)
    tag=re.sub(r'data-duration="[^"]+"',f'data-duration="{dur(f):.2f}"',tag)
    return tag.replace('<audio ',f'<audio id="sfx-{n[0]:02d}-{name}" ',1)
s=re.sub(r'<audio src="assets/sfx/[^>]+>',addid,s)
rep=[
('tl.from("#t-title", { opacity: 0, letterSpacing: "0.4em", filter: "blur(10px)", duration: 0.7, ease: "power3.out" }, 5.3);',
 'tl.from("#t-title", { opacity: 0, scale: 1.35, filter: "blur(10px)", duration: 0.7, ease: "power3.out" }, 5.3);'),
('tl.from("#c2-place2", { opacity: 0, letterSpacing: "0.6em", duration: 0.6 }, 19.9);',
 'tl.from("#c2-place2", { opacity: 0, scale: 1.2, duration: 0.5 }, 19.25);'),
('tl.from("#t-mosque .m-ray", { opacity: 0, scale: 0.6, transformOrigin: "50% 36%", duration: 0.8 }, 5.7);\n      tl.to("#t-mosque .m-ray", { rotation: 6, transformOrigin: "50% 36%", duration: 3, ease: "none" }, 5.7);',
 'tl.fromTo("#t-mosque .m-ray", { opacity: 0, scale: 0.6, rotation: 0 }, { opacity: 1, scale: 1, rotation: 6, svgOrigin: "350 200", duration: 3, ease: "power2.out" }, 5.7);'),
('      tl.to("#c2-mosque", { y: -10, scale: 0.86, duration: 6, ease: "sine.inOut" }, 25.5);\n',''),
('tl.to("#c2-mosque", { y: -40, duration: 0.6, ease: "power2.inOut" }, 25.5);','tl.to("#c2-mosque", { y: -40, scale: 0.9, duration: 0.6, ease: "power2.inOut" }, 24.15);'),
('}, 25.65);\n      tl.from("#c2-verse .tr", { opacity: 0, y: 20, duration: 0.6 }, 26.5);\n      tl.from("#c2-verse .ref", { opacity: 0, duration: 0.5 }, 27.1);',
 '}, 24.3);\n      tl.from("#c2-verse .tr", { opacity: 0, y: 20, duration: 0.6 }, 24.8);\n      tl.from("#c2-verse .ref", { opacity: 0, duration: 0.5 }, 25.3);'),
('transformOrigin: "700px 600px"','svgOrigin: "700 600"'),
('transformOrigin: "700px 90px"','svgOrigin: "700 90"'),
('ease: "power3.out" }, 41.4);','ease: "power3.out" }, 40.7);'),
('tl.from("#c3-cap2", { opacity: 0, y: 20, duration: 0.5 }, 41.7);','tl.from("#c3-cap2", { opacity: 0, y: 20, duration: 0.5 }, 40.9);'),
('<text class="r-arcl" x="300" y="620"','<text class="r-arcl" x="330" y="520"'),
('<text class="r-arcl" x="300" y="664" fill="#b9c9bf" font-family="Montserrat" font-weight="700" font-size="26">','<text class="r-arcl" x="330" y="562" fill="#b9c9bf" font-family="Montserrat" font-weight="700" font-size="28">'),
('font-size="26" text-anchor="middle">MAKKAH','font-size="28" text-anchor="middle">MAKKAH'),
('font-size="26" text-anchor="middle">BAITULMAQDIS','font-size="28" text-anchor="middle">BAITULMAQDIS'),
('.chip-in .rl { font-weight: 600; font-size: 21px;','.chip-in .rl { font-weight: 700; font-size: 28px;'),
('.tl-tx small { display: block; font-weight: 600; font-size: 25px;','.tl-tx small { display: block; font-weight: 600; font-size: 28px;'),
('.card .s { font-weight: 600; font-size: 26px;','.card .s { font-weight: 600; font-size: 28px;'),
('.bar-you { position: absolute; top: 0; font-weight: 800; font-size: 26px;','.bar-you { position: absolute; top: 0; font-weight: 800; font-size: 30px;'),
('letter-spacing: 0.32em; font-size: 26px;','letter-spacing: 0.32em; font-size: 28px;'),
('letter-spacing: 0.24em; font-size: 26px;','letter-spacing: 0.24em; font-size: 30px;'),
('#c2-verse .ref { font-weight: 800; font-size: 26px;','#c2-verse .ref { font-weight: 800; font-size: 28px;'),
('tl.from("#h-tag", { opacity: 0, y: -30, duration: 0.5, ease: "power3.out" }, 0.1);\n      tl.from("#h1", { opacity: 0, y: 60, filter: "blur(10px)", duration: 0.35, ease: "power3.out" }, 0.4);',
 'tl.fromTo("#h1", { scale: 1 }, { scale: 1.06, duration: 0.4, ease: "power2.out" }, 0.4);'),
('      tl.fromTo("#frame", { opacity: 0 }, { opacity: 1, duration: 1 }, 0.1);\n',''),
]
for a,b in rep:
    assert a in s, a[:70]
    s=s.replace(a,b)
open(p,'w').write(s)
print("ok", n[0])
