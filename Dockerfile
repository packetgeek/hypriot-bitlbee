FROM        resin/rpi-raspbian:jessie
MAINTAINER  Tim Kramer <joatblog@gmail.com>
# Date: 26 Jan 2016

# This will build bitlbee 3.4.1 from source

# Following is adapted Dockerfile at:
# https://github.com/sprsquish/dockerfiles/blob/master/bitlbee/Dockerfile

# build your image by running the following:
# docker build -t pg/bitlbee .

# build your container by running the following:
# docker run -d --name bitlbee -p 16667:6667 -v data:/var/lib/bitlbee pg/bitlbee:3.4.1 password

# for now, the password at the end is required as I've not 
# yet determined how to avoid it.  It can be anything though.

# Grab the build dependencies
# Note: The xmlto install adds a lot of files and appears
# to stall on "xmlto".  Be patient.

# In the following, I had to substitute libssl-dev for libgnutls-dev because
# the latter wasn't available
RUN apt-get update
RUN apt-get install -y libglib2.0-dev g++ make g++ make xsltproc xmlto libotr5-dev libgtk2.0-dev curl tar apt-utils libssl-dev

# following needed for plugins
RUN apt-get install -y git autogen libtool automake pkgconf libjson-glib-dev libjansson-dev cmake gettext libreadline-dev dialog libssl-dev ruby-dev ruby1.8-dev rubygems

RUN libtoolize --force

# Optional, add bash to assist with troubleshooting 
# from inside the container
RUN apt-get install -y bash

# grab the source code from bitlbee.org and build it

ADD http://get.bitlbee.org/src/bitlbee-3.4.1.tar.gz .
RUN tar xvf bitlbee-3.4.1.tar.gz
RUN cd bitlbee-3.4.1 && ./configure --ssl=openssl --otr=1
RUN cd bitlbee-3.4.1 && make && make install
RUN cd bitlbee-3.4.1 && make install-dev

# add in the plugins here

RUN git clone git://github.com/jgeboski/bitlbee-facebook.git
RUN cd bitlbee-facebook && ./autogen.sh
RUN cd bitlbee-facebook && make && make install

RUN git clone git://github.com/jgeboski/bitlbee-steam.git
RUN cd bitlbee-steam && ./autogen.sh
RUN cd bitlbee-steam && make && make install

RUN git clone git://github.com/meh/bitlbee-omegle.git
RUN cd bitlbee-omegle && ./autogen.sh
RUN cd bitlbee-omegle && ./configure --prefix=/usr/local
RUN cd bitlbee-omegle && make && make install


RUN git clone git://github.com/meh/bitlbee-torchat.git
RUN cd bitlbee-torchat && ./autogen.sh
RUN cd bitlbee-torchat && ./configure --prefix=/usr/local
RUN cd bitlbee-torchat && make && make install
RUN cd bitlbee-torchat && gem install --pre torchat

# current verison of libwebsockets required for bitlbee-discord
RUN git clone git://github.com/warmcat/libwebsockets.git
RUN cd libwebsockets && mkdir build
RUN cd libwebsockets/build && cmake ..
RUN cd libwebsockets/build && make all && make install
RUN libtoolize --force

RUN git clone git://github.com/sm00th/bitlbee-discord.git
RUN cd bitlbee-discord && ./autogen.sh
RUN cd bitlbee-discord && ./configure
RUN cd bitlbee-discord && make && make install
#RUN libtool --finish /usr/local/lib/bitlbee/
RUN libtoolize --force

# following is a cheesy work-around to help discord find libwebsockets
RUN echo /usr/local/lib/bitlbee >> /etc/ld.so.conf
RUN ldconfig

# Other things to try
# - https://github.com/bentglasstube/bitlbee-gvoice
# - http://www.jhh.me/blog/2012/03/11/configuring-bitlbee-with-everything/ 
#   look at bottom of page

# following pulls in the run script and sets up the service
ADD run /bitlbee/run
RUN chmod +x /bitlbee/run

# If you have the account file for a separate bitlbee account,
# uncomment the following and change "tim.xml" to your.xml.
# Note: must be the same version of bitlbee as the one that
# created the .xml file.
#ADD tim.xml /bitlbee/state/accounts/tim.xml
#RUN chown root: /bitlbee/state/accounts/tim.xml
#RUN chmod 600 /bitlbee/state/accounts/tim.xml

EXPOSE 6667
ENTRYPOINT ["/bitlbee/run"]
CMD ["noop"]
