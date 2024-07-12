DESCRIPTION = "Flutter example image"
LICENSE = "MIT"

inherit core-image features_check

require common.inc

IMAGE_FEATURES += " \
    splash \
    hwcodecs \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston', \
       bb.utils.contains('DISTRO_FEATURES',     'x11', 'x11-base x11-sato', \
                                                       '', d), d)} \
"

CORE_IMAGE_EXTRA_INSTALL += " \
        ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'weston-xwayland', '', d)} \
"
systemd_disable_vt () {
    rm ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/getty.target.wants/getty@tty*.service
}

IMAGE_INSTALL += " \
    ${MACHINE_EXTRA_RRECOMMENDS} \
    flutter-gallery \
    flutter-wayland-client \
    xdg-user-dirs \
"

IMAGE_PREPROCESS_COMMAND:raspberrypi3-64:append = " ${@ 'systemd_disable_vt;' if bb.utils.contains('DISTRO_FEATURES', 'systemd', True, False, d) and bb.utils.contains('USE_VT', '0', True, False, d) else ''} "
IMAGE_PREPROCESS_COMMAND:raspberrypi4-64:append = " ${@ 'systemd_disable_vt;' if bb.utils.contains('DISTRO_FEATURES', 'systemd', True, False, d) and bb.utils.contains('USE_VT', '0', True, False, d) else ''} "

# See
#
# https://github.com/meta-flutter/meta-flutter/blob/kirkstone/README.md#include-the-flutter-sdk-into-yocto-sdk
#
# to look for the extra steps required after SDK installation!
TOOLCHAIN_HOST_TASK:append = " nativesdk-flutter-sdk"
