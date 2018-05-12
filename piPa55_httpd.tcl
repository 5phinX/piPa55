#!/bin/bash
piPa55_DIR=/root/piPa55

cd $piPa55_DIR

# Setup the USB gadgets
./usb_setup.sh

# Run the HTTP server
tclsh ./piPa55_httpd.tcl &

# Run the keyboard emulator
tclsh ./keyboard.tcl &
