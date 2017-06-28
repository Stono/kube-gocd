#!/bin/bash
set -e
GO_USER_FILE=/etc/go-users
GO_CONFIG_DIR=/godata/config
GO_CONFIG_FILE=$GO_CONFIG_DIR/cruise-config.xml

if [ ! -f "$GO_USER_FILE" ]; then
	echo "Creating default user file"
	echo $(htpasswd -nb -s $GO_USERNAME $GO_PASSWORD | xargs) > $GO_USER_FILE
	echo "You will need to enable password auth for $GO_USER_FILE from the GoCD GUI"
else
	echo "$GO_USER_FILE already exists, please delete it if you wish to change passwords"
fi

/docker-entrypoint.sh
