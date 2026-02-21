# Hello.

These fancy files and other knick-knacks power rubberverse.xyz and my home network overall.

Feel free to roam through them and do things with them.

## Why not put it on Rubberverse organization?

Because I'm too lazy to do the few clicks each time to quickly change, or update something. Yes, we all go on shortcuts in life, stop looking at me that way. 

## What does this repository really contain?

It contains...

- Sample configuration files for services such as [Matrix](https://github.com/MrRubberDucky/Homelab/tree/main/1-LAN/Configurations/Matrix), [cloud-init (for Proxmox)](https://github.com/MrRubberDucky/Homelab/tree/main/1-LAN/Configurations/Proxmox) 
- [Hosts files](https://github.com/MrRubberDucky/Homelab/tree/main/1-LAN/Configurations/DNS-AdFiltering)
- Ready to (re-)use Quadlets for Podman v5.7+: [LAN](https://github.com/MrRubberDucky/Homelab/tree/main/1-LAN/Quadlet), [WAN](https://github.com/MrRubberDucky/Homelab/tree/main/2-WAN/Quadlet)

...and anything else I feel like putting on here.

This is just a dump for example configuration, or my own Quadlet files so I can re-use them whenever I have the fancy.

## Should I use Podman?

While Podman has it's short-comings - especially regarding rootless networking - it's still a great piece of software that integrates pretty well with systemd. Granted you *need* to be on the latest version in order for it to be 100% usable. By that I don't mean the software itself won't work, or it will suddenly explode - I mean that you'll be missing on quadlet features *and* some of the newest Podman goodies that make managing containers way easier.

If you're on Debian/Ubuntu, consider using [Aalvistack OBS repository](https://software.opensuse.org/download/package?package=podman&project=home%3Aalvistack). Remember to pin components as otherwise it will update too much of your system, the example pinning files can be found in my cloud-init repository. While not recommended by Debian maintainers, Podman maintainers themselves said they don't want to maintain seperate repos for such distros, which is fair. It takes time to maintain those and that time is better spent for them maintaining Podman (and related resources to it). [More about it in this discussion](https://github.com/containers/podman/discussions/17362). 

**P.S.**: When installing through Aalvistack OBS repository, you must **manually** specify all packages to install. It's not like Debian repository where you do `apt install podman` and it will install everything else ex. `aardvark-dns`, `passt`, you must specify those! You'll also need to manually install `dbus-user-session` and enable it.

Here's a full command for you if you gonna use Aalvistack OBS

`apt install dbus-user-session podman buildah cron fuse-overlayfs netavark nftables passt slirp4netns tini uidmap`

To enable and run `dbus-user-session` right after installation, run following command

`systemctl enable --global --now dbus.service`

If you want extended SUID/SGIDs then just take a look at what modifications I do in my cloud-init image. That's about as much as you need to do to get it working though.

However if you need functionality such as Docker Swarm, you won't really get it here. So, if you rely on that, then stay on Docker for the time being, *or* look into Kubernetes. Though it's yaml syntax is confusing as fuck if you ask me and it also seems to enforce High Availability approach by default so you'll need a proper cluster to toy around with it properly.

> Podman will never support Swarm functionality. If other tools are based on top of Podman to provide cross node functionality then that is fine, but we have no thoughts of adding this functionality to Podman.
> [Podman Maintainer](https://github.com/containers/podman/discussions/12886#discussioncomment-1982876)

There are no tools to my knowledge making use of Quadlet functionality yet and probably never will be, considering you need to talk with the host system to do any of this vs. with Podman socket. If you really want something comparable to Docker Swarm, there's always Komodo which uses `podman-compose` to my knowledge.
