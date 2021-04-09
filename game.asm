#####################################################################
#
# CSCB58 Winter 2021 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Raymond Ma, 1006210048, maraymon
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

## COLOURS for the ship and the obstacles
.eqv BLACK		0x000000
.eqv GREY		0x6f6f6f
.eqv LIGHT_GREY		0xa7a7a7
.eqv ORANGE		0xfd9825
.eqv BLUE		0x006dff
.eqv YELLOW		0xe3e70f
.eqv RED		0xff0000
.eqv WHITE		0xffffff

.eqv SMALL_OBS_SIZE	6	# size of the small_obs_list

.data
SMALL_OBS_LIST:		.word -5,0,-6,0,-7,0,-7,0,-7,0,-7,0	# array of (x,y), (x,y), (x,y)
SHIP_LOC:		.word 4, 14				# an array that stores the ship's coordinates. SHIP_LOC[0] = x, SHIP_LOC[1] y
								# Initially starts at (4,14)
SHIP_HEALTH:		.word 12				# health of the ship. 12 hits then game_over
SHIP_HEALTH_STATUS:	.word 3716, 3844, 3848, 3720, 3728, 3856, 3860, 3732, 3740, 3868, 3872, 3744
			# array coordinates (in offset form) to pixels that represent the ship's health

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
	addi $sp, $sp, -4	# save $t1 to the stack
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
	
	## GENERATE NEW Y BETWEEN 1 AND 25 INCLUSIVE
	li $v0, 42
	li $a0, 0
	li $a1, 25
	syscall
	move $t3, $a0		# move random value to $t3
	addi $t3,$t3, 1		# add 1 to it to achieve 1 AND 25 INCLUSIVE
	sw $t3, 4($t0)		# store in array
	####
	
add_obs:
	addi $t2, $t2, -1	# set current x = x - 1
	sw $t2, 0($t0)		# store in array[i]
	
	move $a0, $t2		# call draw_obs(x,y,1)
	move $a1, $t3
	li $a2, 1
	
	# call draw_obs(x,y,s)
	addi $sp, $sp, -4	# save $t1 to the stack
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
	
	j update_obs_loop	# jump back to loop condition
	
update_obs_end:
	jr $ra			# return to caller
	
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
	
	# LOAD COLOURS to draw obstalce color1: $t5, color2: $t6
	beq $t0, 0, wipe_obs
	li $t5, GREY
	li $t6, LIGHT_GREY
	j paint_obs
	
	# LOAD black to clear the obstacle from the screen
wipe_obs:
	li $t5, BLACK
	li $t6, BLACK
	
	# check the if the first pixel column of the obstacle is in bounds. Draw if it is.
paint_obs:
	ble $t2, -1, paint_col_two	# if the column is left of the screen (x < -1) move on to second column
	bge $t2, 32, paint_col_two	# if the column is right of the screen (x > 32) move on to second column
	
	sw $t5, 0($t4)			# draw the first column pixel
	# check the if the second pixel column of the obstacle is in bounds. Draw if it is.
paint_col_two:
	addi $t4, $t4, 4		# shift to next column
	addi $t2, $t2, 1		# shift the x coordinate to the second column (x = x + 1)
	ble $t2, -1, paint_col_three	# if the column is left of the screen (x < -1) move on to third column
	bge $t2, 32, paint_col_three	# if the column is right of the screen (x > 32) move on to thrid column
	
	sw $t5, -128($t4)		# draw the pixels for the second column
	sw $t6, 0($t4)
	sw $t5, 128($t4)
	# check the if the third pixel column of the obstacle is in bounds. Draw if it is.
paint_col_three:
	addi $t4, $t4, 4		# shift to next column
	addi $t2, $t2, 1		# shift the x coordinate to the second column (x = x + 1)
	ble $t2, -1, draw_obs_end	# if the column is left of the screen (x < -1) end the function
	bge $t2, 32, draw_obs_end	# if the column is right of the screen (x > 32) end the function
	sw $t5, 0($t4)

draw_obs_end:
	jr $ra			# return to caller

## Pass in a number (0,1,2) to $a0. if 1, draw the ship. Otherwise, clear the ship
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
	# case where you need to render the ship
	li $t4, YELLOW
	li $t5, ORANGE
	li $t6, BLUE
	j render_ship
	
	# make the ship red to indicate a hit
hit_ship:
	li $t4, YELLOW
	li $t5, ORANGE
	li $t6, RED
	j render_ship
	
	# remove the ship off the screen
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
	beq $t3, 112, RESTART		# if P was pressed
	jr $ra				# otherwise return to caller
	
GO_UP:	addi $t2, $t2, -2		# y = y - 2
	j update_ship_array
	
GO_LEFT:
	addi $t1, $t1, -2		# x = x - 2
	j update_ship_array
	
GO_DOWN:	
	addi $t2, $t2, 2		# y = y + 2
	j update_ship_array
	
GO_RIGHT:
	addi $t1, $t1, 2		# x = x + 2
	
update_ship_array:
	# CHECK IF THE CHANGES ARE OUT OF BOUNDS
	#  if x < 4 or x > 31 return to caller
	blt $t1, 4, update_ship_end
	bgt $t1, 31, update_ship_end
	
	# if y < 2 or y > 24 return to caller (white line boundary)
	blt $t2, 2, update_ship_end
	bgt $t2, 24, update_ship_end
	
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
	
draw_gui:
	# draw the white line at the bottom
	li $t1, WHITE			# $t1 = colour white
	la $t0, BASE_ADDRESS		# load the base address
	li $t2, 3456			# $t2 = iterator
	
draw_gui_loop:
	bgt $t2, 3580, setup_health	# if pixel is greater tha 3580 exit loop
	add $t7, $t0, $t2		# calculate address for pixel	
	sw $t1, 0($t7)			# store white on that pixel
	addi $t2, $t2, 4		# move to the right pixel
	j draw_gui_loop			# jump to loop condition
	
setup_health:
	li $t3, RED
	la $t4, BASE_ADDRESS		# $t4 = BASE_ADDRESS			
	la $t0, SHIP_HEALTH_STATUS	# $t0 = address of SHIP_HEALTH_STATUS
	li $t1, 0			# $t1 = iterator = 0
	
setup_health_loop:
	bge $t1, 12, draw_gui_end	# i > 12 
	sll $t5, $t1, 2			# $t5 = offset for i
	add $t5, $t5, $t0		# $t5 = address for array[i]
	lw $t5, 0($t5)			# $t5 = offset for pixel location
	add $t5, $t5, $t4		# $t5 = pixel location
	sw $t3, 0($t5)			# draw the pixel red
	addi $t1, $t1, 1		# update the iterator i = i + 1
	j setup_health_loop
	
draw_gui_end:
	jr $ra				# return to caller
	
# reset all values
RESTART:
	## reset ship health
	la $t0, SHIP_HEALTH	# $t0 = health of the ship
	li $t1, 12		# load intital health of the ship
	sw $t1, 0($t0)		# store to variable

	## reset ship location
	la $t0, SHIP_LOC	# $t0, location of the ship_array
	li $t1, 4		# ship's spawn point x = 4
	li $t2, 14		# ship's spawn point y = 14
	sw $t1, 0($t0)		# store the ship's new location
	sw $t2, 4($t0)
	
	## reset obstacle location
	la $t0, SMALL_OBS_LIST	# $t0 = location of small obstacle array
	li $t1, 0		# $t1 = iterator = 0
	
	
restart_obs_loop:
	bge $t1, SMALL_OBS_SIZE, restart_end
	sll $t2, $t1, 3		# $t2 = offset for the iterator
	add $t3, $t2, $t0	# $t3 = address of small obs array[i]
	li $t4, -5		# $t3 = location of new obstacle (off the screen)
	sw $t4, 0($t3)		# array[i] = -5
	addi $t1, $t1, 1	# update the iterator i++
	j restart_obs_loop	# jump back to while condition
	
restart_end:
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
	jal draw_gui
GAME_LOOP:
	#beq $t1, $zero, END	# if lives are 0 then jump to END

	jal update_obs		# update the location of obstacles
	jal collision_check	# iterate thorugh each obstacle, and checks if it hits the ship
	
	li $a0, 0		# call draw_ship(0)
	jal draw_ship		# clear the ship on the screen
	
	jal update_ship		# check user input and update location
	
	li $a0, 1		# call draw_ship(1)
	jal draw_ship		# draw the ship	on the screen

SLEEP:	# sleep for 40ms the refresh rate
	li $v0, 32
	li $a0, 40
	syscall
	
	j GAME_LOOP	# jump back to beginning of game loop

END:
	li $v0, 10	# terminate the program gracfully
	syscall	

















