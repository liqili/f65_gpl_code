FROM ubuntu:16.04

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata \
    build-essential flex bison bc ccache ecj fastjar file g++ gawk uuid-dev \
    gettext git java-propose-classpath libelf-dev libncurses5-dev \
    libncursesw5-dev libssl-dev python python2.7-dev python3 unzip wget \
    python3-setuptools python3-dev rsync subversion \
    swig time xsltproc zlib1g-dev sudo \
    && apt-get clean \
    # Set "docker" as root password
    echo "root:docker" | chpasswd && \
    # Adds docker user
    useradd -m docker && \
    echo "docker:docker" | chpasswd && adduser docker sudo && \
    echo "docker ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/docker

RUN git config --global user.email "liqili2005@gmail.com"
RUN git config --global user.name "Kunkka Li"

# Download and install OpenSSL 1.0.2
RUN wget https://www.openssl.org/source/openssl-1.0.2u.tar.gz && \
    tar -xvzf openssl-1.0.2u.tar.gz && \
    cd openssl-1.0.2u && \
    ./config --prefix=/usr/local/openssl-1.0.2 --openssldir=/usr/local/openssl-1.0.2 && \
    make && \
    make install

ENV PATH="/usr/local/openssl-1.0.2/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/openssl-1.0.2/lib:${LD_LIBRARY_PATH}"
RUN ln -sf /bin/bash /bin/sh

# The layers above are identical to eap772_gpl_code's Dockerfile so an existing image cache is reused.
# MediaTek kernel step: toolchain/util/mtk_lzma/lzma is a prebuilt 32-bit (i386) C++ binary,
# so the image needs the 32-bit C/C++ runtime to run it.
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get -y install lib32stdc++6 \
    && apt-get clean

# Ubuntu 16.04's GNU sed 4.2.2 creates the `sed -i` temp file under umask 0700 (mode 0000). Native
# filesystems still let the creator open it, but FUSE-like mounts such as colima/lima virtiofs refuse
# ("couldn't open temporary file ./sedXXXXXX: Permission denied"), and the TP-Link Makefiles use
# sed -i on the mapped source tree. sed >= 4.3 fixed this; install 4.8 ahead of /bin in PATH.
RUN wget https://ftp.gnu.org/gnu/sed/sed-4.8.tar.gz && \
    tar -xzf sed-4.8.tar.gz && \
    cd sed-4.8 && \
    ./configure --prefix=/usr/local && \
    make && \
    make install && \
    /usr/local/bin/sed --version | head -1

# Set docker as default
USER docker:docker

CMD ["bash"]
