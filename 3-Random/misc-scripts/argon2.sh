#!/bin/bash
# Call this lazy but it makes generating argon2id hashes less annoying lol
printf "%b" "Input password:\n"
IFS= read -rs password
salt_16=$(openssl rand -hex 16)
argon2 "${salt_16}" -id -t 6 -m 17 -p 1 <<< "$password"
unset password salt_16
exit 0
