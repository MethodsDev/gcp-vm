export OPAL_PREFIX="/usr"
export GRPC_FORK_SUPPORT_ENABLED=0
export MOUNTS_ON_ALL_CONTAINERS=/usr/local/share/ca-certificates,/etc/ssl/certs,/etc/ca-certificates/update.d
export TMPDIR="/var/tmp"
export OS_NAME=DEBIAN_11
# configure-conda
CURRENT_SHELL_OPTIONS="hB"
set +eu
. "/opt/bin/mamba/etc/profile.d/conda.sh"
conda activate base
set -""
unset CURRENT_SHELL_OPTIONS
# end configure-conda
