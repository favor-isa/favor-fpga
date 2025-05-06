#include <stdio.h>
#include <stdlib.h>
#include "Vtop_sim.h"
#include "verilated.h"

void
dump_at_clk(Vtop_sim *top) {
    printf("%d -> %d\n", top->i_clk, top->o_tx);
}

char data[] = "horse";
int data_idx = 0;

void
tick(Vtop_sim *top) {
    top->eval();
    dump_at_clk(top);
    top->i_clk = 1;
    top->eval();

    dump_at_clk(top);
    top->i_clk = 0;
    top->eval();
}

int
main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    Vtop_sim *top = new Vtop_sim;

    char chars[] = "horse";

    tick(top);
    tick(top);

    for(int loop = 0; loop < 10; ++loop) {
        for(int i = 0; i < 5; ++i) {
            char next = chars[i];
            printf("expect: '%c' 0 ", next);
            for(int j = 0; j < 8; ++j) printf("%c", (next >> j) & 1 ? '1' : '0');
            printf(" 1\n");
            for(int k = 0; k < 11; ++k) {
                tick(top);
            }
        }
    }
}