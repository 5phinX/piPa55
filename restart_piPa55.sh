#!/bin/bash

cd /root/piPa55

# Check is the USB is configured
if [ -f "/tmp/usb_gadget_configured" ]; then
  echo "USB configured" > /dev/null
else
  ./usb_setup.sh
fi

kill $(cat /tmp/piPa55_httpd.pid)
kill $(cat /tmp/piPa55_keyboard.pid)

tclsh /root/piPa55/piPa55_httpd.tcl &
# Save HTTP server PID
echo $$ > /tmp/piPa55_httpd.pid

tclsh /root/piPa55/keyboard.tcl &
# Save keyboard PID
echo $$ > /tmp/piPa55_keyboard.pid
