#!/bin/bash -eu

DATA_DIR=$1
WARN_MSG="WARNING: failed to mount data disk, please ignore if this is a single disk instance"
mount -o discard,defaults /dev/sdb "${DATA_DIR}" || echo "${WARN_MSG}"
