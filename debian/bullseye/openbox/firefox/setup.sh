export DEBIAN_FRONTEND=noninteractive

echo "Creating firefox user"
useradd -g vboxsf -m -s /bin/bash firefox
cp -r /home/vagrant/.config /home/firefox/
# Automount the downloads shared folder, if available.
# I wish there were a better way to do this, but I can't find any way
# to poll the guest environment for available shared folders. Instead,
# we try to manually mount the shared folder, and if that works, then
# update /etc/fstab to automatically handle it on reboot.
mkdir -p /home/firefox/Downloads
if mount -t vboxsf downloads /home/firefox/Downloads 2>/dev/null; then
    echo "Attaching Downloads shared folder"
    echo "downloads              /home/firefox/Downloads         vboxsf  defaults,uid=firefox,gid=vboxsf         0       0" | tee -a /etc/fstab >/dev/null
fi

echo "Installing firefox-esr"
apt-get -qy install firefox-esr >/dev/null

echo "Configuring autostart"
sed -i -e 's/^autologin-user=.*$/autologin-user=firefox/g' /etc/lightdm/lightdm.conf.d/01_autologin.conf
echo '/usr/bin/firefox &' | tee -a /home/firefox/.config/openbox/autostart >/dev/null
