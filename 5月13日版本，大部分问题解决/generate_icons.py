from PIL import Image, ImageDraw
import os

def create_icon(size, path):
    img = Image.new('RGBA', (size, size), (238, 238, 238, 255))
    draw = ImageDraw.Draw(img)
    
    # 蓝色圆形背景
    cx, cy = size // 2, size // 2
    r = int(size * 0.37)
    
    # 渐变蓝色
    for y in range(size):
        for x in range(size):
            dx = x - cx
            dy = y - cy
            if dx * dx + dy * dy <= r * r:
                f = (dx + dy) / (2 * r) + 0.5
                cr = int(96 + (29 - 96) * f)
                cg = int(165 + (62 - 165) * f)
                cb = int(250 + (100 - 250) * f)
                img.putpixel((x, y), (cr, cg, cb, 255))
    
    # 方块尺寸
    sq_size = int(size * 0.175)
    sq_radius = int(size * 0.03)
    spacing = int(size * 0.05)
    left_pos = cx - sq_size - spacing // 2
    top_pos = cy - sq_size - spacing // 2
    
    # 左上角方块
    draw.rounded_rectangle(
        [left_pos, top_pos, left_pos + sq_size, top_pos + sq_size],
        sq_radius,
        fill=(255, 255, 255, 255)
    )
    
    # 左下角方块
    draw.rounded_rectangle(
        [left_pos, top_pos + sq_size + spacing, left_pos + sq_size, top_pos + 2 * sq_size + spacing],
        sq_radius,
        fill=(255, 255, 255, 255)
    )
    
    # 右下角方块
    draw.rounded_rectangle(
        [left_pos + sq_size + spacing, top_pos + sq_size + spacing, left_pos + 2 * sq_size + spacing, top_pos + 2 * sq_size + spacing],
        sq_radius,
        fill=(255, 255, 255, 255)
    )
    
    # 右上角圆形（半透明）
    circle_cx = left_pos + sq_size + spacing + sq_size // 2
    circle_cy = top_pos + sq_size // 2
    circle_r = sq_size // 2
    
    for y in range(size):
        for x in range(size):
            dx = x - circle_cx
            dy = y - circle_cy
            if dx * dx + dy * dy <= circle_r * circle_r:
                img.putpixel((x, y), (255, 255, 255, 128))
    
    img.save(path, 'PNG')
    print(f"Created: {path}")

output_dir = "ACROSSDataCollection/Assets.xcassets/AppIcon.appiconset"
icons = [
    ("Icon-App-20x20@2x.png", 40),
    ("Icon-App-20x20@3x.png", 60),
    ("Icon-App-29x29@2x.png", 58),
    ("Icon-App-29x29@3x.png", 87),
    ("Icon-App-40x40@2x.png", 80),
    ("Icon-App-40x40@3x.png", 120),
    ("Icon-App-60x60@2x.png", 120),
    ("Icon-App-60x60@3x.png", 180),
    ("Icon-App-20x20@1x.png", 20),
    ("Icon-App-29x29@1x.png", 29),
    ("Icon-App-40x40@1x.png", 40),
    ("Icon-App-76x76@1x.png", 76),
    ("Icon-App-76x76@2x.png", 152),
    ("Icon-App-83.5x83.5@2x.png", 167),
    ("Icon-App-1024x1024@1x.png", 1024),
]

for name, sz in icons:
    create_icon(sz, os.path.join(output_dir, name))

print("All icons created successfully!")
