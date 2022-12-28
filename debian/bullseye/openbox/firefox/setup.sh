echo "Installing firefox-esr"
apt -qy install firefox-esr >/dev/null

echo "Configuring autostart"
echo '/usr/bin/firefox &' | tee -a /home/vagrant/.config/openbox/autostart
