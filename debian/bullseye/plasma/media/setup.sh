export DEBIAN_FRONTEND=noninteractive

echo "Creating dev user"
useradd -U -G vboxsf,sudo -m -s /bin/bash developer
cp -r /home/vagrant/.config /home/developer/
chown -R developer:developer /home/developer/.config

# Automount the downloads shared folder, if available.
# I wish there were a better way to do this, but I can't find any way
# to poll the guest environment for available shared folders. Instead,
# we try to manually mount the shared folder, and if that works, then
# update /etc/fstab to automatically handle it on reboot.
mkdir -p /home/developer/Downloads
if mount -t vboxsf downloads /home/developer/Downloads 2>/dev/null; then
    echo "Attaching Downloads shared folder"
    echo "downloads              /home/developer/Downloads         vboxsf  defaults,uid=developer,gid=vboxsf         0       0" | tee -a /etc/fstab >/dev/null
fi

echo "Installing curl, git, gzip, rsync, wget"
apt-get -qy install curl git gzip rsync wget >/dev/null

echo "Installing Plasma applications"
apt-get -qy install konsole dolphin >/dev/null

echo "Installing sublime-text"
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg >/dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
apt-get -qy update >/dev/null && apt-get -qy install sublime-text >/dev/null

echo "Installing firefox-esr"
apt-get -qy install firefox-esr >/dev/null

echo "Installing yakuake"
apt-get -qy install yakuake >/dev/null

echo "Configuring autostart"
sed -i -e 's/^autologin-user=.*$/autologin-user=developer/g' /etc/lightdm/lightdm.conf.d/01_autologin.conf

echo "Cleaning up"
balooctl disable
apt-get -qy purge apache2 apache2-bin avahi-daemon avahi-autoipd bluedevil bluetooth bluez doc-debian debian-faq genisoimage iw kde-config-screenlocker kdeconnect keditbookmarks khelpcenter kinfocenter kscreen kup-backup kuserfeedback-doc modemmanager plasma-discover plymouth plymouth-label powerdevil qemu-utils upower wpasupplicant wireless-tools wireless-regdb xorg-docs-core >/dev/null
apt-get -qy --purge autoremove >/dev/null
dpkg -l | grep '^rc' | awk '{print $2}' | xargs apt-get -qy purge >/dev/null
apt-get -qy clean >/dev/null
