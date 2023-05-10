 # Name: Brandon Qiu
 # Email: bqiu@buffalo.edu
 # UBIT: bqiu
 
 #Function/Module Name: Hamming Encoder/ Decoder
#
 #Summary of Purpose: Takes user input and performs a hamming encode or decode operation based on user choice
#
 #Input/Stored Value Requirements: 16/11 sequence of binary
 #
#Values Stored/Returned: Encoded/ Decoded Input & Message Bits


.data 0x10000000
	prompt1: .asciiz "Please choose operation (e to encode, d to decode, t to terminate): "
.data 0x10000100
	newLine: .asciiz "\n"
.data 0x10000200
	validMSG: .asciiz "\nValidated message after correction: "
.data 0x10002000
	exitprompt: .asciiz "\nProgram end."
.data 0x10003000
	encodePrompt: .asciiz "\nPlease enter message to encode (11 bits of binary): "
.data 0x10004000
	decodePrompt: .asciiz "\nPlease enter encoded message (16 bits hamming code): "
.data 0x10004100
	error: .asciiz "\nERROR: Please choose e, d, or t\n"
.data 0x10004500
	buffer: .space 12 # space for the string
.data 0x10004700
	arr: .space 48 # 44 bytes for 11 numbers + 1
.data 0x10005000
	ham: .space 64 # 64 bytes to store 16 integers
.data 0x10006000
	loopCheckMsg: .asciiz "\nEncoded Message: "
.data 0x10007000
	parity8: .asciiz "\n P8: "
.data 0x10007010
	parity4: .asciiz "\n P4: "
.data 0x10007020
	parity2: .asciiz "\n P2: "
.data 0x10007030
	parity1: .asciiz "\n P1: "
.data 0x10007040
	parityTotal: .asciiz "\n PT: "
.data 0x10007100
	dArr: .space 64 # 64 bytes to hold encoded message
.data 0x10007200
	dBuffer: .space 17
.data 0x10007300
	dMessageBits: .space 44
.data 0x10007400
	msg: .asciiz "\nMessage: "
.data 0x10007500
	pInvalid: .space 16 # unvalidated parity bits
.data 0x10008000
	pValid: .space 20 # validated parity bits
.data 0x10008100
	syndrome: .space 16 # syndrome
.data 0x10008200
	syndromeMsg: .asciiz "\nHamming Syndrome: "
.data 0x10008300
	invalidBits: .asciiz "\nBefore validation: "
.data 0x10008350
	validBits: .asciiz "\nAfter running encode: "
.data 0x10008400
	pass: .asciiz "\n Total Parity - PASS"
.data 0x10008450
	failmsg: .asciiz "\n Total Parity - FAIL"
.data 0x10008500
	zeroError: .asciiz "\n The encoded codeword is valid"
.data 0x10008550
	oneError: .asciiz "\n The encoded codeword has 1 error"
.data 0x10008600
	twoErrors: .asciiz "\n The encoded codeword has 2 errors"
.data 0x10008650
	hammingValid: .asciiz "\nValidated hamming code: "


.text
	main:
		addi $v1, $0, 1
		# prints prompt1
		lui $t9, 0x1000
		ori $a0, $t9, 0x0000
		addi $v0, $0, 4
		syscall # print string
		add $0, $0, $0 #nop

		# reads the character and stores it
		or $0, $0, $0
		addi $v0, $0, 12
		syscall
		add $0, $0, $0 #nop
		add $t0, $0, $v0 # stores read character into t0
		add $a3, $0, $v0 # stores input into a3, to be used as a check

		# check what the input instructs
		ori $t1, 101 # e
		ori $t2, 100 # d
		ori $t3, 116 # t
		ori $t4, 69 # E
		ori $t5, 68 # D
		ori $t6, 84 # T
		beq $t0, $t1, encode
		add $0, $0, $0
		beq $t0, $t4, encode
		add $0, $0, $0
		
		beq $t0, $t2, decode
		add $0, $0, $0
		beq $t0, $t5, decode
		add $0,$0,$0
		
		beq $t0, $t3, exit
		add $0, $0, $0
		beq $t0, $t6, exit
		add $0,$0,$0
		
		addi $v0, $0, 4
		ori $a0, $t9, 0x4100
		syscall
		j decode
		add $0,$0,$0
		
	encode:
		# prints prompt asking for message
		ori $a0, $t9, 0x3000
		addi $v0, $0, 4
		syscall # code 4: print string
		or $0, $0, $0
		
		# stores given message as a string
		ori $a0, $t9, 0x4500
		addi $v0, $0, 8
		addi $a1, $0, 12
		syscall # syscall code 8 : read string
		add $0, $0, $0 #nop
		
		#newLine
		addi $v0, $0, 4
		ori $a0, $t9, 0x1000
		syscall
		
		
		#sw $ra, 0($sp)
		#addi $sp, $sp, -4 # make room to store return pointer onto stack
		
		ori $a0,$t9, 0x4500 # a0 = buffer
		ori $a1, $t9, 0x4700 #a1 = start of arr
		add $t3, $0, $0
		
		# insert a 1 at the start of the buffer
		addi $t1, $0, 1
		sw $t1, 0($a1)
		add $0,$0,$0
		
		addiu $a1, $a1, 4
		
		j loop # loop to copy string over to buffer as integers
		add $0,$0,$0
	loopEnd:
		# initialize t1 as the hamming array
		ori $t1, $t9, 0x5000
		# initialize s1 as the start of the message array
		ori $s1,$t9, 0x4700
		addiu $s1, $s1, 4
		# initialize iterators
		add $a1, $0, $0
		add $a2, $0, $0
		
		# everything before hamming runs
		
		#newLine
		addi $v0,$0, 4
		ori $a0, $t9, 0x1000
		syscall
		
		
		
		j hamming # run hamming function
		add $0,$0,$0
		#lw $ra, 0($sp) # store return pointer back
		#addi $sp, $sp, 4 # move stack back up
	hammingEnd:
		# loop thru the memory to verify the hamming code
		ori $a0,$t9, 0x6000
		
		#print loop message
		addi $v0, $0, 4
		syscall
		
		ori $a1,$t9, 0x5000
		#addi $a1, $a1, 0x4
		addi $t4, $0, 0
		j hammingPrinter
		add $0,$0,$0
	loop: # puts the inputted message into an array of integers
		# t3 = iterator
		lb $t5, 0($a0)
		add $0,$0,$0
		addi $t1, $0, 48
		beq $t5, $t1, putZero # if t5 is not zero go to label
		add $0, $0, $0
		addi $t1, $0, 49
		beq $t5, $t1, putOne
		add $0, $0, $0
		
	loopContinue:
		addi $t0, $0, 11 # iterator end
		
		addi $t3, $t3, 1
		
		#blt $t3, $t0, loop
		slt $t4, $t3, $t0
		bne $t4, $0, loop
		
		j loopEnd
		add $0, $0, $0
	
	putOne: # puts a one into the int buffer
		addi $t2, $0, 1
		sw $t2, 0($a1)
		add $0,$0,$0
		addiu $a0, $a0, 1 # increment a1 by a byte to get next char
		addiu $a1, $a1, 4 # increment a2 by 4 to next word
		j loopContinue
		add $0, $0, $0
		
	putZero: # puts a one into the int buffer
		addi $t2, $0, 0
		sw $t2, 0($a1)
		add $0,$0,$0
		addiu $a0, $a0, 1 # increment a1 by a byte to get next char
		addiu $a1, $a1, 4 # increment a2 by 4 to next word
		j loopContinue
		add $0, $0, $0
		
		
		
	hamming:
		# parity bits are 7,11,13,14,15
		# if index = parity bit index then put a zero and increment the hamming iterator 
		# else: input what is in the original message into hamming array and increment both iterators
		# t1 = start of hamming array
		# s1 = start of original message array
		# a1 = iterator variable for hamming array
		# a2 = iterator variable for original message array
		add $0, $0, $0
		
		addi $t2, $0, 7
		addi $t3, $0, 11
		addi $t4, $0, 13
		addi $t5, $0, 14
		addi $t6, $0, 15
		addi $t7, $0, 16

		#addi $s4, $0, 32
		
		beq $a1, $t2, insertZero # if index is at parity bit index
		add $0, $0, $0
		beq $a1, $t3, insertZero
		add $0, $0, $0
		beq $a1, $t4, insertZero
		add $0, $0, $0
		beq $a1, $t5, insertZero
		add $0, $0, $0
		beq $a1, $t6, insertZero
		add $0, $0, $0

		#beq $a1, $t7, insertZero
		
		
		
		# if a2 > 16, it means the original message is finished, and you need to pad with zeros
		#slt $s2, $t7, $a2
		#beq $s2, $t3, insertZero
		
		
		# if index is not at parity index, insert message[a2] into hArr[a1], then increment both
		lw $s5, 0($s1) # s5 is used to temporarily store the word that s1 is pointing at
		add $0,$0,$0
		addiu $s1, $s1, 4 # increment s1 to next word
		sw $s5, 0($t1) # store s5 into location at t1
		add $0,$0,$0 #nop
		addiu $t1, $t1, 4 # increment t1 to next word
		addi $a2, $a2, 1
		addi $a1, $a1, 1
		
		
		# break out loop if a1 < 16
		
		
		#blt $a1, $t7, hamming
		slt $t4, $a1, $t7
		bne $t4, $0, hamming
		add $0,$0,$0
		
		
		#addi $s4, $0, 68
		#beq $a3, $s4, decodeParity
		#add $0, $0, $0
		#beq $s4, $0, 100
		#beq $a3, $s4, decodeParity
		#add $0, $0, $0
		ori $a1, $t9,0x5000
		ori $t7,$t9, 0x8000
		j p8
		add $0, $0, $0
	
		
	insertZero:
		# places zeros in t1
		
		add $a3, $0, $0
		sw $a3, 0($t1)
		add $0, $0, $0
		addiu $t1, $t1, 4 # increment location of t1
		addi $a1, $a1, 1 # increment hamming iterator only
		
		
		j hamming
		
		add $0, $0, $0

		
	p8: # D5, D6, D7, D8, D9, D10, D11
		
		
		
		lw $a2, 0($a1) # a2 = d11
		add $0,$0,$0
		lw $a3, 4($a1) # a3 = d10
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 8($a1) # a3 = d9
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 12($a1) # a3 = d8
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 16($a1) # a3 = d7
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 20($a1) # a3 = d6
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 24($a1) # a3 = d5
		add $0,$0,$0
		xor $a2, $a2, $a3
		
		# store parity bit back in
		sw $a2, 28($a1)
		add $0,$0,$0
		sw $a2, 0($t7)
		add $0,$0,$0
		
		addi $s7, $0, 2002
		beq $s3, $s7, p4
		add $0,$0,$0
		
		# print the stuff out
		ori $a0,$t9, 0x7000
		addi $v0, $0, 4
		syscall
		add $0,$0,$0
		add $a0, $0, $a2
		addi $v0, $0, 1
		syscall
		add $0,$0,$0
		
	
	p4: # D2, D3, D4, D8, D9, D10, D11
		lw $a2, 0($a1) # a2 = d11
		add $0,$0,$0
		lw $a3, 4($a1) # a3 = d10
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 8($a1) # a3 = d9
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 12($a1) # a3 = d8
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 32($a1) # a3 = d4
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 36($a1) # a3 = d3
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 40($a1) # a3 = d2
		add $0,$0,$0
		xor $a2, $a2, $a3
		
		# store parity bit back in
		sw $a2, 44($a1)
		add $0,$0,$0
		sw $a2, 4($t7)
		add $0,$0,$0
		
		addi $s7, $0, 2002 # if decoding skip
		beq $s3, $s7, p2
		add $0,$0,$0
		
		# print the stuff out
		ori $a0,$t9, 0x7010
		addi $v0, $0, 4
		syscall
		add $0,$0,$0
		add $a0, $0, $a2
		addi $v0, $0, 1
		syscall
		add $0,$0,$0
		j p2
		add $0,$0,$0
		
	p2: # D1, D3, D4, D6, D7, D10, D11
		lw $a2, 0($a1) # a2 = d11
		add $0,$0,$0
		lw $a3, 4($a1) # a3 = d10
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 16($a1) # a3 = d7
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 20($a1) # a3 = d6
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 32($a1) # a3 = d4
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 36($a1) # a3 = d3
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 48($a1) # a3 = d1
		add $0,$0,$0
		xor $a2, $a2, $a3
		
		# store parity bit back in
		sw $a2, 52($a1)
		add $0,$0,$0
		sw $a2, 8($t7)
		add $0,$0,$0
		
		addi $s7, $0, 2002
		beq $s3, $s7, p1
		add $0,$0,$0
		
		# print the stuff out
		ori $a0,$t9, 0x7020
		addi $v0, $0, 4
		syscall
		add $0,$0,$0
		add $a0, $0, $a2
		addi $v0, $0, 1
		syscall
		add $0,$0,$0
		j p1
		add $0,$0,$0
		
	p1: # D1, D2, D4, D5, D7, D9, D11
		lw $a2, 0($a1) # a2 = d11
		add $0,$0,$0
		lw $a3, 8($a1) # a3 = d9
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 16($a1) # a3 = d7
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 24($a1) # a3 = d5
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 32($a1) # a3 = d4
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 40($a1) # a3 = d2
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 48($a1) # a3 = d1
		add $0,$0,$0
		xor $a2, $a2, $a3
		
		# store parity bit back in
		sw $a2, 56($a1)
		add $0,$0,$0
		sw $a2, 12($t7)
		add $0,$0,$0
		
		addi $s7, $0, 2002
		beq $s3, $s7, ptotal
		add $0,$0,$0
		
		# print the stuff out
		ori $a0,$t9, 0x7030
		addi $v0, $0, 4
		syscall
		add $0,$0,$0
		addi $t5, $0, 2023
		
		add $a0, $0, $a2
		addi $v0, $0, 1
		syscall
		add $0, $0, $0
		beq $s3, $t5, dParity
		j ptotal
		add $0, $0, $0
	ptotal: # D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, P1, P2, P4, P8
		ori $a1,$t9, 0x5000
		lw $a2, 0($a1) # a2 = d11
		add $0,$0,$0
		lw $a3, 4($a1) # a3 = d9
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 8($a1) # a3 = d7
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 12($a1) # a3 = d5
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 16($a1) # a3 = d4
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 20($a1) # a3 = d2
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 24($a1) # a3 = d1
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 28($a1) # a3 = d1
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 32($a1) # a3 = d1
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 36($a1) # a3 = d1
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 40($a1) # a3 = d1
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 44($a1) # a3 = d1
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 48($a1) # a3 = d1
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 52($a1) # a3 = d1
		add $0,$0,$0
		xor $a2, $a2, $a3
		lw $a3, 56($a1) # a3 = d1
		add $0,$0,$0
		xor $a2, $a2, $a3
		
		# store parity bit back in
		sw $a2, 60($a1)
		add $0,$0,$0
		
		# print the stuff out
		ori $a0,$t9, 0x7040
		addi $v0, $0, 4
		syscall
		add $0,$0,$0
		
		add $a0, $0, $a2
		addi $v0, $0, 1
		syscall
		add $0, $0,$0
		

		addi $s5, $0, 2002
		beq $s3, $s5, syndromeCalc1
		add $0, $0, $0
		j hammingEnd
		add $0,$0,$0
	hammingPrinter:
		# a1 = start of hamming buffer
		# t4 = iterator
		addi $v0, $0, 1
		addi $t6, $0, 16
		lw $a0, 0($a1)
		add $0,$0,$0
		syscall
		addiu $a1, $a1, 4
		addi $t4, $t4, 1
		
		
		#blt $t4, $t6, hammingPrinter
		slt $t7, $t4, $t6
		bne $t7, $0, hammingPrinter
		
		add $0,$0,$0
		addi $t8, $0, 404
		beq $s5, $t8, validMsgPrint
		add $0,$0,$0
		j exit
		add $0,$0,$0
	decode:
		ori $a0, $t9, 0x4000
		addi $v0, $0, 4
		syscall
		
		# stores given message as a string
		ori $a0,$t9, 0x7200
		addi $v0, $0, 8
		addi $a1, $0, 17
		syscall # syscall code 8 : read string
		add $0, $0, $0 #nop
		
		add $t3, $0, $0
		 
		ori $a1,$t9, 0x7100
		j dloop
		add $0,$0,$0
		
	dloop: # puts the inputted message into an array of integers
		# t3 = iterator
		lb $t5, 0($a0)
		add $0,$0,$0
		addi $t1, $0, 48
		beq $t5, $t1, dputZero # if t5 is not zero go to label
		add $0, $0, $0
		addi $t1, $0, 49
		beq $t5, $t1, dputOne
		add $0, $0, $0
		
	dloopContinue:
		addi $t0, $0, 16 # iterator end
		
		addi $t3, $t3, 1
		
		#blt $t3, $t0, dloop
		slt $t5, $t3, $t0
		bne $t5, $0, dloop
		
		j dloopEnd
		add $0, $0, $0
		
	dputOne: # puts a one into the int buffer
		addi $t2, $0, 1
		sw $t2, 0($a1)
		add $0,$0,$0
		addiu $a0, $a0, 1 # increment a1 by a byte to get next char
		addiu $a1, $a1, 4 # increment a2 by 4 to next word
		j dloopContinue
		add $0, $0, $0
		
	dputZero: # puts a one into the int buffer
		addi $t2, $0, 0
		sw $t2, 0($a1)
		add $0,$0,$0
		addiu $a0, $a0, 1 # increment a1 by a byte to get next char
		addiu $a1, $a1, 4 # increment a2 by 4 to next word
		j dloopContinue
		add $0, $0, $0
	
	dloopEnd:
		# extract the 11 message bits and output it
		ori $a1,$t9, 0x7100
		ori $s1,$t9, 0x7300
		
		addi $v0, $0, 4
		ori $a0,$t9, 0x7400
		syscall
		
		
		lw $s2, 0($a1)
		add $0,$0,$0
		sw $s2, 0($s1)
		add $0,$0,$0
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		
		lw $s2, 4($a1)
		add $0,$0,$0
		sw $s2, 4($s1)
		add $0,$0,$0
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 8($a1)
		add $0,$0,$0
		sw $s2, 8($s1)
		add $0,$0,$0
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 12($a1)
		add $0,$0,$0
		sw $s2, 12($s1)
		add $0,$0,$0
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 16($a1)
		add $0,$0,$0
		sw $s2, 16($s1)
		add $0,$0,$0
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 20($a1)
		add $0,$0,$0
		sw $s2, 20($s1)
		add $0,$0,$0
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 24($a1)
		add $0,$0,$0
		sw $s2, 24($s1)
		add $0,$0,$0
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 32($a1)
		add $0,$0,$0
		sw $s2, 28($s1)
		add $0,$0,$0
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 36($a1)
		add $0,$0,$0
		sw $s2, 32($s1)
		add $0,$0,$0
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 40($a1)
		add $0,$0,$0
		sw $s2, 36($s1)
		add $0,$0,$0
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 48($a1)
		add $0,$0,$0
		sw $s2, 40($s1)
		add $0,$0,$0
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		
		addi $s3, $0, 2023 # flag for ptotal to check if the user called encode or decode 
		ori $a1,$t9, 0x7100
		ori $t7,$t9, 0x7500
		
		
		ori $a0,$t9, 0x7000 # P8:
		addi $v0, $0, 4
		syscall
		add $0,$0,$0
		
		
		lw $t6, 28($a1) #p8
		add $0,$0,$0
		sw $t6, 0($t7)
		add $0,$0,$0
		add $a0, $0, $t6
		addi $v0, $0, 1
		syscall
		add $0,$0,$0
		
		ori $a0,$t9, 0x7010 # P4:
		addi $v0, $0, 4
		syscall
		add $0,$0,$0
		
		lw $t6, 44($a1) #p4
		add $0,$0,$0
		sw $t6, 4($t7)
		add $0,$0,$0
		add $a0, $0, $t6
		addi $v0, $0, 1
		syscall
		add $0,$0,$0
		
		ori $a0,$t9, 0x7020 # P2:
		addi $v0, $0, 4
		syscall
		add $0,$0,$0
		
		lw $t6, 52($a1) #p2
		add $0,$0,$0
		sw $t6, 8($t7)
		add $0,$0,$0
		add $a0, $0, $t6
		addi $v0, $0, 1
		syscall
		add $0,$0,$0
		
		ori $a0,$t9, 0x7030 # P1:
		addi $v0, $0, 4
		syscall
		add $0,$0,$0
		
		lw $t6, 56($a1) #p1
		add $0,$0,$0
		sw $t6, 12($t7)
		add $0,$0,$0
		add $a0, $0, $t6
		addi $v0, $0, 1
		syscall
		add $0,$0,$0
		
		j dParity
		add $0,$0,$0
		
		
	syndromeCalc1:
		ori $a1,$t9, 0x7500 # a1 = pInvalid
		ori $a2,$t9, 0x8000 # a2 = pvalid
		ori $s2,$t9, 0x8100 # s2 = syndrome
		addi $s4, $0, 0 # s4 = iterator
		addi $t2, $0, 0 # t2 = incorrect counter
		addi $t8, $0, 0 # t8 holds the integer that corresponds to the syndrome
		
		ori $a0,$t9, 0x8200
		addi $v0, $0, 4
		syscall
		add $0, $0, $0
		
		j syndromeCalc2
		add $0, $0, $0
		
	syndromeCalc2:
		addi $s7, $0, 4 

		lw $t0, 0($a1)
		add $0,$0,$0
		lw $t1, 0($a2)
		add $0,$0,$0
		#addi $v0, $0, 1
		#lw $a0, 0($a1)
		#syscall
		#addi $v0, $0, 1
		#lw $a0, 0($a2)
		#syscall
		beq $t0, $t1, correct
		add $0, $0, $0
		bne $t0, $t1, incorrect
		add $0, $0, $0
	syndromeCalc3:
		#blt $s4, $s7, syndromeCalc2
		
		slt $t6, $s4, $s7
		bne $t6, $0, syndromeCalc2
		
		add $0, $0, $0
		j passOrFail
		add $0,$0,$0
		
	correct:
	
		addi $a0, $0, 0 # prints zero
		addi $v0, $0, 1
		syscall
		add $0, $0, $0
		
		addi $t5, $0, 0 # puts a zero into hamming syndrome array
		sw $t5, 0($s2)
		add $0, $0, $0
		addiu $a1, $a1, 4
		addiu $a2, $a2, 4
		addiu $s2, $s2, 4
		addi $s4, $s4, 1
		sll $t8, $t8, 1
		addi $t8, $t8, 0
		
		j syndromeCalc3
		add $0, $0, $0
		
	incorrect:
		addi $a0, $0, 1 # prints and puts a 1 into hamming syndrome array
		addi $v0, $0, 1
		syscall
		add $0, $0, $0
		
		addi $t5, $0, 1
		sw $t5, 0($s2)
		add $0, $0, $0
		addiu $a1, $a1, 4
		addiu $a2, $a2, 4
		addiu $s2, $s2, 4
		addi $s4, $s4, 1
		addi $t2, $t2, 1
		sll $t8, $t8, 1

		add $t8, $t8, $t5  # add value to register and shift left

		j syndromeCalc3
		add $0, $0, $0
	dParity:
		ori $t7,$t9, 0x8000
		addi $s3, $0, 2002
		addi $s4, $0, 4000
		# t1 = start of hamming array
		# s1 = start of original message array
		# a1 = iterator variable for hamming array
		# a2 = iterator variable for original message array
		ori $t1,$t9, 0x5000
		ori $s1,$t9, 0x7300
		addi $a1, $0, 0
		addi $a2, $0, 0

		j hamming
		add $0,$0,$0
		
	parityPrinter: # verifies the integrity of the parity bits
		addi $v0, $0, 4
		ori $a0,$t9, 0x8300
		syscall
		add $0, $0, $0
		
		ori $a1,$t9, 0x8300
		ori $a2,$t9, 0x8000
		
		addi $v0, $0, 1
		lw $a0, 0($a1)
		add $0,$0,$0
		syscall
		lw $a0, 4($a1)
		add $0,$0,$0
		syscall
		lw $a0, 8($a1)
		add $0,$0,$0
		syscall
		lw $a0, 12($a1)
		add $0,$0,$0
		syscall
		
			
		addi $v0, $0, 4
		ori $a0,$t9,0x8350
		syscall
		add $0, $0, $0	
			
		addi $v0, $0, 1
		lw $a0, 0($a2)
		add $0,$0,$0
		syscall
		lw $a0, 4($a2)
		add $0,$0,$0
		syscall
		lw $a0, 8($a2)
		add $0,$0,$0
		syscall
		lw $a0, 12($a2)
		add $0,$0,$0
		syscall
		
		j exit
		add $0,$0,$0

	passOrFail:
		ori $a1,$t9, 0x7100
		ori $a2,$t9, 0x5000
		lw $t5, 60($a2)
		add $0,$0,$0
		lw $t6, 60($a1)
		add $0,$0,$0
		ori $a0,$t9, 0x0100
		addi $v0, $0, 4
		syscall
		
		
		bne $t5, $t6, fail
		add $0,$0,$0
		
		ori $a1,$t9, 0x8000
		ori $a2,$t9, 0x7100
		
	
		ori $a0,$t9, 0x8400
		addi $v0, $0, 4
		syscall
		add $0,$0,$0
		
		ori $a1,$t9, 0x8000
		lw $s5, 16($a1)
		add $0,$0,$0
		bne $t2, $0, twoErrorCase # if the hamming syndrome is non zero, but parity total is zero
		add $0,$0,$0
		
		ori $a0,$t9, 0x8500
		addi $v0, $0, 4
		syscall 
		add $0,$0,$0
		
		
		
		j exit
		add $0,$0,$0
	
	fail:
		ori $a0,$t9, 0x8450
		addi $v0, $0, 4
		syscall
		add $0,$0,$0
		addi $t6, $0, 1
		
		
		
		j oneErrorCase # in order to check for one error, convert syndrome into an integer that corresponds to a position in the code
		add $0,$0,$0
	
	ptInvalid:
		addi $t4, $0, 0
		addi $s5, $0, 404 # flag for hamming print
		
		ori $a0,$t9, 0x8450
		addi $v0, $0, 4
		syscall
		add $0,$0,$0
		
		ori $a0,$t9, 0x8550
		addi $v0, $0, 4
		syscall 
		add $0,$0,$0
		
		ori $a0,$t9, 0x8650
		addi $v0, $0, 4
		syscall
		add $0,$0,$0
		
		addi $t6, $0, 1
		
		ori $a1,$t9, 0x5000
		lw $a2, 56($a1)
		add $0,$0,$0
		xor $a2, $a2, $v1 # flips the bit
				
		sw $a2, 56($a1)
		add $0,$0,$0
		j hammingPrinter
		add $0,$0,$0
	
	oneErrorCase:	
		ori $a0,$t9, 0x8550
		addi $v0, $0, 4
		syscall 
		add $0,$0,$0
		
		
		addi $t4, $0, 0
		addi $s5, $0, 404 # flag for hamming print
		
		
		ori $a0,$t9, 0x8650
		addi $v0, $0, 4
		syscall
		add $0,$0,$0
		
		addi $t6, $0, 1
		
		
		addi $t0, $0, 15
		beq $t8, $t0, flip11 # 15 = 1111 
		
		addi $t0, $0, 14
		beq $t8, $t0, flip10 # 14 = 1110
		
		addi $t0, $0, 13
		beq $t8, $t0, flip9 # etc.
		
		addi $t0, $0, 12
		beq $t8, $t0, flip8
		
		addi $t0, $0, 11
		beq $t8, $t0, flip7 
		
		addi $t0, $0, 10
		beq $t8, $t0, flip6 
		
		addi $t0, $0, 9
		beq $t8, $t0, flip5 
		
		addi $t0, $0, 7
		beq $t8, $t0, flip4 
		
		addi $t0, $0, 6
		beq $t8, $t0, flip3 
		
		addi $t0, $0, 5
		beq $t8, $t0, flip2 
		
		addi $t0, $0, 3
		beq $t8, $t0, flip1 
		
		
		
	flip11:
		ori $a1,$t9, 0x5000
		lw $a2, 0($a1)
		add $0,$0,$0
		xor $a2, $a2, $v1
		
		sw $a2, 0($a1)
		add $0,$0,$0
		j hammingPrinter
		add $0,$0,$0
	
	flip10:
		ori $a1,$t9, 0x5000
		lw $a2, 4($a1)
		add $0,$0,$0
		xor $a2, $a2, $v1
		sw $a2, 4($a1)
		add $0,$0,$0
		j hammingPrinter
		add $0,$0,$0
	
	flip9:
		ori $a1,$t9, 0x5000
		lw $a2, 8($a1)
		add $0,$0,$0
		xor $a2, $a2, $v1	
		sw $a2, 8($a1)
		add $0,$0,$0
		j hammingPrinter
		add $0,$0,$0
	
	flip8:
		ori $a1,$t9, 0x5000
		lw $a2, 12($a1)
		add $0,$0,$0
		xor $a2, $a2, $v1	
		sw $a2, 12($a1)
		add $0,$0,$0
		j hammingPrinter
		add $0,$0,$0
	
	flip7:
		ori $a1,$t9, 0x5000
		lw $a2, 16($a1)
		add $0,$0,$0

		
		xor $a2, $a2, $v1	
		
		sw $a2, 16($a1)
		add $0,$0,$0
		j hammingPrinter
		add $0,$0,$0
		
	flip6:
		ori $a1,$t9, 0x5000
		lw $a2, 20($a1)
		add $0,$0,$0
		add $0,$0,$0
		xor $a2, $a2, $v1

		sw $a2, 20($a1)
		add $0,$0,$0
		j hammingPrinter
		add $0,$0,$0
	
	flip5:
		ori $a1,$t9, 0x5000
		lw $a2, 24($a1)
		
		add $0,$0,$0
		xor $a2, $a2, $v1	
		sw $a2, 24($a1)
		add $0,$0,$0
		j hammingPrinter
		add $0,$0,$0
		
	flip4:
		ori $a1,$t9, 0x5000
		lw $a2, 32($a1)
		add $0,$0,$0
		xor $a2, $a2, $v1	
		sw $a2, 32($a1)
		add $0,$0,$0
		j hammingPrinter
		add $0,$0,$0
	
	flip3:
		ori $a1,$t9, 0x5000
		lw $a2, 36($a1)
		add $0,$0,$0
		add $0,$0,$0
		xor $a2, $a2, $v1		
		sw $a2, 36($a1)
		add $0,$0,$0
		j hammingPrinter
		add $0,$0,$0
		
	flip2:
		ori $a1,$t9, 0x5000
		lw $a2, 40($a1)
		add $0,$0,$0
		xor $a2, $a2, $v1		
		sw $a2, 40($a1)
		add $0,$0,$0
		j hammingPrinter
		add $0,$0,$0
	
	flip1:
		ori $a1,$t9, 0x5000
		lw $a2, 48($a1)
		add $0,$0,$0
		xor $a2, $a2, $v1	
		sw $a2, 48($a1)
		add $0,$0,$0
		j hammingPrinter
		add $0,$0,$0
		
	validMsgPrint:
		ori $a1,$t9, 0x5000
		
		addi $v0, $0, 4
		ori $a0,$t9, 0x0200
		syscall
		
		
		lw $s2, 0($a1)
		add $0,$0,$0
		
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		
		lw $s2, 4($a1)
		add $0,$0,$0
		
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 8($a1)
		add $0,$0,$0
		
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 12($a1)
		add $0,$0,$0
		
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 16($a1)
		add $0,$0,$0
		
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 20($a1)
		add $0,$0,$0
		
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 24($a1)
		add $0,$0,$0
		
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 32($a1)
		add $0,$0,$0
		
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 36($a1)
		add $0,$0,$0
		
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 40($a1)
		add $0,$0,$0
		
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		lw $s2, 48($a1)
		add $0,$0,$0
		
		addi $v0, $0, 1
		add $a0, $0, $s2
		syscall
		
		j exit
		add $0,$0,$0
	
	twoErrorCase:
		ori $a0,$t9, 0x8600
		addi $v0, $0, 4
		syscall 
		add $0,$0,$0
		j exit
		add $0,$0,$0
	
	exit:
		ori $a0, $t9, 0x2000
		addi $v0, $0, 4
		syscall
		addi $v0, $0, 10
		syscall # exit
		add $0,$0,$0
		
		
	