export DEBIAN_FRONTEND=noninteractive

# Turn off syslog; for this use, it isn't needed, and just adds unnecessary disk i/o.
systemctl disable rsyslog

# Also neuter journald's log storage.
cat <<'JOURNALD' | tee /etc/systemd/journald.conf >/dev/null
[Journal]
Storage=none
ForwardToSyslog=yes
JOURNALD
systemctl daemon-reload
apt-get -qy purge rsyslog >/dev/null

echo "Installing xorg"
apt-get -qy --no-install-recommends install xorg >/dev/null

# lightdm is required for basic desktop application support, and requires additional
# recommended packages to work properly.
echo "Installing desktop environment"
apt-get -qy install lightdm openbox virtualbox-guest-x11 >/dev/null

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
    <number>1</number>
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
apt-get -qy purge doc-debian debian-faq genisoimage man-db manpages plymouth plymouth-label qemu-utils xorg-docs-core >/dev/null
apt-get -qy --purge autoremove >/dev/null
dpkg -l | grep '^rc' | awk '{print $2}' | xargs apt-get -qy purge >/dev/null
apt-get -qy clean >/dev/null
