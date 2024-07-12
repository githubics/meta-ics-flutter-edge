#/bin/bash

set -e

if [ -n "${http_proxy}" ]; then
  echo "http_proxy=$http_proxy"
fi

if [ -n "${https_proxy}" ]; then
  echo "https_proxy=$https_proxy"
fi

apt-get update
apt-get install --yes \
  asciidoc \
  autoconf \
  automake \
  bc \
  build-essential \
  ca-certificates \
  chrpath \
  coreutils \
  cpio \
  curl \
  cvs \
  debianutils \
  desktop-file-utils \
  diffstat \
  docbook-utils \
  docker.io \
  dos2unix \
  g++ \
  g++-multilib \
  gawk \
  gcc \
  gcc-multilib \
  git \
  git-lfs \
  gnupg \
  groff \
  help2man \
  iputils-ping \
  jq \
  libarchive-dev \
  libelf-dev \
  libgl1-mesa-dev \
  libglib2.0-dev \
  libglu1-mesa-dev \
  libgnutls28-dev \
  liblz4-tool \
  libncurses5 \
  libncurses5-dev \
  libncursesw5-dev \
  libsdl1.2-dev \
  libssl-dev \
  libtool \
  libyaml-dev \
  locales \
  lz4 \
  lzop \
  make \
  mercurial \
  mtd-utils \
  npm \
  procps \
  pv \
  python3 \
  python3-git \
  python3-pexpect \
  python3-pip \
  python3-yaml \
  python-is-python3 \
  rename \
  sed \
  socat \
  subversion \
  texi2html \
  texinfo \
  u-boot-tools \
  unzip \
  wget \
  xterm \
  xz-utils \
  zlib1g-dev \
  zstd

# Set bash as default shell
echo "dash dash/sh boolean false" | debconf-set-selections - && dpkg-reconfigure dash

# Clean up apt.
apt-get clean
apt-get --purge autoremove
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*