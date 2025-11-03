#!/bin/bash
sudo rm -rf /usr/share/LegendaryOS/
sudo mv /tmp/LegendaryOS/updates/LegendaryOS/ /usr/share/
cd /usr/share/LegendaryOS/SCRIPTS/
sudo mkdir LOS-CLI
sudo mkdir LCR
sudo chmod a+x ./legendaryos-upgrade
cd LOS-CLI

