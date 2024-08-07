#!/bin/sh

export USERNAME=scotthal
export USER_UID=1100
export USER_GID=$USER_UID
export DEBIAN_FRONTEND='noninteractive'

apt-get update; \
  apt-get -y dist-upgrade; \
  apt-get -y install sudo locales less dialog apt-utils man-db bc guile-3.0 zsh fish zip unzip zstd sudo tmux bat parallel vim emacs-nox git iproute2 procps lsb-release libnss3-tools curl httpie jq sqlite3 docker.io docker-compose; \
  apt-get -y install build-essential autoconf automake cmake ninja-build m4 bison flex gettext; \
  apt-get -y install libssl-dev libcurl4-openssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev libelf-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl; \
  apt-get -y install libgmp-dev; \
  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen; \
  locale-gen; \
  update-locale LANG=en_US.UTF-8

groupadd --gid $USER_GID $USERNAME
useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME; \
  chmod 440 /etc/sudoers.d/$USERNAME;

su $USERNAME -lc "\
  git clone https://github.com/scotthal/homedir; \
  mv homedir/.git .; \
  git reset --hard HEAD; \
  mv .git homedir \
"

usermod -s /bin/zsh $USERNAME
usermod -a -G docker $USERNAME

mkdir -p /home/$USERNAME/bin; \
  chown $USERNAME:$USERNAME /home/$USERNAME/bin; \
  chmod 0755 /home/$USERNAME/bin

mkdir /tmp/helm-unz; \
  curl -L https://get.helm.sh/helm-v3.14.0-linux-amd64.tar.gz | gzip -dc | tar -C /tmp/helm-unz -xf -; \
  install -o $USERNAME -g $USERNAME /tmp/helm-unz/linux-amd64/helm /home/$USERNAME/bin/helm; \
  rm -rf /tmp/helm-unz; \
  curl -L https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64 > /tmp/kind; \
  install -o $USERNAME -g $USERNAME /tmp/kind /home/$USERNAME/bin/kind; \
  rm -f /tmp/kind; \
  curl -L https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 > /tmp/minikube; \
  install -o $USERNAME -g $USERNAME /tmp/minikube /home/$USERNAME/bin/minikube; \
  rm -f /tmp/minikube; \
  curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" > /tmp/kubectl; \
  install -o $USERNAME -g $USERNAME /tmp/kubectl /home/$USERNAME/bin/kubectl; \
  rm -f /tmp/kubectl; \
  curl -L https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 > /tmp/skaffold; \
  install -o $USERNAME -g $USERNAME /tmp/skaffold /home/$USERNAME/bin/skaffold; \
  rm -f /tmp/skaffold

if [ "$1" != "nogui" ]
then
  curl -L https://storage.googleapis.com/scotthal-devmachine-public/Roboto_Mono.zip > /tmp/Roboto_Mono.zip; \
    su $USERNAME -lc "\
      mkdir .fonts; \
      mkdir roboto-unz; \
      cd roboto-unz; \
      unzip /tmp/Roboto_Mono.zip; \
      cp static/RobotoMono-Regular.ttf ../.fonts; \
      cp static/RobotoMono-Medium.ttf ../.fonts; \
      cp static/RobotoMono-SemiBold.ttf ../.fonts; \
      cp static/RobotoMono-Bold.ttf ../.fonts; \
      cd ..; \
      rm -rf roboto-unz \
    "

  rm -f /tmp/Roboto_Mono.zip

  apt-get -y install lightdm; \
    apt-get -y install xubuntu-desktop xscreensaver fonts-roboto fonts-croscore fonts-noto flatpak; \
    apt-get -y remove blueman; \
    systemctl stop lightdm.service; \
    systemctl disable lightdm.service; \
    systemctl stop gdm.service; \
    systemctl disable gdm.service; \
    update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper

  curl -L https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb > /tmp/crd.deb; \
    dpkg -i /tmp/crd.deb; \
    apt-get -y install -f; \
    rm -f /tmp/crd.deb; \
    echo 'dbus-launch startxfce4' > /etc/chrome-remote-desktop-session; \
    curl -L https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > /tmp/chrome.deb; \
    dpkg -i /tmp/chrome.deb; \
    apt-get -y install -f; \
    rm -f /tmp/chrome.deb; \
    update-alternatives --set x-www-browser /usr/bin/google-chrome-stable; \
    curl -L 'https://download.mozilla.org/?product=firefox-devedition-latest&os=linux64&lang=en-US' | bzip2 -dc | tar -C /opt -xf -

  cat <<EOF > /usr/share/applications/firefox.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Firefox
Exec=/opt/firefox/firefox
Icon=/opt/firefox/browser/chrome/icons/default/default64.png
Categories=Network
EOF

  snap install code --classic; \
    snap install intellij-idea-community --classic
    
  su $USERNAME -lc "\
      code --install-extension dbaeumer.vscode-eslint; \
      code --install-extension editorconfig.editorconfig; \
      code --install-extension esbenp.prettier-vscode; \
      code --install-extension github.github-vscode-theme; \
      code --install-extension hashicorp.terraform; \
      code --install-extension jakebecker.elixir-ls; \
      code --install-extension ms-azuretools.vscode-docker; \
      code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools; \
      code --install-extension ms-python.python; \
      code --install-extension ms-vscode.cpptools; \
      code --install-extension ms-vscode.powershell; \
      code --install-extension ms-vscode-remote.vscode-remote-extensionpack; \
      code --install-extension pivotal.vscode-boot-dev-pack; \
      code --install-extension rebornix.ruby; \
      code --install-extension rust-lang.rust-analyzer; \
      code --install-extension visualstudioexptteam.vscodeintellicode; \
      code --install-extension vscjava.vscode-java-pack
    "

  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

apt-get -y remove exim4-base postfix; \
  apt-get autoremove -y ; \
  apt-get clean -y

touch /tmp/setup-done
