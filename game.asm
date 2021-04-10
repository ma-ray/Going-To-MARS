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
.eqv SHOOTING_SPEED	2	# speed of the bullets

.data
SMALL_OBS_LIST:		.word 30,14,-6,0,-7,0,-7,0,-7,0,-7,0	# array of (x,y), (x,y), (x,y)
SHIP_LOC:		.word 4, 14				# an array that stores the ship's coordinates. SHIP_LOC[0] = x, SHIP_LOC[1] y
								# Initially starts at (4,14)
SHIP_HEALTH:		.word 12				# health of the ship. 12 hits then game_over
SHIP_HEALTH_STATUS:	.word 3716, 3844, 3848, 3720, 3728, 3856, 3860, 3732, 3740, 3868, 3872, 3744
			# array coordinates (in offset form) to pixels that represent the ship's health
SHOOTING_LIST:		.word -1,10				# array of (x,y), (x,y), (x,y) coordinates of the bullets -1 indicates it has not spawned

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
	
	## GENERATE NEW Y BETWEEN 1 AND 24 INCLUSIVE
	li $v0, 42
	li $a0, 0
	li $a1, 24
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
	sw $t5, 0($t4)			# draw the pixel for the third column

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
	beq $t3, 32, SPAWN_BULLET	# is SPACE was pressed
	beq $t3, 112, RESTART		# if P was pressed
	jr $ra				# otherwise return to caller
	
SPAWN_BULLET:
	# no need to update ship
	la $t3, SHOOTING_LIST			
	# load the contents at index i
	lw $t4, 0($t3)				# $t4 = bulltet's x
	lw $t6, 4($t3) 				# $t6 = bullet's y
	bgt $t4, -1, update_shooting_end	# if bullet active end
	#addi $t1, $t1, SHOOTING_SPEED		# x location of bullet
	sw $t1, 0($t3)				# store new location of bullet
	sw $t2, 4($t3)
	j update_shooting_end
	
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
	add $t7, $t4, $t2	# $t7 = address of obs_array[i]
	lw $t5, 4($t7)		# $t5 = obstacle's y coords
	lw $t4, 0($t7)		# $t4 = obstacles's x coords
	
	# DO NOT CHECK IF OBSTACLES ARE ON THE EDGES
	blt $t4, 1, collision_check_update	# if obs x coords < 1, move on to next obstacle
	bgt $t4, 30, collision_check_update	# if obs x coords > 30, move on to next obstacle
	
	## CHECK IF OBSTASCLE IS INBOUNDS OF SHIP
	sll $t0, $t4, 2		# $t2 = 4x
	sll $t1, $t5, 7		# $t3 = 128y
	add $t0, $t0, $t1	# offset for pixel from frame buffer
	la $t1, BASE_ADDRESS	# $t1 = BASE_ADDRESS
	add $t0, $t1, $t0	# address of the pixel
	
	# Check the left of the obstacle
	lw $t4, -4($t0)				# load the colour of the adjacent pixel
	addi $t5, $t0, -4			# pixel for bullet if we are going to erase
	beq $t4, WHITE, collision_bullet	# if adjacent pixel is white, the obstacle has hit a bullet
	beq $t4, BLUE, collision_hit		# if the adjacent if pixel is blue, thats means we hit a ship
	
	# Check the top of the obstacle
	lw $t4, -128($t0)			
	addi $t5, $t0, -128			
	beq $t4, WHITE, collision_bullet	
	
	# Check the bottom of the obstacle
	lw $t4, 128($t0)			
	addi $t5, $t0, 128			
	beq $t4, WHITE, collision_bullet	
	
	### Check if the bullet has drawn over the obstacles
	lw $t4, 0($t0)				
	addi $t5, $t0, 0			
	beq $t4, WHITE, collision_bullet	
	
	# Check the 
	lw $t4, 4($t0)				
	addi $t5, $t0, 4			
	beq $t4, WHITE, collision_bullet	
	
	lw $t4, 8($t0)				
	addi $t5, $t0, 8			
	beq $t4, WHITE, collision_bullet	
	
	lw $t4, -124($t0)			
	addi $t5, $t0, -124			
	beq $t4, WHITE, collision_bullet	
	
	lw $t4, 132($t0)			
	addi $t5, $t0, 132			
	beq $t4, WHITE, collision_bullet
	######################################################	
	### Check if the bullet was in proximity of the obstacle
	lw $t4, -252($t0)			
	addi $t5, $t0, -252			
	beq $t4, WHITE, collision_bullet	
	
	lw $t4, 260($t0)			
	addi $t5, $t0, 260			
	beq $t4, WHITE, collision_bullet	
	
	lw $t4, -132($t0)			
	addi $t5, $t0, -132			
	beq $t4, WHITE, collision_bullet	
	
	lw $t4, 124($t0)			
	addi $t5, $t0, 124			
	beq $t4, WHITE, collision_bullet	
	
	j collision_check_update
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
	jal update_health	# call update_health to decrease health
	
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
	j collision_check_update	

collision_bullet:
	# erase the obstacle and reset
	sw $zero, 0($t0)			# draw the first column pixel
	sw $zero, 4($t0)			# draw the pixels for the second column
	sw $zero, 8($t0)
	sw $zero, -124($t0)
	sw $zero, 132($t0)
	li $t6, -5				# load a value that is off the screen
	sw $t6, 0($t7)				# reset the obstacle
	sw $zero, 4($t7)
	# erase bullet and reset
	sw $zero, 0($t5)			# undraw the bullet
	la $t7, SHOOTING_LIST			# $t7 = address of shooting list
	li $t6, -1				# load the inactive state
	sw $t6, 0($t7)				# store it in shooting list
	
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
	
update_health:
	############################
	la $t0, SHIP_HEALTH		# $t0 = address of ship health
	lw $t1, 0($t0)			# $t1 = ship health
	addi $t1, $t1, -1		# decrease ship health
	
	la $t2, SHIP_HEALTH_STATUS	# $t2 = address of SHIP_HEALTH_STATUS
	sll $t3, $t1, 2			# offset for accessing array[ship_health}
	add $t2, $t2, $t3		# address for array[ship_health]
	lw $t2, 0($t2)			# $t2 = array[ship_heath]
	la $t3, BASE_ADDRESS		# $t3 = BASE_ADDRESS
	add $t2, $t2, $t3		# address for the pixel to erase
	li $t7, GREY			# load the colour GREY
	sw $t7, 0($t2)			# paint the pixel GREY
	
	sw $t1, 0($t0)			# store the new ship health		
	
	jr $ra
	
update_shooting:
	la $t0, SHOOTING_LIST
	li $t1, 0			# iterator
			
	# load the contents at index i
	lw $t4, 0($t0)			# $t4 = x
	lw $t5, 4($t0) 			# $t4 = y
	blt $t4, 0, update_shooting_end		# if bullet is not active
	# CALCULATE THE PIXEL LOCATION OF BULLET
	sll $t6, $t4, 2		# $t6 = 4x
	sll $t7, $t5, 7		# $t7 = 128y
	add $t6, $t7, $t6	# $t6 = offset of frame buffer verison of location
	add $t6, $t6, $gp	# $t6 = frame buffer verison of location
	
	sw $zero, 0($t6)	# undraw the pixel
	
	addi $t4, $t4, SHOOTING_SPEED	# x = x + 3
	# x is out of bounds move to next iteration
	bgt $t4, 31, bullet_inactive
	li $t7, WHITE
	li $t5, SHOOTING_SPEED
	sll $t5, $t5, 2			# shooting speed * 4
	add $t6, $t5, $t6		# update pixel address
	sw $t7, 0($t6)			# draw the new pixel 3 to the right from original location
	sw $t4, 0($t0)			# store new x in array
	
update_shooting_end:
	jr $ra
	
bullet_inactive:
	li $t4, -1
	sw $t4, 0($t0)			# store new x in array
	j update_shooting_end
	
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
	
	la $t0, SHIP_HEALTH	# $t0 = address of SHIP_HEALTH
	lw $t0, 0($t0)		# $t1 = ship health
GAME_LOOP:
	blt $t0, 1, dead_state		# if lives are 0 then jump to END
	
	jal update_obs		# update the location of obstacles
	jal update_shooting	# move the bullets and check for collisions
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
	
	la $t0, SHIP_HEALTH	# $t0 = address of SHIP_HEALTH
	lw $t0, 0($t0)		# $t1 = ship health
	
	j GAME_LOOP	# jump back to beginning of game loop
	
dead_state:
	jal clear_screen
	jal game_over
	
again_loop:
	beq $t3, 113, END	# if Q was pressed restart the game
	
	# GET THE KEYBOARD INPUT
	li $t3, 0xffff0000		# load addrress of keypress
	lw $t4, ($t3)			# load if key was pressed
	bne $t4, 1, again_loop		# if key not pressed jump to SLEEP
	lw $t3, 4($t3)			# otherwise load the button that was pressed
	beq $t3, 112, RESTART		# if P was pressed restart the game
	j again_loop			# check again for keyboard input
	
END:
	li $v0, 10	# terminate the program gracfully
	syscall	
	
## IMAGE FUNCTIONS
game_over:				# draws the game over screen generated by a python script
        la $t0, BASE_ADDRESS		# $t0 is the base address
        li $t1, 0xff0000		# loads the colours required to draw the image
        li $t2, 0xffffff
        li $t3, 0xff8d00
        li $t4, 0x009eff
        li $t5, 0x4baf31
        sw $t1, 276($t0)
        sw $t1, 280($t0)
        sw $t1, 284($t0)
        sw $t1, 288($t0)
        sw $t1, 300($t0)
        sw $t1, 304($t0)
        sw $t1, 308($t0)
        sw $t1, 320($t0)
        sw $t1, 336($t0)
        sw $t1, 344($t0)
        sw $t1, 348($t0)
        sw $t1, 352($t0)
        sw $t1, 356($t0)
        sw $t1, 360($t0)
        sw $t1, 400($t0)
        sw $t1, 424($t0)
        sw $t1, 440($t0)
        sw $t1, 448($t0)
        sw $t1, 452($t0)
        sw $t1, 460($t0)
        sw $t1, 464($t0)
        sw $t1, 472($t0)
        sw $t1, 528($t0)
        sw $t1, 536($t0)
        sw $t1, 540($t0)
        sw $t1, 544($t0)
        sw $t1, 552($t0)
        sw $t1, 556($t0)
        sw $t1, 560($t0)
        sw $t1, 564($t0)
        sw $t1, 568($t0)
        sw $t1, 576($t0)
        sw $t1, 584($t0)
        sw $t1, 592($t0)
        sw $t1, 600($t0)
        sw $t1, 604($t0)
        sw $t1, 608($t0)
        sw $t1, 612($t0)
        sw $t1, 656($t0)
        sw $t1, 672($t0)
        sw $t1, 680($t0)
        sw $t1, 696($t0)
        sw $t1, 704($t0)
        sw $t1, 720($t0)
        sw $t1, 728($t0)
        sw $t1, 784($t0)
        sw $t1, 800($t0)
        sw $t1, 808($t0)
        sw $t1, 824($t0)
        sw $t1, 832($t0)
        sw $t1, 848($t0)
        sw $t1, 856($t0)
        sw $t1, 916($t0)
        sw $t1, 920($t0)
        sw $t1, 924($t0)
        sw $t1, 936($t0)
        sw $t1, 952($t0)
        sw $t1, 960($t0)
        sw $t1, 976($t0)
        sw $t1, 984($t0)
        sw $t1, 988($t0)
        sw $t1, 992($t0)
        sw $t1, 996($t0)
        sw $t1, 1000($t0)
        sw $t1, 1300($t0)
        sw $t1, 1304($t0)
        sw $t1, 1308($t0)
        sw $t1, 1320($t0)
        sw $t1, 1336($t0)
        sw $t1, 1344($t0)
        sw $t1, 1348($t0)
        sw $t1, 1352($t0)
        sw $t1, 1356($t0)
        sw $t1, 1360($t0)
        sw $t1, 1368($t0)
        sw $t1, 1372($t0)
        sw $t1, 1376($t0)
        sw $t1, 1380($t0)
        sw $t1, 1424($t0)
        sw $t1, 1440($t0)
        sw $t1, 1448($t0)
        sw $t1, 1464($t0)
        sw $t1, 1472($t0)
        sw $t1, 1496($t0)
        sw $t1, 1512($t0)
        sw $t1, 1552($t0)
        sw $t1, 1568($t0)
        sw $t1, 1576($t0)
        sw $t1, 1592($t0)
        sw $t1, 1600($t0)
        sw $t1, 1604($t0)
        sw $t1, 1608($t0)
        sw $t1, 1612($t0)
        sw $t1, 1624($t0)
        sw $t1, 1628($t0)
        sw $t1, 1632($t0)
        sw $t1, 1636($t0)
        sw $t1, 1680($t0)
        sw $t1, 1696($t0)
        sw $t1, 1708($t0)
        sw $t1, 1716($t0)
        sw $t1, 1728($t0)
        sw $t1, 1752($t0)
        sw $t1, 1764($t0)
        sw $t1, 1808($t0)
        sw $t1, 1824($t0)
        sw $t1, 1836($t0)
        sw $t1, 1844($t0)
        sw $t1, 1856($t0)
        sw $t1, 1880($t0)
        sw $t1, 1896($t0)
        sw $t1, 1940($t0)
        sw $t1, 1944($t0)
        sw $t1, 1948($t0)
        sw $t1, 1968($t0)
        sw $t1, 1984($t0)
        sw $t1, 1988($t0)
        sw $t1, 1992($t0)
        sw $t1, 1996($t0)
        sw $t1, 2000($t0)
        sw $t1, 2008($t0)
        sw $t1, 2024($t0)
        sw $t2, 2292($t0)
        sw $t2, 2316($t0)
        sw $t2, 2368($t0)
        sw $t2, 2392($t0)
        sw $t2, 2456($t0)
        sw $t2, 2480($t0)
        sw $t3, 2796($t0)
        sw $t2, 2824($t0)
        sw $t2, 2844($t0)
        sw $t4, 2868($t0)
        sw $t4, 2872($t0)
        sw $t4, 2876($t0)
        sw $t4, 2880($t0)
        sw $t4, 2884($t0)
        sw $t4, 2888($t0)
        sw $t2, 2912($t0)
        sw $t5, 2988($t0)
        sw $t4, 2992($t0)
        sw $t4, 2996($t0)
        sw $t4, 3000($t0)
        sw $t4, 3004($t0)
        sw $t4, 3008($t0)
        sw $t4, 3012($t0)
        sw $t4, 3016($t0)
        sw $t5, 3020($t0)
        sw $t5, 3024($t0)
        sw $t5, 3112($t0)
        sw $t5, 3116($t0)
        sw $t4, 3120($t0)
        sw $t4, 3124($t0)
        sw $t4, 3128($t0)
        sw $t4, 3132($t0)
        sw $t4, 3136($t0)
        sw $t5, 3140($t0)
        sw $t5, 3144($t0)
        sw $t5, 3148($t0)
        sw $t5, 3152($t0)
        sw $t5, 3156($t0)
        sw $t5, 3236($t0)
        sw $t5, 3240($t0)
        sw $t5, 3244($t0)
        sw $t4, 3248($t0)
        sw $t4, 3252($t0)
        sw $t4, 3256($t0)
        sw $t4, 3260($t0)
        sw $t5, 3264($t0)
        sw $t5, 3268($t0)
        sw $t5, 3272($t0)
        sw $t5, 3276($t0)
        sw $t5, 3280($t0)
        sw $t5, 3284($t0)
        sw $t5, 3288($t0)
        sw $t5, 3364($t0)
        sw $t5, 3368($t0)
        sw $t5, 3372($t0)
        sw $t5, 3376($t0)
        sw $t4, 3380($t0)
        sw $t4, 3384($t0)
        sw $t4, 3388($t0)
        sw $t5, 3392($t0)
        sw $t5, 3396($t0)
        sw $t5, 3400($t0)
        sw $t5, 3404($t0)
        sw $t5, 3408($t0)
        sw $t5, 3412($t0)
        sw $t5, 3416($t0)
        sw $t2, 3464($t0)
        sw $t4, 3488($t0)
        sw $t4, 3492($t0)
        sw $t5, 3496($t0)
        sw $t5, 3500($t0)
        sw $t5, 3504($t0)
        sw $t5, 3508($t0)
        sw $t4, 3512($t0)
        sw $t5, 3516($t0)
        sw $t5, 3520($t0)
        sw $t5, 3524($t0)
        sw $t5, 3528($t0)
        sw $t5, 3532($t0)
        sw $t5, 3536($t0)
        sw $t5, 3540($t0)
        sw $t4, 3544($t0)
        sw $t4, 3548($t0)
        sw $t2, 3560($t0)
        sw $t4, 3616($t0)
        sw $t4, 3620($t0)
        sw $t4, 3624($t0)
        sw $t5, 3628($t0)
        sw $t5, 3632($t0)
        sw $t5, 3636($t0)
        sw $t4, 3640($t0)
        sw $t5, 3644($t0)
        sw $t5, 3648($t0)
        sw $t5, 3652($t0)
        sw $t5, 3656($t0)
        sw $t5, 3660($t0)
        sw $t5, 3664($t0)
        sw $t4, 3668($t0)
        sw $t4, 3672($t0)
        sw $t4, 3676($t0)
        sw $t2, 3700($t0)
        sw $t4, 3744($t0)
        sw $t4, 3748($t0)
        sw $t4, 3752($t0)
        sw $t4, 3756($t0)
        sw $t5, 3760($t0)
        sw $t5, 3764($t0)
        sw $t4, 3768($t0)
        sw $t5, 3772($t0)
        sw $t5, 3776($t0)
        sw $t5, 3780($t0)
        sw $t5, 3784($t0)
        sw $t5, 3788($t0)
        sw $t5, 3792($t0)
        sw $t4, 3796($t0)
        sw $t4, 3800($t0)
        sw $t4, 3804($t0)
        sw $t4, 3872($t0)
        sw $t4, 3876($t0)
        sw $t4, 3880($t0)
        sw $t4, 3884($t0)
        sw $t5, 3888($t0)
        sw $t5, 3892($t0)
        sw $t4, 3896($t0)
        sw $t4, 3900($t0)
        sw $t4, 3904($t0)
        sw $t5, 3908($t0)
        sw $t5, 3912($t0)
        sw $t5, 3916($t0)
        sw $t4, 3920($t0)
        sw $t4, 3924($t0)
        sw $t4, 3928($t0)
        sw $t4, 3932($t0)
        sw $t4, 4000($t0)
        sw $t4, 4004($t0)
        sw $t4, 4008($t0)
        sw $t4, 4012($t0)
        sw $t5, 4016($t0)
        sw $t5, 4020($t0)
        sw $t4, 4024($t0)
        sw $t4, 4028($t0)
        sw $t4, 4032($t0)
        sw $t4, 4036($t0)
        sw $t5, 4040($t0)
        sw $t5, 4044($t0)
        sw $t4, 4048($t0)
        sw $t4, 4052($t0)
        sw $t4, 4056($t0)
        sw $t4, 4060($t0)
        jr $ra			# return to caller

















