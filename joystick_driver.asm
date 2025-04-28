.data
.text

joy_loop:
addi $v0, $0, 21
syscall

add $t0, $0, $v0 # $t0 = x
add $t1, $0, $v1 # $t1 = y

sw $t0, -224($0) 
sw $t1, -220($0)
sw $0, -216($0)
sw $0, -212($0)

j joy_loop