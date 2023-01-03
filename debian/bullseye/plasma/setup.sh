export DEBIAN_FRONTEND=noninteractive

echo "Installing xorg"
apt-get -qy --no-install-recommends install xorg >/dev/null

# lightdm is required for basic desktop application support, and requires additional
# recommended packages to work properly.
echo "Installing desktop environment"
apt-get -qy install lightdm plasma-desktop virtualbox-guest-x11 >/dev/null

echo "Configuring desktop environment"
mkdir -p /home/vagrant/.config/openbox

# Configure LightDM to automatically login (start the desktop)
mkdir -p /etc/lightdm/lightdm.conf.d
cat <<'AUTOLOGIN' | tee /etc/lightdm/lightdm.conf.d/01_autologin.conf >/dev/null
[Seat:*]
autologin-user=vagrant
autologin-user-timeout=0
autologin-session=plasma
AUTOLOGIN

# Post-install cleanup
echo "Cleaning up"
apt-get -qy purge doc-debian debian-faq genisoimage plymouth plymouth-label qemu-utils xorg-docs-core >/dev/null
apt-get -qy --purge autoremove >/dev/null
dpkg -l | grep '^rc' | awk '{print $2}' | xargs apt-get -qy purge
apt-get -qy clean >/dev/null
