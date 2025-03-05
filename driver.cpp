#include <stdio.h>
#include <stdlib.h>
#include "Vcpu.h"
#include "verilated.h"

int
main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    Vcpu *tb = new Vcpu;

    for(int k = 0; k < 20; ++k) {
        tb->i_sw = k & 1;
        tb->eval();

        printf("k = %2d, sw = %d, led = %d\n", k, tb->i_sw, tb->o_led);
    }
}