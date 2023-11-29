<#

#[tmp reg (8bits)]   
$t0 000 val_MEM[$s0]    (for even 29:0)                
$t1 001 val_MEM[$s0+1]  (for odd 29:0)    
$t2 010 val_MEM[$s1]    (for even 59:30)
$t3 011 val_MEM[$s1+1]  (for odd 59:30)
$t4 100 zero
$t5 101 tmp_bit        
$t6 110 tmp_exe                   
$t7 111 tmp_val                   

#[save reg (8bits)]
$s0 000 addr_MEM[0]       
$s1 001 addr_MEM[30]
$s2 010 dx59
$s3 011 bit_parity0
$s4 100 bit_parity1 
$s5 101 bit_parity2 
$s6 110 bit_parity4
$s7 111 bit_parity8

#[cmd]
0 000 lw addr_MEM[0:59] #(load word to $t7 from MEM[])
1 001 sw addr_MEM[0:59] #(save word to MEM[] from $t7)
2 010 bnez addr_cmd     #($t5's LSB != 0 then go cmd)
3 011 xor $rd $rs       #($rd ^= $rs) 
4 100 inc $rd [7:0]     #($rd += 1)
5 101 shl $rd [7:0]     #($rd <<  [7:0])
6 110 shr $rd [7:0]     #($rd >> [7:0])
7 111 and $rd $rs       #($rd &= $rs)

#>

# [program 1] 
.data
    origin:  .word  29:0         # MEM[29:0]
    #       0 0 0 0 0 B A 9      (given)
    #       8 7 6 5 4 3 2 1      (given)
    w_parity: .word 59:30        # MEM[59:30]
    #       B A 9 8 7 6 5 e      (need to be filled)
    #       4 3 2 f 1 t o z      (need to be filled)

.text
.globl main

main:
    # initiate input data(origin) address
    and $s0 $t4         # reset $s0 ($s0 = 0)
   
    # initiate output data(w_parity) address 
    inc $s1 111         # $s1 += 7  ($s1 = 7)  ($s1 = 0 0 0 0 0 1 1 1)
    shl $s1 010         # $s1 << 2  ($s1 = 28) ($s1 = 0 0 0 1 1 1 0 0)
    inc $s1 010         # $s1 += 2  ($s1 = 30) ($s1 = 0 0 0 1 1 1 1 0)

    # escaping iteration data($s2)
    inc $s2 111         # $s1 += 7 ($s2 = 7)   ($s1 = 0 0 0 0 0 1 1 1) 
    shl $s2 011         # $s1 << 3 ($s2 = 56)  ($s1 = 0 0 1 1 1 0 0 0)
    inc $s2 011         # $s1 += 3 ($s2 = 59)  ($s1 = 0 0 1 1 1 0 1 1)
    
loop:
    # reset
    and $s3 $t4         # reset bit_parity0    ($s3 = 0)
    and $s4 $t4         # reset bit_parity1    ($s4 = 0) 
    and $s5 $t4         # reset bit_parity2    ($s5 = 0)
    and $s6 $t4         # reset bit_parity4    ($s6 = 0)
    and $s7 $t4         # reset bit_parity8    ($s7 = 0)
    and $t0 $t4         # reset $t0            ($t0 = 0)
    and $t1 $t4         # reset $t1            ($t1 = 0)
    and $t6 $t4         # reset $t6            ($t6 = 0)
    and $t7 $t4         # reset $t7            ($t7 = 0)

    # value_of_even_MEM($s0) -> tmp7 -> tmp0 
    lw  $s0             # load data MEM -> $t7 ($t7 = b8 b7 b6 b5 b4 b3 b2 b1)
    xor $t0 $t7         # move $t7 -> $t0      ($t0 = b8 b7 b6 b5 b4 b3 b2 b1)
    
    # calculate parity bits so far
    # b1
    inc $t6 001         # $t6 += 1             ($t6 = 0 0 0 0 0 0 0 1) 
    and $t6 $t0         # masking $t0 -> $t6   ($t6 = 0 0 0 0 0 0 0 b1)
    xor $s3 $t6         # b1          -> $s3
    xor $s4 $t6         # b1          -> $s4
    xor $s5 $t6         # b1          -> $s5

    # b2
    and $t6 $t4         # reset $t6            ($t6 = 0) 
    inc $t6 001         # $t6 += 1             ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 001         # $t6 << 1             ($t6 = 0 0 0 0 0 0 1 0)
    and $t6 $t0         # masking $t0 -> $t6   ($t6 = 0 0 0 0 0 0 b2 0)
    shr $t6 001         # shift to LSB         ($t6 = 0 0 0 0 0 0 0 b2)
    xor $s3 $t6         # b12         -> $s3
    xor $s4 $t6         # b12         -> $s4
    xor $s6 $t6         # b 2         -> $s6

    # b3
    and $t6 $t4         # reset $t6             ($t6 = 0) 
    inc $t6 001         # $t6 += 1              ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 010         # $t6 << 2              ($t6 = 0 0 0 0 0 1 0 0)
    and $t6 $t0         # masking $t0 -> $t6    ($t6 = 0 0 0 0 0 b3 0 0)
    shr $t6 010         # shift to LSB          ($t6 = 0 0 0 0 0 0 0 b3)
    xor $s3 $t6         # b123        -> $s3
    xor $s5 $t6         # b1 3        -> $s5
    xor $s6 $t6         # b 23        -> $s6

    # b4
    and $t6 $t4         # reset $t6             ($t6 = 0) 
    inc $t6 001         # $t6 += 1              ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 011         # $t6 << 3              ($t6 = 0 0 0 0 1 0 0 0)
    and $t6 $t0         # masking $t0 -> $t6    ($t6 = 0 0 0 0 b4 0 0 0)
    shr $t6 011         # shift to LSB          ($t6 = 0 0 0 0 0 0 0 b4)
    xor $s4 $t6         # b12 4       -> $s4
    xor $s5 $t6         # b1 34       -> $s5
    xor $s6 $t6         # b 234       -> $s6

    # b5
    and $t6 $t4         # reset $t6             ($t6 = 0) 
    inc $t6 001         # $t6 += 1              ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 100         # $t6 << 4              ($t6 = 0 0 0 1 0 0 0 0)
    and $t6 $t0         # masking $t0 -> $t6    ($t6 = 0 0 0 b5 0 0 0 0)
    shr $t6 100         # shift to LSB          ($t6 = 0 0 0 0 0 0 0 b5)
    xor $s3 $t6         # b123 5      -> $s3
    xor $s4 $t6         # b12 45      -> $s4
    xor $s7 $t6         # b    5      -> $s7

    # b6
    and $t6 $t4         # reset $t6             ($t6 = 0) 
    inc $t6 001         # $t6 += 1              ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 101         # $t6 << 5              ($t6 = 0 0 1 0 0 0 0 0)
    and $t6 $t0         # masking $t0 -> $t6    ($t6 = 0 0 b6 0 0 0 0 0)
    shr $t6 101         # shift to LSB          ($t6 = 0 0 0 0 0 0 0 b6)
    xor $s3 $t6         # b123 56     -> $s3
    xor $s5 $t6         # b1 34 6     -> $s5
    xor $s7 $t6         # b    56     -> $s7

    # b7
    and $t6 $t4         # reset $t6             ($t6 = 0) 
    inc $t6 001         # $t6 += 1              ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 110         # $t6 << 6              ($t6 = 0 1 0 0 0 0 0 0)
    and $t6 $t0         # masking $t0 -> $t6    ($t6 = 0 b7 0 0 0 0 0 0)
    shr $t6 110         # shift to LSB          ($t6 = 0 0 0 0 0 0 0 b7)
    xor $s4 $t6         # b12 45 7    -> $s4
    xor $s5 $t6         # b1 34 67    -> $s5
    xor $s7 $t6         # b    567    -> $s7

    # b8
    and $t6 $t4         # reset $t6             ($t6 = 0) 
    inc $t6 001         # $t6 += 1              ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 111         # $t6 << 7              ($t6 = 1 0 0 0 0 0 0 0)
    and $t6 $t0         # masking $t0 -> $t6    ($t6 = b8 0 0 0 0 0 0 0)
    shr $t6 111         # shift to LSB          ($t6 = 0 0 0 0 0 0 0 b8)
    xor $s3 $t6         # b123 56 8   -> $s3
    xor $s6 $t6         # b 234   8   -> $s6
    xor $s7 $t6         # b    5678   -> $s7

    # reset
    and $t0 $t4         # reset $t0             ($t0 = 0)
    and $t6 $t4         # reset $t6             ($t6 = 0)
    and $t7 $t4         # reset $t7             ($t7 = 0)

    # value_of_odd_MEM(++$s0) -> tmp7 -> tmp1 
    inc $s0 001         # $s0 += 1
    lw  $s0             # load data MEM -> $t7  ($t7 = 0 0 0 0 0 bB bA b9)
    xor $t1 $t7         # move $t7 -> $t1       ($t1 = 0 0 0 0 0 bB bA b9)

    # calculate parity bits so far
    # b9
    inc $t6 001         # $t6 = 1               ($t6 = 0 0 0 0 0 0 0 1) 
    and $t6 $t1         # masking $t1 -> $t6    ($t6 = 0 0 0 0 0 0 0 b9)
    xor $s4 $t6         # b12 45 7 9  -> $s4
    xor $s6 $t6         # b 234   89  -> $s6
    xor $s7 $t6         # b    56789  -> $s7

    # bA
    and $t6 $t4         # reset $t6             ($t6 = 0) 
    inc $t6 001         # $t6 += 1              ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 001         # $t6 << 1              ($t6 = 0 0 0 0 0 0 1 0)
    and $t6 $t1         # masking $t1 -> $t6    ($t6 = 0 0 0 0 0 0 bA 0)
    shr $t6 001         # shift to LSB          ($t6 = 0 0 0 0 0 0 0 bA)
    xor $s5 $t6         # b1 34 67  A -> $s5
    xor $s6 $t6         # b 234   89A -> $s6
    xor $s7 $t6         # b    56789A -> $s7

    # bB
    and $t6 $t4         # reset $t6             ($t6 = 0) 
    inc $t6 001         # $t6 += 1              ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 010         # $t6 << 2              ($t6 = 0 0 0 0 0 1 0 0)
    and $t6 $t1         # masking $t1 -> $t6    ($t6 = 0 0 0 0 0 bB 0 0)
    shr $t6 010         # shift to LSB          ($t6 = 0 0 0 0 0 0 0 bB)
    xor $s3 $t6         # b123 56 8  B => $s3   calculated bit_parity0 
    xor $s4 $t6         # b12 45 7 9 B => $s4   calculated bit_parity1 
    xor $s5 $t6         # b1 34 67  AB => $s5   calculated bit_parity2 
    xor $s6 $t6         # b 234   89AB => $s6   calculated bit_parity4 
    xor $s7 $t6         # b    56789AB => $s7   calculated bit_parity8 

    # output
    # value_of_even_MEM($s1)
    and $t6 $t4         # reset $t6             ($t6 = 0) 
    and $t7 $t4         # reset $t7             ($t7 = 0) 
    inc $t6 111         # $t6 += 7              ($t6 = 0 0 0 0 0 1 1 1) 
    shl $t6 001         # $t6 << 1              ($t6 = 0 0 0 0 1 1 1 0) 
    and $t6 $t0         # masking $t0 -> $t6    ($t6 = 0 0 0 0 b4 b3 b2 0) 
    and $t6 $s6         # concatenate  p4       ($t6 = 0 0 0 0 b4 b3 b2 p4)
    shl $t6 001         # $t6 << 1              ($t6 = 0 0 0 b4 b3 b2 p4 0) 
    xor $t7 $t6         # move $t6 -> $t7       ($t7 = 0 0 0 b4 b3 b2 p4 0)
    and $t6 $t4         # reset $t6             ($t6 = 0) 
    inc $t6 001         # $t6 += 1              ($t6 = 0 0 0 0 0 0 0 1) 
    and $t6 $t0         # masking $t0 -> $t6    ($t6 = 0 0 0 0 0 0 0 b1)
    and $t7 $t6         # concatenate b1        ($t7 = 0 0 0 b4 b3 b2 p4 b1)
    shl $t7 001         # $t7 << 1              ($t7 = 0 0 b4 b3 b2 p4 b1 0) 
    and $t7 $s5         # concatenate p2        ($t7 = 0 0 b4 b3 b2 p4 b1 p2)
    shl $t7 001         # $t7 << 1              ($t7 = 0 b4 b3 b2 p4 b1 p2 0) 
    and $t7 $s4         # concatenate p1        ($t7 = 0 b4 b3 b2 p4 b1 p2 p1)
    shl $t7 001         # $t7 << 1              ($t7 = b4 b3 b2 p4 b1 p2 p1 0) 
    and $t7 $s2         # concatenate p0        ($t7 = b4 b3 b2 p4 b1 p2 p1 p0)
    sw $s1              # store data $t7 -> MEM

    # value_of_odd_MEM(++$s1)
    inc $s1 001         # $s1 += 1
    and $t6 $t4         # reset $t6             ($t6 = 0) 
    and $t7 $t4         # reset $t7             ($t7 = 0) 
    inc $t6 111         # $t6 += 7              ($t6 = 0 0 0 0 0 1 1 1) 
    and $t6 $t1         # masking $t1 -> $t6    ($t6 = 0 0 0 0 0 bB bA b9)
    xor $t7 $t6         # move $t6 -> $t7       ($t7 = 0 0 0 0 0 bB bA b9)
    shl $t7 101         # $t7 << 5              ($t7 = bB bA b9 0 0 0 0 0)
    and $t6 $t4         # reset $t6             ($t6 = 0) 
    xor $t6 $t0         # move $t0 -> $t6       ($t6 = b8 b7 b6 b5 b4 b3 b2 b1)
    shr $t6 100         # $t7 >> 4              ($t6 = 0 0 0 0 b8 b7 b6 b5)
    shl $t6 001         # $t7 << 1              ($t6 = 0 0 0 b8 b7 b6 b5 0)
    and $t7 $t6         # concatenate b8-5      ($t7 = bB bA b9 b8 b7 b6 b5 0)
    and $t7 $s7         # concatenate p8        ($t7 = bB bA b9 b8 b7 b6 b5 p8)
    sw $s1               # store data $t7 -> MEM
    
    # escape loop
    and $t6 $t4         # reset $t6             ($t6 = 0) 
    xor $t6 $s1         # move $s1 -> $t6       ($t6 = addr_MEM[30])
    xor $t6 $s2         # $t6 ^= $s2            // addr_MEM[0]^59 == 0 ?
    inc $s0 001         # $s0 += 1
    inc $s1 001         # $s1 += 1
    and $t5 $t4         # reset $t5             ($t5 = 0) 
    xor $t5 $t6         # move $t6    -> $t5
    bnez loop           # if $t5 != 0 -> go loop   

exit:
    li $v0, 10          # exit program syscall# 10
    syscall 