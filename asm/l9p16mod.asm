		ori $29,$0,0
		ori $4,$0,1
		ori $5,$0,2
		beq $4,$5,target1	# not taken
		ori $29,$29,1	# 00'0000'0001
b:		bne $4,$5,target2	# taken
		ori $29,$29,2	# 00'0000'0010
c:		bgez $4,target3		# taken
		ori $29,$29,4	# 00'0000'0100
d:		jal target4
		ori $29,$29,8	# 00'0000'1000
		j exit
		ori $29,$29,16	# 00'0001'0000
target1:	ori $29,$29,32	# 00'0010'0000
		j b
target2:	ori $29,$29,64	# 00'0100'0000
		j c
target3:	ori $29,$29,128	# 00'1000'0000
		j d
target4:	ori $29,$29,256	# 01'0000'0000
		jr $31
exit:		ori $30,$29,512	# 10'0000'0000