# Docker image for Yocto with Ubuntu 20.04

## Building

In this directory run the following command:

```bash
$ docker build \
 --build-arg user=$USER \
 --build-arg uid=$(id -u $USER) \
 --build-arg gid=$(id -g $USER) \
 --pull -t yocto_ubuntu_22.04 .
```

Or, if you have squid-deb-proxy or apt-cacher-ng installed, changing the IPs as needed:

```bash
$ docker build \
 --build-arg user=$USER \
 --build-arg uid=$(id -u $USER) \
 --build-arg gid=$(id -g $USER) \
 --build-arg httpproxy="http://<some IP>:3142" \
 --build-arg httpsproxy="https://<some IP>:3142" \
 --pull -t yocto_ubuntu_22.04 .
```

## Running the container

The basic command would be like (substituting YOUR_PROJECT_NAME with your project name):

```bash
$ docker run -v /mnt/yocto/${YOUR_PROJECT_NAME}:/home/$USER -v /mnt/yocto/downloads:/home/$USER/downloads -v /mnt/yocto/sstate-cache:/home/$USER/sstate-cache --rm -it yocto_ubuntu_22.04
```
You can create an alias in your ~/.bashrc

```bash
alias docker_${YOUR_PROJECT_NAME}='docker run -v /mnt/yocto/${YOUR_PROJECT_NAME}:/home/$USER -v /mnt/yocto/downloads:/home/$USER/downloads -v /mnt/yocto/sstate-cache:/home/$USER/sstate-cache --rm -it yocto_ubuntu_22.04'
```
