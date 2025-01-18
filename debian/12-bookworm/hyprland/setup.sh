xport DEBIAN_FRONTEND=noninteractive

# Because of a `#include <format>` in one file in hyprwayland-scanner, we need gcc >= 13, and the most
# reasonable way to get that is to switch to Debian Trixie (currently Testing), which provides gcc-14.
sed -i -e 's/bookworm/trixie/g' /etc/apt/sources.list
apt-get -qy update
apt-get -qy dist-upgrade

# Install hyprland's dependencies
echo "Installing hyprland's dependencies"
apt-get -qy --no-install-recommends install make meson wget ninja-build gettext gettext-base fontconfig libfontconfig-dev libffi-dev libxml2-dev libdrm-dev libxkbcommon-x11-dev libxkbregistry-dev libxkbcommon-dev libpixman-1-dev libudev-dev libseat-dev seatd libxcb-dri3-dev libvulkan-dev libvulkan-volk-dev vulkan-validationlayers-dev libvkfft-dev libgulkan-dev libegl-dev libgles2 libegl1-mesa-dev glslang-tools libxcb-composite0-dev libavutil-dev libavcodec-dev libavformat-dev libxcb-ewmh2 libxcb-ewmh-dev libxcb-present-dev libxcb-icccm4-dev libxcb-render-util0-dev libxcb-res0-dev libxcb-xinput-dev jq hwdata libgbm-dev xwayland foot >/dev/null

# gcc >= 13 is required due to a line in one of the source files of one of the dependencies.
apt-get -qy --no-install-recommends install gcc build-essential

# Each of the following are a result of trial-and-erroring my way through `make all && make install` in the Hyprland directory.
apt-get -qy --no-install-recommends install make pkg-config libgl1-mesa-dev

# We need the latest version of cmake to make this all work.
# This was added before the installation process switched to Trixie; may not
# be necessary anymore depending on which version of cmake is packaged.
echo "Installing cmake"
# Download their self-extracting archive
cd /home/vagrant
wget -q https://github.com/Kitware/CMake/releases/download/v3.31.4/cmake-3.31.4-linux-x86_64.sh
# Run the shell script (self-extracting archive)
# cmake's installation script will clobber stuff in /bin and other root directories if installed to /,
# so install to /usr/local where it can still be found in the default $PATH but will do less damage.
sh cmake-3.31.4-linux-x86_64.sh --skip-license --prefix=/usr/local

# Git
echo "Installing git"
apt-get -qy install git >/dev/null

# "pugixml" is apparently required by hyprwayland-scanner but is not a part of its build process.
# This is resolved with libpugixml-dev in Debian.
apt-get -qy install libpugixml-dev >/dev/null

# hyprwayland-scanner is apparently required by aquamarine but is not a part of its build process.
cd /home/vagrant
git clone -q https://github.com/hyprwm/hyprwayland-scanner.git
cd /home/vagrant/hyprwayland-scanner
cmake -DCMAKE_INSTALL_PREFIX=/usr -B build
cmake --build build -j `nproc`
cmake --install build

# pixman-1 is required by hyprutils.
apt-get -qy install libpixman-1-dev

# hyprutils is required by aquamarine.
cd /home/vagrant
git clone -q https://github.com/hyprwm/hyprutils.git
cd /home/vagrant/hyprutils
cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
cmake --install build

# Install MORE dependencies for Aquamarine.
apt-get -qy install libseat-dev libinput-dev libwayland-dev wayland-protocols libdrm-dev libgbm-dev libdisplay-info-dev hwdata

# "Aquamarine" is apparently required by Hyprland but is not a part of its build process.
echo "Installing aquamarine"
cd /home/vagrant
git clone -q https://github.com/hyprwm/aquamarine.git
cd /home/vagrant/aquamarine
cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF`
cmake --install build

# "hyprlang" (NOT "-land") is apparently required by Hyprland but is not a part of its build process.
# ...because what the world really needed was ANOTHER FUCKING CONFIGURATION LANGUAGE.
cd /home/vagrant
git clone -q https://github.com/hyprwm/hyprlang.git
cd /home/vagrant/hyprlang
cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
cmake --build ./build --config Release --target hyprlang -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF`
cmake --install build

# Install dependencies for hyprcursor.
apt-get -qy install libzip-dev libcairo-dev librsvg2-dev libtomlplusplus-dev

# "hyprcursor" is apparently required by Hyprland but is not a part of its build process.
cd /home/vagrant
git clone -q https://github.com/hyprwm/hyprcursor.git
cd /home/vagrant/hyprcursor
cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF`
cmake --install build

# Install unmet dependencies for hyprgraphics.
apt-get -qy install libmagic-dev

# "hyprgraphics" is apparently required by Hyprland but is not a part of its build process.
cd /home/vagrant
git clone -q https://github.com/hyprwm/hyprgraphics.git
cd /home/vagrant/hyprgraphics
cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
cmake --install build

# Install unmet dependencies for hyprland.
apt-get -qy install libxkbcommon-dev libxcursor-dev libre2-dev libxcb-xfixes0-dev libxcb-icccm4-dev libxcb-composite0-dev libxcb-res0-dev libxcb-errors-dev

# ...Aaaaand finally ... maybe ... hyprland?
echo "Preparing to build hyprland"
cd /home/vagrant
git clone --recursive https://github.com/hyprwm/Hyprland
cd /home/vagrant/Hyprland
make all && make install

exit 0

# lightdm is required for basic desktop application support, and requires additional
# recommended packages to work properly.
# echo "Installing desktop environment"
# apt-get -qy install lightdm virtualbox-guest-x11 >/dev/null

# Configure LightDM to automatically login (start the desktop)
# mkdir -p /etc/lightdm/lightdm.conf.d
# cat <<'AUTOLOGIN' | tee /etc/lightdm/lightdm.conf.d/01_autologin.conf >/dev/null
# [Seat:*]
# autologin-user=vagrant
# autologin-user-timeout=0
# autologin-session=plasma
# AUTOLOGIN

# Desktop environments are likely to be more RAM hungry. zram as a swap utility
# can help take a little pressure off when things get tight.
# https://wiki.debian.org/ZRam
apt-get -qy install zram-tools
sed -i -e 's/^\s*\(#\?\s*\)PERCENT=.*$/PERCENT=25/g' /etc/default/zramswap

# Post-install cleanup
echo "Cleaning up"
apt-get -qy purge doc-debian debian-faq genisoimage plymouth plymouth-label qemu-utils xorg-docs-core >/dev/null
apt-get -qy --purge autoremove >/dev/null
dpkg -l | grep '^rc' | awk '{print $2}' | xargs apt-get -qy purge
apt-get -qy clean >/dev/null

