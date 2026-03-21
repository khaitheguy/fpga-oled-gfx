from PIL import Image
import numpy as np

# ==== CONFIG ====
INPUT_IMAGE = "input.png"
OUTPUT_MEM  = "sprite.mem"
OUTPUT_V    = "sprite.v"
SPRITE_W    = 32
SPRITE_H    = 32
GENERATE_VERILOG = True  # Set False if you only want .mem

# ==== LOAD + RESIZE IMAGE ====
img = Image.open(INPUT_IMAGE).convert("RGB")
img = img.resize((SPRITE_W, SPRITE_H))
pixels = np.array(img)

# ==== RGB888 -> RGB565 ====
def rgb888_to_rgb565(r, g, b):
    return ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)

bitmap = []

for y in range(SPRITE_H):
    for x in range(SPRITE_W):
        r, g, b = pixels[y][x]
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
