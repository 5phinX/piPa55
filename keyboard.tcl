# Keyboard emulation
#
# Author: Oto Petura (5phinX)
#
# Description:
#   The keyboard is activated by toggling the caps lock on and off within 2 seconds

# Initialize global variables
set countdown_start 0
set keyboard_activated 0

proc typePassword {fd} {
  # Load the scancodes
  if { [file exists "./selected_keymap"] } {
    set fin [open "./selected_keymap" r]
    set keymap [gets $fin]
    close $fin
  } else {
    set keymap "us"
  }
  source "keymaps/keymap_$keymap.tcl"

  # Verify if the selected password file exists
  if { [file exists "/tmp/piPa55_selected_password"] } {
    set fin [open "/tmp/piPa55_selected_password" r]
    set password_filename [gets $fin]
    close $fin
    puts $password_filename
    
    if { [file exists "pass_storage/$password_filename"] } {
      set fin [open "pass_storage/$password_filename" r]
      set username [gets $fin]
      set separator [gets $fin]
      set password [gets $fin]
      set key_after [gets $fin]
      close $fin
      # Type in all the data
      if { $separator != "none" } {
        for { set i 0 } { $i < [string length $username] } { incr i } {
          keyPress $fd [string index $username $i] $scancodes
        }
        keyPress $fd $separator $scancodes
      }
      for { set i 0 } { $i < [string length $password] } { incr i } {
        keyPress $fd [string index $password $i] $scancodes
      }
      if { $key_after != "none" } {
        keyPress $fd $key_after $scancodes
      }
    }
  } else { ;# Try default password
    if { [file exists "default_pass"] } {
      set fin [open "default_pass" r]
      set password [gets $fin]
      close $fin
      for { set i 0 } { $i < [string length $password] } { incr i } {
        keyPress $fd [string index $password $i] $scancodes
      }
      keyPress $fd "enter" $scancodes
    }
  }
}

# Process data received by keyboard
proc processData {fd} {
  global countdown_start
  global keyboard_activated

  set data [binary encode hex [read $fd]]
  # Extract the caps lock field
  set caps_bit [expr $data & 2]
  if { $caps_bit == 2 } { ;# Caps lock toggled
    # Start the countdown
    set countdown_start [clock seconds]
    set keyboard_activated 1
  } elseif { $caps_bit == 0 } {
    if { $keyboard_activated == 1 && [expr [clock seconds] - $countdown_start] <= 2 } {
      set keyboard_activated 0
      typePassword $fd
    }
  }
}

# Press a key
proc keyPress {fd key scancodes} {

  if { $key == "tab" } {
    # Press TAB
    puts -nonewline $fd "\x00\x00\x2B\x00\x00\x00\x00\x00"
    # Release TAB
    puts -nonewline $fd "\x00\x00\x00\x00\x00\x00\x00\x00"
  } elseif { $key == "enter" } {
    # Press enter
    puts -nonewline $fd "\x00\x00\x28\x00\x00\x00\x00\x00"
    # Release enter
    puts -nonewline $fd "\x00\x00\x00\x00\x00\x00\x00\x00"
  } else {
    # Press a key
    puts -nonewline $fd [binary decode hex [dict get $scancodes [string index $key 0]]]
    # Release a key
    puts -nonewline $fd "\x00\x00\x00\x00\x00\x00\x00\x00"
  }
}

# Open keyboard device
set fd [open /dev/hidg0 w+]

# Define callback to delayed typing
proc delayedPasswordType {sock addr port} {
  global fd
  set delay [gets $sock] ;# Get delay from socket
  after $delay typePassword $fd ;# Type password after specified delay
  close $sock ;# Close the socket
}

# No buffering
fconfigure $fd -buffering none -blocking false

# Source CAPS lock detection settings
source "settings/capsEnable.tcl"
if { $capsEnabled == 1 } {
  # When data is received, process it
  fileevent $fd readable [list processData $fd]
}

# Open socket for IPC in order to activate delayed password typing
socket -server delayedPasswordType 1100 ;# Open socket at port 1100

# Wait forever
vwait ::FOREVER

close $fd
