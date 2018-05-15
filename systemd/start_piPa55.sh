#!/bin/bash

# Timeout for ethernet startup
ETH_TIMEOUT=5

cd /root/piPa55/systemd/

# Check is the USB is configured
if [ -f "/tmp/usb_gadget_configured" ]; then
  echo "USB already configured"
else
  ./usb_setup.sh
  # Wait until the ethernet is up and IP address set
  ETH_CHECK_START=$(date +%s)
  while ( 1 ); do
    tmp=$(ip addr | grep "192.168.148.1/24")
    if [ $? -eq 0 ]; then
      break
    fi
    let tmp=$(date +%s)-$ETH_CHECK_START
    if [ $tmp -gt $ETH_TIMEOUT ]; then
      echo "Ethernet is not up!"
      exit 1
    fi
  done
fi

cd /root/piPa55

tclsh /root/piPa55/piPa55_httpd.tcl &
# Save HTTP server PID
echo $$ > /tmp/piPa55_httpd.pid

tclsh /root/piPa55/keyboard.tcl &
# Save keyboard PID
echo $$ > /tmp/piPa55_keyboard.pid

exit 0
