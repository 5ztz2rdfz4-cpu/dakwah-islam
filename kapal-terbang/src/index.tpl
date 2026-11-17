<!doctype html>
<html lang="ms" data-resolution="portrait">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=1080, height=1920" />
    <script src="assets/js/gsap.min.js"></script>
    <script src="assets/js/MotionPathPlugin.min.js"></script>
    <style>
      @font-face { font-family: "Cinzel"; src: url(assets/fonts/cinzel-latin-700-normal.woff2) format("woff2"); font-weight: 700; }
      @font-face { font-family: "Cinzel"; src: url(assets/fonts/cinzel-latin-900-normal.woff2) format("woff2"); font-weight: 900; }
      @font-face { font-family: "Mont"; src: url(assets/fonts/montserrat-latin-500-normal.woff2) format("woff2"); font-weight: 500; }
      @font-face { font-family: "Mont"; src: url(assets/fonts/montserrat-latin-600-normal.woff2) format("woff2"); font-weight: 600; }
      @font-face { font-family: "Mont"; src: url(assets/fonts/montserrat-latin-700-normal.woff2) format("woff2"); font-weight: 700; }
      @font-face { font-family: "Mont"; src: url(assets/fonts/montserrat-latin-800-normal.woff2) format("woff2"); font-weight: 800; }
      @font-face { font-family: "Mont"; src: url(assets/fonts/montserrat-latin-900-normal.woff2) format("woff2"); font-weight: 900; }
      @font-face { font-family: "AmiriAr"; src: url(assets/fonts/amiri-arabic-700-normal.woff2) format("woff2"); font-weight: 700; }
      @font-face { font-family: "AmiriAr"; src: url(assets/fonts/amiri-arabic-400-normal.woff2) format("woff2"); font-weight: 400; }
      @font-face { font-family: "AmiriLat"; src: url(assets/fonts/amiri-latin-400-normal.woff2) format("woff2"); font-weight: 400; }
      @font-face { font-family: "AmiriLat"; src: url(assets/fonts/amiri-latin-700-normal.woff2) format("woff2"); font-weight: 700; }

      :root {
        --ground: #04211b;
        --ground-2: #0a3d32;
        --ink: #f8f1de;
        --gold: #e2bd5b;
        --gold-hi: #f7dc8e;
        --gold-lo: #a9822c;
        --teal: #47c2a8;
        --rose: #e0705f;
        --font-display: "Cinzel", serif;
        --font-body: "Mont", sans-serif;
        --font-ar: "AmiriAr", "AmiriLat", serif;
      }
      * { margin: 0; padding: 0; box-sizing: border-box; }
      html, body { width: 1080px; height: 1920px; overflow: hidden; background: var(--ground); }
      #root { position: relative; width: 1080px; height: 1920px; overflow: hidden; font-family: var(--font-body); color: var(--ink); }
      .clip { position: absolute; inset: 0; }
      .abs { position: absolute; }
      .cx { left: 0; right: 0; margin: 0 auto; width: fit-content; }
      .center { display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; }
      .gold-text {
        background: linear-gradient(180deg, #fff1bf 0%, var(--gold-hi) 30%, var(--gold) 62%, var(--gold-lo) 100%);
        -webkit-background-clip: text; background-clip: text; color: transparent;
      }
      .shadow { filter: drop-shadow(0 6px 18px rgba(0, 0, 0, 0.55)); }

      /* ---------- background ---------- */
      #bg { background: radial-gradient(ellipse 120% 70% at 50% 18%, #11584a 0%, #0a3d32 38%, #052720 70%, #03140f 100%); }
      #pattern { position: absolute; left: -540px; top: -540px; width: 2160px; height: 3000px; opacity: 0.085; }
      #rays {
        position: absolute; left: -460px; top: -1200px; width: 2000px; height: 2000px; border-radius: 50%;
        background: repeating-conic-gradient(from 0deg, rgba(247, 220, 142, 0.16) 0deg 5deg, transparent 5deg 15deg);
        -webkit-mask-image: radial-gradient(circle, #000 0%, transparent 62%); mask-image: radial-gradient(circle, #000 0%, transparent 62%);
        opacity: 0.35;
      }
      #glow { position: absolute; left: 140px; top: 460px; width: 800px; height: 800px; border-radius: 50%; background: radial-gradient(circle, rgba(226, 189, 91, 0.16), transparent 65%); }
      #vignette { position: absolute; inset: 0; background: radial-gradient(ellipse 85% 75% at 50% 45%, transparent 55%, rgba(0, 0, 0, 0.62) 100%); }
      .dot { position: absolute; border-radius: 50%; background: var(--gold-hi); box-shadow: 0 0 10px rgba(247, 220, 142, 0.9); }
      #frame { position: absolute; inset: 34px; border: 2px solid rgba(226, 189, 91, 0.35); border-radius: 14px; }
      #frame::after { content: ""; position: absolute; inset: 10px; border: 1px solid rgba(226, 189, 91, 0.16); border-radius: 8px; }
      .corner { position: absolute; width: 90px; height: 90px; }

      /* ---------- shared bits ---------- */
      .kicker { font: 700 30px var(--font-body); letter-spacing: 0.32em; color: var(--gold); text-transform: uppercase; white-space: nowrap; }
      .h-display { font-family: var(--font-display); font-weight: 900; line-height: 1.02; text-transform: uppercase; }
      .orn { display: flex; align-items: center; gap: 18px; }
      .orn i { display: block; height: 2px; width: 110px; background: linear-gradient(90deg, transparent, var(--gold)); }
      .orn i:last-child { transform: scaleX(-1); }
      .orn b { width: 16px; height: 16px; background: var(--gold); transform: rotate(45deg); }
      .card {
        position: absolute; border-radius: 30px; padding: 34px 40px;
        background: linear-gradient(160deg, rgba(255, 255, 255, 0.09), rgba(255, 255, 255, 0.025));
        border: 2px solid rgba(226, 189, 91, 0.45);
        box-shadow: 0 30px 60px rgba(0, 0, 0, 0.35), inset 0 1px 0 rgba(255, 255, 255, 0.12);
      }
      .chip { display: inline-flex; align-items: center; gap: 14px; padding: 16px 30px; border-radius: 999px; font: 800 34px var(--font-body); letter-spacing: 0.06em; white-space: nowrap; }

      /* ---------- captions ---------- */
      #caps { position: absolute; left: 70px; right: 70px; top: 1318px; height: 190px; }
      .cap {
        position: absolute; inset: 0; display: flex; flex-wrap: wrap; justify-content: center; align-content: center; gap: 6px 24px;
        font: 800 58px/1.18 var(--font-body); text-align: center; opacity: 0; visibility: hidden;
      }
      .cap .w { display: inline-block; color: var(--ink); opacity: 0.45; text-shadow: 0 4px 0 rgba(0, 0, 0, 0.45), 0 0 24px rgba(0, 0, 0, 0.6); }

      /* ---------- speaker badge ---------- */
      #badge { position: absolute; left: 0; right: 0; margin: 0 auto; width: fit-content; top: 150px; display: flex; align-items: center; gap: 22px; padding: 12px 34px 12px 14px; border-radius: 999px; background: rgba(3, 20, 15, 0.55); border: 2px solid rgba(226, 189, 91, 0.55); white-space: nowrap; }
      .mini-arch { position: relative; width: 100px; height: 100px; border-radius: 50%; overflow: hidden; border: 3px solid var(--gold-hi); box-shadow: 0 0 16px rgba(247, 220, 142, 0.45); }
      .mini-arch img { position: absolute; inset: 0; width: 100%; height: 100%; }
      #badge .nm { font: 800 27px var(--font-body); letter-spacing: 0.04em; color: var(--ink); }
      #badge .rl { font: 600 22px var(--font-body); color: var(--gold); letter-spacing: 0.05em; margin-top: 4px; }

      /* ---------- round portrait ---------- */
      .ring-wrap { position: absolute; }
      .ring-glow { position: absolute; inset: -60px; border-radius: 50%; background: radial-gradient(circle, rgba(247, 220, 142, 0.38), transparent 66%); }
      .ring-deco { position: absolute; inset: -30px; border-radius: 50%; border: 3px dashed rgba(226, 189, 91, 0.6); }
      .ring-deco2 { position: absolute; inset: -14px; border-radius: 50%; border: 2px solid rgba(226, 189, 91, 0.45); }
      .ring { position: absolute; inset: 0; border-radius: 50%; overflow: hidden; border: 8px solid var(--gold); box-shadow: 0 0 50px rgba(226, 189, 91, 0.45), 0 30px 60px rgba(0, 0, 0, 0.5); background: #0b4a3c; }
      .ring img { position: absolute; inset: 0; width: 100%; height: 100%; }
      .plaque { position: absolute; padding: 20px 48px; border-radius: 18px; text-align: center; white-space: nowrap; background: linear-gradient(180deg, #f7dc8e, #c99a3a); box-shadow: 0 16px 40px rgba(0, 0, 0, 0.45); }
      .plaque .nm { font: 900 40px var(--font-body); color: #1d1406; letter-spacing: 0.02em; }
      .plaque .rl { font: 700 26px var(--font-body); color: #3b2a0a; letter-spacing: 0.12em; text-transform: uppercase; margin-top: 4px; }

      /* ---------- scene specific ---------- */
      .plane { position: absolute; width: 120px; height: 120px; }
      .lbl { position: absolute; font: 900 34px var(--font-body); letter-spacing: 0.12em; padding: 12px 26px; border-radius: 14px; white-space: nowrap; }
      .gauge-card .t { font: 900 46px var(--font-body); letter-spacing: 0.04em; }
      .gauge-card .s { font: 600 30px var(--font-body); color: rgba(248, 241, 222, 0.8); margin-top: 8px; }
      .ticket { position: absolute; left: 90px; width: 900px; height: 690px; top: 470px; border-radius: 34px; background: linear-gradient(180deg, #fbf4e0, #efe1bb); color: #1b2a24; overflow: hidden; box-shadow: 0 40px 80px rgba(0, 0, 0, 0.5); }
      .ticket .top { height: 132px; background: linear-gradient(90deg, #0b4a3c, #12634f); display: flex; align-items: center; justify-content: space-between; padding: 0 44px; color: var(--gold-hi); }
      .ticket .row { position: absolute; left: 50px; right: 50px; display: flex; justify-content: space-between; align-items: flex-end; border-bottom: 3px dashed rgba(11, 74, 60, 0.25); padding-bottom: 18px; }
      .ticket .k { font: 700 26px var(--font-body); letter-spacing: 0.2em; color: #6b7d75; }
      .ticket .v { font: 900 48px var(--font-body); color: #0b4a3c; letter-spacing: 0.02em; }
      .stamp { position: absolute; right: 60px; bottom: 50px; width: 250px; height: 250px; border-radius: 50%; border: 8px solid #b8452f; color: #b8452f; display: flex; flex-direction: column; align-items: center; justify-content: center; font: 900 40px var(--font-body); letter-spacing: 0.06em; text-align: center; line-height: 1.1; }
      .stamp::before { content: ""; position: absolute; inset: 10px; border: 3px solid #b8452f; border-radius: 50%; }
      .duty .num { font: 900 92px var(--font-display); line-height: 1; }
      .duty .ar { font: 700 120px var(--font-ar); line-height: 1.1; direction: rtl; }
      .duty .t { font: 900 64px var(--font-body); letter-spacing: 0.08em; }
      .duty .s { font: 600 32px var(--font-body); color: rgba(248, 241, 222, 0.85); }
      .cmp .ic { width: 110px; height: 110px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex: none; }
      .cmp .tx { font: 600 36px/1.3 var(--font-body); }
      .cmp .tx b { font-weight: 900; }
      .ayah { font: 700 104px/1.6 var(--font-ar); direction: rtl; white-space: nowrap; }
    </style>
  </head>
  <body>
    <div id="root" data-composition-id="main" data-start="0" data-duration="68.5" data-width="1080" data-height="1920">
      <!-- ================= AUDIO ================= -->
      <audio id="a-voice" src="assets/audio/voice.wav" data-start="3" data-duration="58.8" data-volume="1"></audio>
      <audio id="a-bgm" src="assets/audio/bgm.wav" data-start="0" data-duration="68.5" data-volume="1" data-fade-out="2.5"></audio>
      __SFX__

      <!-- ================= BACKGROUND ================= -->
      <div id="bg" class="clip" data-start="0" data-duration="68.5">
        <div id="rays"></div>
        <svg id="pattern" viewBox="0 0 2160 3000" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <pattern id="star8" width="180" height="180" patternUnits="userSpaceOnUse">
              <g fill="none" stroke="#f7dc8e" stroke-width="2">
                <rect x="45" y="45" width="90" height="90" />
                <rect x="45" y="45" width="90" height="90" transform="rotate(45 90 90)" />
                <circle cx="90" cy="90" r="22" />
                <path d="M0 0 L26 26 M180 0 L154 26 M0 180 L26 154 M180 180 L154 154 M90 0 V26 M90 180 V154 M0 90 H26 M180 90 H154" />
              </g>
            </pattern>
          </defs>
          <rect width="2160" height="3000" fill="url(#star8)" />
        </svg>
        <div id="glow"></div>
        <div id="dots"></div>
        <div id="vignette"></div>
        <div id="frame"></div>
        __CORNERS__
      </div>

      <!-- ================= S0 HOOK 0-3.05 ================= -->
      <div id="s0" class="clip" data-start="0" data-duration="3.05">
        <svg class="abs" style="left: 0; top: 0" width="1080" height="1920" viewBox="0 0 1080 1920">
          <defs>
            <linearGradient id="fallg" x1="0" x2="1">
              <stop offset="0" stop-color="#e2bd5b" stop-opacity="0" />
              <stop offset="1" stop-color="#e0705f" stop-opacity="0.9" />
            </linearGradient>
          </defs>
          <path id="fallpath" d="M60 520 C 300 560, 420 760, 560 900 S 860 1180, 1000 1300" fill="none" stroke="url(#fallg)" stroke-width="10" stroke-linecap="round" stroke-dasharray="20 18" />
        </svg>
        <div id="h0-plane" class="plane" style="left: 940px; top: 1240px">__PLANE__</div>
        <div class="abs center" style="left: 0; right: 0; top: 560px">
          <div id="h0-l1" style="font: 800 58px var(--font-body); letter-spacing: 0.16em">PERNAH RASA HIDUP</div>
          <div id="h0-l2" class="h-display gold-text shadow" style="font-size: 236px; margin-top: 10px">JATUH</div>
          <div id="h0-l3" class="h-display" style="font-size: 120px; margin-top: -6px">KE BAWAH?</div>
          <div id="h0-orn" class="orn" style="margin-top: 50px"><i></i><b></b><i></i></div>
          <div id="h0-l4" style="font: 400 50px var(--font-ar); font-style: italic; color: var(--gold-hi); margin-top: 28px; font-family: AmiriLat, serif">Dengar perkongsian ini sampai habis…</div>
        </div>
      </div>

      <!-- ================= S1 TITLE + SPEAKER 3.0-7.05 ================= -->
      <div id="s1" class="clip" data-start="3" data-duration="5.48">
        <div class="abs center" style="left: 0; right: 0; top: 190px">
          <div id="s1-k" class="orn"><i></i><span class="kicker">Perkongsian Kehidupan</span><i></i></div>
          <div id="s1-t1" class="h-display" style="font-size: 88px; margin-top: 26px">Hidup Ibarat</div>
          <div id="s1-t2" class="h-display gold-text shadow" style="font-size: 108px">Kapal Terbang</div>
        </div>
        <div id="s1-arch-wrap" class="ring-wrap" style="left: 230px; top: 570px; width: 620px; height: 620px">
          <div class="ring-glow"></div>
          <div id="s1-deco" class="ring-deco"></div>
          <div class="ring-deco2"></div>
          <div class="ring"><img id="s1-img" src="assets/img/nabil_round.jpg" alt="" /></div>
        </div>
        <div id="s1-plaque" class="plaque cx" style="top: 1150px">
          <div class="nm">MUHAMMAD NABIL AHNAF</div>
          <div class="rl">Founder · Salam Automobile</div>
        </div>
        <div id="s1-plane" class="plane" style="left: -160px; top: 470px; width: 110px; height: 110px">__PLANE__</div>
      </div>

      <!-- ================= S2 FLIGHT PATH 7.0-11.8 ================= -->
      <div id="s2" class="clip" data-start="8.44" data-duration="3.36">
        <div class="abs center" style="left: 0; right: 0; top: 330px">
          <div id="s2-k" class="kicker">✈ Perjalanan Sebuah Kapal Terbang</div>
          <div id="s2-t" class="h-display" style="font-size: 76px; margin-top: 18px">Ada <span class="gold-text">Naik</span>, Ada <span style="color: var(--rose)">Turun</span></div>
        </div>
        <svg class="abs" style="left: 60px; top: 560px" width="960" height="680" viewBox="0 0 960 680">
          <g stroke="rgba(248,241,222,0.10)" stroke-width="2">
            <line x1="0" y1="100" x2="960" y2="100" /><line x1="0" y1="250" x2="960" y2="250" /><line x1="0" y1="400" x2="960" y2="400" /><line x1="0" y1="550" x2="960" y2="550" />
          </g>
          <g id="s2-clouds" fill="rgba(248,241,222,0.10)">
            <g transform="translate(120 160)"><circle cx="0" cy="0" r="34" /><circle cx="40" cy="-14" r="44" /><circle cx="86" cy="0" r="32" /><rect x="0" y="0" width="86" height="32" /></g>
            <g transform="translate(640 80)"><circle cx="0" cy="0" r="26" /><circle cx="32" cy="-12" r="36" /><circle cx="68" cy="0" r="26" /><rect x="0" y="0" width="68" height="26" /></g>
            <g transform="translate(720 470)"><circle cx="0" cy="0" r="30" /><circle cx="36" cy="-12" r="40" /><circle cx="76" cy="0" r="28" /><rect x="0" y="0" width="76" height="28" /></g>
          </g>
          <path id="s2-path-bg" d="M20 420 C 140 420, 200 120, 330 120 S 520 560, 660 560 S 860 300, 940 220" fill="none" stroke="rgba(226,189,91,0.18)" stroke-width="8" stroke-linecap="round" />
          <path id="s2-path" d="M20 420 C 140 420, 200 120, 330 120 S 520 560, 660 560 S 860 300, 940 220" fill="none" stroke="#e2bd5b" stroke-width="8" stroke-linecap="round" />
          <circle id="s2-pk" cx="330" cy="120" r="16" fill="#f7dc8e" />
          <circle id="s2-tr" cx="660" cy="560" r="16" fill="#e0705f" />
        </svg>
        <div id="s2-lbl-up" class="lbl" style="left: 300px; top: 590px; background: var(--gold); color: #1d1406">▲ ATAS</div>
        <div id="s2-lbl-dn" class="lbl" style="left: 600px; top: 1180px; background: var(--rose); color: #fff">▼ BAWAH</div>
        <div id="s2-plane" class="plane" style="left: 0; top: 0; width: 110px; height: 110px">__PLANE_R__</div>
      </div>

      <!-- ================= S3 ALTIMETER 11.75-20.3 ================= -->
      <div id="s3" class="clip" data-start="11.75" data-duration="8.55">
        <div class="abs center" style="left: 0; right: 0; top: 330px">
          <div id="s3-k" class="kicker">Sama Juga Kehidupan Kita</div>
          <div id="s3-t" class="h-display" style="font-size: 72px; margin-top: 18px">Altitud <span class="gold-text">Kehidupan</span></div>
        </div>
        <div id="s3-gauge" class="abs" style="left: 110px; top: 540px; width: 150px; height: 700px">
          <div class="abs" style="left: 55px; top: 0; width: 40px; height: 700px; border-radius: 20px; background: linear-gradient(180deg, rgba(226,189,91,0.85), rgba(71,194,168,0.35) 55%, rgba(224,112,95,0.85)); box-shadow: 0 0 30px rgba(226,189,91,0.25)"></div>
          __TICKS__
          <div id="s3-marker" class="abs" style="left: 22px; top: 300px; width: 106px; height: 106px">
            <div class="abs" style="inset: 0; border-radius: 50%; background: #04211b; border: 4px solid var(--gold-hi); box-shadow: 0 0 30px rgba(247,220,142,0.7)"></div>
            <div class="abs" style="left: 13px; top: 13px; width: 80px; height: 80px">__PLANE__</div>
          </div>
        </div>
        <div id="s3-top" class="card gauge-card" style="left: 320px; top: 540px; width: 660px; height: 300px; border-color: rgba(247,220,142,0.8)">
          <div style="display: flex; align-items: center; gap: 26px">
            <svg width="110" height="110" viewBox="0 0 100 100"><g fill="#f7dc8e"><rect x="22" y="22" width="56" height="56" /><rect x="22" y="22" width="56" height="56" transform="rotate(45 50 50)" /></g><circle cx="50" cy="50" r="15" fill="#04211b" /><path d="M50 40 L54 48 L62 48 L56 53 L58 61 L50 56 L42 61 L44 53 L38 48 L46 48 Z" fill="#f7dc8e" /></svg>
            <div><div class="t gold-text">PUNCAK</div><div class="t gold-text">KEJAYAAN</div></div>
          </div>
          <div class="s">Ada waktu kita di atas</div>
        </div>
        <div id="s3-bot" class="card gauge-card" style="left: 320px; top: 940px; width: 660px; height: 300px; border-color: rgba(224,112,95,0.8)">
          <div style="display: flex; align-items: center; gap: 26px">
            <svg width="110" height="110" viewBox="0 0 100 100"><circle cx="50" cy="50" r="46" fill="none" stroke="#e0705f" stroke-width="6" /><path d="M50 22 V72 M30 54 L50 74 L70 54" fill="none" stroke="#e0705f" stroke-width="9" stroke-linecap="round" stroke-linejoin="round" /></svg>
            <div><div class="t" style="color: var(--rose)">TITIK</div><div class="t" style="color: var(--rose)">TERENDAH</div></div>
          </div>
          <div class="s">Ada waktu kita di bawah</div>
        </div>
      </div>

      <!-- ================= S4 INGAT / RADAR / ALLAH 20.2-29.0 ================= -->
      <div id="s4" class="clip" data-start="20.2" data-duration="8.8">
        <div id="s4a" class="abs center" style="left: 0; right: 0; top: 520px">
          <div id="s4a-k" class="kicker" style="font-size: 40px">Tapi Kita Kena</div>
          <div id="s4a-t" class="h-display gold-text shadow" style="font-size: 170px; margin-top: 16px">INGAT</div>
          <div id="s4a-n" class="center" style="margin-top: 34px; width: 210px; height: 210px; border-radius: 50%; border: 5px solid var(--gold); box-shadow: 0 0 50px rgba(226,189,91,0.45)">
            <div style="font: 900 64px var(--font-body); line-height: 1">SATU</div>
            <div style="font: 800 34px var(--font-body); color: var(--gold); letter-spacing: 0.14em">BENDA</div>
          </div>
        </div>
        <div id="s4b" class="abs" style="left: 0; right: 0; top: 0; bottom: 0">
          <div class="abs center" style="left: 0; right: 0; top: 320px">
            <div id="s4b-k" class="kicker">Di Mana-Mana Posisi Kita</div>
            <div id="s4b-t" class="h-display" style="font-size: 68px; margin-top: 18px">Apa Pun Yang Berlaku…</div>
          </div>
          <div id="s4-radar" class="abs" style="left: 140px; top: 500px; width: 800px; height: 800px">
            <svg class="abs" style="inset: 0" width="800" height="800" viewBox="0 0 800 800">
              <g fill="none" stroke="rgba(226,189,91,0.35)" stroke-width="2">
                <circle cx="400" cy="400" r="390" /><circle cx="400" cy="400" r="295" /><circle cx="400" cy="400" r="200" /><circle cx="400" cy="400" r="105" />
                <line x1="10" y1="400" x2="790" y2="400" /><line x1="400" y1="10" x2="400" y2="790" />
              </g>
            </svg>
            <div id="s4-sweep" class="abs" style="inset: 10px; border-radius: 50%; background: conic-gradient(from 0deg, rgba(247,220,142,0.38), transparent 70deg)"></div>
            <div id="s4-p1" class="abs center" style="left: 520px; top: 120px"><div class="plane" style="position: relative; width: 70px; height: 70px">__PLANE__</div><div class="lbl" style="position: relative; font-size: 26px; background: rgba(226,189,91,0.9); color: #1d1406; padding: 6px 16px">ATAS</div></div>
            <div id="s4-p2" class="abs center" style="left: 80px; top: 280px"><div class="plane" style="position: relative; width: 70px; height: 70px; transform: rotate(-60deg)">__PLANE__</div><div class="lbl" style="position: relative; font-size: 26px; background: rgba(71,194,168,0.9); color: #04211b; padding: 6px 16px">SENANG</div></div>
            <div id="s4-p3" class="abs center" style="left: 560px; top: 520px"><div class="plane" style="position: relative; width: 70px; height: 70px; transform: rotate(140deg)">__PLANE__</div><div class="lbl" style="position: relative; font-size: 26px; background: rgba(224,112,95,0.95); color: #fff; padding: 6px 16px">SUSAH</div></div>
            <div id="s4-p4" class="abs center" style="left: 150px; top: 580px"><div class="plane" style="position: relative; width: 70px; height: 70px; transform: rotate(200deg)">__PLANE__</div><div class="lbl" style="position: relative; font-size: 26px; background: rgba(248,241,222,0.9); color: #04211b; padding: 6px 16px">BAWAH</div></div>
            <div id="s4-allah" class="abs center" style="left: 250px; top: 250px; width: 300px; height: 300px; border-radius: 50%; background: radial-gradient(circle, #0e5546, #04211b 70%); border: 4px solid var(--gold); box-shadow: 0 0 80px rgba(247,220,142,0.55)">
              <div class="gold-text" style="font: 700 170px/1 var(--font-ar); margin-top: -10px">الله</div>
            </div>
          </div>
          <div id="s4c" class="abs center" style="left: 0; right: 0; top: 330px">
            <div class="kicker">Semua Itu Telah</div>
            <div class="h-display gold-text shadow" style="font-size: 82px; margin-top: 14px">Diatur Oleh Allah</div>
          </div>
        </div>
      </div>

      <!-- ================= S5 BOARDING PASS 28.95-36.98 ================= -->
      <div id="s5" class="clip" data-start="28.95" data-duration="8.03">
        <div class="abs center" style="left: 0; right: 0; top: 320px">
          <div id="s5-k" class="kicker">Allah Dah Aturkan</div>
          <div id="s5-t" class="h-display" style="font-size: 78px; margin-top: 16px"><span class="gold-text">Takdir</span> Untuk Kita</div>
        </div>
        <div id="s5-ticket" class="ticket">
          <div class="top">
            <div style="font: 900 40px var(--font-body); letter-spacing: 0.12em">✈ BOARDING PASS</div>
            <div style="font: 700 26px var(--font-body); letter-spacing: 0.2em; color: rgba(247,220,142,0.75)">PERJALANAN HIDUP</div>
          </div>
          <div id="s5-r1" class="row" style="top: 180px"><div><div class="k">DIATUR OLEH</div><div class="v">ALLAH SWT</div></div><div style="font: 700 64px var(--font-ar); color: #0b4a3c">الله</div></div>
          <div id="s5-r2" class="row" style="top: 330px"><div><div class="k">PELAN PERJALANAN</div><div class="v">TAKDIR</div></div><div style="font: 700 54px var(--font-ar); color: #0b4a3c">قَدَر</div></div>
          <div id="s5-r3" class="row" style="top: 480px; border-bottom: none; right: 330px"><div><div class="k">STATUS</div><div class="v" style="color: #b8452f">YANG TERBAIK</div><div class="v" style="font-size: 36px; color: #6b7d75">UNTUK KITA</div></div></div>
          <div id="s5-stamp" class="stamp">✓<br />TERBAIK</div>
          <div class="abs" style="left: -26px; top: 106px; width: 52px; height: 52px; border-radius: 50%; background: #062c24"></div>
          <div class="abs" style="right: -26px; top: 106px; width: 52px; height: 52px; border-radius: 50%; background: #062c24"></div>
        </div>
        <div class="abs" style="left: 0; right: 0; top: 1200px; display: flex; justify-content: center; gap: 22px">
          <div id="s5-c1" class="chip" style="background: rgba(248,241,222,0.12); border: 2px solid rgba(226,189,91,0.6); font-size: 30px">◉ TANPA KITA SEDAR</div>
          <div id="s5-c2" class="chip" style="background: rgba(248,241,222,0.12); border: 2px solid rgba(226,189,91,0.6); font-size: 30px">◉ TANPA KITA TAHU</div>
        </div>
      </div>

      <!-- ================= S6 TANGGUNGJAWAB 36.9-44.35 ================= -->
      <div id="s6" class="clip" data-start="36.9" data-duration="7.45">
        <div class="abs center" style="left: 0; right: 0; top: 320px">
          <div id="s6-k" class="kicker">2 Tanggungjawab Kita</div>
          <div id="s6-t" class="h-display" style="font-size: 76px; margin-top: 16px">Redha <span class="gold-text">&amp;</span> Syukur</div>
        </div>
        <div id="s6-c1" class="card duty" style="left: 90px; top: 520px; width: 900px; height: 340px">
          <div class="abs" style="left: 40px; top: 30px"><div class="num gold-text">01</div></div>
          <div class="abs ar gold-text" style="right: 46px; top: 22px">رِضَا</div>
          <div class="abs" style="left: 40px; top: 150px"><div class="t">REDHA</div><div class="s" style="margin-top: 6px">atas setiap yang berlaku dalam hidup</div></div>
        </div>
        <div id="s6-c2" class="card duty" style="left: 90px; top: 900px; width: 900px; height: 340px">
          <div class="abs" style="left: 40px; top: 30px"><div class="num gold-text">02</div></div>
          <div class="abs ar gold-text" style="right: 46px; top: 22px">شُكْر</div>
          <div class="abs" style="left: 40px; top: 150px"><div class="t">SYUKUR</div><div class="s" style="margin-top: 6px">atas setiap nikmat yang Allah beri</div></div>
        </div>
      </div>

      <!-- ================= S7 SYUKUR = SIKAP 44.3-54.8 ================= -->
      <div id="s7" class="clip" data-start="44.3" data-duration="10.5">
        <div id="s7a" class="abs center" style="left: 0; right: 0; top: 600px">
          <div class="h-display gold-text shadow" style="font-size: 200px">INGAT!</div>
          <div class="kicker" style="margin-top: 20px; font-size: 38px">Satu Benda Tentang Syukur</div>
        </div>
        <div id="s7b" class="abs" style="left: 0; right: 0; top: 0; bottom: 0">
          <div class="abs center" style="left: 0; right: 0; top: 320px">
            <div id="s7-k" class="kicker">Hakikat Syukur</div>
            <div id="s7-t" class="h-display" style="font-size: 80px; margin-top: 16px">Syukur Itu <span class="gold-text">Apa?</span></div>
          </div>
          <div id="s7-r1" class="card cmp" style="left: 90px; top: 520px; width: 900px; height: 280px; display: flex; align-items: center; gap: 34px; border-color: rgba(224,112,95,0.75)">
            <div class="ic" style="background: rgba(224,112,95,0.18); border: 4px solid var(--rose)"><svg width="56" height="56" viewBox="0 0 56 56"><path d="M10 10 L46 46 M46 10 L10 46" stroke="#e0705f" stroke-width="9" stroke-linecap="round" /></svg></div>
            <div class="tx"><b style="color: var(--rose); font-size: 46px">BUKAN</b><br />atas dasar <span id="s7-strike" style="position: relative; white-space: nowrap">apa yang kita ada<i id="s7-line" style="position: absolute; left: -4px; right: -4px; top: 52%; height: 6px; background: var(--rose); border-radius: 3px; transform-origin: left center"></i></span></div>
          </div>
          <div id="s7-r2" class="card cmp" style="left: 90px; top: 840px; width: 900px; height: 300px; display: flex; align-items: center; gap: 34px; border-color: rgba(247,220,142,0.95); background: linear-gradient(160deg, rgba(226,189,91,0.22), rgba(226,189,91,0.05))">
            <div class="ic" style="background: rgba(226,189,91,0.2); border: 4px solid var(--gold-hi)"><svg width="60" height="60" viewBox="0 0 60 60"><path d="M10 31 L25 46 L51 14" fill="none" stroke="#f7dc8e" stroke-width="9" stroke-linecap="round" stroke-linejoin="round" /></svg></div>
            <div class="tx"><b class="gold-text" style="font-size: 46px">TAPI</b><br />adalah <b id="s7-sikap" class="gold-text" style="font-size: 56px; display: inline-block">SIKAP KITA</b><br />dengan apa yang kita ada</div>
          </div>
          <div id="s7-eq" class="abs center" style="left: 0; right: 0; top: 1170px">
            <div class="chip" style="background: var(--gold); color: #1d1406; font-size: 36px">SYUKUR = SIKAP, BUKAN MILIKAN</div>
          </div>
        </div>
      </div>

      <!-- ================= S8 JANGAN PUTUS ASA 54.75-59.5 ================= -->
      <div id="s8" class="clip" data-start="54.75" data-duration="4.75">
        <div id="s8-k" class="abs center" style="left: 0; right: 0; top: 400px"><div class="orn"><i></i><span class="kicker" style="font-size: 38px">Oleh Itu, Sekali Lagi</span><i></i></div></div>
        <div class="abs center" style="left: 0; right: 0; top: 560px">
          <div id="s8-l1" class="h-display" style="font-size: 96px">Jangan Pernah</div>
          <div id="s8-l2" class="h-display gold-text shadow" style="font-size: 150px; margin-top: 8px">Putus Asa</div>
          <div id="s8-l3" class="h-display" style="font-size: 96px; margin-top: 8px">Dengan Allah</div>
        </div>
        <svg class="abs" style="left: 0; top: 0" width="1080" height="1920" viewBox="0 0 1080 1920">
          <path id="s8-trail" d="M-40 1260 C 300 1220, 640 1080, 1120 760" fill="none" stroke="rgba(247,220,142,0.55)" stroke-width="6" stroke-dasharray="16 14" stroke-linecap="round" />
        </svg>
        <div id="s8-plane" class="plane" style="left: 0; top: 0; width: 120px; height: 120px">__PLANE_R__</div>
      </div>

      <!-- ================= S9 AYAH 59.45-63.3 ================= -->
      <div id="s9" class="clip" data-start="59.45" data-duration="3.85">
        <div class="abs center" style="left: 0; right: 0; top: 380px">
          <div id="s9-k" class="orn"><i></i><b></b><i></i></div>
          <div id="s9-ar" class="ayah gold-text shadow" style="margin-top: 40px">لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ</div>
          <div id="s9-tr" style="font: 400 54px/1.35 AmiriLat, serif; font-style: italic; margin-top: 30px; padding: 0 110px">“Janganlah kamu berputus asa daripada rahmat Allah.”</div>
          <div id="s9-src" class="kicker" style="margin-top: 30px; font-size: 28px">Surah Az-Zumar · Ayat 53</div>
        </div>
      </div>

      <!-- ================= S10 OUTRO 63.2-68.5 ================= -->
      <div id="s10" class="clip" data-start="63.2" data-duration="5.3">
        <div class="abs center" style="left: 0; right: 0; top: 190px">
          <div id="o-k" class="orn"><i></i><span class="kicker">Semoga Bermanfaat</span><i></i></div>
        </div>
        <div id="o-arch" class="ring-wrap" style="left: 270px; top: 320px; width: 540px; height: 540px">
          <div class="ring-glow"></div>
          <div id="o-deco" class="ring-deco"></div>
          <div class="ring-deco2"></div>
          <div class="ring"><img src="assets/img/nabil_round.jpg" alt="" /></div>
        </div>
        <div id="o-plaque" class="plaque cx" style="top: 830px">
          <div class="nm">MUHAMMAD NABIL AHNAF</div>
          <div class="rl">Founder · Salam Automobile</div>
        </div>
        <div id="o-msg" class="abs center" style="left: 0; right: 0; top: 1030px">
          <div style="font: 400 52px/1.3 AmiriLat, serif; font-style: italic; color: var(--ink)">Sebarkan kebaikan,<br /><span style="color: var(--gold-hi)">moga jadi saham akhirat.</span></div>
        </div>
        <div class="abs" style="left: 0; right: 0; top: 1250px; display: flex; justify-content: center; gap: 20px">
          <div id="o-c1" class="chip" style="background: rgba(248,241,222,0.12); border: 2px solid rgba(226,189,91,0.6)">♥ LIKE</div>
          <div id="o-c2" class="chip" style="background: rgba(248,241,222,0.12); border: 2px solid rgba(226,189,91,0.6)">↗ KONGSI</div>
          <div id="o-c3" class="chip" style="background: var(--gold); color: #1d1406">＋ FOLLOW</div>
        </div>
      </div>

      <!-- ================= OVERLAYS ================= -->
      <div id="ov-badge" class="clip" data-start="8.44" data-duration="51.06">
        <div id="badge">
          <div class="mini-arch"><img src="assets/img/nabil_round.jpg" alt="" /></div>
          <div><div class="nm">MUHAMMAD NABIL AHNAF</div><div class="rl">Founder · Salam Automobile</div></div>
        </div>
      </div>
      <div id="ov-caps" class="clip" data-start="3" data-duration="59.3">
        <div id="caps"></div>
      </div>
      <div id="ov-fade" class="clip" data-start="0" data-duration="68.5" style="background: #000; opacity: 0; pointer-events: none"></div>
    </div>

    <script>
      gsap.registerPlugin(MotionPathPlugin);
      const CAPS = __CAPS__;
      gsap.defaults({ lazy: false });
      const tl = gsap.timeline({ paused: true });
      const E = "power3.out";
      // seek-safe exit: explicit start state, no lazy start-value capture
      const BASE = { opacity: 1, y: 0, scale: 1, filter: "blur(0px)" };
      const out = (sel, vars, t) => {
        const from = {};
        Object.keys(BASE).forEach((k) => { if (k in vars) from[k] = BASE[k]; });
        return tl.fromTo(sel, from, Object.assign({ immediateRender: false }, vars), t);
      };

      // deterministic pseudo-random
      let seed = 1337;
      const rnd = () => ((seed = (seed * 16807) % 2147483647) / 2147483647);

      /* ---------------- background ---------------- */
      tl.fromTo("#pattern", { rotation: 0, scale: 1 }, { rotation: 12, scale: 1.12, duration: 68.5, ease: "none" }, 0);
      tl.fromTo("#rays", { rotation: 0 }, { rotation: 40, duration: 68.5, ease: "none" }, 0);
      tl.fromTo("#glow", { scale: 0.9, opacity: 0.7 }, { scale: 1.15, opacity: 1, duration: 4, ease: "sine.inOut", repeat: 16, yoyo: true }, 0);
      const dots = document.getElementById("dots");
      for (let i = 0; i < 42; i++) {
        const d = document.createElement("div");
        d.className = "dot";
        const sz = 3 + rnd() * 6;
        d.style.width = d.style.height = sz + "px";
        d.style.left = 60 + rnd() * 960 + "px";
        d.style.top = 0 + "px";
        dots.appendChild(d);
        const y0 = 1950 + rnd() * 200, y1 = -100 - rnd() * 300;
        const dur = 14 + rnd() * 14, off = -rnd() * dur;
        tl.fromTo(d, { y: y0, opacity: 0.25 + rnd() * 0.5 }, { y: y1, duration: dur, ease: "none", repeat: Math.ceil(70 / dur) + 1 }, off);
      }

      /* ---------------- S0 HOOK ---------------- */
      tl.fromTo("#fallpath", { strokeDashoffset: 0, opacity: 0 }, { opacity: 1, duration: 0.3 }, 0.05);
      tl.fromTo("#fallpath", { attr: { "stroke-dasharray": "0 2000" } }, { attr: { "stroke-dasharray": "1400 0" }, duration: 1.2, ease: "power2.in" }, 0.1);
      tl.fromTo("#h0-plane", { x: -880, y: -720, rotation: 130, opacity: 0 }, { x: 0, y: 0, rotation: 135, opacity: 1, duration: 1.2, ease: "power2.in" }, 0.1);
      tl.to("#h0-plane", { x: "+=8", yoyo: true, repeat: 7, duration: 0.05 }, 1.3);
      tl.fromTo("#h0-l1", { y: -40, opacity: 0, scale: 1.3 }, { y: 0, opacity: 1, scale: 1, duration: 0.45, ease: E }, 0.05);
      tl.fromTo("#h0-l2", { y: -380, scale: 1.4, opacity: 0 }, { y: 0, scale: 1, opacity: 1, duration: 0.42, ease: "bounce.out" }, 0.3);
      tl.to("#s0", { x: 14, yoyo: true, repeat: 5, duration: 0.04, ease: "none" }, 0.62);
      tl.set("#s0", { x: 0 }, 0.86);
      tl.fromTo("#h0-l3", { y: 60, opacity: 0, filter: "blur(10px)" }, { y: 0, opacity: 1, filter: "blur(0px)", duration: 0.4, ease: E }, 1.05);
      tl.fromTo("#h0-orn", { scaleX: 0, opacity: 0 }, { scaleX: 1, opacity: 1, duration: 0.5, ease: E }, 1.65);
      tl.fromTo("#h0-l4", { y: 30, opacity: 0 }, { y: 0, opacity: 1, duration: 0.5, ease: E }, 1.75);
      out("#s0 > div, #h0-plane", { scale: 1.25, opacity: 0, filter: "blur(16px)", duration: 0.35, ease: "power2.in" }, 2.7);

      /* ---------------- S1 TITLE + SPEAKER ---------------- */
      tl.fromTo("#s1-k", { opacity: 0, y: -20 }, { opacity: 1, y: 0, duration: 0.5, ease: E }, 3.0);
      tl.fromTo("#s1-t1", { opacity: 0, y: 40, filter: "blur(10px)" }, { opacity: 1, y: 0, filter: "blur(0px)", duration: 0.55, ease: E }, 3.1);
      tl.fromTo("#s1-t2", { opacity: 0, scale: 0.6 }, { opacity: 1, scale: 1, duration: 0.6, ease: "back.out(1.8)" }, 5.4);
      tl.fromTo("#s1-arch-wrap", { opacity: 0, y: 120, scale: 0.9 }, { opacity: 1, y: 0, scale: 1, duration: 0.8, ease: E }, 3.2);
      tl.fromTo("#s1-img", { scale: 1.12 }, { scale: 1, duration: 3.8, ease: "power2.out" }, 3.2);
      tl.fromTo("#s1-deco", { rotation: 0 }, { rotation: 60, duration: 4, ease: "none" }, 3.0);
      tl.fromTo("#s1-plaque", { opacity: 0, y: 40, xPercent: 0 }, { opacity: 1, y: 0, duration: 0.5, ease: "back.out(1.6)" }, 3.7);
      tl.fromTo("#s1-plane", { x: 0, y: 0, rotation: 80 }, { x: 1400, y: -200, rotation: 80, duration: 1.3, ease: "power1.inOut" }, 4.9);
      out("#s1 > div:not(#s1-plane)", { opacity: 0, y: -30, duration: 0.3, ease: "power2.in" }, 8.16);

      /* ---------------- S2 FLIGHT ---------------- */
      tl.fromTo("#s2-k", { opacity: 0, y: -20 }, { opacity: 1, y: 0, duration: 0.45, ease: E }, 8.46);
      tl.fromTo("#s2-t", { opacity: 0, y: 30 }, { opacity: 1, y: 0, duration: 0.5, ease: E }, 8.56);
      const p2 = document.getElementById("s2-path");
      const L2 = p2.getTotalLength();
      tl.fromTo(p2, { strokeDasharray: L2, strokeDashoffset: L2 }, { strokeDashoffset: 0, duration: 2.75, ease: "none" }, 8.61);
      tl.fromTo("#s2-clouds", { x: 40 }, { x: -60, duration: 3.2, ease: "none" }, 8.44);
      tl.fromTo("#s2-plane", { opacity: 0 }, { opacity: 1, duration: 0.2 }, 8.61);
      tl.to("#s2-plane", { motionPath: { path: "#s2-path", align: "#s2-path", alignOrigin: [0.5, 0.5], autoRotate: true }, duration: 2.75, ease: "none", immediateRender: true }, 8.61);
      tl.fromTo(["#s2-pk", "#s2-lbl-up"], { scale: 0, opacity: 0, transformOrigin: "50% 50%" }, { scale: 1, opacity: 1, duration: 0.4, ease: "back.out(2.5)" }, 9.46);
      tl.fromTo(["#s2-tr", "#s2-lbl-dn"], { scale: 0, opacity: 0, transformOrigin: "50% 50%" }, { scale: 1, opacity: 1, duration: 0.4, ease: "back.out(2.5)" }, 10.71);
      out("#s2 > *", { opacity: 0, duration: 0.3, ease: "power2.in" }, 11.26);

      /* ---------------- S3 ALTIMETER ---------------- */
      tl.fromTo("#s3-k", { opacity: 0, y: -20 }, { opacity: 1, y: 0, duration: 0.45, ease: E }, 11.8);
      tl.fromTo("#s3-t", { opacity: 0, y: 30 }, { opacity: 1, y: 0, duration: 0.5, ease: E }, 11.9);
      tl.fromTo("#s3-gauge", { opacity: 0, scaleY: 0, transformOrigin: "50% 100%" }, { opacity: 1, scaleY: 1, duration: 0.7, ease: E }, 12.0);
      tl.fromTo("#s3-marker", { y: 0 }, { y: 290, duration: 1.1, ease: "power2.inOut" }, 13.7);
      tl.fromTo("#s3-bot", { opacity: 0, x: 120 }, { opacity: 1, x: 0, duration: 0.55, ease: E }, 14.4);
      tl.to("#s3-bot", { boxShadow: "0 0 60px rgba(224,112,95,0.45)", duration: 0.4, yoyo: true, repeat: 1 }, 15.0);
      tl.to("#s3-marker", { y: -300, duration: 1.3, ease: "power3.inOut" }, 16.9);
      tl.fromTo("#s3-top", { opacity: 0, x: 120 }, { opacity: 1, x: 0, duration: 0.55, ease: E }, 17.7);
      tl.to("#s3-top", { boxShadow: "0 0 80px rgba(247,220,142,0.55)", scale: 1.03, duration: 0.5, yoyo: true, repeat: 1 }, 18.3);
      out("#s3 > *", { opacity: 0, y: -20, duration: 0.3, ease: "power2.in" }, 20.0);

      /* ---------------- S4 ---------------- */
      tl.fromTo("#s4a-k", { opacity: 0, y: -30 }, { opacity: 1, y: 0, duration: 0.4, ease: E }, 20.25);
      tl.fromTo("#s4a-t", { opacity: 0, scale: 2.2, filter: "blur(14px)" }, { opacity: 1, scale: 1, filter: "blur(0px)", duration: 0.45, ease: "power4.out" }, 20.4);
      tl.fromTo("#s4a-n", { opacity: 0, scale: 0, rotation: -90 }, { opacity: 1, scale: 1, rotation: 0, duration: 0.5, ease: "back.out(2)" }, 21.0);
      out("#s4a", { opacity: 0, scale: 0.85, filter: "blur(10px)", duration: 0.3, ease: "power2.in" }, 21.45);
      tl.fromTo("#s4b-k", { opacity: 0, y: -20 }, { opacity: 1, y: 0, duration: 0.45, ease: E }, 21.75);
      tl.fromTo("#s4b-t", { opacity: 0, y: 30 }, { opacity: 1, y: 0, duration: 0.5, ease: E }, 24.0);
      tl.fromTo("#s4-radar", { opacity: 0, scale: 0.6, rotation: -30 }, { opacity: 1, scale: 1, rotation: 0, duration: 0.8, ease: E }, 21.75);
      tl.fromTo("#s4-sweep", { rotation: 0 }, { rotation: 1080, duration: 7, ease: "none" }, 21.75);
      ["#s4-p1", "#s4-p2", "#s4-p3", "#s4-p4"].forEach((id, i) => {
        tl.fromTo(id, { opacity: 0, scale: 0 }, { opacity: 1, scale: 1, duration: 0.4, ease: "back.out(2.4)" }, 22.2 + i * 0.55);
        tl.to(id, { y: i % 2 ? 14 : -14, duration: 1.2, yoyo: true, repeat: 2, ease: "sine.inOut" }, 22.8 + i * 0.3);
      });
      tl.fromTo("#s4-allah", { opacity: 0, scale: 0 }, { opacity: 1, scale: 1, duration: 0.7, ease: "back.out(1.7)" }, 25.9);
      tl.to(["#s4-p1", "#s4-p2", "#s4-p3", "#s4-p4"], { x: (i) => [-120, 170, -160, 150][i], y: (i) => [130, 120, -120, -150][i], scale: 0.6, opacity: 0.3, duration: 1.0, ease: "power2.inOut" }, 26.2);
      out(["#s4b-k", "#s4b-t"], { opacity: 0, y: -20, duration: 0.3 }, 25.8);
      tl.fromTo("#s4c", { opacity: 0, y: 30 }, { opacity: 1, y: 0, duration: 0.5, ease: E }, 26.1);
      tl.to("#s4-allah", { boxShadow: "0 0 140px rgba(247,220,142,0.9)", scale: 1.08, duration: 0.8, yoyo: true, repeat: 1, ease: "sine.inOut" }, 27.0);
      out("#s4b", { opacity: 0, scale: 1.08, filter: "blur(10px)", duration: 0.3, ease: "power2.in" }, 28.7);

      /* ---------------- S5 BOARDING PASS ---------------- */
      tl.fromTo("#s5-k", { opacity: 0, y: -20 }, { opacity: 1, y: 0, duration: 0.45, ease: E }, 29.0);
      tl.fromTo("#s5-t", { opacity: 0, y: 30 }, { opacity: 1, y: 0, duration: 0.5, ease: E }, 29.1);
      tl.fromTo("#s5-ticket", { opacity: 0, y: 260, rotation: -6 }, { opacity: 1, y: 0, rotation: 0, duration: 0.7, ease: "back.out(1.3)" }, 29.2);
      tl.fromTo("#s5-r1", { opacity: 0, x: -60 }, { opacity: 1, x: 0, duration: 0.4, ease: E }, 29.6);
      tl.fromTo("#s5-r2", { opacity: 0, x: -60 }, { opacity: 1, x: 0, duration: 0.4, ease: E }, 30.8);
      tl.fromTo("#s5-r3", { opacity: 0, x: -60 }, { opacity: 1, x: 0, duration: 0.4, ease: E }, 32.5);
      tl.fromTo("#s5-stamp", { opacity: 0, scale: 2.6, rotation: -30 }, { opacity: 0.92, scale: 1, rotation: -14, duration: 0.3, ease: "power4.in" }, 32.9);
      tl.fromTo("#s5-ticket", { y: 0 }, { y: 10, duration: 0.06, yoyo: true, repeat: 1, immediateRender: false }, 33.2);
      tl.fromTo("#s5-c1", { opacity: 0, y: 40 }, { opacity: 1, y: 0, duration: 0.4, ease: "back.out(2)" }, 34.2);
      tl.fromTo("#s5-c2", { opacity: 0, y: 40 }, { opacity: 1, y: 0, duration: 0.4, ease: "back.out(2)" }, 35.4);
      out("#s5 > *", { opacity: 0, y: -24, duration: 0.3, ease: "power2.in" }, 36.65);

      /* ---------------- S6 DUTIES ---------------- */
      tl.fromTo("#s6-k", { opacity: 0, y: -20 }, { opacity: 1, y: 0, duration: 0.45, ease: E }, 36.95);
      tl.fromTo("#s6-t", { opacity: 0, y: 30 }, { opacity: 1, y: 0, duration: 0.5, ease: E }, 37.05);
      tl.fromTo("#s6-c1", { opacity: 0, x: -140 }, { opacity: 1, x: 0, duration: 0.6, ease: E }, 37.7);
      tl.fromTo("#s6-c1 .ar", { opacity: 0, scale: 0.4 }, { opacity: 1, scale: 1, duration: 0.6, ease: "back.out(2)" }, 38.0);
      tl.fromTo("#s6-c2", { opacity: 0, x: 140 }, { opacity: 1, x: 0, duration: 0.6, ease: E }, 40.9);
      tl.fromTo("#s6-c2 .ar", { opacity: 0, scale: 0.4 }, { opacity: 1, scale: 1, duration: 0.6, ease: "back.out(2)" }, 41.2);
      tl.to("#s6-c1", { borderColor: "rgba(247,220,142,1)", boxShadow: "0 0 60px rgba(247,220,142,0.35)", duration: 0.5, yoyo: true, repeat: 1 }, 38.4);
      tl.to("#s6-c2", { borderColor: "rgba(247,220,142,1)", boxShadow: "0 0 60px rgba(247,220,142,0.35)", duration: 0.5, yoyo: true, repeat: 1 }, 41.7);
      out("#s6 > *", { opacity: 0, y: -24, duration: 0.3, ease: "power2.in" }, 44.05);

      /* ---------------- S7 SYUKUR ---------------- */
      tl.fromTo("#s7a", { opacity: 0, scale: 2, filter: "blur(14px)" }, { opacity: 1, scale: 1, filter: "blur(0px)", duration: 0.4, ease: "power4.out" }, 44.35);
      out("#s7a", { opacity: 0, scale: 0.85, duration: 0.3, ease: "power2.in" }, 45.8);
      tl.fromTo("#s7-k", { opacity: 0, y: -20 }, { opacity: 1, y: 0, duration: 0.45, ease: E }, 46.1);
      tl.fromTo("#s7-t", { opacity: 0, y: 30 }, { opacity: 1, y: 0, duration: 0.5, ease: E }, 46.15);
      tl.fromTo("#s7-r1", { opacity: 0, y: 80 }, { opacity: 1, y: 0, duration: 0.55, ease: E }, 46.6);
      tl.fromTo("#s7-line", { scaleX: 0 }, { scaleX: 1, duration: 0.4, ease: "power2.inOut" }, 49.2);
      tl.to("#s7-r1", { opacity: 0.55, scale: 0.97, duration: 0.5 }, 50.2);
      tl.fromTo("#s7-r2", { opacity: 0, y: 80 }, { opacity: 1, y: 0, duration: 0.55, ease: E }, 50.3);
      tl.fromTo("#s7-sikap", { scale: 1 }, { scale: 1.15, duration: 0.35, yoyo: true, repeat: 1, ease: "sine.inOut" }, 52.4);
      tl.fromTo("#s7-eq", { opacity: 0, scale: 0.6 }, { opacity: 1, scale: 1, duration: 0.5, ease: "back.out(2)" }, 52.9);
      out("#s7b", { opacity: 0, y: -24, duration: 0.3, ease: "power2.in" }, 54.5);

      /* ---------------- S8 PUTUS ASA ---------------- */
      tl.fromTo("#s8-k", { opacity: 0, y: -20 }, { opacity: 1, y: 0, duration: 0.5, ease: E }, 54.8);
      tl.fromTo("#s8-l1", { opacity: 0, y: 40 }, { opacity: 1, y: 0, duration: 0.45, ease: E }, 57.1);
      tl.fromTo("#s8-l2", { opacity: 0, scale: 1.8, filter: "blur(14px)" }, { opacity: 1, scale: 1, filter: "blur(0px)", duration: 0.45, ease: "power4.out" }, 57.5);
      tl.fromTo("#s8-l3", { opacity: 0, y: 40 }, { opacity: 1, y: 0, duration: 0.45, ease: E }, 58.2);
      const p8 = document.getElementById("s8-trail");
      const L8 = p8.getTotalLength();
      tl.fromTo(p8, { strokeDashoffset: L8, strokeDasharray: "16 14" }, { strokeDashoffset: 0, duration: 4.0, ease: "power1.inOut" }, 55.2);
      tl.fromTo("#s8-plane", { opacity: 0 }, { opacity: 1, duration: 0.3 }, 55.2);
      tl.to("#s8-plane", { motionPath: { path: "#s8-trail", align: "#s8-trail", alignOrigin: [0.5, 0.5], autoRotate: true }, duration: 4.0, ease: "power1.inOut", immediateRender: true }, 55.2);
      out("#s8 > div", { opacity: 0, scale: 1.1, filter: "blur(10px)", duration: 0.3, ease: "power2.in" }, 59.2);
      tl.to("#rays", { opacity: 0.85, duration: 1.2, ease: "sine.inOut" }, 58.8);
      tl.to("#rays", { opacity: 0.35, duration: 1.5, ease: "sine.inOut" }, 64);

      /* ---------------- S9 AYAH ---------------- */
      tl.fromTo("#s9-k", { opacity: 0, scaleX: 0 }, { opacity: 1, scaleX: 1, duration: 0.5, ease: E }, 59.5);
      tl.fromTo("#s9-ar", { opacity: 0, y: 30, filter: "blur(12px)" }, { opacity: 1, y: 0, filter: "blur(0px)", duration: 0.9, ease: E }, 59.55);
      tl.fromTo("#s9-tr", { opacity: 0, y: 30 }, { opacity: 1, y: 0, duration: 0.6, ease: E }, 60.4);
      tl.fromTo("#s9-src", { opacity: 0 }, { opacity: 1, duration: 0.5 }, 61.0);
      out("#s9 > div", { opacity: 0, y: -30, duration: 0.35, ease: "power2.in" }, 62.95);

      /* ---------------- S10 OUTRO ---------------- */
      tl.fromTo("#o-k", { opacity: 0, y: -20 }, { opacity: 1, y: 0, duration: 0.5, ease: E }, 63.3);
      tl.fromTo("#o-deco", { rotation: 0 }, { rotation: 60, duration: 5.3, ease: "none" }, 63.2);
      tl.fromTo("#o-arch", { opacity: 0, y: 100, scale: 0.9 }, { opacity: 1, y: 0, scale: 1, duration: 0.8, ease: E }, 63.3);
      tl.fromTo("#o-plaque", { opacity: 0, y: 40 }, { opacity: 1, y: 0, duration: 0.5, ease: "back.out(1.6)" }, 63.8);
      tl.fromTo("#o-msg", { opacity: 0, y: 30 }, { opacity: 1, y: 0, duration: 0.6, ease: E }, 64.3);
      ["#o-c1", "#o-c2", "#o-c3"].forEach((id, i) => tl.fromTo(id, { opacity: 0, y: 40, scale: 0.8 }, { opacity: 1, y: 0, scale: 1, duration: 0.4, ease: "back.out(2.2)" }, 65.0 + i * 0.18));
      tl.to("#o-c3", { scale: 1.08, duration: 0.4, yoyo: true, repeat: 3, ease: "sine.inOut" }, 65.8);
      tl.to("#ov-fade", { opacity: 1, duration: 1.0, ease: "power1.in" }, 67.5);

      /* ---------------- BADGE ---------------- */
      tl.fromTo("#badge", { opacity: 0, y: -40 }, { opacity: 1, y: 0, duration: 0.5, ease: E }, 8.5);
      out("#badge", { opacity: 0, y: -30, duration: 0.35 }, 59.1);

      /* ---------------- CAPTIONS ---------------- */
      const capWrap = document.getElementById("caps");
      CAPS.forEach((c) => {
        const line = document.createElement("div");
        line.className = "cap";
        const spans = c.w.map((w) => {
          const s = document.createElement("span");
          s.className = "w";
          s.textContent = w[0];
          line.appendChild(s);
          return s;
        });
        capWrap.appendChild(line);
        tl.set(line, { autoAlpha: 1 }, c.s - 0.04);
        tl.fromTo(line, { scale: 0.9, y: 16 }, { scale: 1, y: 0, duration: 0.2, ease: "back.out(2.2)" }, c.s - 0.04);
        c.w.forEach((w, i) => {
          const s = spans[i];
          const col = w[3] ? "#f7dc8e" : "#f8f1de";
          tl.to(s, { opacity: 1, color: col, scale: 1.06, duration: 0.08, ease: "power2.out" }, w[1]);
          tl.to(s, { scale: 1, duration: 0.15, ease: "power2.out" }, Math.max(w[1] + 0.09, w[2] - 0.05));
        });
        tl.set(line, { autoAlpha: 0 }, c.e - 0.03);
      });

      window.__timelines = window.__timelines || {};
      window.__timelines["main"] = tl;
      tl.seek(0);
    </script>
  </body>
</html>
