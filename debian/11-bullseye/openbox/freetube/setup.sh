export DEBIAN_FRONTEND=noninteractive

echo "Creating freetube user"
useradd -g vboxsf -m -s /bin/bash freetube
cp -r /home/vagrant/.config /home/freetube/
chown -R freetube:vboxsf /home/freetube/.config
# Automount the downloads shared folder, if available.
# I wish there were a better way to do this, but I can't find any way
# to poll the guest environment for available shared folders. Instead,
# we try to manually mount the shared folder, and if that works, then
# update /etc/fstab to automatically handle it on reboot.
mkdir -p /home/freetube/Downloads
if mount -t vboxsf downloads /home/freetube/Downloads 2>/dev/null; then
    echo "Attaching Downloads shared folder"
    echo "downloads              /home/freetube/Downloads         vboxsf  defaults,uid=freetube,gid=vboxsf         0       0" | tee -a /etc/fstab >/dev/null
fi

echo "Installing dependencies"
apt-get -qy install libasound2
echo "Downloading freetube"
wget -O /home/freetube/Downloads/freetube.deb https://github.com/FreeTubeApp/FreeTube/releases/download/v0.19.1-beta/freetube_0.19.1_amd64.deb
echo "Installing freetube"
apt-get -qy install /home/freetube/Downloads/freetube.deb && rm /home/freetube/Downloads/freetube.deb 

echo "Configuring autostart"
sed -i -e 's/^autologin-user=.*$/autologin-user=freetube/g' /etc/lightdm/lightdm.conf.d/01_autologin.conf
echo '/usr/bin/freetube &' | tee -a /home/freetube/.config/openbox/autostart >/dev/null
