# Fluxer

Free and open source instant messaging and VoIP chat app built for friends, groups, and communities.<br>
Project: https://github.com/fluxerapp/fluxer

In less boring language, self-hosted Discord. Somewhat.

**This is not usable out of the box, please wait for a guide before raw-dogging this.** It will be up on my main site soon. (https://rubberverse.xyz)
I'm lazy though so it may take a few months.

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
