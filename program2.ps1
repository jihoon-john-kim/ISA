<#

#[tmp reg (8bits)]   
$t0 000 val_MEM[$s0]    (for even 29:0)                
$t1 001 val_MEM[$s0+1]  (for odd 29:0)    
$t2 010 val_MEM[$s1]    (for even 59:30)
$t3 011 val_MEM[$s1+1]  (for odd 59:30)
$t4 100 zero
$t5 00101 tmp_bit               
$t6 00110 tmp_exe                   
$t7 111 tmp_val                   

#[save reg (8bits)]
$s0 000 addr_MEM[0]       
$s1 001 addr_MEM[30]
$s2 010 dx59
$s3 011 validity_parity0 
$s4 100 validity_parity1 
$s5 101 validity_parity2 
$s6 110 validity_parity4
$s7 111 validity_parity8

#[cmd]
0 000 lw addr_MEM[0:59] (load word to $t7 from MEM[])
1 001 sw addr_MEM[0:59] (save word to MEM[] from $t7)
2 010 bnez addr_cmd     ($t5 != 0 then go cmd)
3 011 xor $rd $rs       ($rd ^= $rs) 
4 100 inc $rd [7:0]     ($rd += 1)
5 101 shl $rd [7:0]     ($rd << [7:0])
6 110 shr $rd [7:0]     ($rd >> [7:0])
7 111 and $rd $rs       ($rd &= $rs)

#>

# [program 2]
.data
    origin:  .word  29:0   # MEM[29:0]
    #     0 0 0 0 0 B A 9           (need to be filled)
    #     8 7 6 5 4 3 2 1           (need to be filled)
    w_parity: .word 59:30  # MEM[59:30]
    #     B A 9 8 7 6 5 e           (given)
    #     4 3 2 f 1 t o z           (given)

.text
.globl main

main:
    # initiate input data(origin) address
    inc $s0 000         # ($s0 = 0)
   
    # initiate output data(w_parity) address 
    inc $s1 111         # $s1 += 7  ($s1 = 7)       ($s1 = 0 0 0 0 0 1 1 1)
    shl $s1 010         # $s1 << 2  ($s1 = 28)      ($s1 = 0 0 0 1 1 1 0 0)
    inc $s1 010         # $s1 += 2  ($s1 = 30)      ($s1 = 0 0 0 1 1 1 1 0)

    # escaping iteration data($s2)
    inc $s2 111         # $s1 += 7 ($s2 = 7)        ($s1 = 0 0 0 0 0 1 1 1) 
    shl $s2 011         # $s1 << 3 ($s2 = 56)       ($s1 = 0 0 1 1 1 0 0 0)
    inc $s2 011         # $s1 += 3 ($s2 = 59)       ($s1 = 0 0 1 1 1 0 1 1)

loop:
    # reset
    and $s3 $t4         # reset validity_p0         ($s3 = 0)
    and $s4 $t4         # reset validity_p1         ($s4 = 0) 
    and $s5 $t4         # reset validity_p2         ($s5 = 0)
    and $s6 $t4         # reset validity_p4         ($s6 = 0)
    and $s7 $t4         # reset validity_p8         ($s7 = 0)
    and $t0 $t4         # reset $t0                 ($t0 = 0)
    and $t1 $t4         # reset $t1                 ($t1 = 0)
    and $t2 $t4         # reset $t2                 ($t2 = 0)
    and $t3 $t4         # reset $t3                 ($t3 = 0)
    and $t6 $t4         # reset $t6                 ($t6 = 0)
    and $t7 $t4         # reset $t7                 ($t7 = 0)

# CALCULATE PARITY BITS FROM EVENth MEMORY
    # value_of_even_MEM($s1) -> tmp7 -> tmp2 
    lw  $s1             # load data MEM -> $t7      ($t7 = b4 b3 b2 p4 b1 p2 p1 p0)
    xor $t2 $t7         # move $t7 -> $t2           ($t2 = b4 b3 b2 p4 b1 p2 p1 p0)

    # p0
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    and $t6 $t2         # masking $t2 -> $t6        ($t6 = 0 0 0 0 0 0 0 p0)
    xor $s3 $t6         # p0    b            -> $s3

    # p1
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 001         # $t6 << 1                  ($t6 = 0 0 0 0 0 0 1 0)
    and $t6 $t2         # masking $t2 -> $t6        ($t6 = 0 0 0 0 0 0 p1 0)
    shr $t6 001         # $t6 >> 1                  ($t6 = 0 0 0 0 0 0 0 p1)
    xor $s3 $t6         # p01   b            -> $s3
    xor $s4 $t6         # p 1   b            -> $s4

    # p2
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 010         # $t6 << 2                  ($t6 = 0 0 0 0 0 1 0 0)
    and $t6 $t2         # masking $t2 -> $t6        ($t6 = 0 0 0 0 0 p2 0 0)
    shr $t6 010         # $t6 >> 2                  ($t6 = 0 0 0 0 0 0 0 p2)
    xor $s3 $t6         # p012  b            -> $s3
    xor $s5 $t6         # p  2  b            -> $s5

    # b1
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 011         # $t6 << 3                  ($t6 = 0 0 0 0 1 0 0 0)
    and $t6 $t2         # masking $t2 -> $t6        ($t6 = 0 0 0 0 b1 0 0 0)
    shr $t6 011         # $t6 >> 3                  ($t6 = 0 0 0 0 0 0 0 b1)
    xor $s3 $t6         # p012  b1           -> $s3
    xor $s4 $t6         # p 1   b1           -> $s4
    xor $s5 $t6         # p  2  b1           -> $s5
 
    # p4
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 100         # $t6 << 4                  ($t6 = 0 0 0 1 0 0 0 0)
    and $t6 $t2         # masking $t2 -> $t6        ($t6 = 0 0 0 p4 0 0 0 0)
    shr $t6 100         # $t6 >> 4                  ($t6 = 0 0 0 0 0 0 0 p4)
    xor $s3 $t6         # p0124 b1           -> $s3
    xor $s6 $t6         # p   4 b            -> $s6

    # b2
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 101         # $t6 << 5                  ($t6 = 0 0 1 0 0 0 0 0)
    and $t6 $t2         # masking $t2 -> $t6        ($t6 = 0 0 b2 0 0 0 0 0)
    shr $t6 101         # $t6 >> 5                  ($t6 = 0 0 0 0 0 0 0 b2)
    xor $s3 $t6         # p0124 b12          -> $s3
    xor $s4 $t6         # p 1   b12          -> $s4
    xor $s6 $t6         # p   4 b 2          -> $s6

    # b3
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 110         # $t6 << 6                  ($t6 = 0 1 0 0 0 0 0 0)
    and $t6 $t2         # masking $t2 -> $t6        ($t6 = 0 b3 0 0 0 0 0 0)
    shr $t6 110         # $t6 >> 6                  ($t6 = 0 0 0 0 0 0 0 b3)
    xor $s3 $t6         # p0124 b123         -> $s3
    xor $s5 $t6         # p  2  b1 3         -> $s5
    xor $s6 $t6         # p   4 b 23         -> $s6

    # b4
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 111         # $t6 << 7                  ($t6 = 1 0 0 0 0 0 0 0)
    and $t6 $t2         # masking $t2 -> $t6        ($t6 = b4 0 0 0 0 0 0 0)
    shr $t6 111         # $t6 >> 7                  ($t6 = 0 0 0 0 0 0 0 b4)
    xor $s3 $t6         # p0124 b1234        -> $s3
    xor $s4 $t6         # p 1   b12 4        -> $s4
    xor $s5 $t6         # p  2  b1 34        -> $s5
    xor $s6 $t6         # p   4 b 234        -> $s6

    # reset
    and $t3 $t4         # reset $t3                 ($t3 = 0)
    and $t6 $t4         # reset $t6                 ($t6 = 0)
    and $t7 $t4         # reset $t7                 ($t7 = 0)

# CALCULATE PARITY BITS FROM ODDth MEMORY
    # value_of_odd_MEM(++$s1) -> tmp7 -> tmp3 
    inc $s1 001         # $s1 += 1
    lw  $s1             # load data MEM -> $t7      ($t7 = bB bA b9 b8 b7 b6 b5 p8)
    xor $t3 $t7         # move $t7 -> $t3           ($t3 = bB bA b9 b8 b7 b6 b5 p8)

    # p8
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    and $t6 $t3         # masking $t3 -> $t6        ($t6 = 0 0 0 0 0 0 0 p8)
    xor $s3 $t6         # p01248b1234        -> $s3
    xor $s7 $t6         # p    8             -> $s7

    # b5
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 $t6         # $t6 << 1                  ($t6 = 0 0 0 0 0 0 1 0)
    and $t6 $t3         # masking $t3 -> $t6        ($t6 = 0 0 0 0 0 0 b5 0)
    shr $t6 $t6         # $t6 >> 1                  ($t6 = 0 0 0 0 0 0 0 b5)
    xor $s3 $t6         # p01248b12345       -> $s3
    xor $s4 $t6         # p 1   b12 45       -> $s4
    xor $s7 $t6         # p    8b    5       -> $s7

    # b6
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 010         # $t6 << 2                  ($t6 = 0 0 0 0 0 1 0 0)
    and $t6 $t3         # masking $t3 -> $t6        ($t6 = 0 0 0 0 0 b6 0 0)
    shr $t6 010         # $t6 >> 2                  ($t6 = 0 0 0 0 0 0 0 b6)
    xor $s3 $t6         # p01248b123456      -> $s3
    xor $s5 $t6         # p  2  b1 34 6      -> $s5
    xor $s7 $t6         # p    8b    56      -> $s7

    # b7
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 011         # $t6 << 3                  ($t6 = 0 0 0 0 1 0 0 0)
    and $t6 $t3         # masking $t3 -> $t6        ($t6 = 0 0 0 0 b7 0 0 0)
    shr $t6 011         # $t6 >> 3                  ($t6 = 0 0 0 0 0 0 0 b7)
    xor $s3 $t6         # p01248b1234567     -> $s3
    xor $s4 $t6         # p 1   b12 45 7     -> $s4
    xor $s5 $t6         # p  2  b1 34 67     -> $s5
    xor $s7 $t6         # p    8b    567     -> $s7

    # b8
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 100         # $t6 << 4                  ($t6 = 0 0 0 1 0 0 0 0)
    and $t6 $t3         # masking $t3 -> $t6        ($t6 = 0 0 0 b8 0 0 0 0)
    shr $t6 100         # $t6 >> 4                  ($t6 = 0 0 0 0 0 0 0 b8)
    xor $s3 $t6         # p01248b12345678    -> $s3
    xor $s6 $t6         # p   4 b 234   8    -> $s6
    xor $s7 $t6         # p    8b    5678    -> $s7

    # b9
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 101         # $t6 << 5                  ($t6 = 0 0 1 0 0 0 0 0)
    and $t6 $t3         # masking $t3 -> $t6        ($t6 = 0 0 b9 0 0 0 0 0)
    shr $t6 101         # $t6 >> 5                  ($t6 = 0 0 0 0 0 0 0 b9)
    xor $s3 $t6         # p01248b123456789   -> $s3
    xor $s4 $t6         # p 1   b12 45 7 9   -> $s4
    xor $s6 $t6         # p   4 b 234   89   -> $s6
    xor $s7 $t6         # p    8b    56789   -> $s7

    # bA
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 110         # $t6 << 6                  ($t6 = 0 1 0 0 0 0 0 0)
    and $t6 $t3         # masking $t3 -> $t6        ($t6 = 0 bA 0 0 0 0 0 0)
    shr $t6 110         # $t6 >> 6                  ($t6 = 0 0 0 0 0 0 0 bA)
    xor $s3 $t6         # p01248b123456789A  -> $s3
    xor $s5 $t6         # p  2  b1 34 67  A  -> $s5
    xor $s6 $t6         # p   4 b 234   89A  -> $s6
    xor $s7 $t6         # p    8b    56789A  -> $s7

    # bB
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 111         # $t6 << 7                  ($t6 = 1 0 0 0 0 0 0 0)
    and $t6 $t3         # masking $t3 -> $t6        ($t6 = bB 0 0 0 0 0 0 0)
    shr $t6 111         # $t6 >> 7                  ($t6 = 0 0 0 0 0 0 0 bB)
    xor $s3 $t6         # p01248b123456789AB -> $s3
    xor $s4 $t6         # p1    b12 45 7 9 B -> $s4
    xor $s5 $t6         # p2    b1 34 67  AB -> $s5
    xor $s6 $t6         # p4    b 234   89AB -> $s6
    xor $s7 $t6         # p8    b    56789AB  -> $s7

    # reset $t6
    and $t0 $t4         # reset $t0                 ($t0 = 0)
    and $t1 $t4         # reset $t1                 ($t1 = 0)
    and $t6 $t4         # reset $t6                 ($t6 = 0)
    and $t7 $t4         # reset $t7                 ($t7 = 0) 

# CASE BY CASE
    # bad - 1 BIT ERROR -> insert01
    # bad - MORE 2 BITS ERRORS -> insert10
    # good case NO ERROR -> insert00

    # To be good case                45673 eftoz
    # every validity_paritiy bit is supposed to Zero !!
    # Unless it is zero, that is false.
    # false -> not equals zero -> jump

# GO 1 BIT ERROR CASE
    # check $s3 validity_parity0 
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s3         # $s3 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez yesRecover     # IF 3 == F -> GO           // ????F (16 yesRecover cases)    
    # now every case in here -> ????T

# GO MORE 2 BITS ERRORS
    # check $s7 validity_parity8 
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s7         # $s7 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez noRecover      # IF 7 == F -> GO           // F???T (8 noRecover cases)
    # now every case in here -> T???T

    # check $s6 validity_parity4 
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s6         # $s6 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez noRecover      # IF 6 == F -> GO           // TF??T (4 noRecover cases)
    # now every case in here -> TT??T

    # check $s5 validity_parity2 
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s5         # $s5 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez noRecover      # IF 5 == F -> GO           // TTF?T (2 noRecover cases)
    # now every case in here -> TTT?T

    # check $s4 validity_parity1 
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s4         # $s4 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez noRecover      # IF 4 == F -> GO           // TTTFT (1 noRecover case)
    # now every case in here -> TTTTT               ($t5 = 0 0 0 0 0 0 0 0)

# GO GOOD CASE NO ERROR
    # TTTTT : the only good case (no errer)
<#
    # good case:   
    # insert00     # good case -> [29:0] 중 첫 두자리 넣기
    # ($t3 = bB bA b9 b8 b7 b6 b5 p8)
    # ($t2 = b4 b3 b2 p4 b1 p2 p1 p0)
    # wanted t1 = ( 0  0  0  0  0 bB bA b9)
    # wanted t0 = (b8 b7 b6 b5 b4 b3 b2 b1)
#>
    # 시작비트 0 0 -> mem[s1]
    # $t1 already 0 0 (as reset)

    # go to insetRestBits
    inc $t5 001         # $t5 != 0                  ($t5 = 0 0 0 0 0 0 0 1)
    bnez insetRestBits  # go to insetRestBits 

# bad - MORE 2 BITS ERRORS
noRecover:       
<#      
    # insert10     # bad case -> [29:0] 중 첫 두자리 넣기
    #            45673 eftoz 
    # ELSE                      TTTFT
    # ELSE                      TTF?T 
    # ELSE                      TF??T
    # ELSE                      F???T
    # ($t3 = bB bA b9 b8 b7 b6 b5 p8)
    # ($t2 = b4 b3 b2 p4 b1 p2 p1 p0)
    # no neeted t1 = ( 1  0  0  0  0 bB bA b9) -> only care first 1 bit.
    # no neeted t0 = (b8 b7 b6 b5 b4 b3 b2 b1) -> doesn't care at all.
    # directly put $t7 -> addr_MEM[0] ($s0) 
#> 
    # since it is from jump                         ($t5 = 0 0 0 0 0 0 0 1)
    # 시작비트 1 0 -> mem[s1] (Don't care rest -> 바로 MEM으로 넣어버리기)
    inc $t6 001         # $t6 = 1                   ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 111         # $t6 << 7                  ($t6 = 1 0 0 0 0 0 0 0) 
    xor $t7 $t6         # move $t6 -> $t7           ($t7 = 1 0 0 0 0 0 0 0) 
    # Don't care rest of all $s0 bits and even-th $s0 (skipped) !!!
    inc $s0 001         # $s0 += 1 (even -> odd)    
    sw  $s0             # store data $t7 -> MEM (only 1 0 . . . . . .)

    # Don't care rest of all $s0 bits !!!
    # go to excapeLoop
    bnez excapeLoop     # go to excapeLoop 

# bad - 1 BIT ERROR (16 CASES)
yesRecover:             
<#
    # insert01          # bad case -> [29:0] 중 첫 두자리 넣기
    # recover ($t3 = bB bA b9 b8 b7 b6 b5 p8)
    # recover ($t2 = b4 b3 b2 p4 b1 p2 p1 p0)
    # wanted t1 = ( 0  1  0  0  0 bB bA b9)
    # wanted t0 = (b8 b7 b6 b5 b4 b3 b2 b1)
#>
    # 시작비트 0 1 -> $t1    
    inc $t6 001         # $t6 = 1                   ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t6 110         # $t6 << 6                  ($t6 = 0 1 0 0 0 0 0 0) 
    xor $t1 $t6         # move $t6 -> $t1           ($t1 = 0 1 0 0 0 0 0 0) 
    and $t6 $t4         # reset $t6                 ($t6 = 0) 

    # find sole error bit -> recover at addr_MEM[30] ($s1) 
    #                                         45673 eftoz 
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s7         # $s7 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez eIsFalse0      # IF 7 == F -> GO     T???F

    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s6         # $s6 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez fIsFalse0      # IF 6 == F -> GO     TT??F

    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s5         # $s5 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez tIsFalse0      # IF 5 == F -> GO     TTT?F

    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s4         # $s4 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez oIsFalse0      # IF 4 == F -> GO     TTTTF

# 1. TTTTF -> p0 : ~p0 at [59:30]
    # $t6 = 1 1 1 1 1 1 1 ~p0
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1)         
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 0 0 0 0 0 0 0 1)
    and $t6 $t2         # $t6 <- p0                 ($t6 = 0 0 0 0 0 0 0 p0)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = 1 1 1 1 1 1 1 ~p0)
    # ($t2 = b4 b3 b2 p4 b1 p2 p1 0) + 1
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 010         # $t5 += 2                  ($t5 = 1 1 1 1 1 1 1 0) 
    and $t2 $t5         # rest of $t2               ($t2 = b4 b3 b2 p4 b1 p2 p1 0)
    inc $t2 001         # $t2 += 1                  ($t2 = b4 b3 b2 p4 b1 p2 p1 1) 
    # $t2 = b4 b3 b2 p4 b1 p2 p1 ~p0   
    and $t2 $t6         # negation done             ($t2 = b4 b3 b2 p4 b1 p2 p1 ~p0)
    # go to rest of bit
    bnez insetRestBits

oIsFalse0: # TTTFF
# 2. TTTFF -> p1 : recover ~p1 at [59:30] 
    # $t6 = 1 1 1 1 1 1 ~p1 1
    inc $t6 010         # $t6 += 2                  ($t6 = 0 0 0 0 0 0 1 0)         
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 0 0 0 0 0 0 1 0)
    and $t6 $t2         # $t6 <- p1                 ($t6 = 0 0 0 0 0 0 p1 0)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = 1 1 1 1 1 1 ~p1 1)
    # ($t2 = b4 b3 b2 p4 b1 p2 0 p0) + 2
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 001         # $t5 += 1                  ($t5 = 1 1 1 1 1 1 0 1) 
    and $t2 $t5         # rest of $t2               ($t2 = b4 b3 b2 p4 b1 p2 0 p0)
    inc $t2 010         # $t2 += 2                  ($t2 = b4 b3 b2 p4 b1 p2 1 p0) 
    # $t2 = b4 b3 b2 p4 b1 p2 ~p1 p0    
    and $t2 $t6         # negation done             ($t2 = b4 b3 b2 p4 b1 p2 ~p1 p0)
    # go to rest of bit
    bnez insetRestBits

tIsFalse0: # TTF?F
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s4         # $s4 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez oIsFalse1      # IF 4 == F -> GO     TTFTF

# 3. TTFTF -> p2 : recover ~p2 at [59:30]
    # $t6 = 1 1 1 1 1 ~p2 1 1
    inc $t6 100         # $t6 += 4                  ($t6 = 0 0 0 0 0 1 0 0)         
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 0 0 0 0 0 1 0 0)
    and $t6 $t2         # $t6 <- p2                 ($t6 = 0 0 0 0 0 p2 0 0)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = 1 1 1 1 1 ~p2 1 1)
    # ($t2 = b4 b3 b2 p4 b1 0 p1 p0) + 4
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 110         # $t5 += 6                  ($t5 = 0 0 1 1 1 1 1 0) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 0 0 0) 
    inc $t5 011         # $t5 += 1                  ($t5 = 1 1 1 1 1 0 1 1) 
    and $t2 $t5         # rest of $t2               ($t2 = b4 b3 b2 p4 b1 0 p1 p0)
    inc $t2 100         # $t2 += 4                  ($t2 = b4 b3 b2 p4 b1 1 p1 p0) 
    # $t2 = b4 b3 b2 p4 b1 ~p2 p1 p0    
    and $t2 $t6         # negation done             ($t2 = b4 b3 b2 p4 b1 ~p2 p1 p0)
    # go to rest of bit
    bnez insetRestBits

oIsFalse1: # TTFFF
# 4. TTFFF -> b1 : recover ~b1 at [59:30]    
    # $t6 = 1 1 1 1 ~b1 1 1 1
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1)    
    shl $t6 011         # $t6 << 3                  ($t6 = 0 0 0 0 1 0 0 0)      
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 0 0 0 0 1 0 0 0)
    and $t6 $t2         # $t6 <- b1                 ($t6 = 0 0 0 0 b1 0 0 0)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = 1 1 1 1 ~b1 1 1 1)
    # ($t2 = b4 b3 b2 p4 0 p2 p1 p0) + 8
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 101         # $t5 += 5                  ($t5 = 0 0 1 1 1 1 0 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 0 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 0 1 1 1) 
    and $t2 $t5         # rest of $t2               ($t2 = b4 b3 b2 p4 0 p2 p1 p0)
    inc $t2 111         # $t2 += 7                  accumulated 7
    inc $t2 001         # $t2 += 1                  ($t2 = b4 b3 b2 p4 1 p2 p1 p0) 
    # $t2 = b4 b3 b2 p4 ~b1 p2 p1 p0    
    and $t2 $t6         # negation done             ($t2 = b4 b3 b2 p4 ~b1 p2 p1 p0)
    # go to rest of bit
    bnez insetRestBits

fIsFalse0: # TF??F
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s5         # $s5 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez tIsFalse1      # IF 5 == F -> GO     TFT?F

    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s4         # $s4 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez oIsFalse2      # IF 4 == F -> GO     TFTTF

# 5. TFTTF -> p4 : recover ~p4 at [59:30]
    # $t6 = 1 1 1 ~p4 1 1 1 1
    inc $t6 010         # $t6 += 2                  ($t6 = 0 0 0 0 0 0 1 0)               
    shl $t6 011         # $t6 << 3                  ($t6 = 0 0 0 1 0 0 0 0)    
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 0 0 0 1 0 0 0 0)
    and $t6 $t2         # $t6 <- p4                 ($t6 = 0 0 0 p4 0 0 0 0)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = 1 1 1 ~p4 1 1 1 1)
    # ($t2 = b4 b3 b2 0 b1 p2 p1 p0) + 16
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 0 0 1 1 1 0 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 0 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 0 1 1 1 1) 
    and $t2 $t5         # rest of $t2               ($t2 = b4 b3 b2 0 b1 p2 p1 p0)
    inc $t2 111         # $t2 += 7                  accumulated 7
    inc $t2 111         # $t2 += 7                  accumulated 14
    inc $t2 010         # $t2 += 2                  ($t2 = b4 b3 b2 1 b1 p2 p1 p0) 
    # $t2 = b4 b3 b2 ~p4 b1 p2 p1 p0    
    and $t2 $t6         # negation done             ($t2 = b4 b3 b2 ~p4 b1 p2 p1 p0)
    # go to rest of bit
    bnez insetRestBits

oIsFalse2: # TFTFF
# 6. TFTFF -> b2 : recover ~b2 at [59:30]
    # $t6 = 1 1 ~b2 1 1 1 1 1
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1)           
    shl $t6 101         # $t6 << 5                  ($t6 = 0 0 1 0 0 0 0 0)     
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 0 0 1 0 0 0 0 0)
    and $t6 $t2         # $t6 <- $t3                ($t6 = 0 0 b2 0 0 0 0 0)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = 1 1 ~b2 1 1 1 1 1)
    # ($t2 = b4 b3 0 p4 b1 p2 p1 p0) + 32
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 110         # $t5 += 6                  ($t5 = 0 0 0 0 0 1 1 0) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 0 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 0 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 0 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 0 1 1 1 1 1) 
    and $t2 $t5         # rest of $t2               ($t2 = b4 b3 0 p4 b1 p2 p1 p0)
    inc $t2 111         # $t2 += 7                  accumulated 7
    inc $t2 111         # $t2 += 7                  accumulated 14
    inc $t2 111         # $t2 += 7                  accumulated 21
    inc $t2 111         # $t2 += 7                  accumulated 28
    inc $t2 100         # $t2 += 4                  ($t2 = b4 b3 1 p4 b1 p2 p1 p0) 
    # $t2 = b4 b3 ~b2 p4 b1 p2 p1 p0    
    and $t2 $t6         # negation done             ($t2 = b4 b3 ~b2 p4 b1 p2 p1 p0)
    # go to rest of bit
    bnez insetRestBits

tIsFalse1: # TFF?F
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s4         # $s4 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez oIsFalse3      # IF 4 == F -> GO     TFFTF

# 7. TFFTF -> b3 : recover ~b3 at [59:30]
    # $t6 = 1 ~b3 1 1 1 1 1 1
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1)           
    shl $t6 110         # $t6 << 6                  ($t6 = 0 1 0 0 0 0 0 0)     
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 0 1 0 0 0 0 0 0)
    and $t6 $t2         # $t6 <- $t3                ($t6 = 0 b3 0 0 0 0 0 0)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = 1 ~b3 1 1 1 1 1 1)
    # ($t2 = b4 0 b2 p4 b1 p2 p1 p0) + 64
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 101         # $t5 += 5                  ($t5 = 0 0 0 0 0 1 0 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 0 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 0 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 0 1 1 1 1 0 0) 
    inc $t5 001         # $t5 += 1                  ($t5 = 1 0 1 1 1 1 1 1) 
    and $t2 $t5         # rest of $t2               ($t2 = b4 0 b2 p4 b1 p2 p1 p0)
    inc $t2 111         # $t2 += 7                  accumulated 7
    inc $t2 111         # $t2 += 7                  accumulated 14
    inc $t2 111         # $t2 += 7                  accumulated 21
    inc $t2 111         # $t2 += 7                  accumulated 28
    inc $t2 111         # $t2 += 7                  accumulated 35
    inc $t2 111         # $t2 += 7                  accumulated 42
    inc $t2 111         # $t2 += 7                  accumulated 49
    inc $t2 111         # $t2 += 7                  accumulated 56
    inc $t2 111         # $t2 += 7                  accumulated 63
    inc $t2 001         # $t2 += 1                  ($t2 = b4 1 b2 p4 b1 p2 p1 p0) 
    # $t2 = b4 ~b3 b2 p4 b1 p2 p1 p0    
    and $t2 $t6         # negation done             ($t2 = b4 ~b3 b2 p4 b1 p2 p1 p0)
    # go to rest of bit
    bnez insetRestBits

oIsFalse3: # TFFFF        
# 8. TFFFF -> b4 : recover ~b4 at [59:30]# $t6 = ~b4 1 1 1 1 1 1 1
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1)           
    shl $t6 111         # $t6 << 7                  ($t6 = 1 0 0 0 0 0 0 0)     
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 1 0 0 0 0 0 0 0)
    and $t6 $t2         # $t6 <- $t3                ($t6 = b4 0 0 0 0 0 0 0)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 001         # $t5 << 1                  ($t5 = 0 1 1 1 1 1 1 0) 
    inc $t5 001         # $t5 += 1                  ($t5 = 0 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = ~b4 1 1 1 1 1 1 1)
    # ($t2 = 0 b3 b2 p4 b1 p2 p1 p0) + 128
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 001         # $t5 << 1                  ($t5 = 0 1 1 1 1 1 1 0) 
    inc $t5 001         # $t5 += 1                  ($t5 = 0 1 1 1 1 1 1 1) 
    and $t2 $t5         # rest of $t2               ($t2 = 0 b3 b2 p4 b1 p2 p1 p0)
    inc $t2 111         # $t2 += 7                  accumulated 7
    inc $t2 111         # $t2 += 7                  accumulated 14
    inc $t2 111         # $t2 += 7                  accumulated 21
    inc $t2 111         # $t2 += 7                  accumulated 28
    inc $t2 111         # $t2 += 7                  accumulated 35
    inc $t2 111         # $t2 += 7                  accumulated 42
    inc $t2 111         # $t2 += 7                  accumulated 49
    inc $t2 111         # $t2 += 7                  accumulated 56
    inc $t2 111         # $t2 += 7                  accumulated 63
    inc $t2 111         # $t2 += 7                  accumulated 70
    inc $t2 111         # $t2 += 7                  accumulated 77
    inc $t2 111         # $t2 += 7                  accumulated 84
    inc $t2 111         # $t2 += 7                  accumulated 91
    inc $t2 111         # $t2 += 7                  accumulated 98
    inc $t2 111         # $t2 += 7                  accumulated 105
    inc $t2 111         # $t2 += 7                  accumulated 112
    inc $t2 111         # $t2 += 7                  accumulated 119
    inc $t2 111         # $t2 += 7                  accumulated 126
    inc $t2 010         # $t2 += 2                  ($t2 = 1 b3 b2 p4 b1 p2 p1 p0) 
    # $t2 = ~b4 b3 b2 p4 b1 p2 p1 p0    
    and $t2 $t6         # negation done             ($t2 = ~b4 b3 b2 p4 b1 p2 p1 p0)
    # go to rest of bit
    bnez insetRestBits

eIsFalse0: # F???F
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s6         # $s6 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez fIsFalse1      # IF 6 == F -> GO     FT??F

    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s5         # $s5 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez tIsFalse2      # IF 5 == F -> GO     FTT?F

    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s4         # $s4 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez oIsFalse4      # IF 4 == F -> GO     FTTTF

# 9. FTTTF -> p8 : recover ~p8 at [59:30]
    # $t6 = 1 1 1 1 1 1 1 ~p8
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1)         
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 0 0 0 0 0 0 0 1)
    and $t6 $t3         # $t6 <- p8                 ($t6 = 0 0 0 0 0 0 0 p8)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = 1 1 1 1 1 1 1 ~p8)
    # ($t3 = bB bA b9 b8 b7 b6 b5 0) + 1
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 010         # $t5 += 2                  ($t5 = 1 1 1 1 1 1 1 0) 
    and $t3 $t5         # rest of $t3               ($t3 = bB bA b9 b8 b7 b6 b5 0)
    inc $t3 001         # $t3 += 1                  ($t3 = bB bA b9 b8 b7 b6 b5 1) 
    # $t3 = bB bA b9 b8 b7 b6 b5 ~p8  
    and $t3 $t6         # negation done             ($t3 = bB bA b9 b8 b7 b6 b5 ~p8)
    # go to rest of bit
    bnez insetRestBits

oIsFalse4: # FTTFF
# 10. FTTFF -> b5 : recover ~b5 at [59:30]
    # $t6 = 1 1 1 1 1 1 ~b5 1
    inc $t6 010         # $t6 += 2                  ($t6 = 0 0 0 0 0 0 1 0)         
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 0 0 0 0 0 0 1 0)
    and $t6 $t3         # $t6 <- b5                 ($t6 = 0 0 0 0 0 0 b5 0)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = 1 1 1 1 1 1 ~b5 1)
    # ($t3 = bB bA b9 b8 b7 b6 0 p8) + 2
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 001         # $t5 += 1                  ($t5 = 1 1 1 1 1 1 0 1) 
    and $t3 $t5         # rest of $t3               ($t3 = bB bA b9 b8 b7 b6 0 p8)
    inc $t3 010         # $t3 += 2                  ($t3 = bB bA b9 b8 b7 b6 1 p8) 
    # $t3 = bB bA b9 b8 b7 b6 ~b5 p8    
    and $t3 $t6         # negation done             ($t3 = bB bA b9 b8 b7 b6 ~b5 p8)
    # go to rest of bit
    bnez insetRestBits

tIsFalse2:                       FTF?F
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s4         # $s4 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez oIsFalse5      # IF 4 == F -> GO     FTFTF

# 11. FTFTF -> b6 : recover ~b6 at [59:30]
    # $t6 = 1 1 1 1 1 ~b6 1 1
    inc $t6 100         # $t6 += 4                  ($t6 = 0 0 0 0 0 1 0 0)         
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 0 0 0 0 0 1 0 0)
    and $t6 $t3         # $t6 <- b6                 ($t6 = 0 0 0 0 0 b6 0 0)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = 1 1 1 1 1 ~b6 1 1)
    # ($t3 = bB bA b9 b8 b7 0 b5 p8) + 4
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 110         # $t5 += 6                  ($t5 = 0 0 1 1 1 1 1 0) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 0 0 0) 
    inc $t5 011         # $t5 += 1                  ($t5 = 1 1 1 1 1 0 1 1) 
    and $t3 $t5         # rest of $t3               ($t3 = bB bA b9 b8 b7 0 b5 p8)
    inc $t3 100         # $t3 += 4                  ($t3 = bB bA b9 b8 b7 1 b5 p8) 
    # $t3 = bB bA b9 b8 b7 ~b6 b5 p8    
    and $t3 $t6         # negation done             ($t3 = bB bA b9 b8 b7 ~b6 b5 p8)
    # go to rest of bit
    bnez insetRestBits

oIsFalse5: # FTFFF
# 12. FTFFF -> b7 : recover ~b7 at [59:30]
    # $t6 = 1 1 1 1 ~b7 1 1 1
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1)    
    shl $t6 011         # $t6 << 3                  ($t6 = 0 0 0 0 1 0 0 0)      
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 0 0 0 0 1 0 0 0)
    and $t6 $t3         # $t6 <- b7                 ($t6 = 0 0 0 0 b7 0 0 0)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = 1 1 1 1 ~b7 1 1 1)
    # ($t3 = bB bA b9 b8 0 b6 b5 p8) + 8
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 101         # $t5 += 5                  ($t5 = 0 0 1 1 1 1 0 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 0 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 0 1 1 1) 
    and $t3 $t5         # rest of $t3               ($t3 = bB bA b9 b8 0 b6 b5 p8)
    inc $t3 111         # $t3 += 7                  accumulated 7
    inc $t3 001         # $t3 += 1                  ($t3 = bB bA b9 b8 1 b6 b5 p8) 
    # $t3 = bB bA b9 b8 ~b7 b6 b5 p8    
    and $t3 $t6         # negation done             ($t3 = bB bA b9 b8 ~b7 b6 b5 p8)
    # go to rest of bit
    bnez insetRestBits

fIsFalse1: # FF??F
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s5         # $s5 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez tIsFalse3      # IF 5 == F -> GO     FFT?F

    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s4         # $s4 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez oIsFalse6      # IF 4 == F -> GO     FFTTF

# 13. FFTTF -> b8 : recover ~b8 at [59:30]
    # $t6 = 1 1 1 ~b8 1 1 1 1
    inc $t6 010         # $t6 += 2                  ($t6 = 0 0 0 0 0 0 1 0)               
    shl $t6 011         # $t6 << 3                  ($t6 = 0 0 0 1 0 0 0 0)    
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 0 0 0 1 0 0 0 0)
    and $t6 $t3         # $t6 <- b8                 ($t6 = 0 0 0 b8 0 0 0 0)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = 1 1 1 ~b8 1 1 1 1)
    # ($t3 = bB bA b9 0 b7 b6 b5 p8) + 16
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 0 0 1 1 1 0 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 0 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 0 1 1 1 1) 
    and $t3 $t5         # rest of $t3               ($t3 = bB bA b9 0 b7 b6 b5 p8)
    inc $t3 111         # $t3 += 7                  accumulated 7
    inc $t3 111         # $t3 += 7                  accumulated 14
    inc $t3 010         # $t3 += 2                  ($t3 = bB bA b9 1 b7 b6 b5 p8) 
    # $t3 = bB bA b9 ~b8 b7 b6 b5 p8    
    and $t3 $t6         # negation done             ($t3 = bB bA b9 ~b8 b7 b6 b5 p8)
    # go to rest of bit
    bnez insetRestBits

oIsFalse6: # FFTFF
# 14. FFTFF -> b9 : recover ~b9 at [59:30]
    # $t6 = 1 1 ~b9 1 1 1 1 1
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1)           
    shl $t6 101         # $t6 << 5                  ($t6 = 0 0 1 0 0 0 0 0)     
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 0 0 1 0 0 0 0 0)
    and $t6 $t3         # $t6 <- $t3                ($t6 = 0 0 b9 0 0 0 0 0)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = 1 1 ~b9 1 1 1 1 1)
    # ($t3 = bB bA 0 b8 b7 b6 b5 p8) + 32
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 110         # $t5 += 6                  ($t5 = 0 0 0 0 0 1 1 0) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 0 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 0 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 0 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 0 1 1 1 1 1) 
    and $t3 $t5         # rest of $t3               ($t3 = bB bA 0 b8 b7 b6 b5 p8)
    inc $t3 111         # $t3 += 7                  accumulated 7
    inc $t3 111         # $t3 += 7                  accumulated 14
    inc $t3 111         # $t3 += 7                  accumulated 21
    inc $t3 111         # $t3 += 7                  accumulated 28
    inc $t3 100         # $t3 += 4                  ($t3 = bB bA 1 b8 b7 b6 b5 p8) 
    # $t3 = bB bA ~b9 b8 b7 b6 b5 p8    
    and $t3 $t6         # negation done             ($t3 = bB bA ~b9 b8 b7 b6 b5 p8)
    # go to rest of bit
    bnez insetRestBits

tIsFalse3: # FFF?F
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 001         # masking bit               ($t5 = 0 0 0 0 0 0 0 1)
    and $t5 $s4         # $s4 0 digit -> $t5        ($t5 = 0 0 0 0 0 0 0 ?)
    bnez IsFalse7       # IF 4 == F -> GO     FFFTF

# 15. FFFTF -> bA : recover ~bA at [59:30]
    # $t6 = 1 ~bA 1 1 1 1 1 1
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1)           
    shl $t6 110         # $t6 << 6                  ($t6 = 0 1 0 0 0 0 0 0)     
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 0 1 0 0 0 0 0 0)
    and $t6 $t3         # $t6 <- $t3                ($t6 = 0 bA 0 0 0 0 0 0)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 1 1 1 1 1 0 0) 
    inc $t5 011         # $t5 += 3                  ($t5 = 1 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = 1 ~bA 1 1 1 1 1 1)
    # ($t3 = bB 0 b9 b8 b7 b6 b5 p8) + 64
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 101         # $t5 += 5                  ($t5 = 0 0 0 0 0 1 0 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 0 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 0 1 1 1 1) 
    shl $t5 010         # $t5 << 2                  ($t5 = 1 0 1 1 1 1 0 0) 
    inc $t5 001         # $t5 += 1                  ($t5 = 1 0 1 1 1 1 1 1) 
    and $t3 $t5         # rest of $t3               ($t3 = bB 0 b9 b8 b7 b6 b5 p8)
    inc $t3 111         # $t3 += 7                  accumulated 7
    inc $t3 111         # $t3 += 7                  accumulated 14
    inc $t3 111         # $t3 += 7                  accumulated 21
    inc $t3 111         # $t3 += 7                  accumulated 28
    inc $t3 111         # $t3 += 7                  accumulated 35
    inc $t3 111         # $t3 += 7                  accumulated 42
    inc $t3 111         # $t3 += 7                  accumulated 49
    inc $t3 111         # $t3 += 7                  accumulated 56
    inc $t3 111         # $t3 += 7                  accumulated 63
    inc $t3 001         # $t3 += 1                  ($t3 = bB 1 b9 b8 b7 b6 b5 p8) 
    # $t3 = bB ~bA b9 b8 b7 b6 b5 p8    
    and $t3 $t6         # negation done             ($t3 = bB ~bA b9 b8 b7 b6 b5 p8)
    # go to rest of bit
    bnez insetRestBits

oIsFalse7: # FFFFF
# 16. FFFFF -> bB : recover ~bB at [59:30] 
    # $t6 = ~bB 1 1 1 1 1 1 1
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 0 0 0 1)           
    shl $t6 111         # $t6 << 7                  ($t6 = 1 0 0 0 0 0 0 0)     
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    xor $t5 $t6         # $t5 <- $t6                ($t5 = 1 0 0 0 0 0 0 0)
    and $t6 $t3         # $t6 <- $t3                ($t6 = bB 0 0 0 0 0 0 0)   
    and $t5 $t4         # reset $t5                 ($t5 = 0)  
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 001         # $t5 << 1                  ($t5 = 0 1 1 1 1 1 1 0) 
    inc $t5 001         # $t5 += 1                  ($t5 = 0 1 1 1 1 1 1 1) 
    xor $t6 $t5         # nagation $t6              ($t6 = ~bB 1 1 1 1 1 1 1)
    # ($t3 = 0 bA b9 b8 b7 b6 b5 p8) + 128
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 0 0 0 1 1 1) 
    shl $t5 011         # $t5 << 3                  ($t5 = 0 0 1 1 1 0 0 0) 
    inc $t5 111         # $t5 += 7                  ($t5 = 0 0 1 1 1 1 1 1) 
    shl $t5 001         # $t5 << 1                  ($t5 = 0 1 1 1 1 1 1 0) 
    inc $t5 001         # $t5 += 1                  ($t5 = 0 1 1 1 1 1 1 1) 
    and $t3 $t5         # rest of $t3               ($t3 = 0 bA b9 b8 b7 b6 b5 p8)
    inc $t3 111         # $t3 += 7                  accumulated 7
    inc $t3 111         # $t3 += 7                  accumulated 14
    inc $t3 111         # $t3 += 7                  accumulated 21
    inc $t3 111         # $t3 += 7                  accumulated 28
    inc $t3 111         # $t3 += 7                  accumulated 35
    inc $t3 111         # $t3 += 7                  accumulated 42
    inc $t3 111         # $t3 += 7                  accumulated 49
    inc $t3 111         # $t3 += 7                  accumulated 56
    inc $t3 111         # $t3 += 7                  accumulated 63
    inc $t3 111         # $t3 += 7                  accumulated 70
    inc $t3 111         # $t3 += 7                  accumulated 77
    inc $t3 111         # $t3 += 7                  accumulated 84
    inc $t3 111         # $t3 += 7                  accumulated 91
    inc $t3 111         # $t3 += 7                  accumulated 98
    inc $t3 111         # $t3 += 7                  accumulated 105
    inc $t3 111         # $t3 += 7                  accumulated 112
    inc $t3 111         # $t3 += 7                  accumulated 119
    inc $t3 111         # $t3 += 7                  accumulated 126
    inc $t3 010         # $t3 += 2                  ($t3 = 1 bA b9 b8 b7 b6 b5 p8) 
    # $t3 = ~bB bA b9 b8 b7 b6 b5 p8    
    and $t3 $t6         # negation done             ($t3 = ~bB bA b9 b8 b7 b6 b5 p8)
    # go to rest of bit
    bnez insetRestBits

# INSERT REST OF BITS
insetRestBits:#[29:0] 중 첫 두자리 제외하고 복원된 데이터로 나머지 넣기
    # insert rest of bit
    # ($t3 = bB bA b9 b8 b7 b6 b5 p8)
    # ($t2 = b4 b3 b2 p4 b1 p2 p1 p0)
    # ($t1 = 0 1 0 0 0 0 0 0) 
    # ($t0 = 0) 
    # wanted t1 = ( 0  1  0  0  0 bB bA b9)
    # wanted t0 = (b8 b7 b6 b5 b4 b3 b2 b1)

    # t0,t1 완성후 s0으로 넣기
    # t3 -> 3개 뽑아 t1 제작 
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 111         # $t6 += 7                  ($t6 = 0 0 0 0 0 1 1 1) 
    shl $t6 101         # $t6 << 5                  ($t6 = 1 1 1 0 0 0 0 0) 
    and $t6 $t3         # masking $t3 -> $t6        ($t6 = bB bA b9 0 0 0 0 0)
    shr $t6 101         # $t6 >> 5                  ($t6 = 0 0 0 0 0 bB bA b9) 
    xor $t1 $t6         # move $t6 -> $t1           ($t1 = 0 0 0 0 0 bB bA b9) 

    # t3 -> 4개 뽑아 t0 일부제작 
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 111         # $t6 += 7                  ($t6 = 0 0 0 0 0 1 1 1)
    shl $t6 $t6         # $t6 << 1                  ($t6 = 0 0 0 0 1 1 1 0)  
    inc $t6 001         # $t6 += 1                  ($t6 = 0 0 0 0 1 1 1 1)  
    shl $t6 $t6         # $t6 << 1                  ($t6 = 0 0 0 1 1 1 1 0)   
    and $t6 $t3         # masking $t3 -> $t6        ($t6 = 0 0 0 b8 b7 b6 b5 0)
    shl $t6 011         # $t6 << 3                  ($t6 = b8 b7 b6 b5 0 0 0 0) 
    xor $t0 $t6         # move $t6 -> $t0           ($t0 = b8 b7 b6 b5 0 0 0 0) 

    # t2 -> 4개 뽑아 t0 완성
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    inc $t6 111         # $t6 += 7                  ($t6 = 0 0 0 0 0 1 1 1)
    shl $t6 101         # $t6 << 5                  ($t6 = 1 1 1 0 0 0 0 0)   
    and $t6 $t2         # masking $t2 -> $t6        ($t6 = b4 b3 b2 0 0 0 0 0)
    inc $t7 001         # $t7 += 1                  ($t6 = 0 0 0 0 0 0 0 1) 
    shl $t7 011         # $t7 << 3                  ($t7 = 0 0 0 0 1 0 0 0)
    and $t7 $t2         # masking $t2 -> $t7        ($t7 = 0 0 0 0 b1 0 0 0)
    shl $t7 $t7         # $t7 << 1                  ($t7 = 0 0 0 b1 0 0 0 0)
    xor $t6 $t7         # move $t7 -> $t6           ($t6 = b4 b3 b2 b1 0 0 0 0)
    shr $t6 100         # $t6 >> 4                  ($t6 = 0 0 0 0 b4 b3 b2 b1)
    xor $t0 $t6         # move $t6 -> $t0           ($t0 = b8 b7 b6 b5 b4 b3 b2 b1) 
 
    # t0 -> mem[s0] // even
    and $t7 $t4         # reset $t7                 ($t7 = 0)
    xor $t7 $t0         # move $t0 -> $t7           ($t7 = b8 b7 b6 b5 b4 b3 b2 b1) 
    sw  $s0
    inc $s0 001         # $s0 += 1
 
    # t1 -> mem[s0] // odd
    and $t7 $t4         # reset $t7                 ($t7 = 0)
    xor $t7 $t1         # move $t1 -> $t7           ($t7 = 0 0 0 0 0 bB bA b9) 
    sw  $s0

# ESCAPE LOOP
excapeLoop:
    # check escape loop
    and $t6 $t4         # reset $t6                 ($t6 = 0) 
    xor $t6 $s0         # move $s0 -> $t6           ($t6 = addr_MEM[0]) 
    xor $t6 $s2         # $t6 ^= $s2                // addr_MEM[0]^59 == 0 ?
    inc $s0 001         # $s0 += 1
    inc $s1 001         # $s1 += 1
    and $t5 $t4         # reset $t5                 ($t5 = 0)
    xor $t5 $t6         # move $t6 -> $t5
    bnez loop    

exit:
    li $v0, 10         # exit program syscall         # 10
    syscall 