# Copyright (C) 2022 Lisandro Damián Nicanor Pérez Meyer <lpmeyer@ics.com>
#
# Based on flashing-card-image:.bbclass,
# Copyright (C) 2015-2021 Stefano Babic <sbabic@denx.de>
#
# This class currently only supports the Variscite iMX8M-Plus based SoMs.
#
# SPDX-License-Identifier: GPLv3

inherit image-artifact-names

IMAGE_DEPENDS ?= ""

PACKAGE_ARCH = "${MACHINE_ARCH}"

DEPENDS:append = " imx-boot ${FCI_IMAGE}"

SSTATETASKS += "do_flashing_card_image"

python () {
    deps = " " + fci_getdepends(d)
    d.appendVarFlag('do_flashing_card_image', 'depends', deps)
    d.delVarFlag('do_fetch', 'noexec')
    d.delVarFlag('do_unpack', 'noexec')
}

def fci_getdepends(d):
    def adddep(depstr, deps):
        for i in (depstr or "").split():
            if i not in deps:
                deps.append(i)

    deps = []
    images = (d.getVar('IMAGE_DEPENDS', True) or "").split()
    for image in images:
        adddep(image , deps)

    depstr = ""
    for dep in deps:
        depstr += " " + dep + ":do_build"

    return depstr

def imx_boot_target(machine):
    if machine == "imx8mp-var-dart":
        return "flash_evk"
    elif machine == "imx8mp-var-ics-custom":
        return "flash_evk"
    else:
        bb.fatal("flashing-card-image: MACHINE not handled.")


def add_image_to_flashing_image(d, deploydir, imagename, target_dir):
    import os
    import shutil

    src = os.path.join(deploydir, imagename)
    if not os.path.isfile(src):
        return False

    dst = os.path.join(target_dir, "rootfs.tar.gz")
    shutil.copyfile(src, dst)
    return True

def fci_add_image(d, target_dir):
    import shutil
    # Search for images listed in S in the DEPLOY directory.
    images = (d.getVar('FCI_IMAGE', True) or "").split()
    if len(images) != 1:
        bb.fatal("flashing-card-image: FCI_IMAGE should contain only one image.")

    image = images[0]

    deploydir = d.getVar('DEPLOY_DIR_IMAGE', True)

    fstypes = (d.getVarFlag("FCI_IMAGE_FSTYPES", image, True) or "").split()
    if fstypes:
        # Search for a file explicitly with MACHINE
        imagebases = [ image + '-' + d.getVar('MACHINE', True) ]
        for fstype in fstypes:
            image_found = False
            for imagebase in imagebases:
                image_found = add_image_to_flashing_image(d, deploydir, imagebase + fstype, target_dir)
                if image_found:
                    break
            if not image_found:
                bb.fatal("flashing-card-image: cannot find image file: %s" % os.path.join(deploydir, imagebase + fstype))
    else:  # Allow also complete entries like "image.ext4.gz" in FCI_IMAGE
        if not add_image_to_flashing_image(d, deploydir, image, target_dir):
            bb.fatal("flashing-card-image: cannot find %s image file" % image)

def fci_add_bootloader(d, target_dir):
    import os
    import shutil

    machine = d.getVar('MACHINE', True)
    ibt = imx_boot_target(machine)

    deploydir = d.getVar('RECIPE_SYSROOT', True) + "/boot/"
    imagename = "imx-boot-" + machine + "-sd.bin-" + ibt

    src = os.path.join(deploydir, imagename)
    if not os.path.isfile(src):
        bb.fatal("flashing-card-image: cannot find %s bootloader file" % imagename)

    dst = os.path.join(target_dir, "imx-boot-sd.bin")
    shutil.copyfile(src, dst)


python do_flashing_card_image () {
    import shutil

    # Create the destination directory.
    workdir = d.getVar('WORKDIR', True)
    target_dir = workdir + "/rootfs/opt/images/Yocto"
    os.makedirs(target_dir, exist_ok=True)

    # Add artifacts set via FCI_IMAGE
    fci_add_image(d, target_dir)

    # Add the bootloader.
    fci_add_bootloader(d, target_dir)
}

addtask do_flashing_card_image after do_rootfs before do_image_wicenv do_image_tar
