#barney_117

		.data
CHOICE:		.word	0	#Set this as 0 for encrypting, 1 for decrypting.
ONE_TIME_PAD:	.ascii	"IDIDKNOWONCEONLYIVESORTOFFORGOTTEN"
		.align	2
        	.text
        	
		.globl	main
main:   	
li 	$s0, 0xffff0008		# output Control
li 	$s1, 0xffff000c		# output Data
li 	$s2, 0xffff0000		# keyboard Control
li 	$s3, 0xffff0004		# keyboard Data
li 	$s4, 65			#ascii value of "A"
li 	$s5, 90			#ascii value of "Z"
li 	$s6, 97			#ascii value of "a"
li 	$s7, 122		#ascii value of "z"



la	$t0, CHOICE		# encryption or decryption 
lw	$t6, 0($t0)
la	$a1, ONE_TIME_PAD		#load one time pad

		
			
READ:
lw 	$t0, 0($s2)		# read character from keyboard
andi	$t0, $t0, 1
beq	$t0, $zero, READ
lw	$a0, 0($s3)
beq	$a0, 46, FINISH		# if the keyboard input is '.' then finish
jal	CHECK_CASE
beq	$v0, $zero, READ	# if character not valid then read next character		
WAIT_FOR_INPUT:		
lw 	$t0, 0($s0)		#wait for input from user
andi	$t0, $t0, 1
beq	$t0, $zero, WAIT_FOR_INPUT
sw	$v1, 0($s1)
j	READ
FINISH:         	
li      $v0, 10			# close program
syscall
###################

CHECK_CASE:	#check that input is uppercase and converts it if not	
UPPERCASE:	 		
blt	$a0, $s4, SKIP_SYMBOL # if the next character is less than ascii 65 "A" go to SKIP_SYMBOL
bgt	$a0, $s5, LOWERCASE 	# if the next character is greater than ascii 90 "Z" go to LOWERCASE 
		
j	ENCRYPT_MESSAGE		# jump to
LOWERCASE:	#convert to uppercase		
blt	$a0, $s6, SKIP_SYMBOL # if the character is less than ascii 97 "a" go to SKIP_SYMBOL
bgt	$a0, $s7, SKIP_SYMBOL # if the character is greater than ascii 122 "z" go to SKIP_SYMBOL
sub	$a0, $a0, 32		
j UPPERCASE

ENCRYPT_MESSAGE:
bne	$t6, $zero, DECRYPTION_MODE
sub	$t2, $a0, $s4
lb      $t3, 0($a1)
add	$t4, $t3, $t2		# add Subsitition base address to position in the alphabet		
blt	$t4, $s5, STORE_AND_SHIFT
bgt	$t4, $s5,OVERFLOW_ENCRYPTION
				
STORE_AND_SHIFT:	
move  	$v1, $t4		
li	$v0, 1
addi	$a1, $a1, +1	#shift the index of the pointer on the pad up one
j	END_ENC_CHARACTER
		
OVERFLOW_ENCRYPTION:
sub	$t4, $t4, 26	#takes 26 from and chars that goes beyond Z, much like a modulo function			
li	$v0, 1
j	STORE_AND_SHIFT
		
SKIP_SYMBOL: #skips symbols
li	$v0, 0
END_ENC_CHARACTER: #ends ecryption and goes back to waiting for input
jr	$ra
#################
		
DECRYPTION_MODE:	
add	$t2, $a0, $s4	#add 65 t0 the ascii value of the input
lb      $t3, 0($a1)	#load the relevent character from the pad
sub	$t4, $t2, $t3		# sub the value of the char in the pad from the input with 65 added to it
bgt	$t4, $s4, STORE_AND_SHIFT #if the char hasn't gone below 65, jump
blt	$t4, $s4,OVERFLOW_DECRYPTION #if the char has gone below 65 jump to overflow
		
OVERFLOW_DECRYPTION:		
add	$t4, $t4, 26		#if the value has gone below 65 add 26 to it, acts much like a modulo function
j	STORE_AND_SHIFT	
