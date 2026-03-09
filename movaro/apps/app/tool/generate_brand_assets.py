from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
BRAND_DIR = ROOT / "assets" / "brand"
SIZE = 1024
CORNER_RADIUS = 248

TOP_COLOR = (9, 17, 31)
BOTTOM_COLOR = (33, 96, 184)
MARK_LIGHT = (247, 250, 255, 255)
MARK_DARK = (9, 17, 31, 255)
MARK_TINTED = (99, 108, 122, 255)

MARK_POINTS = [
    (246, 770),
    (246, 296),
    (418, 590),
    (512, 428),
    (606, 296),
    (778, 590),
    (778, 296),
]

MARK_WIDTH = 108


def _gradient_background(size: int) -> Image.Image:
    image = Image.new("RGBA", (size, size))
    draw = ImageDraw.Draw(image)
    for y in range(size):
        ratio = y / max(size - 1, 1)
        color = tuple(
            int(TOP_COLOR[index] + (BOTTOM_COLOR[index] - TOP_COLOR[index]) * ratio)
            for index in range(3)
        ) + (255,)
        draw.line((0, y, size, y), fill=color)

    haze = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    haze_draw = ImageDraw.Draw(haze, "RGBA")
    haze_draw.ellipse((540, 120, 980, 560), fill=(71, 196, 255, 48))
    haze_draw.ellipse((60, 620, 480, 1040), fill=(136, 163, 255, 32))
    haze_draw.rounded_rectangle(
        (72, 72, 952, 952),
        radius=220,
        outline=(255, 255, 255, 18),
        width=2,
    )
    return Image.alpha_composite(image, haze.filter(ImageFilter.GaussianBlur(64)))


def _draw_rounded_polyline(
    draw: ImageDraw.ImageDraw,
    points: list[tuple[int, int]],
    width: int,
    color: tuple[int, int, int, int],
) -> None:
    draw.line(points, fill=color, width=width, joint="curve")
    radius = width // 2
    for x, y in points:
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=color)


def _draw_mark(
    draw: ImageDraw.ImageDraw,
    color: tuple[int, int, int, int],
) -> None:
    _draw_rounded_polyline(draw, MARK_POINTS, MARK_WIDTH, color)


def _apply_mask(image: Image.Image, rounded: bool) -> Image.Image:
    if not rounded:
        return image

    mask = Image.new("L", image.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, image.size[0], image.size[1]),
        radius=CORNER_RADIUS,
        fill=255,
    )
    image.putalpha(mask)
    return image


def _new_transparent() -> Image.Image:
    return Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))


def _svg_markup(stroke: str) -> str:
    points = " ".join(f"{x},{y}" for x, y in MARK_POINTS)
    return f"""<svg width="256" height="256" viewBox="0 0 1024 1024" fill="none" xmlns="http://www.w3.org/2000/svg">
  <polyline
    points="{points}"
    stroke="{stroke}"
    stroke-width="{MARK_WIDTH}"
    stroke-linecap="round"
    stroke-linejoin="round"
  />
</svg>
"""


def _write_svgs() -> None:
    (BRAND_DIR / "movaro_mark_light.svg").write_text(
        _svg_markup("#F7FAFF"),
        encoding="utf-8",
    )
    (BRAND_DIR / "movaro_mark_dark.svg").write_text(
        _svg_markup("#09111F"),
        encoding="utf-8",
    )


def generate() -> None:
    BRAND_DIR.mkdir(parents=True, exist_ok=True)

    icon = _gradient_background(SIZE)
    icon = _apply_mask(icon, rounded=True)
    icon_draw = ImageDraw.Draw(icon, "RGBA")
    _draw_mark(icon_draw, MARK_LIGHT)
    icon.save(BRAND_DIR / "movaro_app_icon.png")

    foreground = _new_transparent()
    foreground_draw = ImageDraw.Draw(foreground, "RGBA")
    _draw_mark(foreground_draw, (255, 255, 255, 255))
    foreground.save(BRAND_DIR / "movaro_app_icon_foreground.png")

    monochrome = _new_transparent()
    monochrome_draw = ImageDraw.Draw(monochrome, "RGBA")
    _draw_mark(monochrome_draw, (0, 0, 0, 255))
    monochrome.save(BRAND_DIR / "movaro_app_icon_monochrome.png")

    ios_dark = _new_transparent()
    ios_dark_draw = ImageDraw.Draw(ios_dark, "RGBA")
    _draw_mark(ios_dark_draw, (255, 255, 255, 255))
    ios_dark.save(BRAND_DIR / "movaro_app_icon_ios_dark.png")

    ios_tinted = _new_transparent()
    ios_tinted_draw = ImageDraw.Draw(ios_tinted, "RGBA")
    _draw_mark(ios_tinted_draw, MARK_TINTED)
    ios_tinted.save(BRAND_DIR / "movaro_app_icon_ios_tinted.png")

    _write_svgs()


if __name__ == "__main__":
    generate()
