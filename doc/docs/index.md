# Building the ICS' Flutter Edge demo

By Integrated Computer Solutions, Inc. Part of [Flutter Embedded](https://www.flutter-embedded.com/)

## Conventions

For the purposes of this document, the term target will refer to the target device: a Raspberry Pi machine or Variscite hardware. The term **host** will refer to the Linux machine used for building this image (native or virtual).

## Overview

The purpose of this document is to outline the steps necessary to build a bootable image for ICS' Flutter Edge.

## Setting up the host

For the build host we used an Ubuntu 22.04 LTS build, 64-bit. The following instructions should be used for a native machine, a [Docker container](https://github.com/githubics/ics-flutter-edge-manifests/blob/kirkstone/docker/README.md) or a VM running Ubuntu 22.04 LTS.

**NOTE:** The configuration of the Yocto build will include the “rm_work” class, so that build products will be deleted once packaging is complete. This will reduce the overall disk space required, but it is advised you have at least 100 GB available in the event you need to build without the rm_work class for development/debugging. If you want to avoid this see `local.conf` below.

After installation of the host OS, you will need to install some packages, as well as configure the dash shell to not act as the system shell.

You can find the full list of commands in[this script](https://github.com/githubics/ics-flutter-edge-manifests/blob/kirkstone/docker/install.sh).

## Installing the Yocto environment

For these steps, we will assume you are installing all of this in your home directory, so the paths given will be relative to your home directory.

### Configuring git

It is worth configuring git in case some change to a repository needs to be done:

```bash
$ git config --global user.name "Your Name"
$ git config --global user.email "Your Email"
```

### Installing repo

The first thing we need is the repo command. This command will be responsible for retrieving the initial Yocto build environment, bitbake, and the other basic layers needed.

So, first, install repo:

```bash
$ cd
$ mkdir bin
$ curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$ chmod 755 bin/repo
$ export PATH=~/bin:$PATH
```

Now that we have the repo command, and it is in our PATH, we can begin retrieving the rest of the pieces.

### Installing the Yocto Build Environment

Now we use the repo command to get the Yocto and other layers:

```bash
$ cd
$ mkdir ics-flutter-edge
$ cd ics-flutter-edge
$ repo init -u https://github.com/githubics/ics-flutter-edge-manifests.git -b kirkstone
$ repo sync -j$(nproc)
```

Note that the repo sync command may take a while. The Yocto layers will be located in the `~/ics-flutter-edge/layers/` directory in your home directory.

### Preparing for the first build

At this point we are almost ready for the first build. We will need to set up our shell environment. We provide a script that does so, including copying the default configuration for our build from our `meta-ics-flutter-edge` layer.

The configurations will be located at `~/ics-flutter-edge/build_\<MACHINE\>/conf/`.

In order to initialize and create the directory in which we will do the build run:

```bash
$ cd ~/ics-flutter-edge
$ export MACHINE=<machine>
$ source ics-setup-release build_$MACHINE
```

Where **MACHINE** is one of:
- raspberrypi3-64
- raspberrypi4-64
- imx8mp-var-dart

At this point, you will see that your current directory is now `~/ics-flutter-edge/build_${MACHINE}`. It will be created if it does not already exist.

The above command is only mandatory for the very first build setup: whenever restarting a newer build session (from a different terminal or in a different time), you can skip the full setup and just run:

```bash
$ cd ~/ics-flutter-edge
$ export MACHINE=<machine>
$ source setup-environment build_$MACHINE
```

## Building the Target Image and the SDK

Now that the prerequisites are out of the way, we can build any of the target images first. This is likely to take a few hours, and requires an Internet connection so that the actual package sources can be downloaded. It is worth mentioning that the sources are only downloaded once unless bitbake is directed to do otherwise.

### Available target images

The current images are:

- **flutter-image:** provides an image with flutter on it. It also adds thermostat-flutter and flutter-gallery.

For more info on Flutter take a look at the [flutter section](flutter.md).

### Building the Target Images

If you have been following along, you should still be in your `~/ics-flutter-edge/build/` directory, after having sourced in the export script. To build the image:

```bash
$ bitbake flutter-image
```

This should proceed without errors. If there are intermittent failures due to downloading packages, you can restart the build by simply re-running the bitbake command above from within your `~/ics-flutter-edge/build directory`. It will try to pick up where it left off.

A typical error happens when the system tries to build more than one Flutter app at the same time, retrieving dependencies from [pub.dev](https://pub.dev/). If this happens try building one app at a time and then the full image.

When it completes, you will find an image that will be later used to flash the device. The image will be located in the `~/ics-flutter-edge/build/tmp/deploy/images/${MACHINE}` directory, and will be named:

**flutter-image-\<MACHINE\>-\<date_stamp\>.rootfs.wic**

Where **MACHINE** is the selected machine and **date_stamp** is the build date in YYYYMMDDhhmmss format.

## Flashing the Target

Under Linux there are two main ways to flash the ICS' Flutter Edge's SD card: using bmap-tools' `bmaptool` or `dd`. Both require sudo or super user permissions.

### Locating the SD card device node

Plug the SD card into the reader and then issue `lsblk`. You should see something like:

```bash
$ lsblk
NAME                MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
[...]
sdc                   8:32   1    15G  0 disk
└─sdc1                8:36   1     1G  0 part
[...]

```

In this case the SD card is represented by the device node `/dev/sdc` (note we do not use the final number, ie, it's sdc and not sdc1).

If you are still unsure you can run `lsblk` with and without the SD card plugged into the reader and check the differences.

### Using bmaptool

This tool is able to flash the µSD card in a faster way than dd. The usage is simple:

```bash
$ cd ~/ics-flutter-edge/build_<MACHINE>/tmp/deploy/images/$MACHINE/
$ sudo bmaptool copy flutter-image-$MACHINE-<date_stamp>.rootfs.wic.xz /dev/sdX
```

Replace **X** with the letter representing your µSD card.

### Using dd

dd will copy the image byte per byte to the µSD card.

```bash
$ xzcat flutter-image-$MACHINE-<date_stamp>.rootfs.wic.xz | sudo dd of=/dev/sdX bs=1M status=progress
```

Replace **X** with the letter representing your µSD card.

## Updating the Yocto setup

From time to time you might need to apply an update on the Yocto setup.  As described in “Installing the Yocto Environment” the whole set of files are managed by Google repo’s tool, so we need to invoke  it asking it to sync again:

```bash
$ cd ~/ics-flutter-edge
$ repo sync -j$(nproc)
```

Now compare your `conf/local.conf` and `conf/bblayers.conf` files with the ones in  `~/ics-flutter-edge/meta-ics-flutter-edge/buildconf`. For example if you are using Linux you might do:

```bash
$ kdiff3 ~/ics-flutter-edge/sources/meta-ics-flutter-edge/buildconf/local.conf.sample  ~/ics-flutter-edge/build_<MACHINE>/conf/local.conf
$ kdiff3 ~/ics-flutter-edge/sources/meta-ics-flutter-edge/buildconf/bblayers.conf.sample  ~/ics-flutter-edge/build_<MACHINE>/conf/bblayers.conf
```

If needed modify your current configuration accordingly. If your `local.conf` file needs to be modified it is advised to remove your tmp directory and use the cache to rebuild most of the packages:

```bash
$ rm -rf ~/ics-flutter-edge/build_<MACHINE>/tmp/
```

Finally we need to source the environment, clean the image and rebuild it:

```bash
$ bitbake flutter-image-swu -c cleansstate
$ bitbake flutter-image-swu
```