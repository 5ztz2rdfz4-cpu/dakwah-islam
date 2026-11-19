import numpy as np, soundfile as sf, json, sys
from scipy.signal import fftconvolve, butter, sosfilt
W=sys.argv[1]; OUT=sys.argv[2]
SR=48000; rng=np.random.default_rng(7)
v,_=sf.read(f'{W}/vclean.wav')
SEGS=[(0.00,5.10),(10.86,19.06),(19.66,28.30),(28.66,37.95),(38.30,49.14),(58.72,63.10),(66.18,67.95)]
O=0.60; GAP=0.12
TOTAL=55.0
N=int(TOTAL*SR)
dry=np.zeros(N); t=O; mp=[]
for a,b in SEGS:
    s=v[int(a*SR):int(b*SR)].copy(); f=int(0.015*SR)
    s[:f]*=np.linspace(0,1,f); s[-f:]*=np.linspace(1,0,f)
    i=int(t*SR); dry[i:i+len(s)]+=s; mp.append([a,b,round(t,3)]); t+=(b-a)+GAP
vend=t-GAP
json.dump({'segs':mp,'voice_end':round(vend,3)},open(f'{OUT}/map.json','w'))
print('voice end',vend)
# --- masjid reverb IR (stereo, RT60 ~2.0s, predelay 28ms, early reflections)
def ir(seed):
    r=np.random.default_rng(seed); L=int(2.4*SR); tt=np.arange(L)/SR
    n=r.standard_normal(L)*np.exp(-6.9*tt/2.0)
    n=sosfilt(butter(2,[180,5200],'band',fs=SR,output='sos'),n)
    # darker tail
    lp=sosfilt(butter(1,2500,'low',fs=SR,output='sos'),n); mix=np.clip(tt/1.2,0,1); n=n*(1-mix)+lp*mix
    pre=int(0.028*SR); h=np.zeros(L+pre); h[pre:]=n
    for d,g in [(0.011,.5),(0.019,.38),(0.031,.33),(0.047,.25),(0.063,.2),(0.081,.15)]:
        h[int((d+r.uniform(-.003,.003))*SR)]+=g*r.choice([-1,1])
    return h/np.sqrt(np.sum(h**2))
wl=fftconvolve(dry,ir(1))[:N]; wr=fftconvolve(dry,ir(2))[:N]
# slap echo (masjid PA feel)
def delay(x,d,g): y=np.zeros_like(x); k=int(d*SR); y[k:]=x[:-k]*g; return y
voiceL=dry+0.30*wl+delay(dry,0.115,0.10); voiceR=dry+0.30*wr+delay(dry,0.128,0.10)
voice=np.stack([voiceL,voiceR],1)
voice/=np.max(np.abs(voice))/0.8
# --- BGM: ambient pad (Hijaz-flavoured D), soft & non-percussive
tt=np.arange(N)/SR
def note(m): return 440*2**((m-69)/12)
def pad(freqs,start,dur,amp):
    y=np.zeros(N); i0=int(start*SR); L=min(int(dur*SR),N-i0); x=np.arange(L)/SR
    env=np.minimum(1,x/2.5)*np.minimum(1,(dur-x)/2.5)
    for f in freqs:
        for det in (-0.12,0,0.12):
            ph=rng.uniform(0,6.28)
            y[i0:i0+L]+=amp*env*(np.sin(2*np.pi*f*(1+det/100)*x+ph)+0.25*np.sin(4*np.pi*f*(1+det/100)*x+ph))
    return y
bgm=np.zeros(N)
bgm+=0.05*np.sin(2*np.pi*note(38)*tt)*(0.8+0.2*np.sin(2*np.pi*0.07*tt))   # D drone
bgm+=0.03*np.sin(2*np.pi*note(45)*tt)
chords=[[62,66,69],[63,67,70],[62,66,69],[60,63,67],[62,65,69],[63,67,70],[62,66,69],[67,70,74],[62,66,69],[60,63,67],[62,66,69],[62,66,69]]
for k,c in enumerate(chords):
    bgm+=pad([note(m) for m in c],k*4.6,6.2,0.018)
# sparse shimmer bells (Hijaz scale)
scale=[74,75,78,79,81,82,84,86]
for k in range(26):
    st=1.0+k*2.1+rng.uniform(0,.4); f=note(scale[rng.integers(len(scale))]); i0=int(st*SR); L=int(2.5*SR)
    if i0+L>N: break
    x=np.arange(L)/SR; bgm[i0:i0+L]+=0.012*np.exp(-x*1.8)*(np.sin(2*np.pi*f*x)+0.3*np.sin(2*np.pi*f*2.01*x))
bgm=sosfilt(butter(2,6000,'low',fs=SR,output='sos'),bgm)
bL=bgm; bR=np.roll(bgm,int(0.013*SR))
B=np.stack([bL,bR],1)
B=B+0.35*np.stack([fftconvolve(bgm,ir(3))[:N],fftconvolve(bgm,ir(4))[:N]],1)
B/=np.max(np.abs(B))
# ducking from voice envelope
envv=np.abs(dry); k=int(0.25*SR); envv=np.convolve(envv,np.ones(k)/k,'same')
duck=np.where(envv>0.01,0.45,1.0); duck=np.convolve(duck,np.ones(int(0.4*SR))/int(0.4*SR),'same')
bgm_gain=0.20*duck
# fade bgm in/out
fi=np.minimum(1,tt/1.5); fo=np.clip((TOTAL-tt)/2.5,0,1)
B=B*(bgm_gain*fi*fo)[:,None]
# outro lift: bring bgm up after voice
B*= (1+0.6*np.clip((tt-vend-0.3)/1.0,0,1))[:,None]
# --- SFX
sfx=np.zeros((N,2))
def put(sig,at,g=1.0,pan=0.0):
    i=int(at*SR); L=min(len(sig),N-i)
    if L<=0: return
    sfx[i:i+L,0]+=sig[:L]*g*(1-max(0,pan)); sfx[i:i+L,1]+=sig[:L]*g*(1+min(0,pan))
def whoosh(d=0.7,up=True):
    L=int(d*SR); x=np.arange(L)/SR; n=rng.standard_normal(L)
    out=np.zeros(L); fs=np.linspace(300,4000,24) if up else np.linspace(4000,300,24)
    seg=L//24
    for j,f in enumerate(fs):
        sos=butter(2,[f*0.7,f*1.3],'band',fs=SR,output='sos'); out[j*seg:(j+1)*seg]=sosfilt(sos,n[j*seg:(j+1)*seg])
    env=np.sin(np.pi*x/d)**2
    return 0.6*out*env/np.max(np.abs(out*env)+1e-9)
def impact():
    L=int(1.6*SR); x=np.arange(L)/SR
    f=55*np.exp(-x*1.5)+32; ph=2*np.pi*np.cumsum(f)/SR
    s=np.sin(ph)*np.exp(-x*2.6)
    n=sosfilt(butter(2,1800,'low',fs=SR,output='sos'),rng.standard_normal(L))*np.exp(-x*14)*0.5
    s=s+n; s=fftconvolve(s,ir(5)[:SR])[:L]*0.25+s
    return 0.9*s/np.max(np.abs(s))
def chime(base=1318.5):
    L=int(2.2*SR); x=np.arange(L)/SR; s=np.zeros(L)
    for m,a in [(1,1),(2.76,.4),(5.4,.2),(1.5,.5)]: s+=a*np.sin(2*np.pi*base*m*x)*np.exp(-x*(2.5+m))
    s=s+0.4*fftconvolve(s,ir(6))[:L]
    return 0.5*s/np.max(np.abs(s))
def tick(f=1500):
    L=int(0.09*SR); x=np.arange(L)/SR; return 0.5*np.sin(2*np.pi*f*x)*np.exp(-x*55)
def riser(d=1.6):
    L=int(d*SR); x=np.arange(L)/SR; n=rng.standard_normal(L); out=np.zeros(L); seg=L//20
    for j,f in enumerate(np.geomspace(200,6000,20)):
        out[j*seg:(j+1)*seg]=sosfilt(butter(2,[f*.8,f*1.2],'band',fs=SR,output='sos'),n[j*seg:(j+1)*seg])
    s=out*(x/d)**2; return 0.5*s/np.max(np.abs(s))
cues=json.load(open(f'{OUT}/sfx_cues.json'))
lib={'whoosh':lambda:whoosh(),'whoosh_d':lambda:whoosh(up=False),'impact':impact,'chime':chime,'chime_lo':lambda:chime(987.8),'tick':tick,'tick_hi':lambda:tick(2100),'riser':riser}
for c in cues: put(lib[c['s']](),c['t'],c.get('g',1.0),c.get('p',0))
mix=voice*1.0+B+sfx*0.45
mix/=np.max(np.abs(mix))/0.89
sf.write(f'{OUT}/soundtrack_pre.wav',mix.astype(np.float32),SR)
