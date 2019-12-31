	.text
	# Current max S: 0x16a07
	# Using (32,14) unsigned fixed-point, unless otherwise noted
	sll	$1,$30,14	# S = int2fx(SW)
	beq	$1,$0,s_zero	# sqrt(0) = 0
	# For any non-negative integer S, sqrt(S) < (S / 2) + 1
	srl	$2,$1,1		# x = S / 2
	addi	$2,$2,0x4000	# x += int2fx(1)
	srl	$3,$2,1		# step = S / 2

	# ==[ Main Square Root Loop ]=================================
loop:	multu	$2,$2		# p = x * x	# p is (64,28)
	mfhi	$4		# vhi = higher 32b of p
	srl	$4,$4,14	# vhi = the bits above (32,14)
	bne	$4,$0,vgez	# if vhi is not zero, val > 0 because
				# x*x > 2**32 - 1 [max S]
	mflo	$5		# val = lower 32b of p
	srl	$5,$5,14	# val >>= 14
	mfhi	$4		# vhi = higher 32b of p
	sll	$4,$4,18	# vhi = the upper 14b of (32,14) val
	or	$5,$5,$4	# val |= vhi
	sub	$5,$5,$1	# val -= S
	bgez	$5,vgez
	# If we're here, val < 0
	addu	$2,$2,$3	# x += step
	j	step
vgez:	subu	$2,$2,$3	# x -= step
step:	srl	$3,$3,1		# step /= 2
	bne	$3,$0,loop	# loop until step == 0

	# ==[ Display x [$2] ]========================================
	# Separate Fractional Part
	lui	$3,0x1
	ori	$3,$3,0x86a0	# $3 = 10**5
	andi	$1,$2,0x3fff	# f = lower 14b of x
	multu	$1,$3		# p = f * 10**5
	mflo	$1		# f = p
	srl	$1,$1,14	# f >>= 14	# f is now (32,0)
	# Separate Integer Part
	srl	$2,$2,14	# x >>= 14	# x is now (32,0)

	# Load Constants
	lui	$3,0x1999
	ori	$3,$3,0x999a	# $3 = 0.1 in (32,32)
	ori	$4,$0,0x000a	# $4 = 10 in (32,0)

	# --[ Load hundred thousandths place ]--------
	# Generate digit	
	multu	$1,$3		# p = f * 0.1
	mflo	$5		# $5 = frac(p)	# (32,32)
	mfhi	$1		# f = int(p)
	multu	$5,$4		# p = $5 * 10
	mfhi	$6		# $6 = int(p)

	# --[ Load ten thousandths place ]------------
	# Generate digit
	multu	$1,$3		# p = f * 0.1
	mflo	$5		# $5 = frac(p)	# (32,32)
	mfhi	$1		# f = int(p)
	multu	$5,$4		# p = $5 * 10
	mfhi	$5		# $5 = int(p)
	# Prepend digit
	sll	$5,$5,4		# Move into place
	or	$6,$6,$5	# Insert

	# --[ Load thousandths place ]----------------
	# Generate digit
	multu	$1,$3		# p = f * 0.1
	mflo	$5		# $5 = frac(p)	# (32,32)
	mfhi	$1		# f = int(p)
	multu	$5,$4		# p = $5 * 10
	mfhi	$5		# $5 = int(p)
	# Prepend digit
	sll	$5,$5,8		# Move into place
	or	$6,$6,$5	# Insert

	# --[ Load hundredths place ]-----------------
	# Generate digit
	multu	$1,$3		# p = f * 0.1
	mflo	$5		# $5 = frac(p)	# (32,32)
	mfhi	$1		# f = int(p)
	multu	$5,$4		# p = $5 * 10
	mfhi	$5		# $5 = int(p)
	# Prepend digit
	sll	$5,$5,12	# Move into place
	or	$6,$6,$5	# Insert

	# --[ Load tenths place ]---------------------
	# Generate digit
	multu	$1,$3		# p = f * 0.1
	mflo	$5		# $5 = frac(p)	# (32,32)
	mfhi	$1		# f = int(p)
	multu	$5,$4		# p = $5 * 10
	mfhi	$5		# $5 = int(p)
	# Prepend digit
	sll	$5,$5,16	# Move into place
	or	$6,$6,$5	# Insert

	# --[ Load ones place ]-----------------------
	# Generate digit
	multu	$2,$3		# p = x * 0.1
	mflo	$5		# $5 = frac(p)	# (32,32)
	mfhi	$2		# x = int(p)
	multu	$5,$4		# p = $5 * 10
	mfhi	$5		# $5 = int(p)
	# Prepend digit
	sll	$5,$5,20	# Move into place
	or	$6,$6,$5	# Insert

	# --[ Load tens place ]-----------------------
	# Generate digit
	multu	$2,$3		# p = x * 0.1
	mflo	$5		# $5 = frac(p)	# (32,32)
	mfhi	$2		# x = int(p)
	multu	$5,$4		# p = $5 * 10
	mfhi	$5		# $5 = int(p)
	# Prepend digit
	sll	$5,$5,24	# Move into place
	or	$6,$6,$5	# Insert

	# --[ Load hundreds place ]-------------------
	# Generate digit
	multu	$2,$3		# p = x * 0.1
	mflo	$5		# $5 = frac(p)	# (32,32)
	mfhi	$2		# x = int(p)
	multu	$5,$4		# p = $5 * 10
	mfhi	$5		# $5 = int(p)
	# Prepend digit
	sll	$5,$5,28	# Move into place
	or	$30,$6,$5	# Insert

	j	exit
s_zero:	ori	$30,$0,0	# HEX = 0
exit:	nop