FROM hebryan/ubuntu20.04-llvm-clang9.0-minimal

ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y build-essential libz-dev libncurses-dev \
        autoconf libtool pkg-config cmake python ninja-build git

# build gRPC
WORKDIR /opt
RUN git clone --recurse-submodules -b v1.52.0 --depth 1 --shallow-submodules https://github.com/grpc/grpc
WORKDIR /opt/grpc
RUN mkdir -p cmake/build && \
    cd cmake/build && \
    cmake -G Ninja \
      -DgRPC_INSTALL=ON \
      -DgRPC_BUILD_TESTS=OFF \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      ../.. && \
    ninja install

# build example 
WORKDIR /opt/grpc/examples/cpp/helloworld
RUN mkdir -p cmake/build && \
    cd cmake/build && \
    cmake -G Ninja -DCMAKE_PREFIX_PATH=/usr/local ../.. && \
    ninja

# General version

# Other pkg
RUN apt-get install -y sudo openssh-server

# add user
RUN useradd --create-home --no-log-init --shell /bin/bash -G sudo user && \
    adduser user sudo && \
    echo 'user:00000' | chpasswd

# sshd
RUN mkdir /var/run/sshd
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

CMD [ "/usr/sbin/sshd", "-D" ]
