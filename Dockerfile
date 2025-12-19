FROM ubuntu:rolling

ARG USERNAME=scotthal
ARG USER_UID=1100
ARG USER_GID=$USER_UID

ENV DEBIAN_FRONTEND=noninteractive

RUN /usr/bin/yes | unminimize; \
  apt-get update; \
  apt-get -y dist-upgrade; \
  apt-get -y install sudo locales less dialog apt-utils man-db ripgrep fzf zoxide tree bc guile-3.0 zsh fish zip unzip 7zip zstd sudo tmux bat parallel vim emacs-nox git iproute2 procps lsb-release libnss3-tools curl httpie jq sqlite3 docker.io docker-compose; \
  apt-get -y install docker-buildx; \
  apt-get -y install build-essential autoconf automake bubblewrap cmake ninja-build m4 bison flex gettext; \
  apt-get -y install libssl-dev libcurl4-openssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev libelf-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl; \
  apt-get -y install libgmp-dev; \
  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen; \
  locale-gen; \
  update-locale LANG=en_US.UTF-8; \
  groupadd --gid $USER_GID $USERNAME; \
  useradd --uid $USER_UID --gid $USER_GID -m $USERNAME; \
  usermod -s /bin/zsh $USERNAME; \
  echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME; \
  chmod 440 /etc/sudoers.d/$USERNAME; \
  apt-get autoremove -y ;\
  apt-get clean -y; \
  rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=

WORKDIR /home/${USERNAME}
USER ${USERNAME}

CMD ["/bin/zsh"]
