FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
  file://config_psplash.patch \
  file://psplash-bar.png \
"
SPLASH_IMAGES = "file://psplash-poky.png;outsuffix=default"

EXTRA_OECONF:append=" --disable-startup-msg"

do_configure:prepend() {
  cp ${WORKDIR}/*.png ${S}/base-images
}
