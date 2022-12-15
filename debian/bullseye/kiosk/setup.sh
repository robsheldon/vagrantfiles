# Mute annoying Perl locale warnings on each-and-every-dang apt invocation.
locale-gen en_US.UTF-8
localedef -i en_US -f UTF-8 en_US.UTF-8
export LANGUAGE=en_US.UTF-8 LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Turn off syslog; for this use, it isn't needed, and just adds unnecessary disk i/o.
systemctl disable rsyslog

# Also neuter journald's log storage.
cat <<'JOURNALD' | tee /etc/systemd/journald.conf >/dev/null
[Journal]
Storage=none
ForwardToSyslog=yes
JOURNALD
systemctl daemon-reload

# Clean out some preinstalled cruft before upgrading.
# These need to all be in one command, otherwise initramfs gets rebuilt repeatedly.
echo "Cleaning up preinstalled cruft"
apt -qy purge gcc-9-base git gnustep-common install-info installation-report javascript-common modemmanager netpbm ppp nftables ntfs-3g os-prober packagekit packagekit-tools pinentry-qt reportbug rsyslog scrot smartmontools sweeper tasksel telnet termit upower usbutils >/dev/null

# "fasttrack" is required for installing virtualbox-guest-x11
echo "Adding virtualbox-guest repository"
cat <<'FASTTRACK' | tee /etc/apt/sources.list.d/fasttrack.list >/dev/null
deb https://fasttrack.debian.net/debian-fasttrack/ bullseye-fasttrack main contrib
deb https://fasttrack.debian.net/debian-fasttrack/ bullseye-backports-staging main contrib
FASTTRACK
apt -qy update >/dev/null
apt -qy install fasttrack-archive-keyring >/dev/null
apt -qy update >/dev/null

# Make sure everything is up to date.
echo "Updating preinstalled packages"
apt -qy upgrade >/dev/null

# swapspace prevents OOM death on VMs
echo "Installing utilities"
apt -qy install aptitude swapspace >/dev/null

echo "Installing xorg"
apt -qy --no-install-recommends install xorg >/dev/null

# lightdm is required for basic desktop application support, and requires additional
# recommended packages to work properly.
echo "Installing desktop environment"
apt -qy install lightdm openbox virtualbox-guest-x11 >/dev/null

echo "Configuring desktop environment"
mkdir -p /home/vagrant/.config/openbox

cat <<'AUTOSTART' | tee /home/vagrant/.config/openbox/autostart >/dev/null
# Disable any form of screen saver / screen blanking / power management
xset s off
xset s noblank
xset -dpms

AUTOSTART

cat <<'RCXML' | tee /home/vagrant/.config/openbox/rc.xml >/dev/null
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc" xmlns:xi="http://www.w3.org/2001/XInclude">

  <desktops>
    <number>4</number>
  </desktops>

  <applications>
    <application class="*">
      <decor>no</decor>
    </application>
  </applications>

</openbox_config>
RCXML

# Configure LightDM to automatically login (start the desktop)
mkdir -p /etc/lightdm/lightdm.conf.d
cat <<'AUTOLOGIN' | tee /etc/lightdm/lightdm.conf.d/01_autologin.conf >/dev/null
[Seat:*]
autologin-user=vagrant
autologin-user-timeout=0
AUTOLOGIN

# Post-install cleanup
echo "Cleaning up"
apt -qy purge doc-debian debian-faq genisoimage man-db manpages plymouth plymouth-label qemu-utils xorg-docs-core >/dev/null
apt -qy --purge autoremove >/dev/null
dpkg -l | grep '^rc' | awk '{print $2}' | xargs apt -qy purge
apt -qy clean >/dev/null
