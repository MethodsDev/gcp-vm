#!/bin/bash -eu

DATA_DIR=$1
DEV=$2
WARN_MSG="WARNING: failed to mount data disk, please ignore if this is a single disk instance"
if [[ -n $2 ]]
then
	mount -o discard,defaults "${DEV}" "${DATA_DIR}" || echo "${WARN_MSG}"
fi
