# Protocol:

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

# call LED sycall 
addi $v0, $zero, 14
syscall 

# end program
addi $v0, $zero, 10
syscall