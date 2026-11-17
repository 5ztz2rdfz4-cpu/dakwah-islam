p='index.html'; s=open(p).read()
rep=[
('#t-mosque { left','#t-mosque { position: absolute; left'),
('#c2-pin { left','#c2-pin { position: absolute; left'),
('#c2-mosque { left','#c2-mosque { position: absolute; left'),
('#c3-route { left','#c3-route { position: absolute; left'),
('#o-doa { top: 1150px; }','#o-doa { top: 1185px; }'),
('#o-cta { left: 100px; right: 140px; top: 1310px;','#o-cta { left: 100px; right: 140px; top: 1360px;'),
('#o-name { top: 1040px; }','#o-name { top: 1045px; }'),
('#o-l1 { top: 262px;','#o-l1 { top: 250px;'),
('#o-l3 { top: 330px;','#o-l3 { top: 318px;'),
('style="top:410px; font-weight:900; font-size:96px;','style="top:420px; font-weight:900; font-size:96px;'),
# caption: hard cut between chunks (no overlap)
('const out = next && next[1] - e < 0.25 ? next[1] - 0.05 : e;\n        tl.to(d, { opacity: 0, y: -14, duration: 0.12, ease: "power1.in" }, out);',
 'const out = next && next[1] - e < 0.3 ? next[1] - 0.1 : e;\n        tl.to(d, { opacity: 0, y: -10, duration: 0.06, ease: "power1.in" }, out);'),
('tl.fromTo(d, { opacity: 0, y: 26, scale: 0.94 }, { opacity: 1, y: 0, scale: 1, duration: 0.16, ease: "power2.out" }, s - 0.04);',
 'tl.fromTo(d, { opacity: 0, y: 22, scale: 0.94 }, { opacity: 1, y: 0, scale: 1, duration: 0.14, ease: "power2.out" }, Math.max(s - 0.04, (CAPS[ci - 1] ? CAPS[ci - 1][2] : 0) - 0.03));'),
('tl.fromTo(sp, { scale: 1.18 }, { scale: 1, duration: 0.18, ease: "power2.out" }, acc);','tl.fromTo(sp, { y: 6 }, { y: 0, duration: 0.14, ease: "power2.out" }, acc);'),
# skyline ornament
('        <div id="vignette"></div>','''        <svg id="skyline" viewBox="0 0 1080 360" xmlns="http://www.w3.org/2000/svg" data-layout-ignore>
          <defs><linearGradient id="skyG" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#e8c26a" stop-opacity=".22"/><stop offset="1" stop-color="#e8c26a" stop-opacity="0"/></linearGradient></defs>
          <path fill="url(#skyG)" d="M0 360 V250 h60 v-30 h40 v30 h50 v-70 a6 6 0 0 1 12 0 v-40 h4 v40 a6 6 0 0 1 12 0 v70 h40 v-20 h70 v-40 h20 v-30 l10 -16 l10 16 v30 h20 v40 h60 C398 170 450 120 540 112 C630 120 682 170 682 240 h60 v-40 h20 v-30 l10 -16 l10 16 v30 h20 v40 h70 v20 h40 v-70 a6 6 0 0 1 12 0 v-40 h4 v40 a6 6 0 0 1 12 0 v70 h50 v-30 h40 v30 h60 V360Z"/>
          <path d="M540 112 v-34" stroke="#e8c26a" stroke-opacity=".3" stroke-width="5"/>
          <path d="M540 52 a16 16 0 1 0 12 27 a13 13 0 1 1 -12 -27z" fill="#e8c26a" fill-opacity=".35"/>
        </svg>
        <div id="vignette"></div>'''),
('#vignette { position: absolute;','#skyline { position: absolute; left: 0; bottom: 12px; width: 1080px; height: 360px; }\n      #vignette { position: absolute;'),
]
for a,b in rep:
    assert a in s, a[:80]
    s=s.replace(a,b)
open(p,'w').write(s); print('ok')
