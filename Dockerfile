# Dockerfile to create a development image to build CrealtyPrint
# Initial Dockerfile based on comments from: https://github.com/CrealityOfficial/CrealityPrint/issues/216
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
USER root

ENV TZ=US/Los_Angeles
ENV UNATTENDED=y
# Install base system software
RUN apt-get update && apt-get -y --fix-missing install \
    autoconf \
    automake \
    build-essential \
    bash-completion \
    cmake \
    curl \
    git \
    gawk \
    less \
    locales \
    make \
    openssh-server \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    sudo \
    unzip \
    vim \
    wget

# set the locale
ENV LANG=en_US.UTF-8
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# Install packages to build CrealtyPrint
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libx11-dev \
    libxext-dev \
    libxcb1-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libgstreamer1.0-dev \
    libfuse2 \
    libqt5serialport5-dev \
    libqt5websockets5-dev \
    libqt5svg5-dev \
    llvm-11-dev \
    libomp-11-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libx11-dev \
    libx11-xcb-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxrender-dev \
    libxcb1-dev \
    libxcb-glx0-dev \
    libxcb-keysyms1-dev \
    libxcb-image0-dev \
    libxcb-shm0-dev \
    libxcb-icccm4-dev \
    libxcb-sync-dev \
    libxcb-xfixes0-dev \
    libxcb-shape0-dev \
    libxcb-randr0-dev \
    libxcb-render-util0-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    qt3d5-dev \
    qtbase5-dev \
    qttools5-dev \
    qtmultimedia5-dev \
    qtdeclarative5-dev \
    zlib1g-dev

# Install Conan
RUN pip3 install conan==1.64.0

# Set up SSH server
RUN mkdir /var/run/sshd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config

# Create a non-root user for security
RUN useradd -ms /bin/bash devuser \
    && passwd -d devuser \
    && echo 'devuser ALL=NOPASSWD: ALL' > /etc/sudoers.d/devuser

# Build process try to copy libs to /usr/local/lib, give devuser access
RUN chown -R devuser:devuser /usr/local/lib

# QT installer needs to be run inside the dev env, but create the dir and access for preparation
RUN mkdir -p /opt/qt && chown -R devuser:devuser /opt/qt && \
  wget https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage -O /bin/linuxdeployqt && \
  chmod 777 /bin/linuxdeployqt

# Expose SSH port
EXPOSE 22

# Start the SSH service and keep the container running
CMD ["/usr/sbin/sshd", "-D"]
