#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont, ImageFilter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "Docs"
SCREENSHOTS = OUT / "Screenshots"
SCREENSHOTS.mkdir(parents=True, exist_ok=True)

W, H = 1600, 1000
BG = (244, 247, 252)
INK = (28, 33, 42)
MUTED = (104, 113, 128)
BLUE = (74, 134, 255)
VIOLET = (151, 110, 255)
GREEN = (50, 174, 102)
CARD = (255, 255, 255, 232)
SIDEBAR = (232, 238, 247, 230)


def font(size):
    for name in [
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
        "/Library/Fonts/Arial.ttf",
    ]:
        if Path(name).exists():
            return ImageFont.truetype(name, size=size)
    return ImageFont.load_default()


F = {"hero": font(58), "title": font(38), "h2": font(28), "body": font(22), "small": font(18), "tiny": font(15)}


def rounded(draw, box, radius=24, fill=CARD, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def gradient_bg():
    img = Image.new("RGB", (W, H), BG)
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    od.ellipse((900, -220, 1850, 620), fill=(122, 177, 255, 70))
    od.ellipse((1050, 560, 1750, 1220), fill=(181, 130, 255, 55))
    od.ellipse((-220, 520, 520, 1220), fill=(110, 210, 230, 45))
    overlay = overlay.filter(ImageFilter.GaussianBlur(60))
    return Image.alpha_composite(img.convert("RGBA"), overlay)


def draw_window(title="Silica", selected_index=0):
    img = gradient_bg()
    d = ImageDraw.Draw(img)
    rounded(d, (80, 70, 1520, 930), 34, fill=(255, 255, 255, 218), outline=(214, 222, 235), width=2)
    rounded(d, (80, 70, 1520, 126), 34, fill=(247, 250, 255, 235))
    for i, color in enumerate([(255, 95, 86), (255, 189, 46), (39, 201, 63)]):
        d.ellipse((112 + i * 32, 92, 130 + i * 32, 110), fill=color)
    d.text((236, 88), title, fill=INK, font=F["small"])
    rounded(d, (104, 145, 340, 905), 24, fill=SIDEBAR)
    items = [("Smart", "✦"), ("Archive", "▣"), ("Images", "◧"), ("Lens", "◎"), ("History", "↺"), ("Profiles", "≡"), ("Settings", "⚙")]
    y = 174
    for idx, (label, icon) in enumerate(items):
        selected = idx == selected_index
        if selected:
            rounded(d, (124, y - 8, 318, y + 38), 14, fill=(255, 255, 255, 235))
        d.text((146, y), icon, fill=BLUE if selected else MUTED, font=F["body"])
        d.text((184, y), label, fill=INK if selected else MUTED, font=F["small"])
        y += 62
    d.text((128, 846), "Everything stays on your Mac.", fill=MUTED, font=F["tiny"])
    return img


def draw_pill(d, xy, text, color=BLUE):
    x, y = xy
    tw = d.textlength(text, font=F["tiny"])
    rounded(d, (x, y, x + tw + 30, y + 34), 17, fill=(*color, 32))
    d.text((x + 15, y + 8), text, fill=color, font=F["tiny"])


def smart_screen(path):
    img = draw_window()
    d = ImageDraw.Draw(img)
    d.text((390, 175), "Compress smarter.", fill=INK, font=F["hero"])
    d.text((392, 246), "Drop anything. Silica will find the best way.", fill=MUTED, font=F["body"])
    rounded(d, (390, 320, 990, 700), 34, fill=(255, 255, 255, 225), outline=(204, 216, 235), width=2)
    d.rounded_rectangle((440, 370, 940, 650), radius=26, outline=(118, 164, 255), width=4)
    d.text((535, 465), "Drop files or folders here", fill=INK, font=F["h2"])
    d.text((505, 510), "Silica will analyze archives, images and everyday files.", fill=MUTED, font=F["small"])
    rounded(d, (390, 735, 585, 792), 18, fill=BLUE)
    d.text((438, 752), "Choose Files", fill=(255, 255, 255), font=F["small"])
    rounded(d, (605, 735, 880, 792), 18, fill=(235, 241, 252))
    d.text((635, 752), "Analyze with Silica Lens", fill=INK, font=F["small"])
    rounded(d, (1030, 170, 1458, 582), 30, fill=(255, 255, 255, 232), outline=(218, 225, 238), width=2)
    d.text((1070, 210), "Silica Lens", fill=INK, font=F["h2"])
    draw_pill(d, (1280, 210), "Smart Compress")
    d.text((1070, 282), "Possible saving", fill=MUTED, font=F["small"])
    d.text((1070, 318), "87 MB", fill=INK, font=F["hero"])
    d.text((1070, 410), "Images   72 MB → 28 MB", fill=INK, font=F["small"])
    d.text((1070, 454), "Documents 34 MB → 27 MB", fill=INK, font=F["small"])
    d.text((1070, 498), "Archives already compressed", fill=MUTED, font=F["small"])
    rounded(d, (1030, 620, 1458, 820), 30, fill=(255, 255, 255, 232))
    d.text((1070, 660), "Recommended action", fill=MUTED, font=F["small"])
    d.text((1070, 702), "Smart Compress", fill=INK, font=F["title"])
    img.save(path)


def lens_screen(path):
    img = draw_window(selected_index=3)
    d = ImageDraw.Draw(img)
    d.text((390, 174), "Silica Lens", fill=INK, font=F["hero"])
    d.text((392, 245), "See what can actually shrink before you compress.", fill=MUTED, font=F["body"])
    rounded(d, (390, 315, 820, 810), 32, fill=(255, 255, 255, 232))
    d.text((430, 355), "Possible saving", fill=MUTED, font=F["small"])
    d.text((430, 395), "87 MB", fill=INK, font=F["hero"])
    for y, row in zip([510, 566, 622, 678], [("Images", "72 MB → 28 MB", GREEN), ("PDF files", "34 MB → 27 MB", BLUE), ("Archives", "already compressed", MUTED), ("Metadata", "4 MB removable", VIOLET)]):
        d.text((430, y), row[0], fill=INK, font=F["small"])
        d.text((610, y), row[1], fill=row[2], font=F["small"])
    rounded(d, (870, 315, 1458, 810), 32, fill=(255, 255, 255, 232))
    d.text((915, 355), "How to use Silica Lens", fill=INK, font=F["h2"])
    steps = [("1", "Drop files or folders", "Use images, documents, archives and folders."), ("2", "Read the saving map", "Lens shows what can shrink and what should be skipped."), ("3", "Run Smart Compress", "Use the recommendation and compare real savings after.")]
    y = 430
    for n, title, detail in steps:
        d.ellipse((915, y, 949, y + 34), fill=(236, 242, 255))
        d.text((927, y + 6), n, fill=BLUE, font=F["tiny"])
        d.text((970, y - 2), title, fill=INK, font=F["body"])
        d.text((970, y + 32), detail, fill=MUTED, font=F["small"])
        y += 112
    rounded(d, (915, 715, 1160, 772), 18, fill=BLUE)
    d.text((955, 732), "Smart Compress", fill=(255, 255, 255), font=F["small"])
    img.save(path)


def quick_panel(path):
    img = gradient_bg()
    d = ImageDraw.Draw(img)
    rounded(d, (370, 210, 1230, 790), 38, fill=(255, 255, 255, 230), outline=(210, 222, 240), width=2)
    d.text((430, 265), "Silica", fill=INK, font=F["title"])
    draw_pill(d, (1020, 270), "Option + Space")
    rounded(d, (430, 340, 1170, 410), 20, fill=(241, 246, 255))
    d.text((462, 363), "Drop files or type action...", fill=MUTED, font=F["body"])
    for i, cmd in enumerate(["Compress latest screenshot", "Smart compress", "Extract archive", "Optimize images", "Private compress"]):
        y = 455 + i * 70
        rounded(d, (430, y, 1170, y + 58), 18, fill=(236, 244, 255) if i == 1 else (248, 250, 253))
        d.text((465, y + 16), "›", fill=BLUE, font=F["body"])
        d.text((500, y + 16), cmd, fill=INK, font=F["small"])
    img.save(path)


def menu_bar(path):
    img = gradient_bg()
    d = ImageDraw.Draw(img)
    rounded(d, (180, 105, 1420, 170), 22, fill=(246, 248, 252, 245), outline=(220, 226, 236))
    d.text((230, 126), "Finder   File   Edit   View   Go   Window   Help", fill=INK, font=F["small"])
    d.text((1220, 126), "Silica  Wi‑Fi  17:08", fill=INK, font=F["small"])
    rounded(d, (930, 185, 1390, 705), 28, fill=(255, 255, 255, 238), outline=(216, 225, 238), width=2)
    d.text((970, 228), "Silica", fill=INK, font=F["h2"])
    labels = ["Open Main Window", "Open Floating Quick Panel", "Quick Actions", "Compress Latest Screenshot", "Compress Clipboard File", "Compress Latest File", "Quick ZIP Selected Files", "Extract Selected Archive", "Status: idle"]
    y = 288
    for text in labels:
        if text == "Quick Actions":
            d.line((960, y - 16, 1360, y - 16), fill=(225, 230, 240), width=2)
            d.text((970, y), text, fill=MUTED, font=F["tiny"])
        else:
            d.text((970, y), text, fill=INK if not text.startswith("Status") else MUTED, font=F["small"])
        y += 43
    rounded(d, (230, 250, 820, 700), 34, fill=(255, 255, 255, 210))
    d.text((280, 320), "Fast local actions", fill=INK, font=F["title"])
    d.text((280, 382), "Compress screenshots, clipboard files and recent downloads without opening a heavy archive window.", fill=MUTED, font=F["body"])
    img.save(path)


def demo_gif(path):
    frames = []
    labels = [("Drop files", "Silica starts with local analysis."), ("Silica Lens", "Images and metadata carry the biggest saving."), ("Smart Compress", "Run the recommended local workflow."), ("Saved 84 MB", "Show the result in Finder.")]
    for idx, (title, subtitle) in enumerate(labels):
        img = draw_window(selected_index=idx if idx < 3 else 0)
        d = ImageDraw.Draw(img)
        d.text((390, 190), title, fill=INK, font=F["hero"])
        d.text((392, 262), subtitle, fill=MUTED, font=F["body"])
        rounded(d, (390, 350, 1458, 755), 36, fill=(255, 255, 255, 226), outline=(214, 224, 240), width=2)
        if idx == 0:
            d.rounded_rectangle((520, 445, 1328, 630), radius=30, outline=BLUE, width=5)
            d.text((710, 514), "project-assets", fill=INK, font=F["title"])
        elif idx == 1:
            d.text((470, 420), "Possible saving", fill=MUTED, font=F["small"])
            d.text((470, 460), "87 MB", fill=INK, font=F["hero"])
            d.text((850, 460), "Images 72 MB → 28 MB", fill=GREEN, font=F["h2"])
            d.text((850, 520), "Metadata 4 MB removable", fill=VIOLET, font=F["h2"])
        elif idx == 2:
            rounded(d, (620, 475, 1228, 600), 34, fill=BLUE)
            d.text((765, 514), "Smart Compress", fill=(255, 255, 255), font=F["title"])
        else:
            d.text((560, 440), "Done", fill=GREEN, font=F["hero"])
            d.text((560, 520), "Saved 84 MB", fill=INK, font=F["title"])
            rounded(d, (965, 500, 1215, 562), 18, fill=(235, 242, 255))
            d.text((1005, 518), "Show in Finder", fill=BLUE, font=F["small"])
        frames.extend([img.convert("P", palette=Image.Palette.ADAPTIVE)] * 8)
    frames[0].save(path, save_all=True, append_images=frames[1:], duration=280, loop=0, optimize=True)


smart_screen(SCREENSHOTS / "smart.png")
lens_screen(SCREENSHOTS / "lens.png")
quick_panel(SCREENSHOTS / "quick-panel.png")
menu_bar(SCREENSHOTS / "menu-bar.png")
demo_gif(OUT / "demo.gif")
print("Generated marketing assets in Docs/")
