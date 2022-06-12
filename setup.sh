#!/bin/sh

export USERNAME=scotthal
export USER_UID=1100
export USER_GID=$USER_UID
export DEBIAN_FRONTEND='noninteractive'

groupadd --gid $USER_GID $USERNAME
useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME
echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME; \
  chmod 440 /etc/sudoers.d/$USERNAME;

apt-get update; \
  apt-get -y dist-upgrade; \
  apt-get -y install locales dialog apt-utils man-db bc zsh fish zip unzip sudo tmux bat vim emacs-nox git iproute2 procps lsb-release libnss3-tools build-essential autoconf automake cmake m4 bison flex gettext httpie jq sqlite3; \
  apt-get -y install libssl-dev libcurl4-openssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev libelf-dev xz-utils tk-dev libffi-dev liblzma-dev; \
  apt-get -y install libgmp-dev; \
  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen; \
  locale-gen; \
  update-locale LANG=en_US.UTF-8

su $USERNAME -lc "\
  git clone https://github.com/scotthal/homedir; \
  mv homedir/.git .; \
  git reset --hard HEAD; \
  mv .git homedir \
"

usermod -s /bin/zsh $USERNAME

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
  apt-get -y install xubuntu-desktop xscreensaver fonts-roboto fonts-croscore fonts-noto flatpak docker.io docker-compose; \
  apt-get -y remove blueman; \
  systemctl stop lightdm.service; \
  systemctl disable lightdm.service; \
  systemctl stop gdm.service; \
  systemctl disable gdm.service; \
  update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper

usermod -a -G docker $USERNAME

mkdir -p /home/$USERNAME/bin; \
  chown $USERNAME:$USERNAME /home/$USERNAME/bin; \
  chmod 0755 /home/$USERNAME/bin

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
  curl -L 'https://download.mozilla.org/?product=firefox-devedition-latest&os=linux64&lang=en-US' | bzip2 -dc | tar -C /opt -xf -; \
  curl -L https://releases.hashicorp.com/terraform/1.2.1/terraform_1.2.1_linux_amd64.zip > /tmp/terraform.zip; \
  mkdir /tmp/terraform-unz; \
  unzip /tmp/terraform.zip -d /tmp/terraform-unz; \
  install -o $USERNAME -g $USERNAME /tmp/terraform-unz/terraform /home/$USERNAME/bin/terraform; \
  rm -rf /tmp/terraform.zip /tmp/terraform-unz; \
  mkdir /tmp/helm-unz; \
  curl -L https://get.helm.sh/helm-v3.9.0-linux-amd64.tar.gz | gzip -dc | tar -C /tmp/helm-unz -xf -; \
  install -o $USERNAME -g $USERNAME /tmp/helm-unz/linux-amd64/helm /home/$USERNAME/bin/helm; \
  rm -rf /tmp/helm-unz; \
  curl -L https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64 > /tmp/kind; \
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

cat <<EOF > /usr/share/applications/firefox.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Firefox
Exec=/opt/firefox/firefox
Icon=/opt/firefox/browser/chrome/icons/default/default64.png
Categories=Network
EOF

snap install aws-cli --classic; \
  snap install google-cloud-sdk --classic; \
  snap install code --classic; \
  snap install intellij-idea-community --classic; \
  snap install powershell --classic
  
su $USERNAME -lc "\
    code --install-extension dbaeumer.vscode-eslint; \
    code --install-extension esbenp.prettier-vscode; \
    code --install-extension hashicorp.terraform; \d
    code --install-extension ms-azuretools.vscode-docker; \
    code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools; \
    code --install-extension ms-python.python; \
    code --install-extension ms-vscode.cpptools; \
    code --install-extension ms-vscode.powershell; \
    code --install-extension ms-vscode-remote.vscode-remote-extensionpack; \
    code --install-extension pivotal.vscode-boot-dev-pack; \
    code --install-extension rebornix.ruby; \
    code --install-extension rust-lang.rust; \
    code --install-extension visualstudioexptteam.vscodeintellicode; \
    code --install-extension vscjava.vscode-java-pack
  "

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

apt-get autoremove -y ;\
  apt-get clean -y

touch /tmp/setup-done
