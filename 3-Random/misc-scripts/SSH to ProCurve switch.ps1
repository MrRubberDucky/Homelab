# It's old as hell and it's going to be eventually replaced since it started malfunctioning from time to time.
# That's about what I needed to do to connect to it so if you for some reason got a 2910al-24g then here ya go.
ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 -c 3des-cbc -oHostKeyAlgorithms=+ssh-rsa -m hmac-sha1-96 manager@192.168.1.1
