#!/bin/sh

export USERNAME=scotthal
export DEBIAN_FRONTEND='noninteractive'

echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME; \
  chmod 440 /etc/sudoers.d/$USERNAME;

apt-get update; \
  apt-get -y dist-upgrade; \
  apt-get -y install locales dialog apt-utils man-db bc zsh fish zip unzip sudo tmux vim git iproute2 procps lsb-release build-essential autoconf automake m4 bison flex gettext; \
  apt-get -y install libssl-dev libcurl4-openssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev libelf-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl; \
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
  apt-get -y install xubuntu-desktop xscreensaver fonts-roboto firefox docker.io docker-compose; \
  apt-get -y remove blueman; \
  systemctl service stop lightdm.service; \
  systemctl service disable lightdm-service; \
  systemctl service stop gdm.service; \
  systemctl service disable gdm.service

usermod -a -G docker $USERNAME

mkdir -p /home/$USERNAME/bin; \
  chown $USERNAME:$USERNAME /home/$USERNAME/bin; \
  chmod 0755 /home/$USERNAME/bin

curl -L https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb > /tmp/crd.deb; \
  dpkg -i /tmp/crd.deb; \
  apt-get -y install -f; \
  rm -f /tmp/crd.deb; \
  echo 'exec /usr/bin/xfce4-session' > /etc/chrome-remote-desktop-session; \
  curl -L https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > /tmp/chrome.deb; \
  dpkg -i /tmp/chrome.deb; \
  apt-get -y install -f; \
  rm -f /tmp/chrome.deb; \
  update-alternatives --set x-www-browser /usr/bin/google-chrome-stable; \
  curl -L https://releases.hashicorp.com/terraform/0.15.0/terraform_0.15.0_linux_amd64.zip > /tmp/terraform.zip; \
  mkdir /tmp/terraform-unz; \
  unzip /tmp/terraform.zip -d /tmp/terraform-unz; \
  install -o $USERNAME -g $USERNAME /tmp/terraform-unz/terraform /home/$USERNAME/bin/terraform; \
  rm -rf /tmp/terraform.zip /tmp/terraform-unz; \
  curl -L https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 > /tmp/minikube; \
  install -o $USERNAME -g $USERNAME /tmp/minikube /home/$USERNAME/bin/minikube; \
  rm -f /tmp/minikube; \
  curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" > /tmp/kubectl; \
  install -o $USERNAME -g $USERNAME /tmp/kubectl /home/$USERNAME/bin/kubectl; \
  rm -f /tmp/kubectl

snap install aws-cli --classic; \
  snap install code --classic; \
  snap install intellij-idea-community --classic
  
su $USERNAME -lc "\
    code --install-extension ms-vscode.cpptools; \
    code --install-extension ms-python.python; \
    code --install-extension dbaeumer.vscode-eslint; \
    code --install-extension esbenp.prettier-vscode; \
    code --install-extension visualstudioexptteam.vscodeintellicode; \
    code --install-extension ms-azuretools.vscode-docker; \
    code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools; \
    code --install-extension rust-lang.rust; \
    code --install-extension ms-vscode-remote.vscode-remote-extensionpack \
  "

apt-get autoremove -y ;\
  apt-get clean -y

touch /tmp/setup-done
