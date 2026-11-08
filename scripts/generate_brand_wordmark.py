import os
import math
from PIL import Image, ImageDraw, ImageFont

os.makedirs("assets/logo/brand", exist_ok=True)
os.makedirs("assets/logo/brand/svg", exist_ok=True)

# Brand Color Constants (Strictly 2 colors per theme)
PLUM_LIGHT = "#8A2BA3"    # Brand Primary Plum
PLUM_DARK = "#D58CF0"     # Brand Light Plum (Dark Mode)
DARK_TEXT = "#1D151E"     # Primary dark text
LIGHT_TEXT = "#F3F1F4"    # Primary light text
WHITE = "#FFFFFF"         # Pure White
DARK_BG = "#0E0B0E"       # Brand Deep Dark Background

def render_brand_wordmark(text_hex, accent_hex, bg_hex=None, width=1200, height=500, padding=40):
    """
    Renders the Acedex Brand Wordmark with:
    - Bold sans-serif typography: "Acedex"
    - Colored accent dot: "."
    - Perched line-art academic emblem atop the initial letter "A":
      * Tilted graduation mortarboard cap with hanging tassel
      * Knowledge horizon curve
      * Beacon/Sun open circle
    """
    scale = 4
    w = width * scale
    h = height * scale
    
    if bg_hex:
        bg_rgb = tuple(int(bg_hex.lstrip('#')[i:i+2], 16) for i in (0, 2, 4)) + (255,)
        img = Image.new("RGBA", (w, h), bg_rgb)
    else:
        img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        
    draw = ImageDraw.Draw(img)
    text_rgb = tuple(int(text_hex.lstrip('#')[i:i+2], 16) for i in (0, 2, 4)) + (255,)
    accent_rgb = tuple(int(accent_hex.lstrip('#')[i:i+2], 16) for i in (0, 2, 4)) + (255,)
    
    font_size = int(136 * scale)
    font = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", font_size)
    
    text = "Acedex"
    t_bbox = draw.textbbox((0, 0), text, font=font)
    t_width = t_bbox[2] - t_bbox[0]
    t_height = t_bbox[3] - t_bbox[1]
    
    text_x = int(140 * scale)
    text_y = int(240 * scale)
    
    # 1. Draw "Acedex" text
    draw.text((text_x, text_y), text, font=font, fill=text_rgb)
    
    # 2. Draw Accent Period Dot "."
    dot_radius = int(11 * scale)
    dot_x = text_x + t_width + int(16 * scale)
    dot_y = text_y + t_bbox[3] - dot_radius
    draw.ellipse([
        dot_x - dot_radius, dot_y - dot_radius,
        dot_x + dot_radius, dot_y + dot_radius
    ], fill=accent_rgb)
    
    # 3. Perched Line-Art Academic Emblem atop "A"
    a_top_x = text_x + int(8 * scale)
    a_top_y = text_y + t_bbox[1]
    
    icon_cx = a_top_x + int(42 * scale)
    icon_cy = a_top_y - int(78 * scale)
    stroke_w = int(7 * scale)
    
    d_w = int(64 * scale)
    d_h = int(26 * scale)
    tilt_rad = math.radians(-12)
    
    def rotate_pt(pt, origin, angle):
        ox, oy = origin
        px, py = pt
        qx = ox + math.cos(angle) * (px - ox) - math.sin(angle) * (py - oy)
        qy = oy + math.sin(angle) * (px - ox) + math.cos(angle) * (py - oy)
        return (qx, qy)
    
    # Diamond Cap outline
    cap_top = rotate_pt((icon_cx, icon_cy - d_h), (icon_cx, icon_cy), tilt_rad)
    cap_right = rotate_pt((icon_cx + d_w, icon_cy), (icon_cx, icon_cy), tilt_rad)
    cap_bottom = rotate_pt((icon_cx, icon_cy + d_h), (icon_cx, icon_cy), tilt_rad)
    cap_left = rotate_pt((icon_cx - d_w, icon_cy), (icon_cx, icon_cy), tilt_rad)
    cap_pts = [cap_top, cap_right, cap_bottom, cap_left]
    for i in range(4):
        draw.line([cap_pts[i], cap_pts[(i+1)%4]], fill=accent_rgb, width=stroke_w)
        
    # Cap Skullcap arch
    skull_left = rotate_pt((icon_cx - int(28 * scale), icon_cy + int(14 * scale)), (icon_cx, icon_cy), tilt_rad)
    skull_mid = rotate_pt((icon_cx, icon_cy + int(30 * scale)), (icon_cx, icon_cy), tilt_rad)
    skull_right = rotate_pt((icon_cx + int(28 * scale), icon_cy + int(14 * scale)), (icon_cx, icon_cy), tilt_rad)
    draw.line([skull_left, skull_mid, skull_right], fill=accent_rgb, width=stroke_w)
    
    # Hanging Tassel with circular bead
    tassel_top = rotate_pt((icon_cx, icon_cy), (icon_cx, icon_cy), tilt_rad)
    tassel_drop = rotate_pt((icon_cx + int(56 * scale), icon_cy + int(32 * scale)), (icon_cx, icon_cy), tilt_rad)
    draw.line([tassel_top, tassel_drop], fill=accent_rgb, width=int(5 * scale))
    bead_r = int(6 * scale)
    draw.ellipse([
        tassel_drop[0] - bead_r, tassel_drop[1] - bead_r,
        tassel_drop[0] + bead_r, tassel_drop[1] + bead_r
    ], fill=accent_rgb)

    # Knowledge Horizon Curve
    arch_start = (icon_cx - int(80 * scale), a_top_y - int(8 * scale))
    arch_mid = (icon_cx + int(12 * scale), a_top_y - int(30 * scale))
    arch_end = (icon_cx + int(96 * scale), a_top_y - int(10 * scale))
    
    curve_pts = []
    for step in range(21):
        t = step / 20.0
        cx = (1 - t)**2 * arch_start[0] + 2 * (1 - t) * t * arch_mid[0] + t**2 * arch_end[0]
        cy = (1 - t)**2 * arch_start[1] + 2 * (1 - t) * t * arch_mid[1] + t**2 * arch_end[1]
        curve_pts.append((cx, cy))
        
    for i in range(len(curve_pts) - 1):
        draw.line([curve_pts[i], curve_pts[i+1]], fill=accent_rgb, width=stroke_w)
        
    # Beacon / Sun Circle
    sun_cx = icon_cx + int(76 * scale)
    sun_cy = icon_cy - int(44 * scale)
    sun_r = int(12 * scale)
    draw.ellipse([
        sun_cx - sun_r, sun_cy - sun_r,
        sun_cx + sun_r, sun_cy + sun_r
    ], outline=accent_rgb, width=stroke_w)

    # Crop to snug content bbox + padding
    bbox = img.getbbox()
    if bbox:
        pad = padding * scale
        crop_box = (
            max(0, bbox[0] - pad),
            max(0, bbox[1] - pad),
            min(w, bbox[2] + pad),
            min(h, bbox[3] + pad)
        )
        img = img.crop(crop_box)
        
    target_h = int(img.height / scale)
    target_w = int(img.width / scale)
    return img.resize((target_w, target_h), Image.Resampling.LANCZOS)

def generate_svg_wordmark(text_color, accent_color, bg_color=None):
    """
    Generates a pure vector SVG for Figma & Web.
    """
    bg_rect = f'<rect width="600" height="260" rx="16" fill="{bg_color}"/>' if bg_color else ''
    
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 260" width="600" height="260">
  {bg_rect}
  <g transform="translate(60, 40)">
    <!-- Perched Academic Emblem atop A -->
    <g transform="translate(18, 12)">
      <!-- Knowledge Horizon Curve -->
      <path d="M -15 68 Q 50 48 115 66" fill="none" stroke="{accent_color}" stroke-width="4.5" stroke-linecap="round" />
      
      <!-- Graduation Mortarboard Cap Diamond (tilted) -->
      <g transform="rotate(-12, 45, 30)">
        <polygon points="45,10 90,30 45,50 0,30" fill="none" stroke="{accent_color}" stroke-width="4.5" stroke-linejoin="round" />
        <!-- Skullcap Arc -->
        <path d="M 22 40 Q 45 54 68 40" fill="none" stroke="{accent_color}" stroke-width="4.5" stroke-linecap="round" />
        <!-- Tassel -->
        <line x1="45" y1="30" x2="88" y2="52" stroke="{accent_color}" stroke-width="3" stroke-linecap="round" />
        <circle cx="88" cy="52" r="4.5" fill="{accent_color}" />
      </g>
      
      <!-- Beacon / Sun Circle -->
      <circle cx="98" cy="10" r="8" fill="none" stroke="{accent_color}" stroke-width="4" />
    </g>

    <!-- Wordmark Typography -->
    <text x="0" y="152" font-family="system-ui, -apple-system, 'SF Pro Display', 'Inter', 'Segoe UI', Roboto, sans-serif" font-weight="700" font-size="94" letter-spacing="-1.5" fill="{text_color}">Acedex<tspan fill="{accent_color}">.</tspan></text>
  </g>
</svg>'''
    return svg

# -------------------------------------------------------------
# GENERATE PNGS
# -------------------------------------------------------------
print("Generating Brand Wordmark PNGs...")

# 1. Light Mode (Dark Text + Plum Accent on White)
render_brand_wordmark(DARK_TEXT, PLUM_LIGHT, WHITE).save("assets/logo/brand/acedex_brand_light.png")
# Transparent Light
render_brand_wordmark(DARK_TEXT, PLUM_LIGHT, None).save("assets/logo/brand/acedex_brand_light_transparent.png")

# 2. Dark Mode (Light Text + Light Plum Accent on Dark BG)
render_brand_wordmark(LIGHT_TEXT, PLUM_DARK, DARK_BG).save("assets/logo/brand/acedex_brand_dark.png")
# Transparent Dark
render_brand_wordmark(LIGHT_TEXT, PLUM_DARK, None).save("assets/logo/brand/acedex_brand_dark_transparent.png")

# 3. Plum Brand Mode (White Text + White Accent on Plum BG)
render_brand_wordmark(WHITE, WHITE, PLUM_LIGHT).save("assets/logo/brand/acedex_brand_plum.png")
# Plum Accent Transparent (White text + Plum dot for colored backgrounds)
render_brand_wordmark(WHITE, WHITE, None).save("assets/logo/brand/acedex_brand_white_transparent.png")

# -------------------------------------------------------------
# GENERATE SVGS FOR FIGMA
# -------------------------------------------------------------
print("Generating Brand Wordmark SVGs...")
with open("assets/logo/brand/svg/acedex_brand_light.svg", "w", encoding="utf-8") as f:
    f.write(generate_svg_wordmark(DARK_TEXT, PLUM_LIGHT, WHITE))

with open("assets/logo/brand/svg/acedex_brand_light_transparent.svg", "w", encoding="utf-8") as f:
    f.write(generate_svg_wordmark(DARK_TEXT, PLUM_LIGHT, None))

with open("assets/logo/brand/svg/acedex_brand_dark.svg", "w", encoding="utf-8") as f:
    f.write(generate_svg_wordmark(LIGHT_TEXT, PLUM_DARK, DARK_BG))

with open("assets/logo/brand/svg/acedex_brand_dark_transparent.svg", "w", encoding="utf-8") as f:
    f.write(generate_svg_wordmark(LIGHT_TEXT, PLUM_DARK, None))

with open("assets/logo/brand/svg/acedex_brand_plum.svg", "w", encoding="utf-8") as f:
    f.write(generate_svg_wordmark(WHITE, WHITE, PLUM_LIGHT))

print("ALL BRAND WORDMARK ASSETS GENERATED!")
