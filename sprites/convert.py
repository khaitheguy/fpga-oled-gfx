import sys
import os
from PIL import Image
import numpy as np

# ==== CONFIG ====
GENERATE_VERILOG = True
TRANSPARENT_KEY = 0xF81F  # pink

# ==== ARGUMENT HANDLING ====
if len(sys.argv) < 2:
    print("Usage: python convert.py <input_image> [WIDTHxHEIGHT]")
    sys.exit(1)

INPUT_IMAGE = sys.argv[1]

# Optional size argument
if len(sys.argv) >= 3:
    try:
        w, h = sys.argv[2].lower().split('x')
        SPRITE_W = int(w)
        SPRITE_H = int(h)
        RESIZE = True
    except:
        print("Invalid size format. Use WIDTHxHEIGHT (e.g. 96x64)")
        sys.exit(1)
else:
    RESIZE = False

# ==== AUTO OUTPUT NAMES ====
base_name = os.path.splitext(os.path.basename(INPUT_IMAGE))[0]
OUTPUT_MEM = base_name + ".mem"
OUTPUT_V   = base_name + ".v"

# ==== LOAD IMAGE (KEEP ALPHA) ====
img = Image.open(INPUT_IMAGE).convert("RGBA")

# ==== RESIZE (ONLY IF ARG PROVIDED) ====
if RESIZE:
    img = img.resize((SPRITE_W, SPRITE_H))
else:
    SPRITE_W, SPRITE_H = img.size  # keep original size

pixels = np.array(img)

# ==== RGB888 -> RGB565 ====
def rgb888_to_rgb565(r, g, b):
    r5 = (int(r) * 31) // 255
    g6 = (int(g) * 63) // 255
    b5 = (int(b) * 31) // 255
    return (r5 << 11) | (g6 << 5) | b5

bitmap = []

for y in range(SPRITE_H):
    for x in range(SPRITE_W):
        r, g, b, a = pixels[y][x]

        # ==== TRANSPARENCY HANDLING ====
        if a < 128:
            rgb565 = TRANSPARENT_KEY
        else:
            rgb565 = rgb888_to_rgb565(r, g, b)

        bitmap.append(rgb565)

# ==== WRITE .mem FILE ====
with open(OUTPUT_MEM, "w") as f:
    for value in bitmap:
        f.write(f"{value:04X}\n")

print(f"[OK] Memory file written to {OUTPUT_MEM}")

# ==== OPTIONAL: GENERATE VERILOG INIT BLOCK ====
if GENERATE_VERILOG:
    with open(OUTPUT_V, "w") as f:
        f.write(f"// Auto-generated sprite ({SPRITE_W}x{SPRITE_H})\n")
        f.write("initial begin\n")

        idx = 0
        for y in range(SPRITE_H):
            for x in range(SPRITE_W):
                f.write(f"    sprite[{y}][{x}] = 16'h{bitmap[idx]:04X};\n")
                idx += 1

        f.write("end\n")

    print(f"[OK] Verilog file written to {OUTPUT_V}")