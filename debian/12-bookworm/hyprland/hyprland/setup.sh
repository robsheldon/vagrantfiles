export DEBIAN_FRONTEND=noninteractive

user="$(ls -1 /home | grep -v vagrant)"

echo "Installing curl, git, gzip, rsync, wget"
apt-get -qy install curl git gzip rsync wget >/dev/null

echo "Installing sublime-text"
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg >/dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
apt-get -qy update >/dev/null && apt-get -qy install sublime-text >/dev/null

echo "Installing firefox-esr"
apt-get -qy install firefox-esr >/dev/null

echo "Configuring autostart"
sed -i -e "s/^autologin-user=.*$/autologin-user=$user/g" /etc/lightdm/lightdm.conf.d/01_autologin.conf

echo "Cleaning up"
apt-get -qy purge apache2 apache2-bin avahi-daemon avahi-autoipd bluedevil bluetooth bluez doc-debian debian-faq genisoimage iw kde-config-screenlocker kdeconnect keditbookmarks khelpcenter kinfocenter kscreen kup-backup kuserfeedback-doc modemmanager plasma-discover plymouth plymouth-label powerdevil qemu-utils upower wpasupplicant wireless-tools wireless-regdb xorg-docs-core >/dev/null
apt-get -qy --purge autoremove >/dev/null
dpkg -l | grep '^rc' | awk '{print $2}' | xargs apt-get -qy purge >/dev/null
apt-get -qy clean >/dev/null
