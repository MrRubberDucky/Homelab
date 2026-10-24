# Information

An easy-to-use OAuth 2.0 and OpenID Connect provider that lets users sign in to your services with their passkeys. - https://github.com/pocket-id/pocket-id

## Notes

Healthcheck has a random chance to fail on first start. Once systemd kills it once then it magically starts working fine. This will also break auto-updates because it seemingly does not respond to healthchecks properly so it rolls back the update lol

Restarting container will make the problem either repeat or be fine. It can even start and stop a few times before it finally starts working. Don't ask me why it happens, I have no idea.
