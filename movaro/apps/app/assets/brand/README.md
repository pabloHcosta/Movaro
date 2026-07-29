# Movaro brand assets

The Movaro symbol is a continuous route ribbon: it starts open and bright,
folds into an `M`, and rises toward a warm destination marker. It is designed
to remain recognizable without letters at launcher-icon sizes.

## Files

- `movaro_app_icon.svg`: full-bleed master for the default iOS and legacy
  Android icon. Never add rounded corners or transparency to this file.
- `movaro_app_icon_foreground.svg`: transparent adaptive-icon foreground.
- `movaro_app_icon_macos.svg`: rounded, transparent-canvas master for macOS.
- `movaro_mark_light.svg`: full-color symbol for dark surfaces.
- `movaro_mark_dark.svg`: full-color symbol for light surfaces.
- `movaro_mark_monochrome.svg`: single-color source for Android themed icons
  and other template treatments.
- `movaro_splash_hero.svg`: tightly cropped full-color hero for launch and
  branded loading surfaces.
- PNG files are generated from these SVG masters and should not be edited by
  hand.

## Usage

Keep clear space around the symbol equal to at least half the ribbon width.
Use the light mark on dark/navy backgrounds and the dark mark on white or pale
backgrounds. Do not rotate, outline, recolor individual ribbon segments, bake
corner masks into the app icon, or place text inside the launcher icon.

Core colors: midnight `#050B15`, cobalt `#0B64EE`, cyan `#57DCF7`, coral
`#FF826F`, and cloud `#FFFFFF`.
