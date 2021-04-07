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
.eqv BASE_ADDRESS	0x10008000

.eqv GREY		0x6f6f6f
.eqv LIGHT_GREY		0xa7a7a7
.eqv ORANGE		0xfd9825
.eqv BLUE		0x006dff
.eqv YELLOW		0xe3e70f

.data
OBS_LIST:	.word 0:3
POS:		.word 0
SHIP_LOC:	.word 4, 15	# 0: x coord 1: y coord  (4, 15 is the intial starting location)

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
	
	la $t7, POS		# load pos of obstacles
	lw $t6, 0($t7)
	beq $t6, 0, gen_array_loop	# for initial entry to game loop, generate locations for obs
	
	bne $t6, 29, gen_array_end	# if pos has not reached the left side return to main. otherwise, generate new locations
	sw $zero, 0($t7)	# reset the counter at 0
	
	addi $sp, $sp, -4	# push $ra to stack
	sw $ra, 0($sp)
	
	jal clear_obs		# clear the obs by calling clear_obs
	
	lw $ra, 0($sp)		# restore the return address
	addi $sp, $sp, 4
	
	la $t0, OBS_LIST	# load address of obstacle array
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
	sw $t6, -128($t5)	# top pixel is black
	sw $t6, 0($t5)		# middle pixel is black
	sw $t6, 128($t5)	# down pixel is black
	sw $t6, -4($t5)		# left pixel is black
	sw $t6, 4($t5)		# right pixel is black
	####
	
	addi $t3, $t3, 1	# update the iterator
	j clear_obs_loop
	
clear_obs_end: jr $ra

update_array:			# go through the locations and update its position by 1 unit to the left
	la $t2, OBS_LIST
	li $t3, 0		# iterator = 0
	
	la $t7, POS
	lw $t6, 0($t7)
	addi $t6, $t6, 1	
	sw $t6, 0($t7)		# store back into POS
	
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

## Pass in a number (1 or 0) to $a0. if 1, draw the ship. Otherwise, clear the ship
## Use the register based calling convention
draw_ship:
	la $t0, BASE_ADDRESS	# $t0 = address of framebuffer
	la $t1, SHIP_LOC	# $t1 = address of the ship
	lw $t2, 0($t1)		# $t2 = x coord of ship
	lw $t3, 4($t1)		# $t3 = y coord of ship
	
	# CALCULATE THE PIXEL LOCATION OF SHIP
	sll $t2, $t2, 2		# $t2 = 4x
	sll $t3, $t3, 7		# $t3 = 128y
	add $t1, $t2, $t3	# $t1 = offset of frame buffer verison of location
	add $t1, $t1, $t0	# $t1 = frame buffer verison of location
	
	# LOAD COLOURS NEEDED FOR SHIP
	beq $a0, 0, clear_ship	# if value passed in is 0, clear the ship
	li $t4, YELLOW
	li $t5, ORANGE
	li $t6, BLUE
	j render_ship
	
clear_ship:
	li $t4, 0x000000
	li $t5, 0x000000
	li $t6, 0x000000
	
render_ship:	
	# DRAWING THE SHIP
	sw $t6, 0($t1)		# draw main pixel to screen
	sw $t4, -4($t1)
	sw $t6, -8($t1)
	sw $t6, -12($t1)
	sw $t5, -16($t1)
	sw $t6, -132($t1)
	sw $t6, 124($t1)
	sw $t6, -136($t1)
	sw $t6, -140($t1)
	sw $t5, -144($t1)
	sw $t6, 120($t1)
	sw $t6, 116($t1)
	sw $t5, 112($t1)
	sw $t6, -268($t1)
	sw $t6, 244($t1)
	
	jr $ra			# return to the caller
	
update_ship:
	# GET THE KEYBOARD INPUT
	li $t3, 0xffff0000		# load addrress of keypress
	lw $t4, ($t3)			# load if key was pressed
	bne $t4, 1, update_ship_end	# if key not pressed jump to SLEEP
	lw $t3, 4($t3)			# otherwise load the button that was pressed
	
	# LOAD SHIP COORDS
	la $t0, SHIP_LOC		# $t0 = address of ship
	lw $t1, 0($t0)			# $t1 = x coord of ship
	lw $t2, 4($t0)			# $t2 = y coord of ship
	
	# DETERMINE WHICH DIRECTION IT IS GOING
	beq $t3, 119, GO_UP		# if W was pressed
	beq $t3, 97, GO_LEFT		# if A was pressed
	beq $t3, 115, GO_DOWN		# if D was pressed
	beq $t3, 100, GO_RIGHT		# if S was pressed
	jr $ra				# otherwise return to caller
	
GO_UP:	addi $t2, $t2, -2		# y = y - 1
	j update_ship_array
	
GO_LEFT:
	addi $t1, $t1, -2		# x = x - 1
	j update_ship_array
	
GO_DOWN:	
	addi $t2, $t2, 2	# y = y + 1
	j update_ship_array
	
GO_RIGHT:
	addi $t1, $t1, 2	# x = x + 1
	
update_ship_array:
	# CHECK IF THE CHANGES ARE OUT OF BOUNDS
	#  if x < 4 or x > 31 return to caller
	blt $t1, 4, update_ship_end
	bgt $t1, 31, update_ship_end
	
	# if y < 2 or y > 29 return to caller
	blt $t2, 2, update_ship_end
	bgt $t2, 29, update_ship_end
	
	# load coordinates back to array
	sw $t1, 0($t0)
	sw $t2, 4($t0)

update_ship_end:
	jr $ra
	
main:
	jal draw_ship
GAME_LOOP:
	#beq $t1, $zero, END	# if lives are 0 then jump to END
	
	
	jal gen_array		# check if obstacles have reached the end of the screen
	jal clear_obs		# erase the old obstacles
	jal update_array	# move the obstacles by 1 unit to the left
	jal draw_array		# draw the obstacles agains
	
	li $a0, 0		# call draw_ship(0)
	jal draw_ship		

	jal update_ship		# check user input
	
	li $a0, 1		# call draw_ship(1)
	jal draw_ship		# draw the ship	 

SLEEP:	# sleep for 40ms the  refresh rate
	li $v0, 32
	li $a0, 40
	syscall
	
	j GAME_LOOP	# jump back to beginning of game loop

END:
	li $v0, 10	# terminate the program gracfully
	syscall	

















