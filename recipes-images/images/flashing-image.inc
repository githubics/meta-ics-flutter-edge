DESCRIPTION = "Image for flashing the Variscite boards. \
This image is intended to be used on the flashing SD card. \
It might also be used to run factory tests previous to flashing \
the final image into the board."
LICENSE = "CLOSED"
COMPATIBLE_MACHINE = "(imx8mm-var-dart|imx8mn-var-som|imx8mq-var-dart|imx8qm-var-som|imx8qxp-var-som|imx8qxpb0-var-som|imx8mp-var-dart)"

inherit core-image

IMAGE_FEATURES += " \
    splash \
    package-management \
    ssh-server-openssh \
    hwcodecs \
    debug-tweaks \
    tools-testapps \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston', \
       bb.utils.contains('DISTRO_FEATURES',     'x11', 'x11-base x11-sato', \
                                                       '', d), d)} \
"

CORE_IMAGE_EXTRA_INSTALL += " \
    packagegroup-core-full-cmdline \
    packagegroup-fsl-tools-gpu-external \
    packagegroup-fsl-gstreamer1.0 \
    packagegroup-fsl-gstreamer1.0-full \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xterm', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'weston-xwayland', '', d)} \
    openssh-sftp-server \
    libgpiod \
    libgpiod-tools \
    variscite-scripts \
"

IMAGE_INSTALL:append = " xz"

systemd_disable_vt () {
    rm ${IMAGE_ROOTFS}${sysconfdir}/systemd/system/getty.target.wants/getty@tty*.service
}

IMAGE_PREPROCESS_COMMAND:append = " ${@ 'systemd_disable_vt;' if bb.utils.contains('DISTRO_FEATURES', 'systemd', True, False, d) and bb.utils.contains('USE_VT', '0', True, False, d) else ''} "

# base-files is adding an fstab file that will try to mount the data partition.
# We do not need this behaviour on the flashing image, so comment out that entry.
fstab_do_not_mount_data_partition() {
    sed -i 's@/dev/mmcblk2p3@#/dev/mmcblk2p3@g' ${IMAGE_ROOTFS}${sysconfdir}/fstab
}

IMAGE_PREPROCESS_COMMAND:append = " fstab_do_not_mount_data_partition;"

IMAGE_FSTYPES = "wic.xz wic.bmap tar.xz"
