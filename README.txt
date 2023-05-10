The user chooses either to encode/decode or terminate the program. Encode takes a 11 bit sequence and encodes it into a (15,11) Hamming Code. Decode takes a (15,11) hamming code and decodes it into the 11 bit original message.

Encode:

INPUT: 10101010101
OUTPUT: 101100101010101

INPUT: 11110000111
OUTPUT: 111111100001111

Decode:

INPUT: 101100101010101
OUTPUT: 10101010101

INPUT: 111111100001111
OUTPUT: 11110000111