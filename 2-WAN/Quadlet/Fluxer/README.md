# Fluxer

Free and open source instant messaging and VoIP chat app built for friends, groups, and communities.<br>
Project: https://github.com/fluxerapp/fluxer

In less boring language, self-hosted Discord. Somewhat.

**This is not usable out of the box, please wait for a guide before raw-dogging this.** It will be up on my main site soon. (https://rubberverse.xyz)
I'm lazy though so it may take a few months. Updates here are selective and don't affect all files at once. YMMV if you chose to try it anyway.

## Information

Trying to do least-privilege setups with my Quadlet configurations, not the most nutty overtightened stuff but safer than the defaults projects ship with.

- Hardened with your usual options `ReadOnly=true`, `NoNewPrivileges=true`, `DropCapability=all`, `SystemCallArchitectures=native` and very rarely `MemoryDenyWriteExecute=true`
- All containers run in randomized namespaces[1]
- Internal-only network for database and search containers (Postgres, Valkey and Meilisearch)[2]
- Certain containers run as specific user and bypass entrypoint script to launch as unprivileged user (NATS, SeaweedFS, Meilisearch and Valkey)[3]
- Modify most of the stuff you'll want in `.sysenv` without having to touch the quadlet configs themselves

[1]: Requires extending available user namespaces for your user, otherwise you'll run out instantly after launching one (1) container<br>
[2]: Internal means no outgoing connections are permitted for a container<br>
[3]: Due to usage of `su-exec` by some projects where they just can't help themselves and launch init as root<br>

## Videos you can watch while you wait

- [Have you seen Crazy Hamburger?](https://www.youtube.com/watch?v=pVbtFP40E50)
- [Enjoy this very splendid Xbox message](https://www.youtube.com/watch?v=-ih0B9yn32Q)
- [Learn what future gen consoles may come out](https://www.youtube.com/watch?v=rzLIUgnKY40)
- [See how hard life is for average Yaoi fangirl](https://www.youtube.com/watch?v=vNPzZzoNw2Y)
- [Getting beaten with a metal pipe for ragebaiting your tomboy girlfriend with 67 ASMR](https://www.youtube.com/watch?v=njiWAPXnDio)
- [Pegcraft gameplay](https://www.youtube.com/watch?v=Jv54epRqSU8)
- [First time on the internet? You Must Watch This Video!](https://www.youtube.com/watch?v=k1BneeJTDcU)
- [Say hi to Ronald](https://www.youtube.com/watch?v=5XYUqG_YZRA)
- [Did they overreact?](https://www.youtube.com/watch?v=tT1z5gyKAc8)
- [Everybody wants to waste your time](https://www.youtube.com/watch?v=56EyKNjhUDY)
- [He hates ads](https://www.youtube.com/watch?v=zgklWBIKVno)
- [Kasane Teto - Letter to a Black World on Minecraft noteblocks](https://www.youtube.com/watch?v=R3cBohZKKXE)
- [Looping, Looping, Looping the Rooms](https://www.youtube.com/watch?v=icBDYkfxpMs)
- [Can you guess how many cheaters are in CS2 Premier leaderboards before the video reveals it?](https://www.youtube.com/watch?v=pHmGy-7qTXc)

## Notes, rants and other

Random rambles, crashouts and other crap

### Normalizing the quadlet config

I'm working on making this deployment same as `docker-compose.yaml`, well maybe simpler. Compose injects all environment variables to most containers and substitutes some of them with values from .env so we could get away with a single .env doing the work.

### Kubernetes YAML

In theory you can use `podman kube play` with them. Not sure if it works with helm charts, most likely does but don't quote me on that. If not then I could try throwing up a Kubernetes YAML for it. It's your alternative to running Quadlet deployment.

### rexctl

Fluxer now uses some garbage pre-compiled Go binary to install and deploy the project. Nothing like teaching people terrible security posture by making them run some 30MB binary for something that could be deployed with 3 commands and one env being modified.

<img width="1080" height="240" alt="obraz" src="https://github.com/user-attachments/assets/420d5413-7b19-4e23-b896-1a2ffdb2686f" />

I can't really say I'm happy about this being done, especially since it's a chained install script that downloads and extracts some foreign binary on your system to do something you can't even audit because once again, IT IS A 30 MEGABYTE GO BINARY. Yeah, yeah "just go read the source code bro!!!", I can also have a perfect source code then sneak something nefarious in a pre-compiled binary. What you gonna do, read it??? Haha, loser!

Most of the time it's gonna be newbies using it and newbies should learn how to deploy something and how containerization works instead of having ready to use scripts to handle everything for them. If you gonna self-host then at the very least know your software, we have pages of documentation for both Podman and Docker one could read that's hard to grasp at first but then it starts to click the more you use it! Imagine a newbie has a very unsecure deployment and they get malware, they won't even realize aside from "oh yeah stuff works a bit slower today I guess", they won't even know that there are journal logs they can go through. Making deployment simpler for complex piece of software won't solve the problem of it still being complex to maintain, in fact it will complicate things further down the line.

Nah but seriously for somebody so overworked we sure as hell have enough time to randomly blow our whole day writing a whole Go program that generates a docker-compose.yaml and does the same stuff as the install script previously did which was overkill. This is basically murdering and then beating it up some more to make sure solution, like holy shit I'm at a loss of words! [Related xkcd](https://www.xkcd.com/2138/), [this one too I guess](https://www.xkcd.com/1739/). I hate this.

The Compose is now hidden behind a download in another wiki entry - [here](https://fluxer.dev/compose/latest) instead of being in the repo, so at least that's good that it still exists and I don't have to suffer like I thought I would night prior. I should stop writing shit when I'm sleep deprived and clearly pissed off but to be fair I'm fed up with whole homelab stuff atm so you can't blame me for crashing out. I still don't feel like writing a guide for this because one day I can wake up and see compose being completely removed in favor of this out of blue and I kinda need it because that's what I base my quadlet configs on rn. Just a human after all 🤷‍♂️
