This section is basically me going

> "I want to have an auto-configured VM deployment but I'm fed up with cloud-init sanitizer fucking up stuff".

The cloud-init itself is quite barebones but the `setup.sh` is the star of the show more or so.

It's a bit ugly and enforces checks on every single corner but it works great and that's all that matters. If you're wondering what it does:

- Your typical user & distro checks
- Creates configuration file `/root/.setup` that keeps tracks of completed configuration stages
- Triggers apt update and apt upgrade again just in case
- Installs if missing: qemu-guest-agent, curl, htop, nftables, gpg, chrony, dbus-user-session, unattended-upgrades, cron and patch
- Adds alvistack OBS repository for Podman and sets APT pinning so half of the system doesn't get updated
- Installs Podman: podman, buildah, netavark, aardvark-dns, uidmap, passt, slirp4netns, tini
- Configures sshd, unattended-upgrades, chrony
- Creates rootless user for containers and creates a special directory `/srv/rootless` thqat is owned by him. If the user exists already it will instead create the rootless directory and chown it.
- Modifies subuid and subgid values to allocate way more thna necessary suid/sgid ranges to users
- Enables TCP syncookies
- Enables following services: fstrim.timer, chrony and uanttended-upgrades
- Grabs and runs ovh/debian-cis and lets it apply some hardening crap
- Adds WineHQ repository & installs lib32gcc-s1 lib32stdc++6 and winehq-devel
- Install SteamCMD
- Removes gpg and runs apt clean up commands

It's also a dump of most random config files I have lying around and don't care enough to do something about.
