###### **Linear search program for the normal single-cycle MIPS processor**



**C Pseudo code:**

&#x20;   int mem\[6];

&#x20;   mem\[0] = 7;

&#x20;   mem\[1] = 3;

&#x20;   mem\[2] = 9;

&#x20;   mem\[3] = 5;

&#x20;   mem\[4] = 9;

&#x20;   mem\[5] = -1;



&#x20;   for each array element:

&#x20;       if (mem\[i] == mem\[4]) {

&#x20;           mem\[5] = i;

&#x20;           break;

&#x20;       }



**Memory layout used by the testbench:**



&#x20;   memory\[0] = arr\[0] = 7

&#x20;   memory\[1] = arr\[1] = 3

&#x20;   memory\[2] = arr\[2] = 9

&#x20;   memory\[3] = arr\[3] = 5

&#x20;   memory\[4] = key    = 9

&#x20;   memory\[5] = result = -1 initially, 2 after successful search



**Single-cycle assembly:**



&#x20;       addi $s0, $zero, 0

&#x20;       lw   $t7, 16($s0)

&#x20;       lw   $t0, 0($s0)

&#x20;       beq  $t0, $t7, FOUND0

&#x20;       lw   $t1, 4($s0)

&#x20;       beq  $t1, $t7, FOUND1

&#x20;       lw   $t2, 8($s0)

&#x20;       beq  $t2, $t7, FOUND2

&#x20;       lw   $t3, 12($s0)

&#x20;       beq  $t3, $t7, FOUND3

&#x20;       addi $t6, $zero, -1

&#x20;       sw   $t6, 20($s0)

&#x20;       j    END



FOUND0:

&#x20;       addi $t6, $zero, 0

&#x20;       sw   $t6, 20($s0)

&#x20;       j    END



FOUND1:

&#x20;       addi $t6, $zero, 1

&#x20;       sw   $t6, 20($s0)

&#x20;       j    END



FOUND2:

&#x20;       addi $t6, $zero, 2

&#x20;       sw   $t6, 20($s0)

&#x20;       j    END



FOUND3:

&#x20;       addi $t6, $zero, 3

&#x20;       sw   $t6, 20($s0)



END:

&#x20;       add  $zero, $zero, $zero



