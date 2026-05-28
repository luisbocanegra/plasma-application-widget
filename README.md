# Application widget for Plasma 6

Run arbitrary applications as widgets for your desktop/panel.

<img src="https://raw.githubusercontent.com/luisbocanegra/plasma-application-widget/master/screenshots/demo.png">

## Installation

1. Make sure you have QtWayland installed

   * Debian/Ubuntu: `qml6-module-qtwayland-compositor`
   * Arch/Fedora: `qt6-wayland`

2. Install the widget

    * From [KDE Store](https://store.kde.org/p/2355537)

        Right click on the Panel > *Add or manage widgets* > *Add new...* > *Download new...* > Search for "**Application Widget**", install and add it to a Panel/Desktop.

    * From source using `kpackagetool6`:

        ```sh
        git clone https://github.com/luisbocanegra/plasma-application-widget
        cd plasma-application-widget
        kpackagetool6 -t Plasma/Applet -i package/
        ```

    * From source using `install.sh` (Requires `cmake`, `extra-cmake-modules` and other dependencies)

        ```sh
        git clone https://github.com/luisbocanegra/plasma-application-widget
        cd plasma-application-widget
        ./install.sh
        ```

## Performance

By default, QtWayland will only expose shared memory interface (wl_shm) for buffer sharing, which is quite inefficient for high-res GPU rendered clients.
It also supports much more efficient DMA-BUFs, but this needs to be explicitly enabled by setting the following environment variable:

```sh
QT_WAYLAND_HARDWARE_INTEGRATION=linux-dmabuf-unstable-v1
```

See <https://userbase.kde.org/Session_Environment_Variables> or <https://wiki.archlinux.org/title/Environment_variables>

## Credits

* This project is based on [plasma-wallpaper-application](https://invent.kde.org/dos/plasma-wallpaper-application), adapted to work as a widget.
* [ccatterina's script](https://github.com/ccatterina) (with some modifications) to manage translations
