#Chuong trinh: CHIA 2 SO NGUYEN 32 BIT
#-----------------------------------
#Data segment
	.data
#Cac dinh nghia bien
	filename: .asciiz "INT2.BIN"	#Ten file du lieu dau vao
	dividend: .word 0			#So bi chia
	divisor: .word 0			#So chia
	quotient: .word 0			#Thuong
	remainder: .word 0			#So du
	buff: .space 8			#Dia chi input buffer doc tu file du lieu dau vao
	descriptor: .word 0		#Descriptor cua file du lieu dau vao
#Cac cau nhac nhap du lieu
	Divide_zero: .asciiz "Invalid: Divide by zero!!!"
	Open_success: .asciiz "File Open Successfully\n"
	Open_failed: .asciiz "File Open Failed!"
	Nhap_dividend: .asciiz "dividend = "
	Nhap_divisor: .asciiz "divisor = "
	Xuat_quotient: .asciiz "quotient = "
	Xuat_remainder: .asciiz "remainder = "
#-----------------------------------
#Code segment
	.text
	.globl main
#-----------------------------------
#Chuong trinh chinh
#-----------------------------------
main:	
#Nhap (syscall)
  #Nhap dividend:
  	la $a0, Nhap_dividend
  	li $v0, 4
  	syscall
  	li $v0, 5
  	syscall
  	sw $v0, dividend
  #Nhap divisor:
  	la $a0, Nhap_divisor
  	li $v0, 4
  	syscall
  	li $v0, 5
  	syscall
  	sw $v0, divisor
#Tao va luu file:
  #Tao/Mo file:
  	li $v0, 13
  	la $a0, filename
  	li $a1, 1
  	li $a2, 0
  	syscall
  	move $s6, $v0
  	sw $s6, descriptor
  	bltz $s6, failed		#Mo file that bai
  	la $a0, Open_success 	#Mo file thanh cong
  	li $v0, 4
  	syscall
  	j Write
  failed:
  	la $a0, Open_failed
  	li $v0, 4
  	syscall
  	j Kthuc
  #Ghi du lieu vao file:
  Write:
    #Ghi dividend:
  	li $v0, 15
  	move $a0, $s6
  	la $a1, dividend
  	li $a2, 4
  	syscall
    #Ghi divisor:
    	li $v0, 15
    	move $a0, $s6
    	la $a1, divisor
    	li $a2, 4
    	syscall
   #Dong file:
   	move $a0, $s6
   	li $v0, 16
   	syscall
#Xu ly
  #Mo file du lieu dau vao:
  	li $v0, 13
  	la $a0, filename
  	li $a1, 0
  	li $a2, 0
  	syscall
  	move $s6, $v0
  #Doc tu file:
  	move $a0, $s6
  	la $a1, buff
  	li $a2, 8
  	li $v0, 14
  	syscall
  #Dong file:
   	move $a0, $s6
   	li $v0, 16
   	syscall
   #Luu gia tri:
     #$t0 = 32 bit cao cua dividend, $t1 = 32 bit thap cua dividend
     #$t2 = 32 bit cao cua divisor, $t3 = 32 bit thap cua divisor
   	la $s0, buff
     #Luu dividend:
     	li $t0, 0
     	lw $t1, 0($s0)
     #Luu divisor:
     	lw $t2, 4($s0)
     	li $t3, 0
   #Kiem tra divisor != 0
   	beqz $t2, zero_divisor
   	j Check
   zero_divisor:
   	la $a0, Divide_zero
   	li $v0, 4
   	syscall
   	j Kthuc
   #Kiem tra dau cua dividend, divisor:
   Check:
   	bgez $t1, Posi_dividend
   	bltz $t1, Nega_dividend
   Posi_dividend:		#dividend >= 0
   	bgez $t2, Posi_Posi
   	bltz $t2, Posi_Nega
     Posi_Posi:		#divisor >= 0
   	jal Algorithm
   	sw $t1, remainder
   	sw $s2, quotient
   	j Xuat_KQ
     Posi_Nega:		#divisor < 0
   	mul $t2, $t2, -1
   	jal Algorithm
   	mul $s2, $s2, -1
   	sw $t1, remainder
   	sw $s2, quotient
   	j Xuat_KQ
   Nega_dividend:		#dividend < 0
   	mul $t1, $t1, -1
   	bgez $t2, Nega_Posi
   	bltz $t2, Nega_Nega
     Nega_Posi:		#divisor >= 0
   	jal Algorithm
   	mul $t1, $t1, -1
   	mul $s2, $s2, -1
   	sw $t1, remainder
   	sw $s2, quotient
   	j Xuat_KQ
     Nega_Nega:		#dividend < 0
   	mul $t2, $t2, -1
   	jal Algorithm
   	mul $t1, $t1, -1
   	sw $t1, remainder
   	sw $s2, quotient
   	j Xuat_KQ
   #Giai thuat: ($s1 la bien dem (khoi tao bang 32), $s2 la thuong (quotient, khoi tao bang 0))
   Algorithm:
   	li $s1, 32
   	addi $s2, $zero, 0
     #Vong lap:
     Loop:		
   	bltz $s1, ret
   	move $a0, $t0	#truyen tham so
   	move $a1, $t1	#truyen tham so
   	move $a2, $t2	#truyen tham so
   	move $a3, $t3 	#truyen tham so
   	addi $sp, $sp, -4
   	sw $ra, 0($sp)
   	jal minus		#Tinh: dividend - divisor
   	lw $ra, 0($sp)
   	addi $sp, $sp, 4
   	bltz $v0, Less
   	bgez $v0, Gret
     #dividend - divisor >= 0
       Gret:
   	move $t0, $v0	#gan: dividend -= divisor
   	move $t1, $v1	#gan: dividend -= divisor
   	sll $s2, $s2, 1	#shift left quotient
   	addi $s2, $s2, 1	#bat bit cuoi cua quotient len 1
   	addi $sp, $sp, -4
   	sw $ra, 0($sp)
   	jal shift_right	#shift right divisor
   	lw $ra, 0($sp)
   	addi $sp, $sp, 4
   	addi $s1, $s1, -1
   	j Loop
     #dividend - divisor < 0
       Less:
   	sll $s2, $s2, 1	#shift left quotient
   	addi $sp, $sp, -4
   	sw $ra, 0($sp)
   	jal shift_right	#shift right divisor
   	lw $ra, 0($sp)
   	addi $sp, $sp, 4
   	addi $s1, $s1, -1
   	j Loop
     #Luu so du va thuong so
   ret:
   	jr $ra
#Xuat ket qua (syscall)
Xuat_KQ:
  #Xuat_quotient:
  	la $a0, Xuat_quotient
  	li $v0, 4
  	syscall
  	li $v0, 1
  	lw $a0, quotient
  	syscall
  #Xuong dong:
  	li $v0, 11
  	addi $a0, $zero, '\n'
  	syscall
  #Xuat_remainder:
  	la $a0, Xuat_remainder
  	li $v0, 4
  	syscall
  	li $v0, 1
  	lw $a0, remainder
  	syscall
#ket thuc chuong trinh (syscall)
Kthuc:	addiu $v0, $zero, 10
	syscall
#-----------------------------------
#Cac chuong trinh con khac
   minus: #Tru hai so nguyen 64 bit
     #Tham so:
       #$a0 = 32 bit cao cua dividend, $a1 = 32 bit thap cua dividend
       #$a2 = 32 bit cao cua divisor, $a3 = 32 bit thap cua divisor
     #Tra ve: $v0 = 32 bit cao, $v1 = 32 bit thap
   	subu $v1, $a1, $a3
   	bltz $a3, smaller
   	bgez $a3, posi_t3
   posi_t3:
   	bltz $v1, smaller
   	subu $v0, $a0, $a2
   	jr $ra
   smaller:
   	addi $t9, $a2, 1
   	subu $v0, $a0, $t9
   	jr $ra
   shift_right: #dich phai divisor (64 bit)
   	srl $t3, $t3, 1
   	and $s7, $t2, 1
   	sll $s7, $s7, 31
   	or $t3, $t3, $s7
   	srl $t2, $t2, 1
   	jr $ra
#-----------------------------------
