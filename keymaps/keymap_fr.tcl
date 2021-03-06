# French AZERTY character to scancode mapping
#
# Author: Oto Petura (5phinX)

set scancodes [dict create]

# Lowercase letters
dict set scancodes "q" "0000040000000000"
dict set scancodes "b" "0000050000000000"
dict set scancodes "c" "0000060000000000"
dict set scancodes "d" "0000070000000000"
dict set scancodes "e" "0000080000000000"
dict set scancodes "f" "0000090000000000"
dict set scancodes "g" "00000A0000000000"
dict set scancodes "h" "00000B0000000000"
dict set scancodes "i" "00000C0000000000"
dict set scancodes "j" "00000D0000000000"
dict set scancodes "k" "00000E0000000000"
dict set scancodes "l" "00000F0000000000"
dict set scancodes "," "0000100000000000"
dict set scancodes "n" "0000110000000000"
dict set scancodes "o" "0000120000000000"
dict set scancodes "p" "0000130000000000"
dict set scancodes "a" "0000140000000000"
dict set scancodes "r" "0000150000000000"
dict set scancodes "s" "0000160000000000"
dict set scancodes "t" "0000170000000000"
dict set scancodes "u" "0000180000000000"
dict set scancodes "v" "0000190000000000"
dict set scancodes "z" "00001A0000000000"
dict set scancodes "x" "00001B0000000000"
dict set scancodes "y" "00001C0000000000"
dict set scancodes "w" "00001D0000000000"

# Uppercase letters 0200640000000000"= lowercase letters + left shift (modifier 0x02)
dict set scancodes "Q" "0200040000000000"
dict set scancodes "B" "0200050000000000"
dict set scancodes "C" "0200060000000000"
dict set scancodes "D" "0200070000000000"
dict set scancodes "E" "0200080000000000"
dict set scancodes "F" "0200090000000000"
dict set scancodes "G" "02000A0000000000"
dict set scancodes "H" "02000B0000000000"
dict set scancodes "I" "02000C0000000000"
dict set scancodes "J" "02000D0000000000"
dict set scancodes "K" "02000E0000000000"
dict set scancodes "L" "02000F0000000000"
dict set scancodes "?" "0200100000000000"
dict set scancodes "N" "0200110000000000"
dict set scancodes "O" "0200120000000000"
dict set scancodes "P" "0200130000000000"
dict set scancodes "A" "0200140000000000"
dict set scancodes "R" "0200150000000000"
dict set scancodes "S" "0200160000000000"
dict set scancodes "T" "0200170000000000"
dict set scancodes "U" "0200180000000000"
dict set scancodes "V" "0200190000000000"
dict set scancodes "Z" "02001A0000000000"
dict set scancodes "X" "02001B0000000000"
dict set scancodes "Y" "02001C0000000000"
dict set scancodes "W" "02001D0000000000"

# Numbers
dict set scancodes "1" "02001E0000000000"
dict set scancodes "2" "02001F0000000000"
dict set scancodes "3" "0200200000000000"
dict set scancodes "4" "0200210000000000"
dict set scancodes "5" "0200220000000000"
dict set scancodes "6" "0200230000000000"
dict set scancodes "7" "0200240000000000"
dict set scancodes "8" "0200250000000000"
dict set scancodes "9" "0200260000000000"
dict set scancodes "0" "0200270000000000"

# Symbols
dict set scancodes "²" "0000350000000000"
dict set scancodes "~" "0200350000000000"
dict set scancodes "&" "00001E0000000000"
dict set scancodes "é" "00001F0000000000"
dict set scancodes "\"" "0000200000000000"
dict set scancodes "'" "0000210000000000"
dict set scancodes "(" "0000220000000000"
dict set scancodes "-" "0000230000000000"
dict set scancodes "è" "0000240000000000"
dict set scancodes "_" "0000250000000000"
dict set scancodes "ç" "0000260000000000"
dict set scancodes "à" "0000270000000000"
dict set scancodes ")" "00002D0000000000"
dict set scancodes "=" "00002E0000000000"
dict set scancodes "°" "02002D0000000000"
dict set scancodes "+" "02002E0000000000"
dict set scancodes "^" "00002F0000000000000000000000000000002F0000000000"
dict set scancodes "$" "0000300000000000"
dict set scancodes "m" "0000330000000000"
dict set scancodes "ù" "0000340000000000"
dict set scancodes "*" "0000310000000000"
dict set scancodes ";" "0000360000000000"
dict set scancodes ":" "0000370000000000"
dict set scancodes "!" "0200380000000000"
dict set scancodes "¨" "02002F0000000000000000000000000002002F0000000000"
dict set scancodes "£" "0200300000000000"
dict set scancodes "µ" "0200310000000000"
dict set scancodes "M" "0200330000000000"
dict set scancodes "%" "0200340000000000"
dict set scancodes "." "0200360000000000"
dict set scancodes "/" "0200370000000000"
dict set scancodes "§" "0200380000000000"
dict set scancodes "`" "7000240000000000"
dict set scancodes "<" "0000640000000000"
dict set scancodes ">" "0200640000000000"
dict set scancodes "|" "7000230000000000"
dict set scancodes "\[" "7000220000000000"
dict set scancodes "]" "70002D0000000000"
dict set scancodes "{" "7000210000000000"
dict set scancodes "}" "70002E0000000000"
dict set scancodes "@" "7000270000000000"
dict set scancodes "\\" "7000250000000000"
dict set scancodes "#" "7000200000000000"
