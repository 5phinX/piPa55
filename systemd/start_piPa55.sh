#!/bin/bash

# Timeout for ethernet startup
ETH_TIMEOUT=100

cd /root/piPa55/systemd/

# Check is the USB is configured
if [ -f "/tmp/usb_gadget_configured" ]; then
  echo "USB already configured"
else
  ./usb_setup.sh
  if [ $? -ne 0 ]; then
    exit $?
  fi
fi

cd /root/piPa55

tclsh /root/piPa55/piPa55_httpd.tcl &
# Save HTTP server PID
echo $$ > /tmp/piPa55_httpd.pid

tclsh /root/piPa55/keyboard.tcl &
# Save keyboard PID
echo $$ > /tmp/piPa55_keyboard.pid

exit 0
