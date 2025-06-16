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

## Changing max SUB-UID and SUB-GID

This is in case you get absolutely fed up with Podman moaning about running out of UIDs/GIDs

1. Edit `/etc/subuid` and apply following ranges: `100,000-999,999,999` to first user, then `1,111,111-999,999,999` to each user afterwards (increment by one mil)

```bash
root:100000:999999999
containers:1111111111:999999999
sample:2111111111:999999999
default:3111111111:999999999
secondacc:4111111111:999999999
```

2. Edit `/etc/login.defs` and change `SUB_UID_*` and `SUB_GID_*` to match following values:

```bash
SUB_UID_MIN                100000
SUB_UID_MAX                999999999
SUB_UID_COUNT              100000
(...)
SUB_GID_MIN                100000
SUB_GID_MAX                999999999
SUB_GID_COUNT              100000
```

3. Add two kernel tunables by editing `sysctl.conf`

```bash
kernel.unprivileged_userns_clone=1
user.max_user_namespaces=999999999
```

4. Reboot and run `podman system migrate` afterwards

Now we have 999m UID:GID combinations our user can use. (in theory)

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
