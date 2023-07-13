#!/bin/bash -eu
#
# Copyright 2018 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# This script is a combination of define-jupyter-service.sh and memory_limit.sh
# modified to work with our custom set up
#  - James W.

# shellcheck disable=SC1091
source /etc/profile.d/env.sh || exit 1

# contents of memory_limit.sh pasted here

# Calculate memory limits to be used by Jupyter or custom container

MEMORY_OTHER_NEEDS_IN_BYTES=330000000 # 330 Mb that are required by other system services
SOFT_SHIM_IN_BYTES=50000000 # 50 Mb for safety shim before reaching the memory threshold
MIN_JUPYTER_MEMORY_IN_BYTES=400000000 # 400 Mb is minimum that we must give to Jupyter

TOTAL_IN_KiB=$(cat /proc/meminfo | grep MemTotal | grep -Eo '[0-9]+')
# shellcheck disable=SC2003,SC2006,SC2086
MEMORY_MAX_IN_BYTES=`expr ${TOTAL_IN_KiB} \\* 1024 - ${MEMORY_OTHER_NEEDS_IN_BYTES}`
if (( ${MEMORY_MAX_IN_BYTES}<${MIN_JUPYTER_MEMORY_IN_BYTES} )); then
  MEMORY_MAX_IN_BYTES=${MIN_JUPYTER_MEMORY_IN_BYTES}
fi
# shellcheck disable=SC2003,SC2006,SC2086
MEMORY_HIGH_IN_BYTES=`expr ${MEMORY_MAX_IN_BYTES} - $SOFT_SHIM_IN_BYTES`

# end of memory_limit.sh

function prepare_jupyter_service(){
  JUPYTER_UI="lab"
  JUPYTER_USER="jupyter"
  echo "Jupyter user is: ${JUPYTER_USER}"
  JUPYTER_HOME="/home/${JUPYTER_USER}"
  JUPYTER_PATH=$(command -v jupyter)
}

function define_jupyter_service(){
 # Define service configuration
cat <<-EOH > /lib/systemd/system/jupyter.service
[Unit]
Description=Jupyter Notebook Service

[Service]
Type=simple
PIDFile=/run/jupyter.pid
MemoryHigh=${MEMORY_HIGH_IN_BYTES}
MemoryMax=${MEMORY_MAX_IN_BYTES}
ExecStart=/bin/bash --login -c '${JUPYTER_PATH} ${JUPYTER_UI} --config=/opt/jupyter/jupyter_notebook_config.py'
User=${JUPYTER_USER}
Group=${JUPYTER_USER}
WorkingDirectory=${JUPYTER_HOME}
Restart=always

[Install]
WantedBy=multi-user.target
EOH

 systemctl enable /lib/systemd/system/jupyter.service
 systemctl reload-or-restart jupyter.service
}

main(){
  echo "Jupyter Service will use maximum of ${MEMORY_MAX_IN_BYTES} bytes with high limit ${MEMORY_HIGH_IN_BYTES} bytes."
  prepare_jupyter_service
  define_jupyter_service
}

main

