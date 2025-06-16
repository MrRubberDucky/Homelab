# temp notes

## Fixing borked newuidmap and newgidmap on Fedora

Source: [https://github.com/containers/podman/discussions/20386#discussioncomment-13372671](https://github.com/containers/podman/discussions/20386#discussioncomment-13372671)

Useful after you change max subuid and subgid and everything collapses.

1. `dnf reinstall -y shadow-utils`
2. `chmod 0755 /usr/bin/newuidmap /usr/bin/newgidmap`
3. `chmod -s /usr/bin/newuidmap`
4. `chmod -s /usr/bin/newgidmap`
5. `setcap cap_setuid+ep /usr/bin/newuidmap`
6. `setcap cap_setgid+ep /usr/bin/newgidmap`

## Increasing subuid/subgid limit

This is in case you get absolutely fed up with Podman moaning about running out of UIDs/GIDs. We'll give it 1 million of them.

1. Edit `/etc/subuid` and apply following ranges: `100,000-1,000,000` to first user, then `1,111,111-1,000,000` to each user afterwards (increment by one mil)

```bash
containers:100000:1000000
container_user:1111111:1000000
```

2. Edit `/etc/login.defs` and change `SUB_UID_*` and `SUB_GID_*` to match following values:

```bash
SUB_UID_MIN                100000
SUB_UID_MAX                1000000000
SUB_UID_COUNT              100000
(...)
SUB_GID_MIN                100000
SUB_GID_MAX                1000000000
SUB_GID_COUNT              100000
```

3. Add this kernel tunables by editing `sysctl.conf`. 1B is max you can go before it rejects it.

```bash
user.max_user_namespaces=1000000000
```

4. Reboot and run `podman system migrate` afterwards

Now we have 1M UID:GID combinations our user can use. In theory... can be expanded up to 1B - tho make sure other users have enough. Don't use `keep-id` on `UserNS=` as even a single container is enough to make you get that dreaded error. `keep-id` is just completely broken crapshoot, like seriously avoid using it ever. Same with `auto`, put a size limit on it like so: `UserNS=auto:size=2000`.

## Starting containers rootlessly on an non-shell user

Welcome to whatever this is supposed to be lol. Create an user you want to run a container on rootlessly first (be it for socket or whatever for your rootful container)

1. Enable lingering on them with `sudo loginctl enable-linger <user>`
2. Create an service file for the user and plop it in `$their_home_dir/.config/containers/systemd` then `chown -R $their_home_dir/.config/containers/systemd` so there are no permission issues.
3. Start the service with `sudo systemctl -M <rootless user>@ --user start <service name>`

If you expose a socket via a Volume= then it will be accessible wherever you told it to 'spawn' it.

In case you need to ever get into the shell-less user, you can do so by running following command, only use it to verify if Podman even works

1. `sudo -u <user> bash`
2. `export XDG_RUNTIME_DIR="/run/user/$UID"`
3. `export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"`

Now you can run `podman ps -a` and etc. Don't run systemctl commands here though as that's a recipe for a disaster. Exit it when you're done.
