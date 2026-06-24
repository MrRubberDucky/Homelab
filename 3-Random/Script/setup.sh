#!/bin/bash
# for my own convenience, mostly for automating setup post-installation with cloud-init since it's unreliable.
set -e
if [ "$(id -u)" -ne 0 ]; then
  echo "Run this as root."
  exit 2
fi
. /etc/os-release
if [[ ! "$ID" = "debian" && "$VERSION_CODENAME" = "trixie" ]]; then
  echo "This can only be executed on Debian 13 (codenamed Trixie)"
fi
CONFIG="/root/.setup"
if [ ! -f "$CONFIG" ]; then
cat <<EOF > "$CONFIG"
setup_stage0=false
setup_stage1=false
setup_stage2=false
setup_stage3=false
setup_stage4=false
setup_stage5=false
setup_stage6=false
setup_stage7=false
setup_stage8=false
EOF
fi
. "$CONFIG"
install_if_missing() {
    for pkg in "$@"; do
        if dpkg -s "$pkg" >/dev/null 2>&1; then
            echo "$pkg already installed"
        else
            apt-get install -y --no-install-recommends "$pkg"
        fi
    done
}
set_flag() {
    local key="$1"
    local file="$2"
    if grep -q "^$key=" "$file"; then
        sed -i "s/^$key=.*/$key=true/" "$file"
    else
        echo "$key=true" >> "$file"
    fi
}
if [[ "$setup_stage0" != "true" ]]; then
  echo "Triggering apt update & upgrade"
  apt update; apt upgrade -y
  set_flag setup_stage0 "$CONFIG"
fi
if [[ "$setup_stage1" != "true" ]]; then
  echo "Setting up initial packages"
  install_if_missing qemu-guest-agent curl htop nftables uidmap chrony dbus-user-session unattended-upgrades cron patch wine wine32:i386
  set_flag setup_stage1 "$CONFIG"
fi
if [[ "$setup_stage2" != "true" ]]; then
  echo "Adding alvistack repository to apt"
  # -f: --fail when no response body, -s: --silent, -S: --show-error, -L: --location follow redirects (response code 3XX)
  if [ ! -f "/usr/share/keyrings/home_alvistack.gpg" ]; then
    curl -fsSL https://download.opensuse.org/repositories/home:/alvistack/Debian_13/Release.key -o /usr/share/keyrings/home_alvistack.gpg
    chmod 644 /usr/share/keyrings/home_alvistack.gpg
  fi
  if [ ! -f "/etc/apt/sources.list.d/alvistack.list" ]; then
    echo "deb [signed-by=/usr/share/keyrings/home_alvistack.gpg] https://download.opensuse.org/repositories/home:/alvistack/Debian_13/ /" > /etc/apt/sources.list.d/alvistack.list
    chmod 644 /etc/apt/sources.list.d/alvistack.list
  fi
  if [ ! -f "/etc/apt/preferences.d/50-podman.pref" ]; then
    curl -fsSL https://raw.githubusercontent.com/MrRubberDucky/Homelab/refs/heads/main/3-Random/Script/50-podman.pref -o /etc/apt/preferences.d/50-podman.pref
  fi
  if [ ! -f "/etc/apt/preferences.d/99-block-alvistack.pref" ]; then
    curl -fsSL https://raw.githubusercontent.com/MrRubberDucky/Homelab/refs/heads/main/3-Random/Script/99-block-alvistack.pref -o /etc/apt/preferences.d/99-block-alvistack.conf
  fi
  echo "Triggering apt update"
  apt update
  set_flag setup_stage2 "$CONFIG"
fi
if [[ "$setup_stage3" != "true" ]]; then
  echo "Installing Podman"
  install_if_missing podman buildah netavark aardvark-dns passt slirp4netns tini uidmap
  if [ ! -f "/etc/ssh/sshd_config.d/30-rubberverse.conf" ]; then
    curl -fsSL https://raw.githubusercontent.com/MrRubberDucky/Homelab/refs/heads/main/3-Random/Script/30-rubberverse.conf -o /etc/ssh/sshd_config.d/30-rubberverse.conf
    systemctl restart sshd
     set_flag setup_stage3 "$CONFIG"
  fi
fi
if [[ "$setup_stage4" != "true" ]]; then
  echo "Configuring chrony"
  rm /etc/chrony/chrony.conf
  curl -fsSL https://raw.githubusercontent.com/MrRubberDucky/Homelab/refs/heads/main/3-Random/Script/rubberverse-nts.source -o /etc/chrony/chrony.conf
  if [ ! -f "/etc/chrony/sources.d/rubberverse-nts.source" ]; then
    curl -fsSL https://raw.githubusercontent.com/MrRubberDucky/Homelab/refs/heads/main/3-Random/Script/chrony.conf -o /etc/chrony/sources.d/rubberverse-nts.source
  fi
  set_flag setup_stage4 "$CONFIG"
fi
if [[ "$setup_stage5" != "true" ]]; then
  echo "Configuring unattended-upgrades"
  rm /etc/apt/apt.conf.d/20auto-upgrades
  rm /etc/apt/apt.conf.d/50unattended-upgrades
  curl -fsSL https://raw.githubusercontent.com/MrRubberDucky/Homelab/refs/heads/main/3-Random/Script/20auto-upgrades -o /etc/apt/apt.conf.d/20auto-upgrades
  curl -fsSL https://raw.githubusercontent.com/MrRubberDucky/Homelab/refs/heads/main/3-Random/Script/50unattended-upgrades -o /etc/apt/apt.conf.d/50unattended-upgrades
  set_flag setup_stage5 "$CONFIG"
fi
echo "Checking if user exists, if not creating him & directories"
if ! getent passwd "overseer" >/dev/null; then
  useradd -m -s /bin/bash overseer 
  mkdir -p /srv/rootless
  chown -R overseer:overseer /srv/rootless
  chmod 0700 /srv/rootless
  loginctl enable-linger overseer
  echo "Setting up SSH for user, reusing keys"
  mkdir -p /home/overseer/.ssh
  cp /home/ducky/.ssh/authorized_keys /home/overseer/.ssh
  chown overseer:overseer /home/overseer/.ssh
  chmod 0700 /home/overseer/.ssh
  chmod 0600 /home/overseer/.ssh/authorized_keys
fi
if [[ "$setup_stage6" != "true" ]]; then
  echo "Modifying subuid and subgids manually"
  rm /etc/subuid /etc/subgid
  curl -fsSL https://raw.githubusercontent.com/MrRubberDucky/Homelab/refs/heads/main/3-Random/Script/gid -o /etc/subuid
  cp /etc/subuid /etc/subgid
  chmod 0644 /etc/subuid /etc/subgid
  set_flag setup_stage6 "$CONFIG"
fi
if [ ! -f "/etc/sysctl.d/30-rubberverse.conf" ]; then
  echo "net.ipv4.tcp_syncookies = 1" > /etc/sysctl.d/30-rubberverse.conf
fi
if [[ "$setup_stage7" != "true" ]]; then
  echo "Enabling some services"
  systemctl enable --global dbus.service
  systemctl enable fstrim.timer
  systemctl enable chronyd
  systemctl enable unattended-upgrades
  set_flag setup_stage7 "$CONFIG"
fi
if [[ "$setup_stage8" != "true" ]]; then
  echo "Grabbing cis-hardening from ovh/debian-cis"
  cd /root
  curl -fsSL https://github.com/ovh/debian-cis/releases/download/latest/cis-hardening.deb -o cis-hardening.deb
  dpkg -i ./cis-hardening.deb
  /opt/cis-hardening/bin/hardening.sh --set-hardening-level 2
  /opt/cis-hardening/bin/hardening.sh --apply
  /opt/cis-hardening/bin/hardening.sh --audit
  dpkg -r cis-hardening
  rm ./cis-hardening.deb
  set_flag setup_stage8 "$CONFIG"
fi
echo "SteamCMD dependencies"
if [ ! -f "/srv/steamcmd/steamcmd.sh" ]; then
  dpkg --add-architecture i386
  apt update
  apt install --no-install-recommends -y lib32gcc-s1 lib32stdc++6
  mkdir -p /srv/steamcmd
  echo "Installing SteamCMD"
  curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar -xzv -C /srv/steamcmd
  echo "Type quit after it's done"
  sleep 2
  cd /srv/steamcmd
  ./steamcmd.sh +quit
fi
if ! getent passwd "steamrunner" >/dev/null; then
  echo "Configuring SteamCMD user"
  useradd --system steamrunner
  chown -R steamrunner:steamrunner /srv/steamcmd
fi
echo "Ready. Reboot to kick in all the changes manually."
