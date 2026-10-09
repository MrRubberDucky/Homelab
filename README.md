# Hello.

> [!WARNING]
> This repository is updated *very* rarely. Stuff changes a lot and any changes done here are usually manual so unless I really wanna correct something, it may sit outdated for months.

These fancy files and other knick-knacks power [Rubberverse (my site)](https://rubberverse.xyz) and my home network overall.

Feel free to roam through them and do things with them.

https://github.com/user-attachments/assets/695b4b17-eb91-4a2b-b9b9-5bb61542eca5


## What is it used for?

To store configuration files, scripts, workarounds, hosts files and other crap.

## Anything interesting here?

Depends how you look at it.
My e-mail keeps getting blown up by weird offers to make this repository very popular and have gazillion stars, so it clearly has some worth to a distant LLM agent running on somebody's shitbox.
Dunno why would you want to e-mail me about that, just open an issue about it here.

Alas, it currently has following things...

- [Quadlet systemd template experimentation]()
- [Quadlet configurations for LAN]() and similary [WAN configurations]()
- [Hosts files]()
- [Random ass helper bash scripts]()
- [Deployment script for cloud-init]()

Some quadlet configurations may be more refined than the others but they eventually get their own treatment whenever I feel bored.
Keep in mind they're not just simple copy and paste from somewhere else, I also try to harden them to the best of my extend and at minimum they need to meet my criteria.

The criteria in question is just 'least privilege principle':

1. Container must run as rootless user -- `User=1100:1100`
2. All capabilities must be dropped -- `DropCapability=all`
3. Container rootfs, if possible, should be set to read-only -- `ReadOnly=true`
4. Seccomp set to `no-new-privileges` -- `NoNewPrivileges=true`
5. Auto-updates are configured to be pulled from image registry -- `AutoUpdate=true`

In case I'm super bored then I also try to add resource limits so there's that.

## What services can I spin up with your Quadlet configs?

Typing it all in one line would make reading miserable so here's a table instead. In no particular order. Some are outdated and may not work.

| Quadlet | Service                                                               | Description                                     |
|---------|-----------------------------------------------------------------------|-------------------------------------------------|
| [1](https://github.com/MrRubberDucky/Homelab/blob/main/1-LAN/Quadlet/Beszel/beszel.container)   | [Beszel](https://beszel.dev/)                                         | Simple, lightweight server monitoring           |
| [2](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Beszel/beszel-agent.container)   | [Beszel Agent](https://beszel.dev/guide/what-is-beszel#architecture)  | Monitors systems and communicates system metrics back to Beszel |
| [3](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Beszel/socket-proxy.container)   | [wollomatic/socket-proxy](https://github.com/wollomatic/socket-proxy) | Secure-by-design and flexible Unix socket proxy |
| [4](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Caddy/Caddy.container)   | [rubberverse/qor-caddy](https://github.com/Rubberverse/qor-caddy)     | Caddy on scratch image with third-party plugins |
| [5](https://github.com/MrRubberDucky/Homelab/blob/main/1-LAN/Quadlet/IT-Tools/tools.container)   | [sharevb/it-tools](https://github.com/sharevb/it-tools)               | Fork of IT-Tools with extra tools               |
| [6](https://github.com/MrRubberDucky/Homelab/blob/main/1-LAN/Quadlet/ItchClaim/itchclaim.container)   | [ItchClaim](https://github.com/Smart123s/ItchClaim)                   | Automatically claim free games from itch.io     |
| [7](https://github.com/MrRubberDucky/Homelab/blob/main/1-LAN/Quadlet/Vaultwarden/vaultwarden.container)   | [Vaultwarden](https://github.com/dani-garcia/vaultwarden)             | Unofficial Bitwarden compatible server written in Rust |
| [8](https://github.com/MrRubberDucky/Homelab/blob/main/1-LAN/Quadlet/Vikunja/vikunja.container)   | [Vikunja](https://vikunja.io/)                                        | Vikunja is open-source task management with lists, Kanban, Gantt, and more |
| [9](https://github.com/MrRubberDucky/Homelab/blob/main/1-LAN/Quadlet/Syncthing/syncthing.container)   | [Syncthing](https://syncthing.net/)                                   | Open Source Continuous File Synchronization |
| [10](https://github.com/MrRubberDucky/Homelab/blob/main/1-LAN/Quadlet/SillyTavern/sillytavern.container)  | [SillyTavern](https://sillytavern.app/)                               | LLM Frontend for gooners, bot roleplayers and nerds |
| [11](https://github.com/MrRubberDucky/Homelab/blob/main/1-LAN/Quadlet/Navidrome/navidrome.container)  | [Navidrome](https://www.navidrome.org/)                               | Open source web-based music collection server and streamer |
| [12](https://github.com/MrRubberDucky/Homelab/blob/main/1-LAN/Quadlet/MediaJournal/mediajournal.container)  | [Media Journal](https://github.com/mihail-pop/media-journal)          | A web app for tracking your movies, TV shows, anime, manga, books, games and music |
| [13](https://github.com/MrRubberDucky/Homelab/blob/main/1-LAN/Quadlet/Tududi/tududi.container)  | [Tududi](https://tududi.com/)                                         | A calm, open system for organizing life and work |
| [14](https://github.com/MrRubberDucky/Homelab/blob/main/1-LAN/Quadlet/PyKMS/pykms.container)  | [rubberverse/qor-kms](https://github.com/Rubberverse/qor-kms)         | Fork of py-kms with updated KmsDatabase.xml |
| [15](https://github.com/MrRubberDucky/Homelab/blob/main/1-LAN/Quadlet/VoidAuth/voidauth.container)  | [VoidAuth](https://voidauth.app/#/)                                   | SSO authentication and user management provider |
| [16](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/TinyAuth/TinyAuth-Supporter.container)  | [TinyAuth](https://tinyauth.app/)                                     | Tinyauth is the tiniest authentication and authorization server |
| [17](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/PocketID/pocketid.container)  | [Pocket ID](https://pocket-id.org/)                                   | Passkeys-only SSO authentication and user management provider |
| [18](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Rauthy/rauthy.container)  | [rAuthy](https://sebadob.github.io/rauthy/)                           | OpenID Connect Single Sign-On Identity & Access Management |
| [19](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Crowdsec/crowdsec.container)  | [Crowdsec](https://www.crowdsec.net/)                                 | Open-source IDS/IPS, WAF and bot detection |
| [20](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Coturn/coturn.container)  | [coturn](https://github.com/coturn/coturn)                            | coturn is a free open source implementation of TURN and STUN Server |
| [21](https://github.com/MrRubberDucky/Homelab/tree/main/2-WAN/Quadlet/Pelican)  | [Pelican Game Panel](https://pelican.dev/)                            | Pelican is the ultimate, free game server control panel |
| [22](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Mumble/mumble.container)      | [Mumble](https://www.mumble.info/)                                    | Open-source, low-latency, high quality voice chat software |
| [23](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Nginx/nginx.container)        | [nginx](https://nginx.org/en/)                                        | HTTP web server, reverse proxy, content cache, load balancer, TCP/UDP proxy server... |
| [24](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Umami/umami.container)        | [Umami](https://umami.is)                                             | Privacy-first analytics platform |
| [25](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Umami/sso-sidecar.container)  | [Umami SSO Sidecar](https://codeberg.org/vanutp/umami-sso) | A small tool that adds OIDC authentication to Umami |
| [26](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Umami/valkey-umami.container) | [Valkey](https://valkey.io/) | High-performance key/value datastore |
| [27](https://github.com/MrRubberDucky/Homelab/tree/main/2-WAN/Quadlet/Fluxer)  | [Fluxer](https://fluxer.app/) (+23 containers)                                            | Instant messaging and VoIP chat app built for friends, groups, and communities |
| [28](https://github.com/MrRubberDucky/Homelab/blob/main/1-LAN/Quadlet/NATS/nats.container)          | [NATS](https://nats.io/)                                              | Simple, secure, and high-performance messaging system |
| [29](https://github.com/MrRubberDucky/Homelab/blob/main/1-LAN/Quadlet/Postgres/Postgres.container)        | [Postgres]()        | meow |
| [30](https://github.com/MrRubberDucky/Homelab/blob/main/1-LAN/Quadlet/Meilisearch/meilisearch.container)  | [Meilisearch](https://www.meilisearch.com/) | Search engine API bringing AI-powered hybrid search to your sites and applications |
| [31](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/LiveKit/livekit.container)  | [LiveKit](https://github.com/livekit/livekit)                         | End-to-end realtime communication stack |
| [32](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Gatus/gatus.container)  | [Gatus](https://gatus.io/)                                            | Automated developer-oriented status page with alerting and incident support |
| [33](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/DCTS/DCTS-App.container)  | [DCTS](https://github.com/hackthedev/dcts-shipping)                   | Communication platform for the future |
| 34      | I'm reserving this number for a booru client                          | Image gallery |
| [35](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Hemmelig/hemmelig.container)  | [Hemmelig](https://github.com/HemmeligOrg/Hemmelig.app)               | (Archived) Secret sharing service |
| [36](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Comentario/comentario.container)  | [Comentario](https://gitlab.com/comentario/comentario)                | Fast, flexible, and powerful free comment server for web pages, written in Go |
| [37](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Matrix/tuwunel.container) | [Tuwunel](https://github.com/matrix-construct/tuwunel)                | High Performance Matrix Homeserver written in Rust |
| [38](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Cinny/cinny.container)  | [Cinny Web](https://cinny.in/)                                        | Alternate Matrix client that sports a familiar look |
| [39](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Sable/sable.container)  | [Sable Web](https://github.com/SableClient/Sable)                     | Fork of Cinny that brings a very Discord-like experience |
| [40](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Sygnal/sygnal.container)  | [Sygnal](https://github.com/element-hq/sygnal)                        | Reference Push Gateway for Matrix |
| [41](https://github.com/MrRubberDucky/Homelab/blob/main/2-WAN/Quadlet/Matrix/matrixrtc.container)  | [lk-jwt-service](https://github.com/element-hq/lk-jwt-service)        | Minimal service to issue LiveKit JWTs for MatrixRTC |

## Does this make use of GitOps?

No, frankly I feel like depending on a third-party Git service just to spin up my homelab is a total failure and misses the point of self-hosting by a huge mile. Why do I self-host if I still have to be dependant on a third-party git service, aye? Yeah I can self-host but I dunno, it just seems stupid. I would need to manually spin it up everytime I want to re-deploy and at that point I may as well just setup everything by hand again, fix the small inconsistencies etc.

I keep local versioned git backup of everything I do on my local pc and just selectively add things here more as examples of deployment rather than actual configuration files.

## Do you know any GitOps solutions for Quadlet functionality?

Yeah, you have [Materia by stryan and contributors](https://github.com/stryan/materia).

> [!NOTE]
> Only mount Podman / Docker socket into containers you 100% trust, preferably avoid it or look for alternatives if it's not feasible.

Keep in mind that for any such solution, you'll need to mount `Podman.socket` into the container. If you don't understand the ramifications and any potential security issues that may arise from doing something like that, then just stick to the way you're doing stuff. It's probably better.
