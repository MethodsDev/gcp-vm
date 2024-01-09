set -e

# should pass the name of the data disk to mount, if there is one
DEV=$1
if [[ -z ${DEV} ]]; then
	echo "No device argument provided, assuming this is a single-disk instance"
elif [[ -n ${DEV} ]]; then
	mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard ${DEV}
fi

apt update
apt install -y zsh curl git less nano htop build-essential

adduser --quiet --shell /bin/zsh --disabled-password --no-create-home --gecos "" jupyter
usermod -a -G google-sudoers jupyter
mkdir /home/jupyter
if [[ -n ${DEV} ]]; then
	mount -o discard,defaults ${DEV} /home/jupyter/
fi
mkdir /home/jupyter/.local /home/jupyter/.conda
chown -R jupyter:jupyter /home/jupyter

# downloading the installation script
curl -s -L -o /tmp/miniforge.sh \
	https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh

# tell it to install to `/opt/conda` so it lives on the boot disk
# specifying HOME so it is installed for the jupyter user
HOME=/home/jupyter bash /tmp/miniforge.sh -s -b -p /opt/conda

# install jupyterlab and ripgrep
/opt/conda/bin/conda install -y jupyterlab ripgrep
# set auto_stack so that tools in the base env are always available
/opt/conda/bin/conda config --set auto_stack 1

# move the config file to boot disk
mkdir /opt/jupyter
mv /tmp/gcp-vm/jupyter/jupyter_notebook_config.py /opt/jupyter/
# we need the jupyter user to own these, for installing stuff
chown -R jupyter:jupyter /opt/conda /opt/jupyter

# setup scripts
mv /tmp/gcp-vm/etc/env.sh /etc/profile.d/
chown root:root /etc/profile.d/env.sh

mkdir /opt/bin
mv /tmp/gcp-vm/bin/{define-jupyter-service,mount_workspace}.sh /opt/bin/
chown root:root /opt/bin/{define-jupyter-service,mount_workspace}.sh

# create rc.local on the fly to insert device info
if [[ -n $DEV ]]; then
	UUID=`lsblk -n -o UUID ${DEV}`
else
	UUID=''
fi

cat <<-EOH > /etc/rc.local
#!/bin/bash
/opt/bin/mount_workspace.sh /home/jupyter ${UUID}
/opt/bin/define-jupyter-service.sh
EOH

chown root:root /etc/rc.local
chmod +x /etc/rc.local

# set up the daemon to run this stuff on boot
systemctl daemon-reload
systemctl start rc-local

echo
echo "Done with setup. Reset the instance to start using it"
