<#
[tmp reg (8bits)]   
$t0 000 val_MEM[$s0/ += 1]    (for half 31:0)                
$t1 001 val_MEM[$s0]  (for full 30:0 and 31)    
$t2 010 
$t3 011 
$t4 100 zero
$t5 101 tmp_bit               
$t6 110 tmp_exe                   
$t7 111 tmp_val                   

[save reg (8bits)]
$s0 000 addr_MEM[0]       
$s1 001 pattern
$s2 010 dx31
$s3 011 mem[33] (~128)
$s4 100 mem[34] (~32)
$s5 101 mem[35] (~252)
$s6 110 tmp[34] (0000~1111)
$s7 111

[cmd]
0 000 lw addr_MEM[0:59] (load word to $t7 from MEM[])
1 001 sw addr_MEM[0:59] (save word to MEM[] from $t7)
2 010 bnez addr_cmd     ($t5's LSB != 0 then go cmd)
3 011 xor $rd $rs       ($rd ^= $rs) 
4 100 inc $rd [7:0]     ($rd += 1)
5 101 shl $rd [7:0]     ($rd << [7:0])
6 110 shr $rd [7:0]     ($rd >> [7:0])
7 111 and $rd $rs       ($rd &= $rs)

#>

# [program 3] 
.data
    origin:  .word  29:0         # MEM[29:0]
    w_parity: .word 59:30        # MEM[59:30]

.text
.globl main

# bring pattern from MEM[32] [7:3]
# (- 7 6 5 4 3 - -)
# MEM[0:31] 패턴 분석 -> 4번씩 확인     v:누산  #: 중 1개만 인정          33(~128) 34(~32) 35(~252)
# loop:
# mem[0] (0_8 0_7 0_6 0_5 0_4 0_3 0_2 0_1) 
#                                        -> 0_8 0_7 0_6 0_5 0_4           v1        1         v1 
#                                        -> 0_7 0_6 0_5 0_4 0_3           v2        1         v2
#                                        -> 0_6 0_5 0_4 0_3 0_2           v3        1         v3
#                                        -> 0_5 0_4 0_3 0_2 0_1           v4        1         v4
#        (0_4 0_3 0_2 0_1 1_8 1_7 1_6 1_5) 
#                                        -> 0_4 0_3 0_2 0_1 1_8                               v5
#                                        -> 0_3 0_2 0_1 1_8 1_7                               v6
#                                        -> 0_2 0_1 1_8 1_7 1_6                               v7
#                                        -> 0_1 1_8 1_7 1_6 1_5                               v8
# mem[1] (1_8 1_7 1_6 1_5 1_4 1_3 1_2 1_1) 
#                                        -> 1_8 1_7 1_6 1_5 1_4           v5        2         v9
#                                        -> 1_7 1_6 1_5 1_4 1_3           v6        2         v10
#
#                  ...                             ...                                ...
#
#
#        (30_4 30_3 30_2 30_1 31_8 31_7 31_6 31_5)
#                       -> 30_4 30_3 30_2 30_1 31_8                        v245
#                               -> 30_3 30_2 30_1 31_8 31_7                        v246
#                               -> 30_2 30_1 31_8 31_7 31_6                        v247
#                               -> 30_1 31_8 31_7 31_6 31_5                        v248
# <loop end>
# 
# mem[31] (31_8 31_7 31_6 31_5 31_4 31_3 31_2 31_1) 
#                        -> 31_8 31_7 31_6 31_5 31_4      v125      32        v249
#                                -> 31_7 31_6 31_5 31_4 31_3      v126      32        v250
#                                -> 31_6 31_5 31_4 31_3 31_2      v127      32        v251
#                                -> 31_5 31_4 31_3 31_2 31_1      v128      32        v252

main:
    # initiate input data(pattern) address
    inc $s0 001         # $s0 += 1  ($s0 = 1)   ($s0 = 0 0 0 0 0 0 0 1)
    shl $s0 101         # $s0 << 5  ($s0 = 32)  ($s0 = 0 0 1 0 0 0 0 0)

    # escaping iteration data($s2)
    inc $s2 111         # $s2 += 7  ($s2 = 7)   ($s2 = 0 0 0 0 0 1 1 1)
    shl $s2 010         # $s2 << 2  ($s2 = 28)  ($s2 = 0 0 0 1 1 1 0 0)
    inc $s2 011         # $s2 += 3  ($s2 = 31)  ($s2 = 0 0 0 1 1 1 1 1)
    
    # bring the pattern
    lw  $s0             # load data MEM -> $t7  ($t7 =  b8 b7 b6 b5 b4 b3 b2 b1) : MEM[32]
    shl $t7 001         # $s7 << 1              ($t7 =  b7 b6 b5 b4 b3 b2 b1 0)
    shr $t7 011         # $s7 >> 3              ($t7 =  0 0 0 b7 b6 b5 b4 b3)
    and $s1 $t7         # $s1 <- $t7            ($s1 =  0 0 0 b7 b6 b5 b4 b3) : pattern
    and $s0 $t4         # $s0 reset             ($s0 = 0 0 0 0 0 0 0 0)
    

loop:
    # reset
    and $t0 $t4         # reset $t0 ($t0 = 0 0 0 0 0 0 0 0)
    and $t1 $t4         # reset $t1 ($t0 = 0 0 0 0 0 0 0 0)
    and $t5 $t4         # reset $t5 ($t5 = 0 0 0 0 0 0 0 0)
    and $t7 $t4         # reset $t7 ($t7 = 0 0 0 0 0 0 0 0)

    # value_of_full_MEM($s0) -> tmp7 -> tmp0 
    lw  $s0             # load data MEM -> $t7  ($t7 = b8 b7 b6 b5 b4 b3 b2 b1)
    xor $t0 $t7         # move $t7 -> $t0       ($t0 = b8 b7 b6 b5 b4 b3 b2 b1)

    # value_of_half_MEM($s0/) -> /tmp7 -> tmp1 
    shl $t7 100         # $s7 << 4              ($t7 = b4 b3 b2 b1 0 0 0 0)
    xor $t1 $t7         # move $t7 -> $t1       ($t1 = b4 b3 b2 b1 0 0 0 0)

    # value_of_half_MEM(/ += 1) -> tmp7/ -> tmp1
    inc $s0 001         # $s0 += 1
    lw  $s0             # load data MEM -> $t7  ($t7 = b8 b7 b6 b5 b4 b3 b2 b1)
    shr $t7 100         # $s7 >> 4              ($t7 = 0 0 0 0 b8 b7 b6 b5)
    xor $t1 $t7         # move $t7 -> $t1       ($t1 = b4 b3 b2 b1 b8 b7 b6 b5)

  # $s0 count -> $s3 mem[33] (~128)
  #           -> $s6 tmp[34] -> $s4 mem[34] (~32)
  #           -> $s5 mem[35] (~252)

# [$s0 count -> $s3 mem[33] (~128)]             ($t0 = b8 b7 b6 b5 b4 b3 b2 b1)
# CHECK 0 0 0 b5 b4 b3 b2 b1
    xor $t5 $t0         # move $t0 -> $t5       ($t5 = b8 b7 b6 b5 b4 b3 b2 b1)
    shl $t5 011         # $t5 << 3              ($t5 = b5 b4 b3 b2 b1 0 0 0)
    shr $t5 011         # $t5 >> 3              ($t5 = 0 0 0 b5 b4 b3 b2 b1) 
    xor $t5 $s1         # if $t5 == $s1 -> 0    ($t5 = 0 0 0 ? ? ? ? ?)
    bnez skip1          
    #  $t5 == $s1 -> 0  # found the pattern
    inc $s3 001          # $s3 += 1
    inc $s5 001          # $s5 += 1
    inc $s6 001          # $s6 += 1
skip1:

# CHECK 0 0 b6 b5 b4 b3 b2 0
    and $t5 $t4         # reset $t5             ($t5 = 0 0 0 0 0 0 0 0)
    xor $t5 $t0         # move $t0 -> $t5       ($t5 = b8 b7 b6 b5 b4 b3 b2 b1)
    shl $t5 010         # $t5 << 2              ($t5 = b6 b5 b4 b3 b2 b1 0 0)
    shr $t5 011         # $t5 >> 3              ($t5 = 0 0 0 b6 b5 b4 b3 b2)
    xor $t5 $s1         # $t5 == $s1 -> 0       ($t5 = 0 0 0 ? ? ? ? ?)
    bnez skip2
    #  $t5 == $s1 -> 0  # found the pattern
    inc $s3 001         # $s3 += 1
    inc $s5 001         # $s5 += 1
    inc $s6 001         # $s6 += 1
skip2:

# CHECK 0 b7 b6 b5 b4 b3 0 0
    and $t5 $t4         # reset $t5             ($t5 = 0 0 0 0 0 0 0 0) 
    xor $t5 $t0         # move $t0 -> $t5       ($t5 = b8 b7 b6 b5 b4 b3 b2 b1)
    shl $t5 001         # $t5 << 1              ($t5 = b7 b6 b5 b4 b3 b2 b1 0)
    shr $t5 011         # $t5 >> 3              ($t5 = 0 0 0 b7 b6 b5 b4 b3)
    xor $t5 $s1         # $t5 == $s1 -> 0       ($t5 = 0 0 0 ? ? ? ? ?)
    bnez skip3
    #  $t5 == $s1 -> 0  # found the pattern
    inc $s3 001          # $s3 += 1
    inc $s5 001          # $s5 += 1
    inc $s6 001          # $s6 += 1
skip3:

# CHECK b8 b7 b6 b5 b4 0 0 0 
    and $t5 $t4         # reset $t5             ($t5 = 0 0 0 0 0 0 0 0)
    xor $t5 $t0         # move $t0 -> $t5       ($t5 = b8 b7 b6 b5 b4 b3 b2 b1)
    shr $t5 011         # $t5 >> 3              ($t5 = 0 0 0 b8 b7 b6 b5 b4)
    xor $t5 $s1         # $t5 == $s1 -> 0       ($t5 = 0 0 0 ? ? ? ? ?)
    bnez skip4
    #  $t5 == $s1 -> 0  # found the pattern
    inc $s3 001          # $s3 += 1
    inc $s5 001          # $s5 += 1
    inc $s6 001          # $s6 += 1
skip4:

# [if $s6 > 0 -> $s4 mem[34]++ (~32)]
    and $t5 $t4         # reset $t5             ($t5 = 0 0 0 0 0 0 0 0)
    xor $t5 $s6         # move $s6 -> $t5       ($t5 = 0 0 0 0 0 ? ? ?)
    bnez skip5          
    # $s6 == 0          # no found              ($t5 = 0 0 0 0 0 0 0 0)
    inc $t5 001         # masking bit           ($t5 = 0 0 0 0 0 0 0 1)
    bnez skip6
skip5: # found at least one pattern
    # $s6 != 0          # found at least one pattern
    and $s6 $t4         # reset $s6             ($s6 = 0 0 0 0 0 0 0 0)
    inc $s4 001         # $s6 += 1
    and $s4 $t4         # $s4 reset
skip6: # no found

# [$s1 count -> $s5 += 1 mem[35] (~252)]        ($t1 = b4 b3 b2 b1 b8 b7 b6 b5)
# CHECK 0 0 0 b1 b8 b7 b6 b5
    and $t5 $t4         # reset $t5             ($t5 = 0 0 0 0 0 0 0 0)
    xor $t5 $t1         # move $t1 -> $t5       ($t5 = b4 b3 b2 b1 b8 b7 b6 b5)
    shl $t5 011         # $t5 << 3              ($t5 = b1 b8 b7 b6 b5 0 0 0)
    shr $t5 011         # $t5 >> 3              ($t5 = 0 0 0 b1 b8 b7 b6 b5)
    xor $t5 $s1         # $t5 == $s1 -> 0       ($t5 = 0 0 0 ? ? ? ? ?)
    bnez skip7  
    #  $t5 == $s1 -> 0  # found the pattern
    inc $s5 001         # $s5 += 1
skip7:    

    # 0 0 0 b2 b1 b8 b7 b6
    and $t5 $t4         # reset $t5             ($t5 = 0 0 0 0 0 0 0 0) 
    xor $t5 $t1         # move $t1 -> $t5       ($t5 = b4 b3 b2 b1 b8 b7 b6 b5)
    shl $t5 010         # $t5 << 2              ($t5 = b2 b1 b8 b7 b6 b5 0 0)
    shr $t5 011         # $t5 >> 3              ($t5 = 0 0 0 b2 b1 b8 b7 b6)
    xor $t5 $s1         # $t5 == $s1 -> 0       ($t5 = 0 0 0 ? ? ? ? ?)
    bnez skip8   
    #  $t5 == $s1 -> 0  # found the pattern
    inc $s5 001         # $s5 += 1
skip8:

    # 0 0 0 b3 b2 b1 b8 b7
    and $t5 $t4         # reset $t5             ($t5 = 0 0 0 0 0 0 0 0) 
    xor $t5 $t1         # move $t1 -> $t5       ($t5 = b4 b3 b2 b1 b8 b7 b6 b5)
    shl $t5 001         # $t5 << 1              ($t5 = b3 b2 b1 b8 b7 b6 b5 0)
    shr $t5 011         # $t5 >> 3              ($t5 = 0 0 0 b3 b2 b1 b8 b7)
    xor $t5 $s1         # $t5 == $s1 -> 0       ($t5 = 0 0 0 ? ? ? ? ?)
    bnez skip9
    #  $t5 == $s1 -> 0  # found the pattern
    inc $s5 001          # $s5 += 1
skip9:

    # 0 0 0 b4 b3 b2 b1 b8
    and $t5 $t4         # reset $t5             ($t5 = 0 0 0 0 0 0 0 0) 
    xor $t5 $t1         # move $t1 -> $t5       ($t5 = b4 b3 b2 b1 b8 b7 b6 b5)
    shr $t5 011         # $t5 >> 3              ($t5 = 0 0 0 b4 b3 b2 b1 b8)
    xor $t5 $s1         # $t5 == $s1 -> 0       ($t5 = 0 0 0 ? ? ? ? ?)
    bnez skip10
    #  $t5 == $s1 -> 0  # found the pattern
    inc $s5 001          # $s5 += 1
skip10:

    # escape loop
    and $t5 $t4         # reset $t5             ($t5 = 0 0 0 0 0 0 0 0) 
    xor $t5 $s0         # move $s0 -> $t5       ($t5 = addr_MEM[31])
    xor $t5 $s2         #                       ($t5 = addr_MEM[31]^29)
    bnez loop           # go back to loop
    # $t5 == 29 : $s0 == $s2

# <loop end>
    # reset
    and $t0 $t4         # reset $t0 ($t0 = 0 0 0 0 0 0 0 0)
    and $t5 $t4         # reset $t5 ($t5 = 0 0 0 0 0 0 0 0)
    and $t7 $t4         # reset $t7 ($t7 = 0 0 0 0 0 0 0 0)

    # last value_of_full_MEM[31] -> tmp7 -> tmp0     ($s0 = 31)
    lw  $s0             # load data last MEM to $t7 ($t7 = b8 b7 b6 b5 b4 b3 b2 b1)
    xor $t0 $t7         # move $t7 -> $t0       ($t0 = b8 b7 b6 b5 b4 b3 b2 b1)
    
    # 0 0 0 b5 b4 b3 b2 b1
    xor $t5 $t1         # move $t1 -> $t5       ($t5 = b8 b7 b6 b5 b4 b3 b2 b1)
    shl $t5 011         # $t5 << 3              ($t5 = b5 b4 b3 b2 b1 0 0 0)
    shr $t5 011         # $t5 >> 3              ($t5 = 0 0 0 b5 b4 b3 b2 b1)
    xor $t5 $s1         # $t5 == $s1 -> 0       ($t5 = 0 0 0 ? ? ? ? ?)
    bnez skip11 
    #  $t5 == $s1 -> 0  # found the pattern
    inc $s3 001          # $s3 += 1
    inc $s5 001          # $s5 += 1
    inc $s6 001          # $s6 += 1
skip11:
    
    # 0 0 0 b6 b5 b4 b3 b2
    and $t5 $t4         # reset $t5             ($t5 = 0 0 0 0 0 0 0 0)
    xor $t5 $t1         # move $t1 -> $t5       ($t5 = b8 b7 b6 b5 b4 b3 b2 b1)
    shl $t5 010         # $t5 << 2              ($t5 = b6 b5 b4 b3 b2 b1 0 0)
    shr $t5 011         # $t5 >> 3              ($t5 = 0 0 0 b6 b5 b4 b3 b2)
    bnez skip12  
    #  $t5 == $s1 -> 0  # found the pattern
    inc $s3 001          # $s3 += 1
    inc $s5 001          # $s5 += 1
    inc $s6 001          # $s6 += 1
skip12:
    
    # 0 0 0 b7 b6 b5 b4 b3
    and $t5 $t4         # reset $t5             ($t5 = 0 0 0 0 0 0 0 0) 
    xor $t5 $t1         # move $t1 -> $t5       ($t5 = b8 b7 b6 b5 b4 b3 b2 b1)
    shl $t5 001         # $t5 << 1              ($t5 = b7 b6 b5 b4 b3 b2 b1 0)
    shr $t5 011         # $t5 >> 3              ($t5 = 0 0 0 b7 b6 b5 b4 b3)
    xor $t5 $s1         # $t5 == $s1 -> 0       ($t5 = 0 0 0 ? ? ? ? ?)
    bnez skip13   
    #  $t5 == $s1 -> 0  # found the pattern
    inc $s3 001          # $s3 += 1
    inc $s5 001          # $s5 += 1
    inc $s6 001          # $s6 += 1
skip13:
    
    # 0 0 0 b8 b7 b6 b5 b4 
    and $t5 $t4         # reset $t5             ($t5 = 0 0 0 0 0 0 0 0)
    xor $t5 $t1         # move $t1 -> $t5       ($t5 = b8 b7 b6 b5 b4 b3 b2 b1)
    shr $t5 011         # $t5 >> 3              ($t5 = 0 0 0 b8 b7 b6 b5 b4)
    xor $t5 $s1         # $t5 == $s1 -> 0       ($t5 = 0 0 0 ? ? ? ? ?)
    bnez skip14 
    #  $t5 == $s1 -> 0  # found the pattern
    inc $s3 001          # $s3 += 1
    inc $s5 001          # $s5 += 1
    inc $s6 001          # $s6 += 1
skip14:

# [if $s6 > 0 -> $s4 mem[34]++ (~32)]
    and $t5 $t4         # reset $t5             ($t5 = 0 0 0 0 0 0 0 0)
    xor $t5 $s6         # move $s6 -> $t5       ($t5 = 0 0 0 0 0 ? ? ?)
    bnez skip15          
    # $s6 == 0          # no found              ($t5 = 0 0 0 0 0 0 0 0)
    inc $t5 001         # masking bit           ($t5 = 0 0 0 0 0 0 0 1)
    bnez skip16
skip15: # found at least one pattern
    # $s6 != 0          # found at least one pattern
    and $s6 $t4         # reset $s6             ($s6 = 0 0 0 0 0 0 0 0)
    inc $s4 001         # $s6 += 1
    and $s4 $t4         # $s4 reset
skip16: # no found

  # output
    # MEM[33]
    inc $s0 010         # $s0 += 2              ($s0 = 33)
    and $t7 $t4         # reset $t7             ($t7 = 0 0 0 0 0 0 0 0)
    xor $s7 $s3         # move $s3 -> $t7       ($s3 = (~128))
    sw $s0              # store data MEM[33]

    # MEM[34]
    inc $s0 001         # $s0 += 1              ($s0 = 34)
    and $t7 $t4         # reset $t7             ($t7 = 0 0 0 0 0 0 0 0)
    xor $s7 $s4         # move $s4 -> $t7       ($s4 = (~32))
    sw $s0              # store data MEM[34]

    # MEM[35]
    inc $s0 001         # $s0 += 1              ($s0 = 35)
    and $t7 $t4         # reset $t7             ($t7 = 0 0 0 0 0 0 0 0)
    xor $s7 $s5         # move $s5 -> $t7       ($s5 = (~252))
    sw $s0              # store data MEM[35]

exit:
    li $v0, 10          # exit program syscall# 10
    syscall 











