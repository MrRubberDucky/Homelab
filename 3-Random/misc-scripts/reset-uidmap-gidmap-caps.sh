#!/bin/bash
# sometimes pesky programs modify it and break everything.
sudo chmod u-s /usr/bin/newuidmap /usr/bin/newgidmap
sudo setcap cap_setuid=ep /usr/bin/newuidmap
sudo setcap cap_setgid=ep /usr/bin/newgidmap
