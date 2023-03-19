FROM ubuntu:20.04 AS BUILDSTAGE

ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y build-essential libz-dev libncurses-dev \
        autoconf libtool pkg-config cmake python ninja-build git

# Build llvm clang 9.0.1
RUN apt-get install -y wget
RUN mkdir -p /opt/llvm-source-build
COPY llvm-src-archive /opt/llvm-source-build/llvm-src-archive
RUN wget --directory-prefix /opt/llvm-source-build/llvm-src-archive \
    https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/llvm-9.0.1.src.tar.xz \
    https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/clang-9.0.1.src.tar.xz \
    https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/compiler-rt-9.0.1.src.tar.xz \
    https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/libcxx-9.0.1.src.tar.xz \
    https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/libcxxabi-9.0.1.src.tar.xz \
    https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/clang-tools-extra-9.0.1.src.tar.xz
COPY llvm-clang-install.sh /opt/llvm-source-build
RUN bash /opt/llvm-source-build/llvm-clang-install.sh

# Build gRPC
WORKDIR /opt
RUN git clone --recurse-submodules -b v1.52.0 --depth 1 --shallow-submodules https://github.com/grpc/grpc
RUN mkdir -p /opt/grpc/cmake/build
WORKDIR /opt/grpc/cmake/build
RUN cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=ON \
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
        gdb cmake python ninja-build git

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
