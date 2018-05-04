#! /bin/bash
set -x
docker run --rm --interactive --tty  \
		-e "TERM=screen" \
		dialog:latest \
		bash -c " \
		TERM=screen dialog --msgbox \"TERM=$TERM\" 30 60"

