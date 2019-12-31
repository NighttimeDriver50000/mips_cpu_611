.text
# ==[ Load Constants ]=================
lui $30,0x0001
# Load 0x1999999a (0.1) into $1
#lui $1,0x999a
#srl $1,$1,16
#lui $2,0x1999
#or $1,$2,$1
lui $1,0x1999
ori $1,$1,0x999a
# Load 0x0000000a (10) into $2
lui $2,0x000a
srl $2,$2,16
# Load 0x80000000 (0.5) into $3
lui $3,0x8000

# ==[ Average ]========================

lw $7,0($0)
lw $8,1($0)
add $7,$7,$8
lw $8,2($0)
add $7,$7,$8
lw $8,3($0)
add $7,$7,$8
lw $8,4($0)
add $7,$7,$8
lw $8,5($0)
add $7,$7,$8
lw $8,6($0)
add $7,$7,$8
lw $8,7($0)
add $7,$7,$8
sra $7,$7,3
sw $7,8($0)

# ==[ Load ones place ]================
# Generate fuzzy digit
#multu $30,$1	# p = SW * 0.1
multu $7,$1	# p = $7 * 0.1
mflo $4		# $4 = frac(p)
mfhi $5		# $5 = int(p)
multu $4,$2	# p = $4 * 10
mfhi $6		# $6 = int(p)

# ==[ Load tens place ]================
# Generate fuzzy digit
multu $5,$1	# p = SW * 0.1
mflo $4		# $4 = frac(p)
mfhi $5		# $5 = int(p)
multu $4,$2	# p = $4 * 10
mfhi $4		# $4 = int(p)
# Prepend digit
sll $4,$4,4	# Move into place
or $6,$6,$4	# Insert

# ==[ Load hundreds place ]================
# Generate fuzzy digit
multu $5,$1	# p = SW * 0.1
mflo $4		# $4 = frac(p)
mfhi $5		# $5 = int(p)
multu $4,$2	# p = $4 * 10
mfhi $4		# $4 = int(p)
# Prepend digit
sll $4,$4,8	# Move into place
or $6,$6,$4	# Insert

# ==[ Load thousands place ]================
# Generate fuzzy digit
multu $5,$1	# p = SW * 0.1
mflo $4		# $4 = frac(p)
mfhi $5		# $5 = int(p)
multu $4,$2	# p = $4 * 10
mfhi $4		# $4 = int(p)
# Prepend digit
sll $4,$4,12	# Move into place
or $6,$6,$4	# Insert

# ==[ Load ten thousands place ]================
# Generate fuzzy digit
multu $5,$1	# p = SW * 0.1
mflo $4		# $4 = frac(p)
mfhi $5		# $5 = int(p)
multu $4,$2	# p = $4 * 10
mfhi $4		# $4 = int(p)
# Prepend digit
sll $4,$4,16	# Move into place
or $6,$6,$4	# Insert

# ==[ Load hundred thousands place ]================
# Generate fuzzy digit
multu $5,$1	# p = SW * 0.1
mflo $4		# $4 = frac(p)
mfhi $5		# $5 = int(p)
multu $4,$2	# p = $4 * 10
mfhi $4		# $4 = int(p)
# Prepend digit
sll $4,$4,20	# Move into place
or $30,$6,$4	# Insert
