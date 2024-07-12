FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# This call before setting up the proxy avoids an apt-cacher-ng issue.
RUN apt-get update

# Set proxy variables if defined. Useful if you have a package cacher.
ARG httpproxy
ARG httpsproxy

# Get user, UID and GID as parameters.
ARG user
ARG uid
ARG gid

COPY install.sh /tmp/
RUN cd /tmp && http_proxy=$httpproxy https_proxy=$httpsproxy ./install.sh && rm -vf install.sh

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Remember to change the uid, gid and user in the following stanzas.
RUN export uid=$uid gid=$gid user=$user && \
  mkdir -p /home/${user} && \
  echo "${user}:x:${uid}:${gid}:${user},,,:/home/${user}:/bin/bash" >> /etc/passwd && \
  echo "${user}:x:${uid}:" >> /etc/group && \
  echo "${user} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${user} && \
  chmod 0440 /etc/sudoers.d/${user} && \
  chown ${uid}:${gid} -R /home/${user}

# Allow the normal user to run docker
RUN usermod -a -G docker ${user}

ENV HOME /home/${user}
ENV USER ${user}
USER ${user}
WORKDIR /home/${user}

RUN git config --global color.ui false

# Improve rebuild performance by enabling compiler cache
ENV USE_CCACHE 1
ENV CCACHE_DIR /home/${user}/.ccache

# some QT-Apps/Gazebo do not show controls without this
ENV QT_X11_NO_MITSHM 1

# Share the downloads and sstae-cache by default.
ENV BB_ENV_PASSTHROUGH_ADDITIONS="DL_DIR SSTATE_DIR"
ENV DL_DIR="${HOME}/downloads"
ENV SSTATE_DIR="${HOME}/sstate-cache"
