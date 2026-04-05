import numpy as np
from scipy.io import wavfile

# --------------------------
# Load audio
fs, data = wavfile.read("input.wav")

if data.ndim > 1:
    data = data[:, 0]

data = data.astype(np.float32)

# --------------------------
# Parameters
frame_size = int(fs * 0.15)   # 200 ms
hop_size = frame_size
threshold = 500              # silence threshold

# Quantization settings
TIME_QUANT = 300             # ms per step (like a beat grid)

# --------------------------
# Musical note helpers

def freq_to_midi(freq):
    return 69 + 12 * np.log2(freq / 440.0)

def midi_to_freq(midi):
    return 440.0 * (2 ** ((midi - 69) / 12))

def snap_to_note(freq):
    if freq <= 0:
        return 0
    midi = round(freq_to_midi(freq))
    return int(midi_to_freq(midi))

# --------------------------
# Extract frequencies
freqs = []

for i in range(0, len(data), hop_size):
    frame = data[i:i+frame_size]
    if len(frame) < frame_size:
        break

    amplitude = np.mean(np.abs(frame))
    if amplitude < threshold:
        freqs.append(0)
        continue

    spectrum = np.abs(np.fft.rfft(frame))
    peak_idx = np.argmax(spectrum)
    freq = peak_idx * fs / frame_size

    # Clamp usable range
    if freq < 100 or freq > 5000:
        freq = 0

    # Snap to musical note
    freq = snap_to_note(freq)

    freqs.append(int(freq))

# --------------------------
# Merge consecutive notes
freq_table = []
dur_table = []

prev = None
duration = 0

for f in freqs:
    if f == prev:
        duration += 100
    else:
        if prev is not None:
            freq_table.append(prev)
            dur_table.append(duration)
        prev = f
        duration = 100

if prev is not None:
    freq_table.append(prev)
    dur_table.append(duration)

dur_table = [int(d * 2.0) for d in dur_table]

# --------------------------
# Quantize durations to grid
quant_freq = []
quant_dur = []

for f, d in zip(freq_table, dur_table):
    steps = max(1, round(d / TIME_QUANT))
    quant_freq.append(f)
    quant_dur.append(steps * TIME_QUANT)

# --------------------------
# Save HEX .mem files
with open("freq.mem", "w") as f_freq:
    for f in quant_freq:
        f_freq.write(f"{f:08X}\n")

with open("dur.mem", "w") as f_dur:
    for d in quant_dur:
        f_dur.write(f"{d:08X}\n")

print("✅ Done! Musical quantized output generated.")
print(f"Total notes: {len(quant_freq)}")