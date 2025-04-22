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
    
    # dipswitch
    addi $k1, $0, 13
    beq $v0, $k1, _syscall13

    addi $k1, $0, 14
    beq $v0, $k1, _syscall14
    #Error state - this should never happen - treat it like an end program
    j _syscall10

#Do init stuff
_syscall0:
    addi $sp, $0, -4096 # initialize stack pointer
    la $k1, _END_OF_STATIC_MEMORY_ # Load end of static memory
    addi $t0, $0, -4092  # HEAP POINTER 0x3FFFF004
    sw $k1, 0($t0) # Store initial heap pointer
    j _syscallEnd_

#Print Integer
_syscall1:
    addi $sp, $sp, -8 # allocate space on stack for 2 registers
    sw $t0, 0($sp) # save t0 on the stack
    sw $t1, 4($sp) # save t1 on the stack

    addi $t1, $0, 0 #t1 = 0
    bne $a0, $0, _not_zero # if a0 is not zero
    addi $t0, $0, 48 # t0 = ascii 0
    sw $t0, -256($0) # print 0
    j _end_print_int

_not_zero:
    slt $t0, $a0, $0 # t0 = 1 if a0<0 negative
    beq $t0, $0, _main_print_int_loop # if t0=0, not negative, go to main loop
    addi $t0, $0, 45 # ASCII for -
    sw $t0, -256($0) # print - to terminal
    addi $t0, $0, -1 #make t0 negative
    mult $a0, $t0 #make a0 positve
    mflo $a0

_main_print_int_loop:
    addi $t0, $0, 10
    div $a0, $t0
    mflo $a0
    mfhi $t0 # remainder, rightmost in t0
    beq $a0, $0, _actual_print
    addi $t1, $t1, 1 # increment digit counter
    addi $sp, $sp, -4 # allocate space for 1 int
    sw $t0, 0($sp) # save it on stack
    j _main_print_int_loop

_actual_print:
    addi $t0, $t0, 48 # ASCII
    sw $t0, -256($0) #print to terminal
    beq $t1, $0, _end_print_int
    lw $t0, 0($sp) #get next digit from stack
    addi $sp, $sp, 4 # deallocate
    addi $t1, $t1, -1
    j _actual_print

_end_print_int:
    lw $t0, 0($sp) # get t0 back from mem
    lw $t1, 4($sp) # save t0 on the stack
    addi $sp, $sp, 8 # deallocate stack
    jr $k0

#Read Integer
_syscall5:
    addi $sp, $sp, -16 # allocate space on stack for 4 registers
    sw $t0, 0($sp) # save t0 on the stack
    sw $t1, 4($sp) # save t1 on the stack
    sw $t2, 8($sp) # save t2 on the stack
    sw $t3, 12($sp) # save t3 on the stack

    addi $t3, $0, 1 # t3 = 1
_first_int:
    lw $t0, -240($0) # checks if any input to keyboard
    beq $t0, $0, _first_int # if no, loop

    lw $t0, -236($0) # puts first char in t0
    addi $v0, $0, 0 # v0 = 0
    addi $t1, $0, 45 # ASCII for -

    bne $t0, $t1, _main_read_int_loop # start if not negative
    sw $0, -240($0) # read next int
    addi $t3, $0, -1 # t3 = -1 if negative
    j _first_int

main_read_int_loop:
    lw $t0, -236($0) # puts char in t0
    addi $t1, $0, 58 # above ASCII 9
    slt $t2, $t0, $t1 # t2=1 if t0<t1, input <58
    beq $t2, $0, _end_read_int

    addi $t1, $0, 48 # below ASCII 0
    slt $t2, $t0, $t1 # t2=1 if t0<t1, input < 48
    bne $t2, $0, _end_read_int

    addi $t2, $0, 10 #t2=10
    mult $v0, $t2 # shifts decimals to left
    mflo $v0
    addi $t0, $t0, -48 # converts ascii to int
    add $v0, $v0, $t0 #adds next digit to v0

    lw $t0, -236($0)    # read & discard the data register

_get_int:
    lw $t0, -240($0) # checks if any input to keyboard
    beq $t0, $0, _get_int # if no, loop
    j _main_read_int_loop # start again

_end_read_int:
    mult $v0, $t3 # mult result by t3, making it negative if needed
    mflo $v0 # gets it
    lw $t0, 0($sp) # get t0 back from mem
    lw $t1, 4($sp) # save t0 on the stack
    lw $t2, 8($sp) # save t0 on the stack
    lw $t3, 12($sp) # save t3 on the stack
    addi $sp, $sp, 16 # deallocate stack
    jr $k0

#Heap allocation
_syscall9:
    addi $t0, $0, -4092 # add heap pointer address into $t0
    lw $v0, 0($t0) # load heap pointer into $v0
    add $t1, $v0, $a0 # allocate new space on heap
    sw $t1, 0($t0) # store updated heap pointer
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
    addi $t0, $0, -240 
    addi $t1, $0, -236
    # loop until a character is available
_pollingLoop:
    lw $t2, 0($t0) # lw from keyboard status register
    beq $t2, $0, _pollingLoop  # if status is 0 then no character is available - loop again
    # when character is available read it
    lw $v0, 0($t1) # lw from keyboard data register
    jr $k0

#extra challenge syscalls go here?

# dipswitch: loops until a switch is flicked in the dipswitch device
_syscall13:
    #load dipswitch address
    addi $t0, $0, -168
    sw $0, 0($v0)

_dipLoop:
    lw $v0, 0($t0)
    beq $v0, $0, _dipLoop
    jr $k0

# LED bar: takes $a0 as an argument and outputs it to the LED bar device
_syscall14:
    addi $t0, $0, -160
    sw $a0, 0($t0)
    jr $k0

_syscallEnd_: