#!/bin/bash
BREAK=0
while [ $BREAK -lt 4 ]; do
  # Genereate a password
  PASS=$(tr -cd $1 < /dev/urandom | tr -d '\\][' | fold -w$2 | head -n1)

  # Count uppercase, lowercase letters, digits and special characters
  A=$(echo $PASS | fold -w1 | grep '[[:upper:]]')
  UPPERCNT=${#A}
  A=$(echo $PASS | fold -w1 | grep '[[:lower:]]')
  LOWERCNT=${#A}
  A=$(echo $PASS | fold -w1 | grep '[[:digit:]]')
  DIGITCNT=${#A}
  A=$(echo $PASS | fold -w1 | grep '[[:punct:]]')
  PUNCTCNT=${#A}

  # Preset BREAK value to 4 => all conditions met
  BREAK=4

  # Verify that we have at least one upper and lowercase letter
  if [ $UPPERCNT -eq 0 ]; then
    let BREAK--
  fi
  if [ $LOWERCNT -eq 0 ]; then
    let BREAK--
  fi

  # Verify that we have special characters and numbers if needed
  A=$(echo $1 | grep 'digit') # Check if the numbers are required
  if [ $? -eq 0 ]; then
    if [ $DIGITCNT -eq 0 ]; then
      let BREAK--
    fi
  fi
  A=$(echo $1 | grep 'punct') # Check if the punctuation characters are required
  if [ $? -eq 0 ]; then
    if [ $PUNCTCNT -eq 0 ]; then
      let BREAK--
    fi
  fi
done

echo $PASS
