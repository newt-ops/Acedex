import os
from PIL import Image, ImageDraw

# Create output directories
os.makedirs("assets/logo", exist_ok=True)
os.makedirs("assets/logo/svg", exist_ok=True)
os.makedirs("assets/logo/notification", exist_ok=True)
os.makedirs("assets/logo/in_app", exist_ok=True)
os.makedirs("assets/logo/adaptive", exist_ok=True)

# Android res directories for notification icons
android_res = "android/app/src/main/res"
for folder in ["drawable-mdpi", "drawable-hdpi", "drawable-xhdpi", "drawable-xxhdpi", "drawable-xxxhdpi"]:
    os.makedirs(f"{android_res}/{folder}", exist_ok=True)

# 2-Color Palettes (Strictly 2 colors per theme, no gradients, no glows)
PLUM_LIGHT = "#8A2BA3"    # Brand Primary Plum
PLUM_DARK = "#D58CF0"     # Brand Light Plum (Dark Mode)
WHITE = "#FFFFFF"         # Pure White
DARK_BG = "#0E0B0E"       # Brand Deep Dark Background
DARK_SURFACE = "#1B171C"  # Brand Dark Surface

def get_svg_content(fg_color, bg_color=None, size=512, is_squircle=True, is_circle=False, is_adaptive=False):
    """
    Generates a mathematically balanced, minimalist vector SVG of the Acedex Academic 'A' emblem:
    - Symmetrical diagonal pillars forming the bold letter 'A'
    - Integrated graduation mortarboard diamond crown
    - Dynamic open-book crossbar bridge
    - Safe zone padding for adaptive icons
    """
    scale = size / 512.0
    
    # Safe zone scaling for adaptive icons (fits within 66% circle)
    glyph_scale = scale * 0.72 if is_adaptive else scale
    glyph_offset = (size * 0.14) if is_adaptive else 0.0

    bg_element = ""
    if bg_color:
        if is_circle:
            bg_element = f'<circle cx="{size/2}" cy="{size/2}" r="{size/2}" fill="{bg_color}"/>'
        elif is_squircle:
            r = int(size * 0.22)
            bg_element = f'<rect width="{size}" height="{size}" rx="{r}" fill="{bg_color}"/>'
        else:
            bg_element = f'<rect width="{size}" height="{size}" fill="{bg_color}"/>'

    # Coordinates on 512x512 grid:
    # Cap diamond:
    c_top_x, c_top_y = 256 * glyph_scale + glyph_offset, 96 * glyph_scale + glyph_offset
    c_right_x, c_right_y = 396 * glyph_scale + glyph_offset, 172 * glyph_scale + glyph_offset
    c_bot_x, c_bot_y = 256 * glyph_scale + glyph_offset, 248 * glyph_scale + glyph_offset
    c_left_x, c_left_y = 116 * glyph_scale + glyph_offset, 172 * glyph_scale + glyph_offset

    # Left pillar:
    lp_1 = f"{148 * glyph_scale + glyph_offset} {216 * glyph_scale + glyph_offset}"
    lp_2 = f"{218 * glyph_scale + glyph_offset} {254 * glyph_scale + glyph_offset}"
    lp_3 = f"{170 * glyph_scale + glyph_offset} {416 * glyph_scale + glyph_offset}"
    lp_4 = f"{108 * glyph_scale + glyph_offset} {416 * glyph_scale + glyph_offset}"

    # Right pillar:
    rp_1 = f"{364 * glyph_scale + glyph_offset} {216 * glyph_scale + glyph_offset}"
    rp_2 = f"{294 * glyph_scale + glyph_offset} {254 * glyph_scale + glyph_offset}"
    rp_3 = f"{342 * glyph_scale + glyph_offset} {416 * glyph_scale + glyph_offset}"
    rp_4 = f"{404 * glyph_scale + glyph_offset} {416 * glyph_scale + glyph_offset}"

    # Center crossbar bridge:
    cb_1 = f"{196 * glyph_scale + glyph_offset} {324 * glyph_scale + glyph_offset}"
    cb_2 = f"{256 * glyph_scale + glyph_offset} {342 * glyph_scale + glyph_offset}"
    cb_3 = f"{316 * glyph_scale + glyph_offset} {324 * glyph_scale + glyph_offset}"
    cb_4 = f"{316 * glyph_scale + glyph_offset} {356 * glyph_scale + glyph_offset}"
    cb_5 = f"{256 * glyph_scale + glyph_offset} {374 * glyph_scale + glyph_offset}"
    cb_6 = f"{196 * glyph_scale + glyph_offset} {356 * glyph_scale + glyph_offset}"

    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {size} {size}" width="{size}" height="{size}">
  {bg_element}
  <g fill="{fg_color}">
    <!-- Academic Mortarboard Diamond -->
    <polygon points="{c_top_x},{c_top_y} {c_right_x},{c_right_y} {c_bot_x},{c_bot_y} {c_left_x},{c_left_y}" />
    <!-- Letter A Left Pillar -->
    <polygon points="{lp_1} {lp_2} {lp_3} {lp_4}" />
    <!-- Letter A Right Pillar -->
    <polygon points="{rp_1} {rp_2} {rp_3} {rp_4}" />
    <!-- Knowledge Bridge Crossbar -->
    <polygon points="{cb_1} {cb_2} {cb_3} {cb_4} {cb_5} {cb_6}" />
  </g>
</svg>'''
    return svg

def render_png(fg_hex, bg_hex=None, size=1024, is_squircle=True, is_circle=False, is_adaptive=False):
    """
    Renders pixel-perfect anti-aliased PNG using 4x supersampling.
    """
    scale = 4
    canvas_size = size * scale
    
    if bg_hex:
        img = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        bg_rgb = tuple(int(bg_hex.lstrip('#')[i:i+2], 16) for i in (0, 2, 4)) + (255,)
        
        if is_circle:
            draw.ellipse([0, 0, canvas_size, canvas_size], fill=bg_rgb)
        elif is_squircle:
            r = int(canvas_size * 0.22)
            draw.rounded_rectangle([0, 0, canvas_size, canvas_size], radius=r, fill=bg_rgb)
        else:
            draw.rectangle([0, 0, canvas_size, canvas_size], fill=bg_rgb)
    else:
        img = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)

    fg_rgb = tuple(int(fg_hex.lstrip('#')[i:i+2], 16) for i in (0, 2, 4)) + (255,)
    
    s = canvas_size / 512.0
    glyph_scale = s * 0.72 if is_adaptive else s
    glyph_offset = (canvas_size * 0.14) if is_adaptive else 0.0

    # 1. Academic Cap Mortarboard Diamond
    cap = [
        (256 * glyph_scale + glyph_offset, 96 * glyph_scale + glyph_offset),
        (396 * glyph_scale + glyph_offset, 172 * glyph_scale + glyph_offset),
        (256 * glyph_scale + glyph_offset, 248 * glyph_scale + glyph_offset),
        (116 * glyph_scale + glyph_offset, 172 * glyph_scale + glyph_offset),
    ]
    draw.polygon(cap, fill=fg_rgb)

    # 2. Left Pillar
    left_pillar = [
        (148 * glyph_scale + glyph_offset, 216 * glyph_scale + glyph_offset),
        (218 * glyph_scale + glyph_offset, 254 * glyph_scale + glyph_offset),
        (170 * glyph_scale + glyph_offset, 416 * glyph_scale + glyph_offset),
        (108 * glyph_scale + glyph_offset, 416 * glyph_scale + glyph_offset),
    ]
    draw.polygon(left_pillar, fill=fg_rgb)

    # 3. Right Pillar
    right_pillar = [
        (364 * glyph_scale + glyph_offset, 216 * glyph_scale + glyph_offset),
        (294 * glyph_scale + glyph_offset, 254 * glyph_scale + glyph_offset),
        (342 * glyph_scale + glyph_offset, 416 * glyph_scale + glyph_offset),
        (404 * glyph_scale + glyph_offset, 416 * glyph_scale + glyph_offset),
    ]
    draw.polygon(right_pillar, fill=fg_rgb)

    # 4. Central Knowledge Bridge
    bridge = [
        (196 * glyph_scale + glyph_offset, 324 * glyph_scale + glyph_offset),
        (256 * glyph_scale + glyph_offset, 342 * glyph_scale + glyph_offset),
        (316 * glyph_scale + glyph_offset, 324 * glyph_scale + glyph_offset),
        (316 * glyph_scale + glyph_offset, 356 * glyph_scale + glyph_offset),
        (256 * glyph_scale + glyph_offset, 374 * glyph_scale + glyph_offset),
        (196 * glyph_scale + glyph_offset, 356 * glyph_scale + glyph_offset),
    ]
    draw.polygon(bridge, fill=fg_rgb)

    return img.resize((size, size), Image.Resampling.LANCZOS)

# -------------------------------------------------------------
# 1. EXPORT VECTOR SVGS (for Figma and Web)
# -------------------------------------------------------------
print("Generating SVGs...")
svg_configs = [
    ("assets/logo/svg/acedex_logo_light.svg", PLUM_LIGHT, WHITE, True),
    ("assets/logo/svg/acedex_logo_plum.svg", WHITE, PLUM_LIGHT, True),
    ("assets/logo/svg/acedex_logo_dark.svg", PLUM_DARK, DARK_BG, True),
    ("assets/logo/svg/acedex_icon_plum_transparent.svg", PLUM_LIGHT, None, False),
    ("assets/logo/svg/acedex_icon_dark_transparent.svg", PLUM_DARK, None, False),
    ("assets/logo/svg/acedex_icon_white_transparent.svg", WHITE, None, False),
    ("assets/logo/svg/ic_notification.svg", WHITE, None, False),
]

for path, fg, bg, squircle in svg_configs:
    svg_str = get_svg_content(fg, bg, size=512, is_squircle=squircle)
    with open(path, "w", encoding="utf-8") as f:
        f.write(svg_str)
print("SVGs exported.")

# -------------------------------------------------------------
# 2. EXPORT APP LAUNCHER ICONS (1024x1024 and 512x512)
# -------------------------------------------------------------
print("Generating App Launcher Icons...")
# Light Mode (White BG + Plum Icon)
img_light_1024 = render_png(PLUM_LIGHT, WHITE, size=1024, is_squircle=True)
img_light_1024.save("assets/logo/acedex_logo_light_1024.png")
img_light_512 = render_png(PLUM_LIGHT, WHITE, size=512, is_squircle=True)
img_light_512.save("assets/logo/acedex_logo_light_512.png")

# Brand Plum Mode (Plum BG + White Icon)
img_plum_1024 = render_png(WHITE, PLUM_LIGHT, size=1024, is_squircle=True)
img_plum_1024.save("assets/logo/acedex_logo_plum_1024.png")
img_plum_512 = render_png(WHITE, PLUM_LIGHT, size=512, is_squircle=True)
img_plum_512.save("assets/logo/acedex_logo_plum_512.png")

# Dark Mode (Dark BG + Light Plum Icon)
img_dark_1024 = render_png(PLUM_DARK, DARK_BG, size=1024, is_squircle=True)
img_dark_1024.save("assets/logo/acedex_logo_dark_1024.png")
img_dark_512 = render_png(PLUM_DARK, DARK_BG, size=512, is_squircle=True)
img_dark_512.save("assets/logo/acedex_logo_dark_512.png")

# -------------------------------------------------------------
# 3. EXPORT IN-APP TRANSPARENT LOGOS (No background)
# -------------------------------------------------------------
print("Generating Transparent In-App Icons...")
for size in [512, 256, 128, 64]:
    # Light Mode Plum
    icon_plum = render_png(PLUM_LIGHT, None, size=size)
    icon_plum.save(f"assets/logo/in_app/acedex_icon_plum_{size}.png")
    # Dark Mode Light Plum
    icon_dark = render_png(PLUM_DARK, None, size=size)
    icon_dark.save(f"assets/logo/in_app/acedex_icon_dark_{size}.png")
    # Pure White (for plum buttons / colored headers)
    icon_white = render_png(WHITE, None, size=size)
    icon_white.save(f"assets/logo/in_app/acedex_icon_white_{size}.png")

# Primary in-app transparent asset shortcuts
render_png(PLUM_LIGHT, None, size=512).save("assets/logo/acedex_icon_transparent_plum.png")
render_png(PLUM_DARK, None, size=512).save("assets/logo/acedex_icon_transparent_dark.png")
render_png(WHITE, None, size=512).save("assets/logo/acedex_icon_transparent_white.png")

# -------------------------------------------------------------
# 4. EXPORT ANDROID STATUS BAR ADAPTIVE NOTIFICATION ICONS
# Strict Android Rule: All white silhouette on transparent background
# -------------------------------------------------------------
print("Generating Android Notification Icons...")
notif_densities = {
    "drawable-mdpi": 24,
    "drawable-hdpi": 36,
    "drawable-xhdpi": 48,
    "drawable-xxhdpi": 72,
    "drawable-xxxhdpi": 96,
}

# Master notification icons
render_png(WHITE, None, size=128).save("assets/logo/notification/ic_notification_128.png")
render_png(WHITE, None, size=96).save("assets/logo/notification/ic_notification_96.png")
render_png(WHITE, None, size=48).save("assets/logo/notification/ic_notification_48.png")
render_png(WHITE, None, size=24).save("assets/logo/notification/ic_notification_24.png")

for folder, px in notif_densities.items():
    notif_img = render_png(WHITE, None, size=px)
    # Save to assets/logo/notification/
    notif_img.save(f"assets/logo/notification/ic_notification_{px}x{px}.png")
    # Save directly to Android drawable resource directory
    notif_img.save(f"{android_res}/{folder}/ic_notification.png")

# Default drawable fallback
render_png(WHITE, None, size=48).save(f"{android_res}/drawable/ic_notification.png")
print("Notification icons deployed to Android res drawables.")

# -------------------------------------------------------------
# 5. EXPORT ANDROID ADAPTIVE LAUNCHER LAYERS (432x432 px)
# -------------------------------------------------------------
print("Generating Android Adaptive Layers...")
# Foreground (centered glyph with 66% safe zone margin)
render_png(WHITE, None, size=432, is_adaptive=True).save("assets/logo/adaptive/ic_launcher_foreground_white.png")
render_png(PLUM_LIGHT, None, size=432, is_adaptive=True).save("assets/logo/adaptive/ic_launcher_foreground_plum.png")
render_png(PLUM_DARK, None, size=432, is_adaptive=True).save("assets/logo/adaptive/ic_launcher_foreground_dark.png")

# Backgrounds
bg_plum = Image.new("RGBA", (432, 432), tuple(int(PLUM_LIGHT.lstrip('#')[i:i+2], 16) for i in (0, 2, 4)) + (255,))
bg_plum.save("assets/logo/adaptive/ic_launcher_background_plum.png")

bg_white = Image.new("RGBA", (432, 432), (255, 255, 255, 255))
bg_white.save("assets/logo/adaptive/ic_launcher_background_white.png")

bg_dark = Image.new("RGBA", (432, 432), tuple(int(DARK_BG.lstrip('#')[i:i+2], 16) for i in (0, 2, 4)) + (255,))
bg_dark.save("assets/logo/adaptive/ic_launcher_background_dark.png")

print("ALL ASSETS SUCCESSFULLY GENERATED!")
