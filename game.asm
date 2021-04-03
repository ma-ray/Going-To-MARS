#####################################################################
#
# CSCB58 Winter 2021 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Name, Student Number, UTorID
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4 (choose the one the applies)
#
# Which approved features have been implemented for milestone 4?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know: 
# - (write here, if any)
#
#####################################################################
# first mini goal array of 3 obstacles with random locations	
.eqv BASE_ADDRESS	0x10008000

.eqv GREY		0x6f6f6f
.eqv LIGHT_GRAY		0xa7a7a7

.data
OBS_LIST:	.word 0:3


.text
.globl main

# draw_obstacle(obs_array) loop through the array and draw the obastacle on the screen
draw_obstacle:
	# pop off the stack
	lw $t0, 0($sp)		# pop y off the stack
	addi $sp, $sp, 4
	lw $t1, 0($sp)		# pop x off the stack


	li $t3, 0xa7a7a7	# light gray colour
	li $t4, 0x6f6f6f	# gray colour
	
gen_array:
	la $t0, OBS_LIST	# load address of obstacle array
	li $t1, 0		# set the iterator to 0
	
gen_array_loop:	
	bge $t1, 3, gen_array_end
	sll $t2, $t1, 2		# $t2 = current offset
	add $t3, $t0, $t2, 	# $t3 = address of array[i]
	
	# generate random number from 0 to 29 and the increment by 1 to get range 1 <= num <= 30
	li $v0, 42
	li $a0, 0
	li $a1, 30
	syscall
	
	addi $t4, $a0, 1	# get range 1 <= y <= 30
	li $t5, 128		# $t5 = 128
	mult $t5, $t4		
	mflo $t4		# $t4 = y * 128 
	addi $t4, $t4, 120	# $t4 = the address of (30, y)
	
	sw $t4, 0($t3)		# store the coords to array[i]
	addi $t1, $t1, 1	# update the iterator i = i + 1
	j gen_array_loop	
	
gen_array_end:
	jr $ra
	
draw_array:
	li $t0, BASE_ADDRESS
	la $t2, OBS_LIST
	li $t3, 0		# iterator = 0
	li $t7, GREY		# $t5 = GREY
	
draw_array_loop:
	bge $t3 3, draw_array_end
	sll $t4, $t3, 2		# $t4 = i * 4 (offset)
	add $t4, $t4, $t2	# $t4 = address of array[i]
	lw $t4, 0($t4)		# $t4 = array[i]
	add $t5, $t0, $t4	# load address of the pixel
	sw $t7, 0($t5)		# change pixel colour
	addi $t3, $t3, 1	# update the iterator
	j draw_array_loop
	
draw_array_end: jr $ra

main:
	# generate 3 random locations for the array
	jal gen_array
	jal draw_array
	
END:
	li $v0, 10	# terminate the program gracfully
	syscall	
	
GAME_LOOP:
	beq $t1, $zero, END	# if lives are 0 then jump to END
				 

SLEEP:	# sleep for 40ms the  refresh rate
	li $v0, 32
	li $a0, 40
	syscall
	
	j GAME_LOOP	# jump back to beginning of game loop



















