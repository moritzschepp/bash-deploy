# Bash Deploy

is a small set of scripts to facilitate deployment from UNIX-like to UNIX-like.

## Usage

Clone this repo to some directory on your host

    git clone https://github.com/moritzschepp/bash-deploy.git /home/jon/bash-deploy

and then go to your project's directory

    cd /home/jon/myapp

Now run the installer. This will create a few files below `deploy/`

    /home/jon/bash-deploy/install.sh

Modify `deploy/config.sh` according to your target hosts. This file should also
go to gitignore. `deploy/app.sh` is the place where you add your project
specific deployment steps.

## Upgrading

This is simple, just run

    /home/jon/bash-deploy/install.sh

again.