 




		.data
ENCRYPTED_MESSAGE:	.space	40
		.align 2
DECRYPTED_MESSAGE:	.space	40
		.align 2
MESSAGE:		.ascii	"Win%nie t#h\e p%ooh."
		.align 2
ONE_TIME_PAD:		.ascii	"IDIDKNOWONCEONLYIVESORTOFFORGOTTEN"
		.align 2

        	.text
		.globl	MAIN
MAIN:   	
la	$a0, MESSAGE		#load message to ecrypt
la 	$a1, ONE_TIME_PAD		#load one time pad	
la	$a2, ENCRYPTED_MESSAGE	#load address to save secret message to	
la	$a3, DECRYPTED_MESSAGE	#message that has been decoded

li $s0, 65	#ascii value of "A"
li $s1, 90	#ascii value of "Z"
li $s2, 97	#ascii value of "a"
li $s3, 122	#ascii value of "z"
li $s4, 46	#ascii value of "."

jal	ENCRYPTION			# call encryption subroutine

#print encrypted message
la $a0, ENCRYPTED_MESSAGE
li $v0, 4
syscall

la $a1, ONE_TIME_PAD		#resets's pointer to start on the pad
la $a2, ENCRYPTED_MESSAGE	#reset's pointer to start on the Encrypted Message
jal	DECRYPTION		#call decryption subroutine
		
#print decrypted message
la $a0, DECRYPTED_MESSAGE
li $v0, 4
syscall
				
li $v0, 10			# end program
syscall

#subroutine to ecrypt meassage by converting to uppercase and adding the ascii values
#if it goes past Z, it calls a routine to subtract 26 much like a modulo function
ENCRYPTION:	                
LOOP_START:	
lb	$t0, 0($a0)			# load the next character
li	$t1, 46	 			# if the next character is a "." goto END_ENC_LOOP
beq	$t0, $t1, END_ENC_LOOP

UPPERCASE:	
blt	$t0, $s0,SKIP_SPACE_ENC		# if the next character is less than ascii 65 "A" go to SKIP_SPACE_ENC
bgt	$t0, $s1,LOWERCASE		# if the next character is greater than ascii 90 "Z" go to LOWERCASE
sub	$t0, $t0, $s0	
j	ENCRYPT_MESSAGE		#jump to 

LOWERCASE:
blt	$t0, $s2,SKIP_SPACE_ENC			# if the character is less than ascii 97 "a" go to SKIP_SPACE_ENC 
bgt	$t0, $s3,SKIP_SPACE_ENC 		# if the character is greater than ascii 122 "z" go to SKIP_SPACE_ENC
sub	$t0, $t0, $s2		
		
ENCRYPT_MESSAGE:
lb      $t1, 0($a1)	
add    $t7, $t0, $t1
blt	$t7, $s1,STORE_AND_SHIFT_FOR_ENCRYPTION
bgt	$t7, $s1,OVERFLOW_ENCRYPTION

STORE_AND_SHIFT_FOR_ENCRYPTION:	#stores the new character and shifts the pionters up one		
swr  	$t7, 0($a2)		# store the encrypted character
addi	$a2, $a2, +1		# increment the write pointer for ENCRYPTED MESSAGE
addi	$a1, $a1, +1
addi	$a0, $a0, +1	
j LOOP_START

OVERFLOW_ENCRYPTION:		 #takes 26 from and chars that goes beyond Z
	sub	$t7, $t7, 26
	j STORE_AND_SHIFT_FOR_ENCRYPTION 
						
SKIP_SPACE_ENC:			#skips anything in the message thats not a Char. E.G. spaces and symbols
addi	$a0, $a0, +1		# increment the read pointer
j	LOOP_START		# repeat

END_ENC_LOOP:	
li	$t1, 46
li	$t2, 10
sb	$t1, 0($a2) 		# write full stop
sb 	$t2, 1($a2) 		#new line
jr	$ra
		
############		
#subroutine to decrypt meassage by taking encrypted message and subbing the ascii values, 
#no need to convert, they are already uppercase
#if it goes below "A" , it calls a routine to add 26 much like a modulo function		
DECRYPTION:
	                
LOOP_START_DECRYPTION:	
lb	$t0, 0($a2)		# load the next character from the encrypted message
li	$t1, 46	 		# if the next character is a "." goto END_DEC_LOOP
beq	$t0, $t1, END_DEC_LOOP
add	$t0, $t0, $s0	
j	DECRYPT_MESSAGE		#jump to 
		
DECRYPT_MESSAGE: 
lb      $t1, 0($a1)				#loads first character from the one time Pad
sub    $t8, $t0, $t1				#subtracts one time pad ascii value from value of encrypted char
bgt	$t8, $s0,STORE_AND_SHIFT_FOR_DECRYPTION #if greater than 65 jump to store and shift
blt	$t8, $s0,OVERFLOW_DECRYPTION		#if less than 65 jump to modulo subroutine

STORE_AND_SHIFT_FOR_DECRYPTION:		#stores the new character and shifts the pionters up one		
swr  	$t8, 0($a3)			# store the encrypted character
addi	$a3, $a3, +1			# increment the write pointer for secret message
addi	$a1, $a1, +1
addi	$a2, $a2, +1	
j LOOP_START_DECRYPTION

OVERFLOW_DECRYPTION: 			#takes 26 from and chars that goes beyond Z
	add	$t8, $t8, 26
	j STORE_AND_SHIFT_FOR_DECRYPTION 
		
END_DEC_LOOP:	
li	$t1, 46
li	$t2, 10
sb	$t1, 0($a3) 		# write full stop
sb 	$t2, 1($a3) 		#new line
jr	$ra
