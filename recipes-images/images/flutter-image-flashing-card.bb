require flashing-image.inc

DESCRIPTION = "SD card image for flashing ICS's Flutter image"
SECTION = ""

inherit flashing-card-image

LICENSE = "CLOSED"

# IMAGE_DEPENDS: list of Yocto images that contains a root filesystem
# it will be ensured they are built before creating the image
IMAGE_DEPENDS = "flutter-image"

# FCI_IMAGE: image that will be added to the flashing card image -
# The image must be in the DEPLOY directory
FCI_IMAGE = " \
	flutter-image \
"

# Images can have multiple formats - define which image must be
# taken to be put in the compound image
FCI_IMAGE_FSTYPES[flutter-image] = ".tar.xz"
