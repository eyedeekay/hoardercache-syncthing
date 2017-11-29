hoardercache-syncthing
======================

This is a system for syncing the contents of folders on a remote computer with a
central apt-cacher-ng instance, running in a docker container, on my home
network. Right now it only works with my specific apt-cacher-ng configuration.
But I'm documenting it to see if I can make a more generic version.
Like many things, it's borne out of a desire for efficient communication between
my computers using addresses that can be self-assigned. In this case, my apt
caching repository is pretty important to my life and I wanted a way to cause
pacakges to be imported from remote sources. It enables and encourages this by
exposing the "/var/cache/apt-cacher-ng/_import" directory as a read-write
Syncthing share, which devices can use to sync any debs they acquire with the
apt-cacher-ng import folder.

How it works-Step by Step
-------------------------

Docker Volumes are essential to making this work in the way I wanted it to. But
I also abuse the volumes a little bit because I like having them in the working
directory and not in the volumes directory. So if you want that, create folders
corresponding to the described volumes in the working directory, and transfer
group ownership of them to docker, and make them group writable.

        mkdir -p import syncthing
        sudo chown user:docker import syncthing && sudo chown g+w import syncthing

Then you need to create an alpine:edge container with the following volumes:

        VOLUME ["/home/st/cache"] #This volume corresponds to the shared volume
          #with the apt-cacher-ng container
        VOLUME ["/home/st/import"] #This volume is the _import folder of the
          #apt-cacher-ng container where we will will sync packages
        VOLUME ["/home/st/.config/syncthing"] #This volume is where we keep the
          #syncthing settings between container updates/reboots.

Then, add Syncthing, Make, and the system certificates to the container

        RUN apk update
        RUN apk add syncthing make ca-certificates

Then create the user for within the container. This user will run the syncthing
instance.

        RUN adduser -h /home/st/ -S -D st st

copy the makefiles from this and the hoardercache folder that downloaded it
to the home directory of the st user and change to it

        COPY . /home/st/
        WORKDIR /home/st/

Create the folders inside the container and make sure the permissions are
correct

        RUN mkdir -p /home/st/cache /home/st/import/.stfolder
        RUN chown -R st /home/st/
        RUN chmod a+w /home/st/

Switch user

        USER st

and, in one final step, generate the required settings and launch the syncthing
application, listening on all addresses so we can see the menu from the host of
the docker container. Instead, launch the container so that it only listens on
the localhost.

        CMD syncthing -generate /home/st/.config/syncthing && \
                make syncthing-emitconf && \
                syncthing -gui-address=0.0.0.0:43842 -no-browser

The configuration generation is verbose, but not actually complicated. In this
step what's happening is:

  1. A configuration file is generated in the default syncthing configuration
  directory.

  2. The "make syncthing-emitconf" target is called. It searches the syncthing
  config files you just generates for the device-id and the api key. This allows
  them to be stored in variables that are plugged into a pre-written syncthing
  configuration using the proscribed folders and volumes.

  3. Finally, the syncthing process is started.

A Reasonably Useful Example
---------------------------

In the beginning, I wanted a way to make sure that even when I wasn't on my home
network, my caching proxy at home would back up any packages I downloades. That
led me here, and much to my dismay, I discovered that SyncThing does not, and
does not plan to, follow symbolic links. That kind of bummed me out, since it
meant that I would not simply be able to

        ln -s /var/cache/apt $HOME/Syncthing_Import_Folder

on my laptop to assure that my downloaded packages appeared in the cache. But I
wondered if SyncThing would see a bind mount as valid files. Also, I've never
really liked having to type in a password to do bind mounts, so in case you
didn't know about it, check out bindfs, it's a fuse filesystem which implements
bind mounts in userspace. On Debian, Devuan, or Ubuntu, you can do

        sudo apt-get install bindfs
        sudo addgroup fuse
        sudo adduser user fuse

to get it working. You may need to login and logout to add yourself to the fuse
group. Then, bind the /var/cache/apt directory *to a new directory inside* the
Syncthing\_Import\_folder directory.

        bindfs -o ro /var/cache/apt/ $HOME/Syncthing_Import_Folder/apt

And when an import is triggered, your local package cache will be left intact.

Besides that:
-------------

It also exposes the "/var/cache/apt-cacher-ng" directory as a read-only syncing
directory, which can then be directed to the import directory of another
apt-cacher-ng instance.

