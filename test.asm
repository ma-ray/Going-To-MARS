.eqv BASE_ADDRESS	0x10008000

.text
.globl main

main:
	li $t0, 1024
	li $t1, 0	#iterator i = 0
	li $t2, BASE_ADDRESS
	li $t3, 0xff0000
	li $t4, 0x000000
	
START:	bge $t1, $t0, END
	#sw $t4, -4($t2)
	sw $t3, 0($t2)
	addi $t2, $t2, 4
	# invoke sleep system call
	li $v0, 32 
	li $a0, 10 # Wait one second (1000 milliseconds) 
	syscall
	addi $t1, $t1, 1
	j START
	
END:
	li $v0, 10	# terminate the program gracfully
	syscall
	
	
	# First let's render the 1st obstacle at (30,1)
#	sw $t1, 248($t0)
#	sw $t2, 120($t0)
#	sw $t2, 376($t0)
#	sw $t2, 252($t0)
#	sw $t2, 244($t0)
