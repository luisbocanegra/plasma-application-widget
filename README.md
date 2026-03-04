# Application widget for Plasma 6

Run arbitrary applications as widgets for your desktop/panel.

<img src="https://raw.githubusercontent.com/luisbocanegra/plasma-application-widget/master/screenshots/demo.png">

## Installation

Make sure you have QtWayland installed

* Debian/Ubuntu: `qml6-module-qtwayland-compositor`
* Arch: `qt6-wayland`

The addon can be installed using kpackagetool6:

```sh
kpackagetool6 -t Plasma/Applet -i package
```

To upgrade, run it with `-u` instead of `-i`.

To uninstall, run:

```sh
kpackagetool6 -t Plasma/Applet -r net.dosowisko.PlasmaApplicationWallpaper
```

## Performance

By default, QtWayland will only expose shared memory interface (wl_shm) for buffer sharing, which is quite inefficient for high-res GPU rendered clients.
It also supports much more efficient DMA-BUFs, but this needs to be explicitly enabled by setting the environment variable:

```
QT_WAYLAND_HARDWARE_INTEGRATION=linux-dmabuf-unstable-v1
```

## Credits

This project is based on [plasma-wallpaper-application](https://invent.kde.org/dos/plasma-wallpaper-application), I just adapted it to work as a widget.
