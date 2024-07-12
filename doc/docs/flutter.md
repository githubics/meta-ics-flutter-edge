# Flutter

This layer provides the flutter-image which includes flutter-gallery among other examples. In order to run any of the applications:

1. Check the installed files.

List the files provided by any of the aforementioned packages by issuing:

```bash
$ dpkg -L flutter-gallery
/.
/lib
/lib/systemd
/lib/systemd/system
/lib/systemd/system/flutter-gallery.service
/lib/systemd/system-preset
/lib/systemd/system-preset/98-flutter-gallery.preset
/usr
/usr/share
/usr/share/flutter
/usr/share/flutter/flutter-gallery
/usr/share/flutter/flutter-gallery/3.19.3
/usr/share/flutter/flutter-gallery/3.19.3/release
/usr/share/flutter/flutter-gallery/3.19.3/release/data
[...]
/usr/share/flutter/flutter-gallery/3.19.3/release/data/flutter_assets/vm_snapshot_data
/usr/share/flutter/flutter-gallery/3.19.3/release/lib
/usr/share/flutter/flutter-gallery/3.19.3/release/lib/libapp.so
/usr/share/flutter/flutter-gallery/3.19.3/release/data/icudtl.dat
/usr/share/flutter/flutter-gallery/3.19.3/release/lib/libflutter_engine.so
```

Now that we know where the files are we need to set the required variables to connect to `weston`, but beware that some of them might be there.

The basic set is:
- XDG_RUNTIME_DIR
- WAYLAND_DISPLAY

On the `var-dart-mx8mp` these are set by default on any console.

On the RPis you need to set them both. So if you are on a RPi be sure to do this before calling `flutter-client`;

```bash
$ export XDG_RUNTIME_DIR=/run/user/1000
$ export WAYLAND_DISPLAY=wayland-1
```

**Note:** on the Variscite board you need to either omit setting `WAYLAND_DISPLAY` or set it to `wayland-0` instead.

Now we are ready to launch the application. Open a terminal and run:

```bash
$ LD_LIBRARY_PATH=/usr/share/flutter/flutter-gallery/3.19.3/release/lib flutter-client -b /usr/share/flutter/flutter-gallery/3.19.3/release
```
