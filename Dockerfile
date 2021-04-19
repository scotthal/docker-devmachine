FROM ubuntu:latest

ARG USERNAME=scotthal
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update; \
  apt-get -y install locales dialog apt-utils man-db bc zsh fish zip unzip sudo tmux vim git iproute2 procps lsb-release build-essential autoconf automake m4 bison flex libelf-dev; \
  apt-get -y install libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl; \
  apt-get -y install libgmp-dev; \
  apt-get -y dist-upgrade; \
  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen; \
  locale-gen; \
  update-locale LANG=en_US.UTF-8; \
  groupadd --gid $USER_GID $USERNAME; \
  useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME; \
  echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME; \
  chmod 440 /etc/sudoers.d/$USERNAME; \
  apt-get autoremove -y ;\
  apt-get clean -y; \
  rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=

CMD ["/bin/bash"]
