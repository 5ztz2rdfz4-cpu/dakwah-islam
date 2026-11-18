import numpy as np, wave
SR=44100
def save(name, x):
    x = np.asarray(x)
    if x.ndim==1: x=np.stack([x,x],1)
    x = x/ (np.abs(x).max()+1e-9) * 0.89
    with wave.open(name,'wb') as w:
        w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes((x*32767).astype('<i2').tobytes())
def lp(x, a):  # one-pole lowpass, a in (0,1)
    y=np.empty_like(x); s=0.0
    for i,v in enumerate(x): s+= a*(v-s); y[i]=s
    return y
rng=np.random.default_rng(7)
def env(n, a, r):
    e=np.ones(n); ai=int(a*SR); ri=int(r*SR)
    if ai: e[:ai]=np.linspace(0,1,ai)
    if ri: e[-ri:]*=np.linspace(1,0,ri)**2
    return e

# ---- Background: soft ambient pad, Hijaz-flavoured (D, Eb, F#, G, A), 70s
dur=70; n=dur*SR; t=np.arange(n)/SR
def note(f): return 440*2**((f-69)/12)
pad=np.zeros((n,2))
chords=[[50,57,62,66],[48,55,62,63],[50,57,62,65],[46,53,62,67]]  # D5, Cm-ish(Eb), Dm-ish, Bb
seg=8.0
for k in range(int(dur/seg)+1):
    c=chords[k%len(chords)]; st=int(k*seg*SR); L=int((seg+3)*SR)
    L=min(L,n-st)
    if L<=0: break
    tt=np.arange(L)/SR
    e=np.sin(np.pi*np.clip(tt/(seg+3),0,1))**1.5
    for j,m in enumerate(c):
        f=note(m)
        for d,pan in ((-0.12,0.3),(0.11,0.7)):
            ff=f*2**(d/12/10)
            w=np.sin(2*np.pi*ff*tt+j)+0.25*np.sin(4*np.pi*ff*tt)+0.08*np.sin(6*np.pi*ff*tt)
            pad[st:st+L,0]+=w*e*(1-pan)*0.18
            pad[st:st+L,1]+=w*e*pan*0.18
# low drone D2
dr=np.sin(2*np.pi*note(38)*t)*0.35+np.sin(2*np.pi*note(45)*t)*0.12
pad[:,0]+=dr; pad[:,1]+=dr
# slow tremolo + gentle sparkle bells (pentatonic in Hijaz) every 2s
pad*= (0.85+0.15*np.sin(2*np.pi*0.1*t))[:,None]
bells=[74,75,78,79,81,86,82,81]
for k in range(int(dur/2)):
    if k%4==3: continue
    m=bells[(k*3)%len(bells)]; st=int(k*2.0*SR+0.5*SR); L=int(2.5*SR); L=min(L,n-st)
    if L<=0: continue
    tt=np.arange(L)/SR; f=note(m)
    b=(np.sin(2*np.pi*f*tt)+0.3*np.sin(2*np.pi*f*2.76*tt)*np.exp(-tt*6))*np.exp(-tt*2.2)*0.10
    pan=0.3+0.4*((k*7)%5)/4
    pad[st:st+L,0]+=b*(1-pan); pad[st:st+L,1]+=b*pan
# simple reverb: feedback delays
out=pad.copy()
for dly,g in ((0.137,0.35),(0.211,0.3),(0.293,0.25),(0.41,0.2)):
    d=int(dly*SR); out[d:,0]+=pad[:-d,1]*g; out[d:,1]+=pad[:-d,0]*g
out*=env(n,3,4)[:,None]
save('bgm.wav', out)

# ---- whoosh
n=int(0.9*SR); t=np.arange(n)/SR
noise=rng.standard_normal(n)
sweep=np.concatenate([np.linspace(0.02,0.35,n//2),np.linspace(0.35,0.03,n-n//2)])
y=np.empty(n); s=0.0
for i in range(n): s+=sweep[i]*(noise[i]-s); y[i]=s
e=np.sin(np.pi*t/t[-1])**2
save('whoosh.wav', np.stack([y*e*np.linspace(1,.4,n), y*e*np.linspace(.4,1,n)],1))

# ---- soft cinematic impact (boom)
n=int(2.2*SR); t=np.arange(n)/SR
f=55*np.exp(-t*1.2)+38
boom=np.sin(2*np.pi*np.cumsum(f)/SR)*np.exp(-t*2.2)
click=lp(rng.standard_normal(n),0.15)*np.exp(-t*25)*0.6
save('impact.wav', boom+click)

# ---- shimmer / chime (gold reveal)
n=int(2.5*SR); t=np.arange(n)/SR; y=np.zeros(n)
for k,m in enumerate([86,90,93,98]):
    st=int(k*0.06*SR); tt=t[:n-st]; f=note(m)
    y[st:]+=(np.sin(2*np.pi*f*tt)+0.4*np.sin(2*np.pi*f*2.01*tt))*np.exp(-tt*2.5)
save('chime.wav', y)

# ---- riser
n=int(2.0*SR); t=np.arange(n)/SR
noise=lp(rng.standard_normal(n),0.2)
tone=np.sin(2*np.pi*np.cumsum(200+600*(t/t[-1])**2)/SR)*0.3
e=(t/t[-1])**2.2
save('riser.wav',(noise*0.7+tone)*e)

# ---- pop/tick for list items
n=int(0.25*SR); t=np.arange(n)/SR
y=np.sin(2*np.pi*np.cumsum(1200*np.exp(-t*30)+500)/SR)*np.exp(-t*28)
save('pop.wav', y)
