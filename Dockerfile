FROM hebryan/ubuntu20.04-llvm-clang9.0-minimal AS BUILDSTAGE

ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y build-essential libz-dev libncurses-dev \
        autoconf libtool pkg-config cmake python ninja-build git

# build gRPC
WORKDIR /opt
RUN git clone --recurse-submodules -b v1.52.0 --depth 1 --shallow-submodules https://github.com/grpc/grpc
RUN mkdir -p /opt/grpc/cmake/build
WORKDIR /opt/grpc/cmake/build
RUN cmake -G Ninja \
      -DgRPC_INSTALL=ON \
      -DgRPC_BUILD_TESTS=OFF \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      ../.. && \
    ninja install


FROM ubuntu:20.04

ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY --from=BUILDSTAGE /usr/local /usr/local
RUN mkdir -p /opt/grpc/examples
COPY --from=BUILDSTAGE /opt/grpc/examples /opt/grpc/examples

RUN apt-get update
RUN apt-get install -y build-essential libz-dev libncurses-dev \
        cmake python ninja-build git

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
