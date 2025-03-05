#include <stdio.h>
#include <stdlib.h>
#include "Vcpu.h"
#include "verilated.h"

void
dump(Vcpu *cpu) {
    printf("led = %d\n", cpu->o_led);
}

void
tick(Vcpu *cpu) {
    cpu->eval();
    cpu->i_clk = 1;
    cpu->eval();
    cpu->i_clk = 0;
    cpu->eval();
    dump(cpu);
}

int
main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    Vcpu *cpu = new Vcpu;

    for(int k = 0; k < 400; ++k) {
        tick(cpu);
    }
}