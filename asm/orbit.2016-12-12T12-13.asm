	.text
	# REGISTER MAP
	# 1	DO NOT USE
	# 2	direction_x
	# 3	radius
	# 4	center_x
	# 5	center_y
	# 6	addr; d, new_pos_x, key2
	# 7	r2, S, new_pos_y, key3, rmax
	# 8	x2, x, countdown, screen_x
	# 9	step, screen_y
	# 10	vhi
	# 11	val
	# 12	pos_y
	# 13	foreground
	# 14	pos_x

	# Initialize values for top level
	# GRIDSIZE = 9
	ori	$14,$0,0	# pos_x = 0 << GRIDSIZE
	ori	$12,$0,0x8f2	# pos_y = sqrt(20) << GRIDSIZE
	ori	$2,$0,1		# direction_x = 1
	ori	$3,$0,0x2800	# radius = 20 << GRIDSIZE (min 0, max 26.5 << GRIDSIZE)
	ori	$4,$0,0x5000	# center_x = 40 << GRIDSIZE
	ori	$5,$0,0x3c00	# center_y = 30 << GRIDSIZE
	ori	$13,$0,0xffff	# foreground = 0x00ffff

	ori	$6,$0,0x4000	# addr = 0x3fff
c_loop:	addi	$6,$6,-1	# addr = addr - 1
	sw	$0,0xc000($6)	# clear address 0xc000 + addr
	bne	$6,$0,c_loop	# repeat while addr != 0

	# ==[ Top level ]=============================================================
t_loop: sub	$6,$3,$14	# d = radius - pos_x
	bgez	$6,noleft	# if (radius >= pos_x) do not set to go left
	ori	$2,$0,0		# go left
noleft:	add	$6,$14,$3	# d = pos_x - (-radius)
	bgez	$6,norite	# if (pos_x >= -radius) do not set to go right
	ori	$2,$0,1		# go right
norite:	bne	$2,$0,inc	# if (direction_x) increment
	addi	$6,$14,-16	# new_pos_x = pos_x - 16
	j	sufinc
inc:	addi	$6,$14,16	# new_pos_x = pos_x + 16
sufinc:	mult	$3,$3		# p = radius * radius
	mflo	$7		# r2 = lower 32b of p (all of p if radius valid)
	mult	$6,$6		# p = new_pos_x * new_pos_x
	mflo	$8		# x2 = lower 32b of p (all of p if new_pos_x valid)
	subu	$7,$7,$8	# S = r2 - x2	# Note: (32,2*GRIDSIZE)

	# --[ Square root (modifies $7-$11) (in: $7, out: $8) ]-----------------------
	# Using (32,14) unsigned fixed-point, unless otherwise noted
	srl	$7,$7,4		# Convert S to (32,14) from (32,2*GRIDSIZE)
	beq	$7,$0,s_zero	# sqrt(0) = 0
	# For any non-negative integer S, sqrt(S) < (S / 2) + 1
	srl	$8,$7,1		# x = S / 2
	addi	$8,$8,0x4000	# x += int2fx(1)
	srl	$9,$8,1		# step = S / 2

	# Main square root loop
s_loop:	multu	$8,$8		# p = x * x	# p is (64,28)
	mfhi	$10		# vhi = higher 32b of p
	srl	$10,$10,14	# vhi = the bits above (32,14)
	bne	$10,$0,vgez	# if vhi is not zero, val > 0 because
				# x*x > 2**32 - 1 [max S]
	mflo	$11		# val = lower 32b of p
	srl	$11,$11,14	# val >>= 14
	mfhi	$10		# vhi = higher 32b of p
	sll	$10,$10,18	# vhi = the upper 14b of (32,14) val
	or	$11,$11,$10	# val |= vhi
	sub	$11,$11,$7	# val -= S
	bgez	$11,vgez
	# If we're here, val < 0
	addu	$8,$8,$9	# x += step
	j	step
vgez:	subu	$8,$8,$9	# x -= step
step:	srl	$9,$9,1		# step /= 2
	bne	$9,$0,s_loop	# loop until step == 0

	j	endsr
s_zero:	ori	$8,$0,0		# x = 0
endsr:	# End of square root
	srl	$7,$8,5		# Convert sqrt output x (32,14) to new_pos_y (32,GRID_SIZE)
	beq	$2,$0,noneg	# if (direction_x == 0) do not negate new_pos_y
	sub	$7,$0,$7	# negate new_pos_y
noneg:

	# --[ Wait a bit (modifies $8) ]----------------------------------------------
	ori	$8,$0,0x0400	# countdown = 0x0400
w_loop:	addi	$8,$8,-1	# countdown = countdown - 1
	bne	$8,$0,w_loop	# repeat while countdown != 0

	# --[ Store pixels (modifies $8 and $9) ]-------------------------------------
	add	$8,$14,$4	# screen_x = pos_x + center_x
	sra	$8,$8,9		# screen_x >>= GRID_SIZE
	andi	$8,$8,0x7f	# screen_x = lowest 7b of screen_x
	add	$9,$12,$5	# screen_y = pos_y + center_y
	sra	$9,$9,9		# screen_y >>= GRID_SIZE
	andi	$9,$9,0x3f	# screen_y = lowest 6b of screen_y
	sll	$9,$9,7		# screen_y <<= 7
	#ori	$9,$0,0xf00	# Uncomment to keep center on y
	or	$8,$8,$9	# screen_x |= screen_y
	sw	$0,0xc000($8)	# Output black to the screen

	add	$8,$6,$4	# screen_x = new_pos_x + center_x
	sra	$8,$8,9		# screen_x >>= GRID_SIZE
	andi	$8,$8,0x7f	# screen_x = lowest 7b of screen_x
	add	$9,$7,$5	# screen_y = new_pos_y + center_y
	sra	$9,$9,9		# screen_y >>= GRID_SIZE
	andi	$9,$9,0x3f	# screen_y = lowest 6b of screen_y
	sll	$9,$9,7		# screen_y <<= 7
	#ori	$9,$0,0xf00	# Uncomment to keep center on y
	or	$8,$8,$9	# screen_x |= screen_y
	sw	$13,0xc000($8)	# Output foreground to the screen
	#sw	$13,0xcf28	# Output static pixel

	# --[ Last bit of loop ]------------------------------------------------------
	ori	$14,$6,0	# pos_x = new_pos_x
	ori	$12,$7,0	# pos_y = new_pos_y

	ori	$6,$30,0	# key2 = SW
	srl	$6,$6,22	# key2 >>= 22
	srl	$7,$6,1		# key3 = key2 >> 1
	andi	$6,$6,0x1	# key2 = lowest bit of key2
	andi	$7,$7,0x1	# key3 = lowest bit of key3
	beq	$7,$0,k3z
	addi	$3,$3,1		# if (key3 != 0) increment radius
	ori	$7,$0,0x3500	# rmax = 0x3500
	sub	$7,$7,$3
	bgez	$7,k3z
	ori	$3,$0,0x3500	# if (radius > rmax) radius = rmax
k3z:	beq	$6,$0,k2z
	addi	$3,$3,-1	# if (key2 != 0) decrement radius
	bgez	$3,k2z
	ori	$3,$0,0		# if (radius < 0) radius = 0
k2z:	#ori	$30,$3,0	# Output radius to hex displays
	j	t_loop		# Repeat forever
