# Collection of rootless Quadlet files

They'll work for about anything as long as it's Podman version `5.7.0` and above. Make sure to actually read them - you'll want to at least adjust volumes, mounts and create those directories before spinning up anything from here.

I've moved past using rootful Podman with Quadlet since I've modified my homelab a bit. Now instead of worrying about if x container can reach y container, I can just spin this up and have seperate container connect to main reverse proxy VM.

Current list of apps:

- Caddy via [qor-caddy image]()
- PyKMS via [qor-kms image]()
- VoidAuth using official image: [repository]()
- Navidrome using official image: [repository]()
- ItchClaim using official image: [repository]()
- FlareSolverr using official image: [repository]()
