# Dockerfile to create a development image to build CrealtyPrint
# Initial Dockerfile courtesy of Jose Antonio Espinosa (https://github.com/yoprogramo)
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
    && passwd -d devuser

# Expose SSH port
EXPOSE 22

# Start the SSH service and keep the container running
CMD ["/usr/sbin/sshd", "-D"]
