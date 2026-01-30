# Collection of rootless Quadlet files

They'll work for about anything as long as it's Podman version `5.7.0` and above. Make sure to actually read them - you'll want to at least adjust volumes, mounts and create those directories before spinning up anything from here.

I've moved past using rootful Podman with Quadlet since I've modified my homelab a bit. Now instead of worrying about if x container can reach y container, I can just spin this up and have seperate VM that has a container connect to main reverse proxy VM.

## Philosophy

I guess I need to say what I target with these, well here goes nothing.

- Minimal set of capabilities and privileges
- Run as user via `User=` if needed
- Randomized user namespaces, unless we need same UID/GID on host (ex. UNIX sockets, otherwise you'll have world-writeable socket chilling in your home directory)
- Read-only rootfs on containers whenever possible
- Make use of Podman features while at it and some systemd if needed
- Readable enough

Point is, they should be already pretty secure. Granted you'll have some drawbacks with ex. `UserNS=keep-id` as it will map the namespace to your rootless user which reduces it a bit. Still though, it's a rootless user we are running these as so maybe not that bad.

## Apps

Here's everything that can be found here, repository URLs will jump to project's repository so you can learn more:

- Caddy via [qor-caddy image]()
- PyKMS via [qor-kms image]()
- VoidAuth using official image: [repository]()
- Navidrome using official image: [repository]()
- ItchClaim using official image: [repository]()
- FlareSolverr using official image: [repository]()
