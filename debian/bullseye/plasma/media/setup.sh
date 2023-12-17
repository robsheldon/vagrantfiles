export DEBIAN_FRONTEND=noninteractive

echo "Installing curl, git, gzip, rsync, wget"
apt-get -qy install curl git gzip rsync wget >/dev/null

echo "Installing Plasma applications"
apt-get -qy install dolphin >/dev/null

echo "Installing firefox-esr"
apt-get -qy install firefox-esr >/dev/null

echo "Installing yakuake"
apt-get -qy install yakuake >/dev/null

echo "Installing VLC"
apt-get -qy install vlc >/dev/null

echo "Configuring autostart"
sed -i -e 's/^autologin-user=.*$/autologin-user=rob/g' /etc/lightdm/lightdm.conf.d/01_autologin.conf

echo "Cleaning up"
balooctl disable
apt-get -qy purge apache2 apache2-bin avahi-daemon avahi-autoipd bluedevil bluetooth bluez doc-debian debian-faq genisoimage iw kde-config-screenlocker kdeconnect keditbookmarks khelpcenter kinfocenter kscreen kup-backup kuserfeedback-doc modemmanager plasma-discover plymouth plymouth-label powerdevil qemu-utils upower wpasupplicant wireless-tools wireless-regdb xorg-docs-core >/dev/null
apt-get -qy --purge autoremove >/dev/null
dpkg -l | grep '^rc' | awk '{print $2}' | xargs apt-get -qy purge >/dev/null
apt-get -qy clean >/dev/null
