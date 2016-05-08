#!/bin/bash -e

CALL_ROOT="$( cd "$( dirname "$0" )" && pwd )"

if [ -d deploy.sh ]; then
  # this is an update
  cp $CALL_ROOT/lib.sh > deploy/lib.sh
else
  mkdir -p deploy
  cp $CALL_ROOT/lib.sh deploy/lib.sh
  cp $CALL_ROOT/app.sh.example deploy/app.sh
  cp $CALL_ROOT/config.sh.example deploy/config.sh
  chmod +x deploy/app.sh

  echo "The deployment scripts have been installed to the deploy/ directory."
  echo "Run this script again to update the scripts while keeping your"
  echo "configuration. Make sure to put deploy/config.sh in your gitignore."
fi