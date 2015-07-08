#!/bin/bash

# Copyright (c) 2014 Moritz Schepp <moritz.schepp@gmail.com>
# Distributed under the GNU GPL v3. For full terms see
# http://www.gnu.org/licenses/gpl-3.0.txt

# This is a deploy script for generic apps. Modify the deploy function to suit
# your needs.


# General configuration

TMPROOT=/tmp/deploy


# Deployment settings

CALL_ROOT="$( cd "$( dirname "$0" )" && pwd )"
source $CALL_ROOT/deploy.config.sh


# Deploy

function deploy {
  setup
  deploy_code
  cleanup

  # Your deployment specifics go here

  finalize
}


# Variables

TIMESTAMP=`date +"%Y%m%d%H%M%S"`
REVISION=`git rev-parse $COMMIT`
CURRENT_PATH="$DEPLOY_TO/releases/$TIMESTAMP"
SHARED_PATH="$DEPLOY_TO/shared"
LINKED_CURRENT_PATH="$DEPLOY_TO/current"

RED="\e[0;31m"
GREEN="\e[0;32m"
BLUE="\e[0;34m"
LIGHTBLUE="\e[1;34m"
NOCOLOR="\e[0m"


# Generic functions

function within_do {
  remote "cd $1 ; $2"
}

function remote {
  echo -e "${BLUE}$HOST${NOCOLOR}: ${LIGHTBLUE}$1${NOCOLOR}" 1>&2
  ssh -p $PORT $HOST "bash -c \"$1\""
  STATUS=$?

  if [[ $STATUS != 0 ]] ; then
    echo -e "${RED}deployment failed with status code $STATUS${NOCOLOR}"
    exit $STATUS
  fi
}

function local {
  echo -e "${BLUE}locally${NOCOLOR}: ${LIGHTBLUE}$1${NOCOLOR}" 1>&2
  bash -c "$1"
  STATUS=$?

  if [[ $STATUS != 0 ]] ; then
    echo -e "${RED}deployment failed with status code $STATUS${NOCOLOR}"
    exit $STATUS
  fi
}

function setup {
  remote "mkdir -p $DEPLOY_TO/shared"
  remote "mkdir -p $DEPLOY_TO/releases"
}

function deploy_code {
  TMPDIR=$TMPROOT/`pwgen 20 1`
  local "mkdir -p $TMPROOT"
  local "git clone $CALL_ROOT $TMPDIR"
  local "cd $TMPDIR && git checkout $COMMIT"
  local "tar czf deploy.tar.gz -C $TMPDIR ."
  local "rm -rf $TMPDIR"
  local "scp deploy.tar.gz $HOST:$DEPLOY_TO/deploy.tar.gz"
  local "rm deploy.tar.gz"

  remote "mkdir $CURRENT_PATH"
  within_do $CURRENT_PATH "tar xzf ../../deploy.tar.gz"
  remote "echo $REVISION > $CURRENT_PATH/REVISION"
  remote "echo $PHASE > $CURRENT_PATH/PHASE"
  remote "rm $DEPLOY_TO/deploy.tar.gz"
  remote "ln -sfn $CURRENT_PATH $DEPLOY_TO/current"
}

function cleanup {
  EXPIRED=`remote "(ls -t $DEPLOY_TO/releases | head -n $KEEP ; ls $DEPLOY_TO/releases) | sort | uniq -u | xargs"`
  for d in $EXPIRED ; do
    remote "rm -rf $DEPLOY_TO/releases/$d"
  done
}

function finalize {
  echo -e "${GREEN}deployment successful${NOCOLOR}"
}


# Main

echo "Deploying $PHASE"
deploy
