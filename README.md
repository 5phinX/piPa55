# piPa55 - a hardware password manager based on Raspberry Pi Zero

Pi Zero emulates a USB keyboard and ethernet.
The ethernet provides a connection to the embedded HTTP server used for password management.
USB keyboard then types in selected passwords.

## Dependencies

piPa55 was tested on a Raspbian Stretch.

The device uses composite USB framework build into the linux kernel.
Necessary modules must be loaded at boot.
Add this statement to your `boot/cmdline.txt`:

```
modules-load=dwc2,libcomposite
```

piPa55 is written mostly in Tcl (with a few bash scripts), so `tcl` package must be installed.

## Installation

At current state, piPa55 can only work when installed in `/root/piPa55`.

The systemd unit is in [piPa55.service](./piPa55.service).
To register the unit with the systemd, create a symlink:
```
ln -s /root/piPa55/piPa55.service /etc/systemd/system/piPa55.service
```

Now, the service can be enabled by `systemctl enable piPa55` and started by `systemctl start piPa55`.

## Configuration

Password management is done via embedded HTTP server.
The management interface is accessible through [http://192.168.148.1](http://192.168.148.1).

piPa55 provides a DHCP server, so there is no need to set the host PC interface manually.
The device is bound to a static address `192.168.148.1/24`.

## Usage

After startup, the pre-selected password is the default password.
This is usually the password used to log into the PC.

The keyboard emulator is triggered by switching CAPS-lock on and off within 2 seconds.
The CAPS-lock key is not used by many people and this will give it a purpose.
Moreover, triggering by turning the CAPS-lock on and off still retains the former purpose of CAPS-lock if needed.
