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
.eqv LIGHT_GREY		0xa7a7a7

.data
OBS_LIST:	.word 0:3
OBS_Y:		.word 0:3

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
	la $t7, OBS_Y		# load y values for obstacles
	li $t1, 0		# set the iterator to 0
	
	# check if the obstacles have reached the end
	lw $t2, 0($t0)		# load array[0]
	lw $t3, 0($t7)		# load obs_y[0]
	li $t4, 32
	mult $t3, $t4
	mflo $t3
	sub $t2, $t2, $t3	#
	sra $t2, $t2, 2		# divide by 4
	#bne $t2, 1, gen_array_end
	
gen_array_loop:	
	bge $t1, 3, gen_array_end
	sll $t2, $t1, 2		# $t2 = current offset
	add $t3, $t0, $t2, 	# $t3 = address of array[i]
	add $t6, $t7, $t2	# $t7 = address of obs_y[i]
	
	# generate random number from 0 to 29 and the increment by 1 to get range 1 <= num <= 30
	li $v0, 42
	li $a0, 0
	li $a1, 30
	syscall
	
	addi $t4, $a0, 1	# get range 1 <= y <= 30
	sw $t4, 0($t6)		# store y into obs_y[i]
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
	li $t6, GREY		# $t6 = GREY
	li $t7, LIGHT_GREY	# $t7 = LIGHT GREY
	
draw_array_loop:
	bge $t3 3, draw_array_end
	sll $t4, $t3, 2		# $t4 = i * 4 (offset)
	add $t4, $t4, $t2	# $t4 = address of array[i]
	lw $t4, 0($t4)		# $t4 = array[i]
	add $t5, $t0, $t4	# load address of the pixel
	
	#### DRAWING THE OBSTACLE SPRITE
	sw $t6, -128($t5)	# top pixel is grey
	sw $t7, 0($t5)		# middle pixel is light grey
	sw $t6, 128($t5)	# down pixel is grey
	sw $t6, -4($t5)		# left pixel is grey
	sw $t6, 4($t5)		# right pixel is grey
	####
	
	addi $t3, $t3, 1	# update the iterator
	j draw_array_loop
	
draw_array_end: jr $ra

clear_obs:
	li $t0, BASE_ADDRESS
	la $t2, OBS_LIST
	li $t3, 0		# iterator = 0
	li $t6, 0		# $t6 = BLACK
	
clear_obs_loop:
	bge $t3 3, clear_obs_end
	sll $t4, $t3, 2		# $t4 = i * 4 (offset)
	add $t4, $t4, $t2	# $t4 = address of array[i]
	lw $t4, 0($t4)		# $t4 = array[i]
	add $t5, $t0, $t4	# load address of the pixel
	
	#### CLEAR THE PREVIOUS OBSTACLE LOCATION
	sw $t6, -124($t5)	# top pixel is black
	sw $t6, 4($t5)		# middle pixel is black
	sw $t6, 132($t5)	# down pixel is black
	sw $t6, 0($t5)		# left pixel is black
	sw $t6, 8($t5)		# right pixel is black
	####
	
	addi $t3, $t3, 1	# update the iterator
	j clear_obs_loop
	
clear_obs_end: jr $ra

update_array:			# go through the locations and update its position by 1 unit to the left
	la $t2, OBS_LIST
	li $t3, 0		# iterator = 0
	
update_array_loop:
	bge $t3 3, update_array_end
	sll $t4, $t3, 2		# $t4 = i * 4 (offset)
	add $t4, $t4, $t2	# $t4 = address of array[i]
	lw $t5, 0($t4)		# $t5 = array[i]
	addi $t5, $t5, -4	# move the location to the left by 1 unit
	sw $t5, 0($t4)		# store it back into the array
	
	addi $t3, $t3, 1	# update the iterator
	j update_array_loop
	
update_array_end: jr $ra



main:
	# generate 3 random locations for the array
	jal gen_array
	jal draw_array
	
GAME_LOOP:
	#beq $t1, $zero, END	# if lives are 0 then jump to END
	jal update_array	# move the obstacles by 1 unit to the left
	#jal gen_array		# check if obstacles have reached the end of the screen
	jal clear_obs		# erase the old obstacles
	jal draw_array		# draw the obstacles agains			 

SLEEP:	# sleep for 40ms the  refresh rate
	li $v0, 32
	li $a0, 40
	syscall
	
	j GAME_LOOP	# jump back to beginning of game loop

END:
	li $v0, 10	# terminate the program gracfully
	syscall	

















