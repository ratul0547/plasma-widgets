# Native Plasma 6 widgets

This bundle contains two independent plasmoids:

- **Cookie Clock** — the scalloped analog desktop clock. Clicking it opens Calendar,
  To-Do, Pomodoro Timer, and World Clock tabs. To-do items and saved cities are stored in the plasmoid's own
  Plasma configuration. Version 2 adds an optional Digital style adapted from
  Plasma Workspace 6.7.5's Digital Clock, suitable for replacing the stock
  clock in a panel. Analog and Digital instances keep independent settings.
  Its clock background can be hidden, follow Plasma colors, or use custom
  alpha-capable background and border colors in either style. Analog mode can
  rotate only the cookie shape behind its stationary dial. Its 1–120 speed
  control maps from 120 seconds per rotation down to 1 second per rotation.
  Its configuration is separated into General, Appearance, and World Clock
  pages. General dynamically shows Analog or Digital controls based on the
  selected clock style.
  Digital time, date, and time-zone text can use an optional alpha-capable
  outline configured from Appearance. The complete custom palette includes the
  analog dial, all three hands, accent and accent text, and digital text.
  Appearance follows the style selected in General and only shows relevant
  controls. Digital outlines support configurable 1–8 px thickness.
- **Fortune Cookie** — a customizable desktop quote card. It refreshes every
  15 minutes; double-click or press the refresh button to load another quote.
  Its settings include optional/custom backgrounds, Plasma or custom colors,
  KDE's native searchable font chooser, text size and spacing, an
  optional quotation mark, and an optional fixed 9 pt header with custom text
  and icon. Adaptive font sizing is enabled by default: long fortunes shrink
  only as far as the configured minimum size and remain clipped inside the card.
  The reload button can be hidden without disabling double-click refresh, and
  quote text can use a configurable outline for contrast over wallpapers. All
  custom color controls support alpha through the picker or `#AARRGGBB` values.
  Settings are divided into General, Appearance, and Advanced pages. Adaptive
  sizing uses configurable minimum and maximum sizes; equal values produce a
  fixed font size. If either control crosses the other, its boundary follows
  automatically. The Advanced page keeps the executable locked to `fortune` while
  allowing its flags and arguments to be edited safely.

No Quickshell process, Hyprland integration, or session-start command is used.

## Install (Fish)

From this extracted directory:

```fish
kpackagetool6 --type Plasma/Applet --install packages/app.morpheus.cookieclock.plasmoid
kpackagetool6 --type Plasma/Applet --install packages/app.morpheus.fortunecookie.plasmoid
```

If an older test version is already installed:

```fish
kpackagetool6 --type Plasma/Applet --upgrade packages/app.morpheus.cookieclock.plasmoid
kpackagetool6 --type Plasma/Applet --upgrade packages/app.morpheus.fortunecookie.plasmoid
```

Then right-click the Plasma desktop, choose **Enter Edit Mode** →
**Add Widgets**, and add **Cookie Clock** and **Fortune Cookie**.

Right-click **Cookie Clock** and choose **Configure Cookie Clock…** to change
its scale, sides, dial, hands, date indicators, center time, inner hour marks,
rotation, and sine-cookie shape. Version 1.3.0 applies those changes immediately
when you press **Apply**, without restarting Plasma.

The organizer closes when you click elsewhere. Use the pin button beside its
tabs to keep it open; click the pin again to restore normal auto-close behavior.
The organizer fades in when opened, and its Timer tab accepts custom durations
from 1 to 240 minutes. The World Clock tab stores cities by display name and
IANA time-zone ID. Cities are added and removed only from the dedicated
**World Clock** settings page, which provides a searchable system time-zone
list. The organizer tab stays display-only and presents the saved cities in a
two-column card grid. Cards automatically switch between theme-aware daytime
colors and a dark nighttime appearance based on each city's local hour.

Digital Clock's manual font setting also uses KDE's native searchable font
chooser.

The **Enable organizer popup** option can disable the click-open organizer for
either clock style without disabling the clock itself.

The quote widget requires `fortune`. On Fedora:

```fish
sudo dnf install fortune-mod
```

## Remove

```fish
kpackagetool6 --type Plasma/Applet --remove app.morpheus.cookieclock
kpackagetool6 --type Plasma/Applet --remove app.morpheus.fortunecookie
```
