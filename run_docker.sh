#!/bin/bash

IMAGE="$(docker ps -q -f ancestor=pcs3412_pcs3212)"

if [[ $IMAGE ]] ; then
	if [[ "$1" ]] ; then
		SRCDIR="$( cd $1 && pwd )"
	else
		GITDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
		SRCDIR="$GITDIR"
	fi

	if [[ "$2" ]]; then
		docker run --rm -ti -v "$SRCDIR":/usr/app/src --device="$2":/dev/ttyS0 pcs3412_pcs3212
	else
		docker run --rm -ti -v "$SRCDIR":/usr/app/src pcs3412_pcs3212
	fi
else
	docker-compose up --build
fi