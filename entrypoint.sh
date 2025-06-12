#!/bin/bash

set -e

APP_DIR="/var/www/html"
TEMP_DIR="/tmp/cake"
CAKE_CORE_FILE="$APP_DIR/cake/bin/cake"

# Function to install CakePHP
install_cakephp() {
  echo "CakePHP not found."

  echo "Emptying the temp dir..."
  rm -rf $TEMP_DIR

  echo "Installing CakePHP to temp dir..."
  composer create-project --prefer-dist cakephp/app "$TEMP_DIR"

  echo "Copying files from temp dir to html root"
  cp -r $TEMP_DIR $APP_DIR

  echo "Writing config/app_local.php"
  cp -r app_local.php $APP_DIR/cake/config/

  echo "CakePHP installation complete."
}

# Check if CakePHP is already installed
if [ ! -f "$CAKE_CORE_FILE" ]; then
  install_cakephp
else
  echo "CakePHP is already installed."
fi

# Run Migrations
#bin/cake migrations migrate

# Clear Caches	
#bin/cake cache clear_all

# Run the main container process (from the Dockerfile CMD for example)
exec "$@"
