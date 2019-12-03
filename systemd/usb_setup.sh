#!/bin/bash

# Save current directory
CURDIR=$(pwd)

# Go to config directory
cd /sys/kernel/config/usb_gadget

# Create gadget directory
mkdir -p piPa55
cd piPa55

# Set vendor and product IDs
echo 0x1d6b > idVendor  # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB    # USB2

# Set device strings
mkdir -p strings/0x409
echo "e148"                    > strings/0x409/serialnumber
echo "5phinX"                  > strings/0x409/manufacturer
echo "piPa55 password manager" > strings/0x409/product

# Configure gadget functionality
mkdir -p functions/hid.0 # Keyboard
mkdir -p functions/ecm.0 # Ethernet

# USB keyboard
echo 1 > functions/hid.0/protocol
echo 1 > functions/hid.0/subclass
echo 8 > functions/hid.0/report_length
echo -ne \\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x25\\x65\\x05\\x07\\x19\\x00\\x29\\x65\\x81\\x00\\xc0 > functions/hid.0/report_desc

# USB ethernet
echo "14:6D:5A:CB:84:70" > functions/ecm.0/dev_addr # Set MAC
# MAC generated using this command:
# $(tr -cd '[:xdigit:]' < /dev/urandom | fold -w2 | head -n5 | tr '\n' ':' | cut -c-14)


# Create a config
mkdir -p configs/c.1/strings/0x409
echo "Config 1: USB keyboard and ethernet" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower
ln -s functions/ecm.0 configs/c.1/
ln -s functions/hid.0 configs/c.1/

# Enable USB gadget
ls /sys/class/udc > UDC

# Go back to current working directory
cd $CURDIR

# Wait for the usb0 interface to come up
ETH_CHECK_START=$(date +%s)
while [ 1 ]; do
  tmp=$(ip link | grep "usb0")
  if [ $? -eq 0 ]; then
    ip addr add 192.168.148.1/24 dev usb0
    echo "USB ethernet up"
    break
  fi
  let tmp=$(date +%s)-$ETH_CHECK_START
  if [ $tmp -gt 30 ]; then
    echo "Ethernet is not up!"
    exit 1
  fi
done

# Configure DHCP server for USB ethernet
dnsmasq -C ./dhcpd.conf 

# Set the configure flag
echo 1 > /tmp/usb_gadget_configured

exit 0
