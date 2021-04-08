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

.eqv BLACK		0x000000
.eqv GREY		0x6f6f6f
.eqv LIGHT_GREY		0xa7a7a7
.eqv ORANGE		0xfd9825
.eqv BLUE		0x006dff
.eqv YELLOW		0xe3e70f
.eqv RED		0xff0000

.eqv SMALL_OBS_SIZE	3

.data
SMALL_OBS_LIST:	.word 3,14,-6,0,-7,0	# array of (x,y), (x,y), (x,y)
SHIP_LOC:	.word 4, 14	# 0: x coord 1: y coord  (4, 14 is the intial starting location)

.text
.globl main

update_obs:
	
	li $t1, 0		# $t1 = iterator = 0
	
update_obs_loop:
	bge $t1, SMALL_OBS_SIZE, update_obs_end
	la $t0, SMALL_OBS_LIST	# load the address to obs_list
	sll $t4, $t1, 3		# offset for ith element in array
	add $t0, $t0, $t4	# $t0 = array[i]
	
	lw $t2, 0($t0)		# $t2 = current x
	lw $t3, 4($t0)		# $t3 = current y
	
	## CALLING draw_obs(x,y,0)
	# SAVING VARIABLES: $t0, $t1
	addi $sp, $sp, -4	# save $t0 to the stack
	sw $t0, 0($sp)
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	addi $sp, $sp, -4	# save $ra on the stack
	sw $ra, 0($sp)
	# PUSH ARGUMENTS TO THE STACK
	addi $sp, $sp, -4
	sw $t2, 0($sp)		# push the x to the stack
	addi $sp, $sp, -4
	sw $t3, 0($sp)		# push y to the stack
	addi $sp, $sp, -4
	li $t7, 0		# set $t7 = 0 and then push to stack
	sw $t7, 0($sp)
	
	jal draw_obs
	
	lw $ra, 0($sp)		# restore $ra
	addi $sp, $sp, 4
	lw $t1, 0($sp)		# restore $t1	
	addi $sp, $sp, 4
	lw $t0, 0($sp)		# restore $t0
	addi $sp, $sp, 4
	lw $t2, 0($t0)		# restore $t2 = current x
	lw $t3, 4($t0)		# restore $t3 = current y
	
	bgt $t2, -3, add_obs	# if the obs is not off the screen skip generating new location
	#### GENERATE NEW COORDINATES
	## GENERATE NEW X BETWEEN 32 AND 48 INCLUSIVE (SHIFTED FOR SYSCALL 0 <= X < 17)
	li $v0, 42
	li $a0, 0
	li $a1, 17
	syscall
	move $t2, $a0		# move random value to $t2
	addi $t2, $t2, 32	# add 16 to it to acheive 32 AND 48 INCLUSIVE
	sw $t2, 0($t0)		# store in array
	
	## GENERATE NEW Y BETWEEN 1 AND 30 INCLUSIVE
	li $v0, 42
	li $a0, 0
	li $a1, 29
	syscall
	move $t3, $a0		# move random value to $t3
	addi $t3,$t3, 1		# add 1 to it to achieve 1 AND 30 INCLUSIVE
	sw $t3, 4($t0)		# store in array
	####
	
add_obs:
	addi $t2, $t2, -1	# set current x = x - 1
	sw $t2, 0($t0)		# store in array[i]
	
	move $a0, $t2		# call draw_obs(x,y,1)
	move $a1, $t3
	li $a2, 1
	
	# call draw_obs(x,y,s)
	# SAVING VARIABLES: $t1
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	addi $sp, $sp, -4	# save $ra on the stack
	sw $ra, 0($sp)
	# PUSH ARGUMENTS TO THE STACK
	addi $sp, $sp, -4
	sw $t2, 0($sp)		# push x to the stack
	addi $sp, $sp, -4
	sw $t3, 0($sp)		# push y to the stack
	addi $sp, $sp, -4
	li $t7, 1		# set $t7 = 1 and then push to stack
	sw $t7, 0($sp)
	
	jal draw_obs
	
	lw $ra, 0($sp)		# restore $ra
	addi $sp, $sp, 4
	lw $t1, 0($sp)		# restore $t1	
	addi $sp, $sp, 4
	
	addi $t1, $t1, 1	# update the iterator
	
	j update_obs_loop
	
update_obs_end:
	jr $ra		
	
# Pass in x,y,s. if s is 1, draw the obstacle. Otherwise, clear the obstacle
# Uses stack calling convention
draw_obs:
	lw $t0, 0($sp)		# $t0, = s
	addi $sp, $sp, 4
	lw $t1, 0($sp)		# $t1, = y
	addi $sp, $sp, 4
	lw $t2, 0($sp)		# $t2, = x
	addi $sp, $sp, 4
	
	bgt $t2, 31, draw_obs_end	# if x is not visible end function
	
	la $t4, BASE_ADDRESS	# $t4 = BASE_ADDRESS
	
	# CALCULATE THE PIXEL LOCATION OF SHIP
	sll $t5, $t2, 2		# $t5 = 4x
	sll $t6, $t1, 7		# $t6 = 128y
	add $t5, $t5, $t6	# $t5 = offset of frame buffer verison of location
	add $t4, $t4, $t5	# $t4 = frame buffer verison of location
	
	# LOAD COLOURS color1: $t5, color2: $t6
	beq $t0, 0, wipe_obs
	li $t5, GREY
	li $t6, LIGHT_GREY
	j paint_obs
	
wipe_obs:
	li $t5, BLACK
	li $t6, BLACK
	
paint_obs:
	ble $t2, -1, paint_col_two
	bge $t2, 32, paint_col_two
	
	sw $t5, 0($t4)
paint_col_two:
	addi $t4, $t4, 4		# shift to next column
	addi $t2, $t2, 1
	ble $t2, -1, paint_col_three
	bge $t2, 32, paint_col_three
	
	sw $t5, -128($t4)
	sw $t6, 0($t4)
	sw $t5, 128($t4)
paint_col_three:
	addi $t4, $t4, 4		# shift to next column
	addi $t2, $t2, 1
	ble $t2, -1, draw_obs_end
	bge $t2, 32, draw_obs_end
	sw $t5, 0($t4)

draw_obs_end:
	jr $ra			# return to caller

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
	beq $a0, 2, hit_ship	# if value passed in is 2, render hit ship
	li $t4, YELLOW
	li $t5, ORANGE
	li $t6, BLUE
	j render_ship
	
hit_ship:
	li $t4, YELLOW
	li $t5, ORANGE
	li $t6, RED
	j render_ship
	
clear_ship:
	li $t4, BLACK
	li $t5, BLACK
	li $t6, BLACK
	
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
	#beq $t3, 112, RESTART		# if P was pressed
	jr $ra				# otherwise return to caller
	
GO_UP:	addi $t2, $t2, -2		# y = y - 1
	j update_ship_array
	
GO_LEFT:
	addi $t1, $t1, -2		# x = x - 1
	j update_ship_array
	
GO_DOWN:	
	addi $t2, $t2, 2		# y = y + 1
	j update_ship_array
	
GO_RIGHT:
	addi $t1, $t1, 2		# x = x + 1
	
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
	
collision_check:
	la $t2, SMALL_OBS_LIST	# $t2 = address of obstacle list
	li $t3, 0		# $t3 = iterator = 0
	
collision_check_loop:
	bge $t3, SMALL_OBS_SIZE, collision_check_end	# while i <= 3
	sll $t4, $t3, 3		# the offset size
	add $t4, $t4, $t2	# $t4 = address of obs_array[i]
	lw $t5, 4($t4)		# $t5 = obstacle's y coords
	lw $t4, 0($t4)		# $t4 = obstacles's x coords
	
	# DO NOT CHECK IF OBSTACLES ARE ON THE EDGES
	blt $t4, 1, collision_check_update	# if obs x coords < 1, move on to next obstacle
	bgt $t4, 30, collision_check_update	# if obs x coords > 30, move on to next obstacle
	
	## CHECK IF OBSTASCLE IS INBOUNDS OF SHIP
	sll $t0, $t4, 2		# $t2 = 4x
	sll $t1, $t5, 7		# $t3 = 128y
	add $t0, $t0, $t1	# offset for pixel from frame buffer
	la $t1, BASE_ADDRESS	# $t1 = BASE_ADDRESS
	add $t0, $t1, $t0	# address of the pixel
	
	# Check the tip of the obstacle
	lw $t4, -4($t0)				# load the colour of the adjacent pixel
	bne $t4, BLUE, collision_check_update	# if the adjacent if pixel if blue, thats means we hit a ship
	
collision_hit:
	# save $t0, $t1, $t2, $t3 to the stack
	addi $sp, $sp, -4	# save $t0
	sw $t0, 0($sp)
	addi $sp, $sp, -4	# save $t1
	sw $t1, 0($sp)
	addi $sp, $sp, -4	# save $t2
	sw $t2, 0($sp)
	addi $sp, $sp, -4	# save $t3
	sw $t3, 0($sp)
	addi $sp, $sp, -4	# save $ra
	sw $ra, 0($sp)
	
	li $a0, 2		# call draw_ship(2)
	jal draw_ship
	
	lw $ra, 0($sp)		# restore $ra
	addi $sp, $sp, 4
	lw $t3, 0($sp)		# restore $t3
	addi $sp, $sp, 4
	lw $t2, 0($sp)		# restore $t2
	addi $sp, $sp, 4
	lw $t1, 0($sp)		# restore $t1
	addi $sp, $sp, 4
	lw $t0, 0($sp)		# restore $t0
	addi $sp, $sp, 4
	
	# invoke sleep for 0.25 seconds
	li $v0, 32
	li $a0, 50
	syscall
	
collision_check_update:
	addi $t3, $t3, 1	# i = i + 1
	j collision_check_loop	# jump back to while conditoin
	
collision_check_end:
	addi $sp, $sp, -4	# save $ra
	sw $ra, 0($sp)

	# call draw_ship(1)
	li $a0, 1		# call draw_ship(1)
	jal draw_ship
	
	lw $ra, 0($sp)		# restore $ra
	addi $sp, $sp, 4

	jr $ra			# return to caller
	
# reset all values
RESTART:
	j main
	
# clear the whole screen to black
clear_screen:
	la $t0, BASE_ADDRESS
	li $t1, BLACK
	li $t2, 0		# the iterator
	
clear_screen_loop:
	bge $t2, 1024, clear_screen_end
	sw $t1, 0($t0)		# set the pixel to black
	addi $t0, $t0, 4	# update pixel location
	addi $t2, $t2, 1	# update iterator: i = i + 1
	j clear_screen_loop		

clear_screen_end:
	jr $ra
	
main:
	jal clear_screen
	
	#li $a0, 1		# draw the ship
	#jal draw_ship
GAME_LOOP:
	#beq $t1, $zero, END	# if lives are 0 then jump to END

	jal update_obs		# update the location of obstacles
	jal collision_check	# iterate thorugh each obstacle, and checks if it hits the ship
	
	li $a0, 0		# call draw_ship(0)
	jal draw_ship		# clear the ship on the screen
	
	jal update_ship		# check user input and update location
	
	li $a0, 1		# call draw_ship(1)
	jal draw_ship		# draw the ship	on the screen

SLEEP:	# sleep for 40ms the  refresh rate
	li $v0, 32
	li $a0, 40
	syscall
	
	j GAME_LOOP	# jump back to beginning of game loop

END:
	li $v0, 10	# terminate the program gracfully
	syscall	

















