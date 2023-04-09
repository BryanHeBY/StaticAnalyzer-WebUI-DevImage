FROM hebryan/staticanalyzer-webui-devimage-minimal:v1.4

RUN apt-get update
RUN apt-get install -y build-essential libz-dev libncurses-dev \
        gdb cmake python ninja-build git

# install backend and frontend dependencies

RUN apt-get install -y openjdk-17-jdk curl
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y aptitude
RUN aptitude install -y nodejs npm

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
