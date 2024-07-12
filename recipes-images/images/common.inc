CONFLICT_DISTRO_FEATURES = "directfb"

IMAGE_FEATURES += " \
  hwcodecs \
  package-management \
  splash \
  ssh-server-openssh \
  ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston', '', d)} \
"

CORE_IMAGE_EXTRA_INSTALL += " \
  packagegroup-core-full-cmdline \
  fbgrab \
  libgpiod \
  libgpiod-tools \
  networkmanager-nmcli \
  networkmanager-nmtui \
  networkmanager-wifi \
  rsync \
  kernel-image \
  kernel-devicetree \
"

IMAGE_PREPROCESS_COMMAND:append = " ${@ 'systemd_disable_vt;' if bb.utils.contains('DISTRO_FEATURES', 'systemd', True, False, d) and bb.utils.contains('USE_VT', '0', True, False, d) else ''} "

# Specific image types:
IMAGE_FSTYPES = "wic.xz wic.bmap ext4.gz tar.xz"
