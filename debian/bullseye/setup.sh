export DEBIAN_FRONTEND=noninteractive

# Clean out some preinstalled cruft before upgrading.
# These need to all be in one command, otherwise initramfs gets rebuilt repeatedly.
echo "Cleaning up preinstalled cruft"
apt-get -qy purge gcc-9-base install-info ppp nftables os-prober reportbug tasksel telnet >/dev/null

# "fasttrack" is required for installing virtualbox-guest-x11
echo "Adding virtualbox-guest repository"
apt-get -qy update >/dev/null
apt-get -qy install fasttrack-archive-keyring >/dev/null
cat <<'FASTTRACK' | tee /etc/apt/sources.list.d/fasttrack.list >/dev/null
deb https://fasttrack.debian.net/debian-fasttrack/ bullseye-fasttrack main contrib
deb https://fasttrack.debian.net/debian-fasttrack/ bullseye-backports-staging main contrib
FASTTRACK
apt-get -qy update >/dev/null

# Make sure everything is up to date.
echo "Updating preinstalled packages"
apt-get -qy upgrade >/dev/null

# swapspace prevents OOM death on VMs
echo "Installing utilities"
apt-get -qy install apt-transport-https aptitude swapspace >/dev/null

# Mute annoying Perl locale warnings on each-and-every-dang apt invocation.
locale-gen en_US.UTF-8
localedef -i en_US -f UTF-8 en_US.UTF-8
export LANGUAGE=en_US.UTF-8 LANG=en_US.UTF-8 LC_ALL=C
