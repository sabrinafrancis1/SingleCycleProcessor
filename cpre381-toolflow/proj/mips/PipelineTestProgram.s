.data
testAddress: .word 1

.text
addi $t0, $0, 1            #loads values #0
addiu $t1, $0, 1 #4
lui $t2, 0xFFFF #8
addi $t3, $0, 2 #C
lui $s0, 0x1001 #10
ori $s0, $s0, 0 #14
sw $0, 0($s0) #18
lw $t4, 0($s0) #1C
addi $t5, $0, 1 #20



P1:
	add $t0, $t0, $t0  #24
	addu $t1, $t0, $t1 #28
	and $t2, $t1, $t0  #2C
	andi $t3, $t3, 0x00000000 #30
	nor $t4, $t3, $t4 #34
	xor $t0, $t4, $t1 #38
	xori $t1, $t0, 0x00000001 #3C
	or $t2, $t1, $t2 #40
	slt $t4, $t2, $t4 #44
	slti $t0, $t0, 3 #48
	sll $t1, $t1, 1 #4C
	srl $t2, $t1, 1 #50
	sra $t3, $t2, 1 #54
	sw $t3, 0($s0) #58
	sub $t0, $t0, $t0     #5C      # expect 0
	subu $t1, $t1, $t1   #60      # expect 0
	beq $t2, $0, P1  #64  # expect not taken
	bne $0, $t5, P2 #68
	add $t0, $t0, $t0 #6C 
	addu $t1, $t1, $t1 #70
	and $t2, $t2, $t2  #74

P2:
	j P3 #78
	add $t0, $t0, $t0 #7C 
	addu $t1, $t1, $t1 #80
	and $t2, $t2, $t2  #84
P3:
	jal P4 #88            # expect jump to jr instruction
P4:
	lui $t6, 0x0040 #8C
	ori $t6, $t6, 156 #90
	jr $t6       #94       # expect jump to end of program

Exit:
	add $t0, $t0, $t0 #98
	halt #9C
