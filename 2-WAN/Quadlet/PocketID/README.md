# Information

An easy-to-use OAuth 2.0 and OpenID Connect provider that lets users sign in to your services with their passkeys. - https://github.com/pocket-id/pocket-id

## Notes

Healthcheck has a random chance to fail at start. Once systemd kills it once then it magically starts working fine. This will also break auto-updates because it seemingly does not respond to healthchecks properly so it rolls back the update lol
