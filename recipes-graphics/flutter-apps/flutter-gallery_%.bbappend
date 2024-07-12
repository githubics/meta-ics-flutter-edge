FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://flutter-gallery.service"

inherit systemd

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/flutter-gallery.service ${D}${systemd_system_unitdir}
}


# Systemd service
SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_SERVICE:${PN} = "flutter-gallery.service"

FILES:${PN} += " \
  ${systemd_system_unitdir}/flutter-gallery.service \
"

