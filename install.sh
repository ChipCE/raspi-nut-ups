#!/bin/bash

INSTALLER_VERSION="Omron UPS BY80S / BY50S / BY35S Linux NUT installer."

# root check
FILE="/tmp/out.$$"
GREP="/bin/grep"

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# User who run this script 
INSTALL_USER=($(who))

echo ""

# install confirm
installConfirm=""
echo "This program will install USB driver and NUT daemon for Omron UPS BY80S / BY50S / BY35S"
echo -e "\t* Make sure that Raspberry Pi is connected to UPS vis USB or serial cable."
echo -e "\t* Raspberry will need internet access to download NUT software."
read -p "Process installation? y/n " installConfirm
if [[ "$installConfirm" != "y" ]]
then
    echo "Exit."
    exit 1
fi

echo ""

echo "Scanning for compatible device..."
# find usb vendor and product id
VENDOR_ID=($(lsusb | grep -i omron | grep -oPe "[a-f0-9]+:[a-f0-9]+" | grep -oPe "^[a-f0-9]+"))
PRODUCT_ID=($(lsusb | grep -i omron | grep -oPe "[a-f0-9]+:[a-f0-9]+" | grep -oPe "[a-f0-9]+$"))


# check for invalid ids
if [  "$VENDOR_ID" == "" ] || [ "$PRODUCT_ID" == "" ]
then
    echo "Error : Cannot find any compatible device."
    exit 1
else
    echo "Vendor Id : $VENDOR_ID"
    echo "Product Id : $PRODUCT_ID"
fi

echo ""
USR_PWD=""
read -sp "Enter current user password: " USR_PWD
echo ""
if [[ "$USR_PWD" == "" ]]
then
    echo "Error : Invalid input."
    exit 1
fi

echo ""

# Install NUT service
#echo "Checking for NUT package..."
#NOT_INSTALLED=($(dpkg -l nut | grep -o "no packages found matching nut"))
#if [[ "$NOT_INSTALLED" != "" ]]
#then
#    echo "NUT package not found."
#    echo "Trying to install NUT ..."
#    apt-get update -y
#    apt-get install -y nut
#else
#    echo "NUT package is already installed."
#fi

#INSTALL_FAILED=($(dpkg -l nut | grep -o "no packages found matching nut"))
#if [[ "$INSTALL_FAILED" != "" ]]
#then
#    echo "Cannot install NUT software."
#    exit 1
#fi

echo "Trying to install NUT ..."
apt-get update -y
apt-get install -y nut

# copy template to install-files
yes | cp -rf templates/52-nut-usbups.rules install-files/52-nut-usbups.rules
yes | cp -rf templates/nut.conf install-files/nut.conf
yes | cp -rf templates/ups.conf install-files/ups.conf
yes | cp -rf templates/upsd.users install-files/upsd.users
yes | cp -rf templates/upsmon.conf install-files/upsmon.conf

# replace parameters
# 52-nut-usbups.rules
sed -i 's,'"#@VENDOR_ID"','"$VENDOR_ID"',' install-files/52-nut-usbups.rules
sed -i 's,'"#@PRODUCT_ID"','"$PRODUCT_ID"',' install-files/52-nut-usbups.rules
# nut.conf
#       n/a
# ups.conf
sed -i 's,'"#@VENDOR_ID"','"$VENDOR_ID"',' install-files/ups.conf
sed -i 's,'"#@PRODUCT_ID"','"$PRODUCT_ID"',' install-files/ups.conf
# upsd.users
sed -i 's,'"#@USR_PWD"','"$USR_PWD"',' install-files/upsd.users
# upsmon.conf
sed -i 's,'"#@USR_PWD"','"$USR_PWD"',' install-files/upsmon.conf
sed -i 's,'"#@INSTALL_USER"','"$INSTALL_USER"',' install-files/upsmon.conf


# copy install-files to system
yes | cp -rf install-files/52-nut-usbups.rules /lib/udev/rules.d/52-nut-usbups.rules
yes | cp -rf install-files/nut.conf /etc/nut/nut.conf
yes | cp -rf install-files/ups.conf /etc/nut/ups.conf
yes | cp -rf install-files/upsd.users /etc/nut/upsd.users
yes | cp -rf install-files/upsmon.conf /etc/nut/upsmon.conf

# File permission
chown -R root:nut /etc/nut
chmod -R 644 /etc/nut/*

# copy custom shutdown script
mkdir /home/"$INSTALL_USER"/.nut
yes | cp -rf common/shutdown.sh /home/"$INSTALL_USER"/.nut/shutdown.sh
chmod 775 /home/"$INSTALL_USER"/.nut/shutdown.sh

# Restart daemon
echo "Reloading udev..."
udevadm control --reload-rules
udevadm trigger
upsdrvctl start
echo ""
echo "Enable NUT services..."
systemctl enable nut-server
systemctl enable nut-client
systemctl start nut-server
systemctl start nut-client
echo ""
echo "Done."
exit 0
