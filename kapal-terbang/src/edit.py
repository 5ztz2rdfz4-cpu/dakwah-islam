"""Single source of truth for the audio edit (times in seconds of the ORIGINAL recording)
and the map from the template's authored timeline (old T) to the final timeline (new T)."""

VOICE_IN = 3.0          # voice starts after the hook
SRC_END = 61.05         # end of usable speech in the recording
CUTS = [
    (2.56, 4.72),    # repeated "...kapal terbang. Dia macam kapal terbang" -> keep one
    (8.18, 8.41),    # long pause
    (18.55, 20.80),  # stammer "...mana, di..."
    (31.08, 31.36),  # long pause
    (37.20, 37.54),  # long pause before "redha"
    (46.05, 46.22),  # long pause
    (50.80, 50.99),  # long pause
]
# The template was authored against the first edit, which only removed the stammer.
OLD_CUTS = [(18.55, 20.80)]


def _removed_before(s, cuts):
    r = 0.0
    for a, b in cuts:
        if s >= b:
            r += b - a
        elif s > a:
            r += s - a
    return r


def src_to_new(s):
    return VOICE_IN + s - _removed_before(s, CUTS)


def old_to_src(t):
    v = t - VOICE_IN
    s = v
    for a, b in OLD_CUTS:
        if s >= a:
            s += b - a
    return s


VOICE_LEN = SRC_END - _removed_before(SRC_END, CUTS)
OLD_VOICE_END = VOICE_IN + SRC_END - _removed_before(SRC_END, OLD_CUTS)


def M(t):
    """old authored time -> new time"""
    if t <= VOICE_IN:
        return t
    if t >= OLD_VOICE_END:
        return t - (OLD_VOICE_END - (VOICE_IN + VOICE_LEN))
    return round(src_to_new(old_to_src(t)), 3)


if __name__ == "__main__":
    print("voice len", round(VOICE_LEN, 3), "total", M(68.5))
    for t in (5.4, 6.0, 8.44, 9.46, 10.71, 11.75, 20.2, 36.9, 44.3, 54.75, 59.45, 63.2, 68.5):
        print(t, "->", M(t))
