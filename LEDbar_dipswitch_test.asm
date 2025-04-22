# Protocol: this device driver connects the 8 switches on the dipswitch to the 8 lights on the LED bar 
# through syscalls 13 and 14. The dipswitch syscall 13 is called which loops until a switch is flicked on.
# Once a switch is flicked, the input will be stored in $v0 which is moved to $a0. $a0 is then used as an 
# argument for the LED bar which will flicker on the corresponding light to the dipswitch input.

.data
.text
.align 2 
.globl main
main:
    # call dipswitch syscall that will loop and return the dipswitch input in $v0
    addi $v0, $zero, 13
    syscall

    # store dipswitch input in argument register $a0 for LED bar syscall
    add $a0, $v0, $0

    # call LED bar sycall 
    addi $v0, $zero, 14
    syscall 

    # end program
    addi $v0, $zero, 10
    syscall