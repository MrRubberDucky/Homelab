## Experimenting around with Quadlet templates

If you weren't aware, you can now create a rough template and have it be pretty dynamically filled with passed parameters via `%i`.

This will experiment around with three approaches:

1. Creating environment variables from the name passed then modifying it via env template (without need for symlinks and overrides unless strictly necessary in theory but will log warnings from quadlet-systemd-generator in journald)
2. Abusing override system with symlinks (probably most complicated setup by far but also quite flexible)
3. Overriding the generated systemd service directly (pretty volatile approach)

## Limitations

So far it's not really that much great for services where it may still use same values but with increased resource limits as then you're forced to override the template.

It's because of how quadlet-systemd-generator works where it can only act on something that exists so to override for example template@beszel-agent, I need to:

1. Create a symlink pointing from template@.container to template@beszel-agent.container - Moving this symlink or even the template will break shit
2. Create an override somewhere `template@beszel-agent.container.d` and the override file `10-override.conf`
3. Fill in the override with whatever you want and reload systemd daemon

So it becomes roughly **3 files** (1 extra directory, 2 files) for **one** quadlet configuration. Pretty tragic since this little optimization of reducing it to one template ends up yielding x2-x3 the amount of files needed to run it.

The second approach is only good for small services that already have certain preset to them and you need to override minimal amount of them.

I'm assuming that the `Image=` won't be the same or won't come from some universal repository in this case. If you have a build system going and ex. you mass build images to following repository `mycoolrepo.lan/owner` with simple naming then you can just do `Image=mycoolrepo.lan/owner/%i:latest` for example.

the rest I'll write later as I experiment around some more.
