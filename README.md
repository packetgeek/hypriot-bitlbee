# hypriot-bitlbee

Short version:

Docker container for Bitlbee 3.4.1 + all available non-purple plugins, running on a Raspberry Pi 2 with the Hypriot Linux OS

Longer version:

The attached Dockerfile will build the following in a Docker container:

- Bitlbee core with OTR and libssl enabled (gnutls is not available as a package on Hypriot)
- The Steam plugin
- The Facebook MQTT plugin
- The Omegle plugin
- The Torchat plugin
- The Discord plugin (also builds the libwebsockets dependency from source)

Why:

This was part of my effort to teach myself to work with Docker, as well as getting the various non-purple plugins to work.  I later expanded on this effort by:

- creating an Openfire container
- creating a Mouffette container (bot that monitors RSS feeds)
- creating a Jabberbot container (bot that interfaces w/ home automation)
- writing a presence-sensing script to connect to Openfire and tell monit when either of the bots aren't working
- installing Monit on the host machine, to keep all of the above running

I'll eventually be adding responsitories for the other stuff.

Read the notes in the Dockerfile for help on building the container.

-- Tim
