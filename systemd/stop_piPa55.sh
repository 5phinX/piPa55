#!/bin/bash

kill $(cat /tmp/piPa55_httpd.pid)
kill $(cat /tmp/piPa55_keyboard.pid)

exit 0
