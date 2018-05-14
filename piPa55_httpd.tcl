# piPa55 HTTP server
#
# Author: Oto Petura (5phinX)
#
# Description:
#   Very simple HTTP server, which is used to manage passwords in storage

# Maximum time to read the request (seconds)
set http_timeout 10

# Create URL decode map
lappend url_decode + { } ;# Manually add mapping + -> ' '
for {set i 0} {$i < 256} {incr i} {
  set char [format %c $i]
  set hex %[format %02x $i]
  if { ![string match {[a-zA-Z0-9]} $char] } { ;# Add mapping for all non-alphanumeric characters
    lappend url_decode $hex $char
  }
}

# Accept HTTP connections 
proc accept_connection {sock remoteAddr remotePort} {
  global http_timeout

  # Read HTTP request 
  set timeout_start [clock seconds]
  set lineNum 0
  set headers [dict create]
  # Read every line from socket until the empty line
  for { set req_line [gets $sock] } { $req_line != "" && $req_line != "\r" } { set req_line [gets $sock] } {
    # Create HTTP request data fields
    if { $lineNum == 0 } {
      set method [lindex [split $req_line " "] 0]
      set uri [lindex [split $req_line " "] 1]
      set protocol [lindex [split $req_line " "] 2]
    } else {
      # Header name, data delimiter
      set header_colon [string first ":" $req_line]
      if { $header_colon != -1 } { ;# Valid header
        set header_name [string tolower [string range $req_line 0 $header_colon-1]]
        set header_value [string range $req_line $header_colon+2 end]
        dict set headers $header_name $header_value
      }
    }
    incr lineNum

    # If timeout expires, close the socket and ignore data
    if { [expr [clock seconds] - $timeout_start] >= $http_timeout } {
      set lineNum 0
      close $sock
      break
    }
  }

  # If the request was received, process it
  if { $lineNum != 0 } {
    process_http_request $sock $method $uri $protocol $headers
  }
}

# Process HTTP requests
proc process_http_request {sock method uri protocol headers} {
  # Split the target and URI parameters
  if { [string first "?" $uri] != -1 } {
    set uri_target [lindex [split $uri "?"] 0]
    set uri_params [lindex [split $uri "?"] 1]
  } else {
    set uri_target $uri
    set uri_params "\0"
  }

  # Process data according to the method (only GET and POST are supported)
  switch $method {
    "GET"   {send_get_response $sock $uri_target $uri_params $protocol $headers}
    "POST"  {send_post_response $sock $uri_target $uri_params $protocol $headers}
    default {
      puts $sock "$protocol 501 Not Implemented"
      puts $sock ""
      puts $sock "<html><head><title>Error</title></head><body><h1>501 - Not Implemented</h1><p>Requested HTTP method is not supported</p></body></html>"
      close $sock
    }
  }
}

# Process a GET request and serve a response
proc send_get_response {sock uri_target uri_params protocol headers} {
  # Ignore target and serve index.html
  puts $sock "$protocol 200 OK"
  puts $sock ""
  serve_index $sock
  close $sock
}

# Process a POST request and serve a response
proc send_post_response {sock uri_target uri_params protocol headers} {
  global url_decode

  # Process POST data
  if { ![catch [list dict get $headers content-length]] } {
    # Read the data and split it according to variables
    set post_data [split [read $sock [dict get $headers content-length]] "&"]
    set post_vars [dict create]
    foreach post_field $post_data {
      # Divide variable name and value
      set tmp [split $post_field "="]
      # URL decode both and put them in the dictionary
      dict set post_vars [string map $url_decode [lindex $tmp 0]] [string map $url_decode [lindex $tmp 1]]
    }
    # Free the unused variables
    unset post_data
    unset tmp
  } else {
    puts $sock "$protocol 400 Bad Request"
    puts $sock ""
    puts $sock "<html><head><title>Error</title></head><body><h1>400 - Bad Request</h1><p>Malformed HTTP request</p></body></html>"
    close $sock
    return 1
  }

  # Process form data
  if { ![catch [list dict get $post_vars selectPass]] } { ;# Select a password
    # Verify if the password is provided
    if { [string length [dict get $post_vars selected_pass]] > 0 } {
      set fd [open "/tmp/piPa55_selected_password" w]
      puts -nonewline $fd [dict get $post_vars selected_pass]
      close $fd
      set messages "<div class=\"success_message\">Password [dict get $post_vars selected_pass] selected</div>"
    } else {
      set messages "<div class=\"error_message\">No password selected</div>"
    }
  } elseif { ![catch [list dict get $post_vars genPass]] } { ;# Save/generate a password
    # Verify mandatory fields
    set all_params_ok true
    set messages ""
    # Check for password name
    if { [string length [dict get $post_vars passName]] == 0 } {
      set all_params_ok false
      set messages "$messages<div class=\"error_message\">Password must have a name</div>"
    }
    # Check for username if the username should be typed
    if { [dict get $post_vars username_separator] != "none" && [string length [dict get $post_vars username]] == 0 } {
      set all_params_ok false
      set messages "$messages<div class=\"error_message\">Username must be provided if it is to be typed</div>"
    }
    # Continue only when no errors occures
    if { $all_params_ok == true } {
      # Save a password if it was provided
      if { [string length [dict get $post_vars pass]] != 0 } {
        set fd [open "pass_storage/[dict get $post_vars passName]" w]
        puts $fd [dict get $post_vars username]
        puts $fd [dict get $post_vars username_separator]
        puts $fd [dict get $post_vars pass]
        if { ![catch [list dict get $post_vars key_after_pass]] } { 
          puts $fd [dict get $post_vars key_after_pass]
        } else {
          puts $fd "none"
        }
        close $fd
        set messages "<div class=\"success_message\">Password [dict get $post_vars passName] saved</div>"
      } else { ;# Generate a new password
        set pass_filter "\[:alpha:\]" ;# Initialize password filter
        if { ![catch [list dict get $post_vars numeric]] } {
          set pass_filter "$pass_filter\[:digit:\]"
        }
        if { ![catch [list dict get $post_vars special]] } {
          set pass_filter "$pass_filter\[:punct:\]"
        }
        # Generate a password
        catch [list exec ./generatePassword.sh $pass_filter [dict get $post_vars length]] generated_password
        # Store generated password
        set fd [open "pass_storage/[dict get $post_vars passName]" w]
        puts $fd [dict get $post_vars username]
        puts $fd [dict get $post_vars username_separator]
        puts $fd $generated_password
        if { ![catch [list dict get $post_vars key_after_pass]] } { 
          puts $fd [dict get $post_vars key_after_pass]
        } else {
          puts $fd "none"
        }
        close $fd
        set messages "<div class=\"success_message\">Password [dict get $post_vars passName] generated<br />Generated password: $generated_password</div>"
      }
    }
  } elseif { ![catch [list dict get $post_vars deletePass]] } { ;# Delete a password from storage
    if { [string length [dict get $post_vars selected_pass]] > 0 } {
      if { ![catch [list file delete "pass_storage/[dict get $post_vars selected_pass]"]] } {
        set messages "<div class=\"success_message\">Password [dict get $post_vars selected_pass] was deleted</div>"
      } else {
        set messages "<div class=\"error_message\">Password [dict get $post_vars selected_pass] could not be deleted</div>"
      }
    }
  } elseif { ![catch [list dict get $post_vars setDefaultPass]] } { ;# Save default password
    if { [string length [dict get $post_vars pass]] > 0 } {
      set fd [open "./default_pass" w]
      puts -nonewline $fd [dict get $post_vars pass]
      close $fd
      set messages "<div class=\"success_message\">Default password set</div>"
    } else {
      set messages "<div class=\"error_messages\">Default password must be provided</div>"
    }
  } elseif { ![catch [list dict get $post_vars selectKeymap]] } { ;# Set keymap
    if { [string length [dict get $post_vars selected_keymap]] > 0 } {
      set fd [open "./selected_keymap" w]
      puts -nonewline $fd [dict get $post_vars selected_keymap]
      close $fd
      set messages "<div class=\"success_message\">Keymap '[dict get $post_vars selected_keymap]' selected</div>"
    }
  }


  # Initialize messages if no message was passed
  if { ![info exists messages] } {
    set messages ""
  }

  # Serve index.html
  puts $sock "$protocol 200 OK"
  puts $sock ""
  serve_index $sock $messages
  close $sock
}

# Serve index.html
proc serve_index {sock {messages ""}} {
  # Read the index.html file
  set fd [open "index.html"]
  set index_contents [read $fd]
  close $fd

  # List all the stored passwords and compile an HTML list
  set html_pass_list ""
  if { ![catch [list glob "pass_storage/*"]] } {
    set pass_list [glob "pass_storage/*"]
    foreach pass $pass_list {
      # Leave only the filename, get rid of path
      set pass_name [string range $pass [string last "/" $pass]+1 end]
      set html_pass_list "$html_pass_list<option value=\"$pass_name\">$pass_name</option>"
    }
  }

  # List all installed keymaps
  set html_keymap_list ""
  if { ![catch [list glob "./keymap_*.tcl"]] } {
    set keymap_list [glob "./keymap_*.tcl"]
    foreach keymap $keymap_list {
      # Leave only the keymap
      set keymap_end [expr [string first "." $keymap 2] - 1]
      set keymap_start [expr [string first "keymap_" $keymap] + [string length "keymap_"]]
      set keymap_name [string range $keymap $keymap_start $keymap_end]
      set html_keymap_list "$html_keymap_list<option value=\"$keymap_name\">$keymap_name</option>"
    }
  }

  # Replace <fillSelect1> and <fillSelect2> with password list
  set index_contents [string replace $index_contents [string first "<fillSelect1>" $index_contents] [expr [string length "<fillSelect1>"] + [string first "<fillSelect1>" $index_contents]] $html_pass_list]
  set index_contents [string replace $index_contents [string first "<fillSelect2>" $index_contents] [expr [string length "<fillSelect2>"] + [string first "<fillSelect2>" $index_contents]] $html_pass_list]

  set index_contents [string replace $index_contents [string first "<fillKeymaps>" $index_contents] [expr [string length "<fillKeymaps>"] + [string first "<fillKeymaps>" $index_contents]] $html_keymap_list]

  # Replace <messages> with messages to pass to the user
  set index_contents [string replace $index_contents [string first "<messages>" $index_contents] [expr [string length "<messages>"] + [string first "<messages>" $index_contents]] $messages]

  puts $sock $index_contents
}

# Start a server
socket -server accept_connection 80
# Wait forever
vwait forever
