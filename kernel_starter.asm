#This is starter code, so that you know the basic format of this file.
#Use _ in your system labels to decrease the chance that labels in the "main"
#program will conflict

.data
.text
_syscallStart_:
    beq $v0, $0, _syscall0 #jump to syscall 0
    addi $k1, $0, 1
    beq $v0, $k1, _syscall1 #jump to syscall 1
    addi $k1, $0, 5
    beq $v0, $k1, _syscall5 #jump to syscall 5
    addi $k1, $0, 9
    beq $v0, $k1, _syscall9 #jump to syscall 9
    addi $k1, $0, 10
    beq $v0, $k1, _syscall10 #jump to syscall 10
    addi $k1, $0, 11
    beq $v0, $k1, _syscall11 #jump to syscall 11
    addi $k1, $0, 12
    beq $v0, $k1, _syscall12 #jump to syscall 12
    # Add branches to any syscalls required for your stars.

    #Error state - this should never happen - treat it like an end program
    j _syscall10

#Do init stuff
_syscall0:
    addi $sp, $0, -4096 # initialize stack pointer
    j _syscallEnd_

#Print Integer
_syscall1:
    # Print Integer code goes here
    jr $k0

#Read Integer
_syscall5:
    # Read Integer code goes here
    jr $k0

#Heap allocation
_syscall9:
    la $k1, _END_OF_STATIC_MEMORY_ # Load end of static memory
    lui $t0, -3800  # HEAP POINTER 0x3FFFF128
    sw $k1, 0($t0) # Store initial heap pointer
    jr $k0

#"End" the program
_syscall10:
    j _syscall10

#print character
_syscall11:
    addi $t0, $0, -256
    sw $a0, 0($t0)
    jr $k0

#read character
_syscall12:
    # load addresses
    addi $t0, $0, -236 
    addi $t1, $0, -240 
    # loop until a character is available
_pollingLoop:
    lw $t2, 0($t0) # lw from keyboard status register
    beq $t2, $0, _pollingLoop  # if status is 0 then no character is available - loop again
    # when character is available read it
    lw $v0, 0($t1) # lw from keyboard data register
    jr $k0

#extra challenge syscalls go here?

_syscallEnd_: