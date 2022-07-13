.global main
.text
main:
# Prepare the parameters of SORT routine
    la a0, v # load the address of data set v in a0 - 1st parameter
    lw a1, n # load the number of elements n in a1 - 2nd parameter
# Call sort routine
    jal sort # Call the sort routine
.end main

# Procedure SORT
.global sort # make name sort global
.ent sort # define routine sort entry point
sort:
# Saving registers
    addi sp, sp, -20 # make room on the stack for 5 registers
    sw ra, 16(sp) # save ra on stack
    sw s3, 12(sp) # save s3 on stack
    sw s2, 8(sp) # save s2 on stack
    sw s1, 4(sp) # save s1 on stack ==> j
    sw s0, 0(sp) # save s0 on stack ==> i
# Procedure body
# Move parameters
    addi s2, a0, 0 # copy parameter ao into s2 ==> v
    addi s3, a1, 0 # copy parameter a1 into s3 ==> n
# Outer Loop
    addi s0, $zero, 0 # i = 0
for1tst:
    slt t0, s0, s3 # t0 = 1 if s0 < s3 else t0 = 0 (i < n)
    beq t0, $zero, exit1 # go to exit1 if s0
# Inner Loop
    addi s1, s0, -1 # j = i - 1
for2tst: 
    slti t0, s1, 0 # t0 = 1 if s1 < 0 else t0 = 0 (j < 0)
    bne t0, $zero, exit2 # go to exit2 if s1 < 0 (j < 0)
    slli t1, s1, 2 # t1 = j*4
    add t2, s2, t1 # t2 = v + (j*4)
    lw t3, 0(t2) # t3 = v[j]
    lw t4, 4(t2) # t4 = v[j+1]
    slt t0, t4, t3 # t0 = 1 if t4 < t3 else t0 = 0
    beq t0, $zero, exit2 # go to exit2 if t4 >= t3
# pass parameters and call Swap
    addi a0, s2, 0 # First parameter of Swap is v (old a0)
    addi a1, s1, 0 # Second parameter of Swap is j
    jal swap # Call subrotine Swap
# Inner Loop
    addi s1, s1, -1 # j = j - 1
    jal zero, for2tst # Jump to test of the innerloop
# Outer Loop
exit2:
    addi s0, s0, 1 # i = i + 1
    jal zero, for1tst # Jump to test of the outer loop
# Restorin Registers
exit1:
    lw s0, 0(sp) # Restore s0 from stack
    lw s1, 4(sp) # Restore s1 from stack
    lw s2, 8(sp) # Restore s2 from stack
    lw s3, 12(sp) # Restore s3 from stack
    lw ra, 16(sp) # Restore ra from stack
    addi sp, sp, 20 # Restore Stack Pointer
# Procedure sort Return
    jalr zero, ra # Return from SORT to the calling routine
.end sort # End of routine sort code

# Swap subroutine
.globl swap # Make name swap global
.ent swap # define routine swap entry point
swap:
    slli t1, a1, 2 # reg t1 = k*4
    add t1, a0, t1 # reg t1 = v + (k*4)
# reg t1 has the address of v[k]
    lw t0, 0(t1) # reg t0 (temp) = v[k]
    lw t2, 4(t1) # reg t2 = v[k+1]
# refers to next element of v
    sw t2, 0(t1) # v[k] = reg t2
    sw t0, 4(t1) # v[k+1] = reg t0(temp)
    jalr zero, ra # return from Swap to calling
.end swap # End of subroutine swap code

# Data declarations
.data
v:  .word 4, 3, 5, 2, 1 # data set to be sorted
n:  .word 5 # Number of elements in the data set