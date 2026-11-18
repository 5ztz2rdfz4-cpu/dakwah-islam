import numpy as np, wave, noisereduce as nr
w=wave.open('raw44.wav'); sr=w.getframerate(); x=np.frombuffer(w.readframes(w.getnframes()),np.int16).astype(np.float32)/32768
noise=np.concatenate([x[int(54.4*sr):int(55.0*sr)],x[int(16.25*sr):int(16.55*sr)],x[int(14.6*sr):int(14.85*sr)]])
y=nr.reduce_noise(y=x,sr=sr,y_noise=noise,stationary=True,prop_decrease=0.85,n_std_thresh_stationary=1.3,freq_mask_smooth_hz=300,time_mask_smooth_ms=60)
# second light non-stationary pass for residual room noise
y=nr.reduce_noise(y=y,sr=sr,stationary=False,prop_decrease=0.35)
y=np.clip(y,-1,1)
o=wave.open('nr44.wav','wb'); o.setnchannels(1); o.setsampwidth(2); o.setframerate(sr); o.writeframes((y*32767).astype('<i2').tobytes())
