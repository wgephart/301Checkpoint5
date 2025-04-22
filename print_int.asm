# This prints "Hi!" to the terminal

.text
.globl main
main:
    addi $a0, $0, 105
    addi $v0, $0, 1    
    syscall

    addi $a0, $0, -111
    addi $v0, $0, 1
    syscall

