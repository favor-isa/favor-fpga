#include <stdio.h>
#include <stdlib.h>
#include "Vcpu.h"
#include "Vcpu_cpu.h"
#include "verilated.h"

//void
//dump(Vcpu *cpu) {
//    printf("led = %d\n", cpu->o_led);
//}

const char*
state_name(Vcpu *cpu) {
    switch(cpu->cpu->state) {
        case 0:  return "fetch  ";
        case 1:  return "decode ";
        case 2:  return "execute";
        case 3:  return "halt   ";
        default: return "unknown";
    }
}

void
dump_at_clk(Vcpu *cpu) {
    const char *before = cpu->i_clk ?
        " -->" :
        "next" ;
    printf("%s %s pc=%lx %d %d ", before, state_name(cpu), cpu->cpu->pc, cpu->cpu->dcd_valid, cpu->cpu->dcd_halt);
    if(cpu->cpu->state == 1) { /* STATE_DECODE */
        printf("insn=%x ", cpu->cpu->mem_value);
    }
    puts("");
}

void
tick(Vcpu *cpu) {
    cpu->eval();
    dump_at_clk(cpu);
    cpu->i_clk = 1;
    cpu->eval();
    dump_at_clk(cpu);
    cpu->i_clk = 0;
    cpu->eval();
    //dump(cpu);
}

int
main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    Vcpu *cpu = new Vcpu;

    for(int k = 0; k < 400; ++k) {
        tick(cpu);
        if(cpu->cpu->state == 3) { /* STATE_HALT */
            printf("     execution halted.\n");
            return 0;
        }
    }
}