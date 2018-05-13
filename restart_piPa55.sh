#!/bin/bash

cd /root/piPa55

kill $(cat /tmp/piPa55_httpd.pid)
kill $(cat /tmp/piPa55_keyboard.pid)

tclsh /root/piPa55/piPa55_httpd.tcl &
# Save HTTP server PID
echo $$ > /tmp/piPa55_httpd.pid

tclsh /root/piPa55/keyboard.tcl &
# Save keyboard PID
echo $$ > /tmp/piPa55_keyboard.pid
