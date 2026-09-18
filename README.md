# Cookie Clock and Fortune Cookie for Plasma 6

This bundle contains two independent Plasma 6 widgets. 

[Download from releases page](https://github.com/ratul0547/plasma-widgets/releases)

## Screenshot
<img width="1366" height="730" alt="image" src="https://github.com/user-attachments/assets/31766330-8dd4-43d5-afdc-9e7b1ac814bf" />

## Widgets
### Cookie Clock

Cookie Clock is a material style clock widget that provides two selectable styles:

- **Analog** — a customizable scalloped clock with configurable dial, hands, colors, accents, date indicators, shape, rotation, and rotation speed.
- **Digital** — a panel-friendly clock with configurable time, date, time zone, font, colors, and optional text outline.

Clicking the clock can open an organizer containing Calendar, To-Do, Timer, and World Clock tabs. The organizer can be disabled, pinned open, or allowed to close automatically when focus moves elsewhere. Tasks, timer settings, and saved cities are stored in the widget's Plasma configuration.

### Fortune Cookie

Fortune Cookie displays periodically refreshed output from the `fortune` or `fortune-mod` program depending on the available package in your distro. Double-click the widget to request a new fortune.

It supports:

- Plasma or custom alpha-capable colors
- Optional background and border
- KDE's native font chooser
- Adaptive minimum and maximum font sizes
- Line and letter spacing
- Optional quotation icon and fixed header
- Configurable text outline and outline thickness
- Editable `fortune` flags and arguments

## Requirements

- KDE Plasma 6
- `kpackagetool6`, normally supplied by Plasma Workspace
- `fortune` or `fortune-mod` for Fortune Cookie only

Cookie Clock does not require `fortune`.

## Cookie Clock

### Install Cookie Clock

```sh
kpackagetool6 --type Plasma/Applet --install packages/app.morpheus.cookieclock.plasmoid
```

### Upgrade Cookie Clock

```sh
kpackagetool6 --type Plasma/Applet --upgrade packages/app.morpheus.cookieclock.plasmoid
```

### Add and configure Cookie Clock

1. Right-click the desktop or panel and select **Enter Edit Mode**.
2. Select **Add Widgets**.
3. Search for **Cookie Clock**.
4. Drag it onto the desktop or panel.
5. Right-click the widget and select **Configure Cookie Clock…**.

Digital style is designed to work well in a panel. Analog and Digital styles can both be used on the desktop. The organizer popup can be enabled or disabled from General settings.

### Remove Cookie Clock

Remove active widget instances from the desktop or panel first, then run:

```sh
kpackagetool6 --type Plasma/Applet --remove app.morpheus.cookieclock
```

## Fortune Cookie

### Install the `fortune` command

Fortune Cookie requires the `fortune` executable. Install the appropriate package for your distribution:

```sh
# Fedora and related distributions
sudo dnf install fortune-mod

# Arch Linux and related distributions
sudo pacman -S fortune-mod

# Debian, Ubuntu, and related distributions
sudo apt install fortune-mod

# openSUSE
sudo zypper install fortune
```

Package names may vary slightly between distribution releases.

### Install Fortune Cookie

```sh
kpackagetool6 --type Plasma/Applet --install packages/app.morpheus.fortunecookie.plasmoid
```

### Upgrade Fortune Cookie

```sh
kpackagetool6 --type Plasma/Applet --upgrade packages/app.morpheus.fortunecookie.plasmoid
```

### Add and configure Fortune Cookie

1. Right-click the desktop or panel and select **Enter Edit Mode**.
2. Select **Add Widgets**.
3. Search for **Fortune Cookie**.
4. Drag it onto the desktop.
5. Right-click the widget and select **Configure Fortune Cookie…**.

Use General settings for refresh behavior, Appearance for visual styling, and Advanced for `fortune` flags and arguments.

### Remove Fortune Cookie

Remove active widget instances from the desktop or panel first, then run:

```sh
kpackagetool6 --type Plasma/Applet --remove app.morpheus.fortunecookie
```

## Apply an update

Plasma normally notices upgraded packages automatically. If the old interface remains visible, restart Plasma:

```sh
systemctl --user restart plasma-plasmashell.service
```

If your distribution does not provide that user service, log out and back in.

## Troubleshooting

### “Package is already installed”

Use the corresponding `--upgrade` command instead of `--install`.

### Fortune Cookie is empty

Check whether the command is available:

```sh
command -v fortune
```

If that prints no path, install `fortune` using the instructions above.

You can also test it directly:

```sh
fortune
```

### Check whether either widget is installed

List installed Plasma applets:

```sh
kpackagetool6 --type Plasma/Applet --list
```

Look for these package IDs:

- Cookie Clock: `app.morpheus.cookieclock`
- Fortune Cookie: `app.morpheus.fortunecookie`

### Configuration changes do not appear

Press **Apply** in the settings window. If the widget still displays its previous state, restart Plasma using the command in **Apply an update**.
