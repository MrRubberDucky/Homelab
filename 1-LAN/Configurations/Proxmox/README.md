# cloud-init for Debian <insert version here>

I've spent a lot of time on this and it's still kinda wonky but at this point I'm blaming cloud-init for being way too fragile. It's also quite annoying to test... well, anyways here it is.

No remote syslogging capabilities or anything of the sorts, all this does is create a container-friendly image template you can then clone and deploy at will. Will always fetch latest Podman due to it using [OBS alvistack's repository](https://software.opensuse.org/download/package?package=podman&project=home%3Aalvistack).

You can submit PRs for versions that have that enabled though, that'd be appreciated.


## Requirements

Before you can truly use this cloud-init template snippet, you first must obtain a Debian .qcow2 "generic" cloud image. You can grab one from [Debian themselves](https://cloud.debian.org/images/cloud/).

You will also require `libquestfs-tools` installed on your Proxmox node, you can remove it afterwards if you don't want it. This will be used to chroot into `.qcow2` image and prepare it.

Oh and you also need to manually modify the cloud-init template to include things the way you want it to be. This guide will use local-lvm (non-zfs) so yeah adapt these if ya need to.


## Location of usersnippets on Proxmox 8.4+

`/var/lib/vz/snippets`

This is where you want to put `userconfig.yaml`


## Modifying qcow2 disk image

```bash
# Grab latest "generic" amd64 qcow2 image
wget https://cloud.debian.org/images/cloud/trixie/20260129-2372/debian-13-generic-amd64-20260129-2372.qcow2
# Pull GPG release.key from alvistack's OpenSUSE repository
curl -fsSL https://download.opensuse.org/repositories/home:/alvistack/Debian_Testing/Release.key -o ./home_alvistack.gpg
# Create alvistack.list (I've tried putting this on cloud-init but it does weird parsing and eats trailing slashes as it thinks they're useless so yeah, not do-able on it.)
echo "deb [signed-by=/usr/share/keyrings/home_alvistack.gpg] https://download.opensuse.org/repositories/home:/alvistack/Debian_13/ /" > ./alvistack.list
# See podman.pref from this repo and save it as podman.pref in the same directory as rest of the files
# Add the repository, GPG key and APT pinning files to the qcow2 image. Change debian.qcow2 to actual filename of your image.
virt-customize -a debian.qcow2 \
  --copy-in alvistack.list:/etc/apt/sources.list.d/ \
  --copy-in home_alvistack.gpg:/usr/share/keyrings/ \
  --copy-in podman.pref:/etc/apt/preferences.d/ \
  --run-command 'chmod 644 /etc/apt/sources.list.d/alvistack.list' \
  --run-command 'chmod 644 /usr/share/keyrings/home_alvistack.gpg'
# Remove the leftovers as we don't need the manymore
rm ./podman.pref ./home_alvistack.gpg ./alvistack.list
# Create virtual machine with any VMID you want. Customize parameters here to your liking.
qm create 9000 --name debian13-cloud --memory 1024 --cores 2 --net0 virtio,bridge=vmbr0,tag=30
# Enable qemu-guest-agent
qm set 9000 --agent enabled=1
# Add cloud-init drive
qm set 9000 --ide2 local-lvm:cloudinit --boot c --bootdisk scsi0 --serial0 socket --vga serial0
# Import disk to local-lvm
qm importdisk 9000 debian.qcow local-lvm
# Set the disk as scsi0 volume
qm set 9000 -scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
# Resize it (recommended, rootfs size is 3GB so just add 15GB, or 32GB if you have some extra space to spare.)
qm resize 9000 scsi0 15G
# Change boot order
qm set 9000 --boot order=scsi0
# Attach custom cloud-init to it.
qm set 9000 --cicustom "user=local:snippets/userconfig.yaml"
# Templatify it
printf "Turning it into template..."
qm template 9000
# Now clone the template from Proxmox UI, assign it a static IP address from cloud-init tab (if you don't have DHCP on your network) and test it (or from CLI, whatever you fancy the most.)
```


## Sanity-checking post cloning and running

1. Check if SSH works by trying to SSH into the container as any of the users
2. See if you can `sudo` as main user
3. See if you can run `podman version` - it should report version above, or equal to 5.7.0
4. See if you can run a Quadlet service
5. Check if other files inside the config.yml exist

If all works then... great! Here are some examples.

SSH'ing as rootless user:

```bash
ssh overseer@10.199.72.4
(...)
overseer@localhost:~/$ 
```

Running podman version:

```bash
overseer@localhost:~/$ podman version
Client:       Podman Engine
Version:      5.7.1
API Version:  5.7.1
Go Version:   go1.25.5
Built:        Thu Jan  1 01:00:00 1970
OS/Arch:      linux/amd64
```

Running an example Hello-World Quadlet:

```bash
nano ~/.config/containers/systemd/hello-world.container
---
[Unit]
Description=Hello World

[Install]
WantedBy=default.target

[Service]
Restart=on-failure
SystemCallArchitectures=native
MemoryDenyWriteExecute=false

[Container]
Image=quay.io/podman/hello
ContainerName=hello
---

systemctl --user daemon-reload
systemctl --user start hello-world
journalctl --user -xeu hello-world.service
Feb 09 02:06:57 localhost hello[1199]: !... Hello Podman World ...!
Feb 09 02:06:57 localhost hello[1199]:
Feb 09 02:06:57 localhost hello[1199]:          .--"--.
Feb 09 02:06:57 localhost hello[1199]:        / -     - \
Feb 09 02:06:57 localhost hello[1199]:       / (O)   (O) \
Feb 09 02:06:57 localhost hello[1199]:    ~~~| -=(,Y,)=- |
Feb 09 02:06:57 localhost hello[1199]:     .---. /`  \   |~~
Feb 09 02:06:57 localhost hello[1199]:  ~/  o  o \~~~~.----. ~~
Feb 09 02:06:57 localhost hello[1199]:   | =(X)= |~  / (O (O) \
Feb 09 02:06:57 localhost hello[1199]:    ~~~~~~~  ~| =(Y_)=-  |
Feb 09 02:06:57 localhost hello[1199]:   ~~~~    ~~~|   U      |~~
Feb 09 02:06:57 localhost hello[1199]:
Feb 09 02:06:57 localhost hello[1199]: Project:   https://github.com/containers/podman
Feb 09 02:06:57 localhost hello[1199]: Website:   https://podman.io
Feb 09 02:06:57 localhost hello[1199]: Desktop:   https://podman-desktop.io
Feb 09 02:06:57 localhost hello[1199]: Documents: https://docs.podman.io
Feb 09 02:06:57 localhost hello[1199]: YouTube:   https://youtube.com/@Podman
Feb 09 02:06:57 localhost hello[1199]: X/Twitter: @Podman_io
Feb 09 02:06:57 localhost hello[1199]: Mastodon:  @Podman_io@fosstodon.org
```


## More about the template

This template's aim is to create a solid "production-ready" containerization setup. It extends base subuid/subgid ranges to be pretty comfortable, configures all the annoying bits so you can just get right into spinning up containers, or maybe just setting up software you like. It's universal and is more of a boiler-plate for you to customize as you see fit.

It extends subuid and subgid ranges by:

- 1 billion for `containers` user. This user is used when Podman is running in rootful mode.
- 100k for `ducky` user. This user is not intended to be running containers, only for management and administration. It still gets it's own share as some programs act weird if one user just suddenly doesn't have subuids or subgids assigned.
- 1 billion or `overseer` user. This is the rootless user that you will be mostly using for Podman.

It's also assumed that you will modify your qcow2 disk image to include the Alvistack OBS directory as otherwise Podman distributed in Debian apt repositories is pretty dated and lacks many quality-of-life features and Quadlet directives.

**Why not use Fedora/Alma/Rocky?**

They're pretty bulky and a bit memory hungry, so it means you're either sacrificing extra 3GB on top of 10GB qcow2 disk image for swap, or you're just assigning 4GB to your VM.

It scales pretty well once you start adding more and more inside but running multiple of these is pretty herculean task for a home lab. Meanwhile Debian chills on 1GB of RAM and doesn't complain much.

**What does this template do?**

This template does the following:

1. Sets up a sudo user `ducky` with locked password and a SSH key
2. Sets up a rootless user `overseer` with locked password and a SSH key
3. Creates `/home/overseer/.config/systemd/user` at boot (since cloud-init failed to do it for whatever reason)
4. Toggles growpart mode to `auto` and sets resize_rootfs to `true`
5. Writes configuration files
6. Installs packages
7. Runs commands after boot

To elaborate more on #5, it creates following configuration files:

- SSH hardening snippet in `/etc/ssh/sshd_config.d/30-rubberverse.conf`
- More 'aggressive' Podman containers.conf configuration, extra subnets for containers on 10.72.xx.xx in `/etc/containers/containers.conf`
- Configures Podman storage and sets fuse-overlayfs as default in `/etc/containers/storager.conf`
- Writes three NTS time server sources in case you don't have a NTS time server available to connect to (rename this if that's the case and rename rubberverse-fw.sources in `/etc/chrony/sources.d/rubberverse-nts.sources.inv`
- Adds firewall NTS time server source, this implies it runs on your firewall which also happens to be your gateway. Change IP if that's the case, or just simply use the config above `/etc/chrony/sources.d/rubberverse-fw.sources`
- Simple chronyd configuration in `/etc/chrony/chrony.conf`
- Params for sysctl, disabling IPv6, enabling IPv4 TCP Syncookies and making Unprivileged Ports start at 80 in `/etc/sysctl.d/30-rubberverse.conf`
- More sysctl parameters, this time for zram swap. Configures swappiness levels etc. in `/etc/sysctl.d/99-cloud-tuning.conf`
- Simplest zram generator configuration, makes 1GB zstd swap in `/etc/systemd/zram-generator.conf`
- Configures subuid/subgid ranges by hand for all three users in `/etc/subuid` and `/etc/subgid`
- Sets up unattended-upgrades service in `/etc/apt/apt.conf.d/20auto-upgrades` and `/etc/apt/apt.conf.d/50unattended-upgrades`
- Creates a helper service that is intended to be ran only once, fixes various quirks related to suid/sgid problems with Podman in `/home/overseer/.config/systmed/user/podman-usernamespace.service`

To elaborate more on #6, it installs following packages:

```yml
  - qemu-guest-agent
  - cloud-guest-utils
  - unattended-upgrades
  - systemd-zram-generator
  - dbus-user-session
  - podman
  - buildah
  - cron
  - fuse-overlayfs
  - netavark
  - nftables
  - passt
  - slirp4netns
  - tini
  - uidmap
  - chrony
  - curl
  - htop
```

To elaborate more on #7, it runs following commands:

```yml
  - chmod 0700 -R /home/ducky
  - systemctl daemon-reload
  - sysctl -p /etc/sysctl.d/30-rubberverse.conf || sysctl --system
  - sysctl -p /etc/sysctl.d/99-cloud-tuning.conf || sysctl --system
  - systemctl start dev-zram0.swap
  - systemctl enable --now qemu-guest-agent
  - systemctl enable --now chronyd
  - systemctl enable --now unattended-upgrades
  - systemctl enable --now fstrim.timer
  - systemctl enable --global --now dbus.service
  - systemctl reload ssh || systemctl restart ssh
  - apt -y autoremove --purge
  - apt -y autoclean
  - apt -y clean
  - mkdir -p /usr/local/share/containers
  - mkdir -p /etc/containers/systemd/0
  - mkdir -p /home/overseer/.config/containers/systemd
  - mkdir -p /home/overseer/Appdata /home/overseer/Userdata /home/overseer/Sockets /home/overseer/Environments /home/overseer/Configs /home/overseer/Databases
  - chown -R overseer:overseer /home/overseer
  - chmod 0700 -R /home/overseer
  - loginctl enable-linger overseer
  - systemctl -M overseer@ --user daemon-reload
  - systemctl -M overseer@ --user start podman-usernamespace
  - systemctl -M overseer@ --user start podman-restart.service
  ```

Short explanation:

- Basically changes ownership of /home/ducky and /home/overseer to be more restrictive (rwx------).
- Applies sysctl parameters that were defined before in files, even though it should already do it automatically.
- Enables some services like qemu-guest-agent, chronyd, unattended-upgrades, dbus.service (since dbus-user-session wasn't pre-installed from the alvistack repo and we need it for rootless Podman operation) and fstrim.timer.
- Cleans up apt remnants.
- Creates a lot of directories and makes a skeleton directory for rootless containerization in /home/overseer.
- Enables lingering for overseer user and starts some service as him.



