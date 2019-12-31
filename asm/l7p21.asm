.text
lui $1, 11
srl $1, $1, 16
lui $2, 17
srl $2, $2, 16
add $3, $1, $0
addu $4, $2, $0
sub $5, $0, $3
subu $6, $0, $4
mult $4, $6
mflo $7
mfhi $8
multu $4, $6
mflo $9
mfhi $10
and $11,$3,$4
or $12,$3,$4
xor $13,$3,$4
nor $14,$3,$4
nop
sll $15,$3,1
srl $17,$5,1
sra $19,$5,1
slt $21,$6,$4
sltu $22,$6,$4