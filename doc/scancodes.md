#HID key reporting

Standard HID keyboard report is a byte array [1][1]:
```
[modifier, reserved, key1, key2, key3, key4, key5, key6]
```
This array indicates one single event (up to 6 keys pressed simultaneously).

Pressing the key `a` would produce a following report:
```
[0, 0, 4, 0, 0, 0, 0, 0]
```
This sends a code 4 corresponding to a key `a`.
All the keycodes are available at [2][2] (Section 10: Keyboard/Keypad page).

Upon key release, the keyboard sends a zero report:
```
[0, 0, 0, 0, 0, 0, 0, 0]
```

The first byte contains a bitmap reserved to modifier keys.
Bitfields are assigned as follows:
```
bit 0: left control
bit 1: left shift
bit 2: left alt
bit 3: left GUI (Super, Meta, Win)
bit 4: right control
bit 5: right shift
bit 6: right alt
bit 7: right GUI
```

So a keypress of `A` would produce the following report:
```
[2, 0, 4, 0, 0, 0, 0, 0]
```

## Sources

[1]:https://docs.mbed.com/docs/ble-hid/en/latest/api/md_doc_HID.html
[2]:http://www.usb.org/developers/hidpage/Hut1_12v2.pdf
