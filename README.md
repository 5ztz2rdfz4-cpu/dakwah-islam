# dakwah-islam

Video dakwah TikTok (9:16) dibina dengan [HyperFrames](https://hyperframes.heygen.com).

## Bahaya Riak — Al-Fadhil Ustaz Abd Aziz Al-Qurowy

- `output/Bahaya-Riak-Ustaz-Abd-Aziz-Al-Qurowy.mp4` — video siap (1080×1920, 30fps, ~54s)
- `video/` — projek HyperFrames (boleh disunting)
  - `index.html` — komposisi utama (latar islamik, susunan babak, audio)
  - `compositions/` — babak infografik: `hook`, `timbangan`, `takberbaloi`, `pesanan`, `faham`, `tiada`, `lillahi`, `penutup`, serta `header` dan `captions` (sari kata)
  - `assets/audio/ceramah.m4a` — audio penuh ceramah (dibersihkan & dinormalkan)
  - `assets/img/ustaz.jpg` — gambar ustaz
  - `assets/fonts/` — Amiri (tulisan Arab)

Render semula:

```bash
cd video
npx hyperframes@0.9.56 render -o ../output/Bahaya-Riak-Ustaz-Abd-Aziz-Al-Qurowy.mp4
```
