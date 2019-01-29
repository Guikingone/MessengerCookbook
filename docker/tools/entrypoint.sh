#!/bin/bash
set -e

npm config set cache /www/.npm --global

# Change www-data's uid & guid to be the same as directory in host
usermod -u `stat -c %u /srv/app` www-data || true
groupmod -g `stat -c %g /srv/app` www-data || true

if [ "$1" = 'apache2-foreground' ]; then
    # Let's start apache
    apache2-foreground
else
    # Change to user www-data
    su www-data -s /bin/bash -c "$*"
fi
