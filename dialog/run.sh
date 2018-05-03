#! /bin/bash
set -x
docker run --rm --interactive --tty  \
		-e "TERM=xterm" \
		dialog:latest \
		bash -c " \
		TERM=xterm dialog --msgbox \"TERM=$TERM\" 30 60"

