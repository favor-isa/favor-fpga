#include <stdio.h>
#include <stdlib.h>
#include "Vcpu.h"
#include "Vcpu_cpu.h"
#include "Vcpu_memory.h"
#include "verilated.h"

//void
//dump(Vcpu *cpu) {
//    printf("led = %d\n", cpu->o_led);
//}

const char*
state_name(int state) {
    switch(state) {
        case 0:  return "fetch  ";
        case 1:  return "decode ";
        case 2:  return "execute";
        case 3:  return "halt   ";
        case 4:  return "fetch-w";
        case 5:  return "s1->dst";
        default: return "unknown";
    }
}

struct dump_flags {
    uint32_t dcd_valid: 1;
    uint32_t dcd_to_state: 1;
    uint32_t mem_address: 1;
    uint32_t gpr;
};

struct dump_flags flags = {
    .dcd_valid = 0,
    .dcd_to_state = 0,
    .mem_address = 0,
    .gpr = (1 << 8) | (1 << 9) | (1 << 10) | (1 << 11)
};

void
dump_at_clk(Vcpu *cpu, struct dump_flags *f) {
    const char *before = cpu->i_clk ?
        " -->" :
        "next" ;
    
    printf("%s %s pc=%04lx ", before,
        state_name(cpu->cpu->state), cpu->cpu->pc);
        
    if(f->dcd_valid) {
        printf("dcd_valid=%d ", cpu->cpu->dcd_valid);
    }
    if(f->dcd_to_state) {
        printf("dcd_to_state=%s ", state_name(cpu->cpu->dcd_to_state));
    }
    for(uint32_t i = 0; i < 32; ++i) {
        if(f->gpr & (1 << i)) {
            printf("gpr[%02u]=%016lx ", i, cpu->cpu->gpr[i]);
        }
    }
    if(f->mem_address) {
        printf("mem_address=%04x ", cpu->cpu->mem_address);
    }

    if(cpu->cpu->state == 1) { /* STATE_DECODE */
        printf("insn=%08x ", cpu->cpu->mem_value);
    }
    puts("");
}

void
tick(Vcpu *cpu) {
    cpu->eval();
    dump_at_clk(cpu, &flags);
    cpu->i_clk = 1;
    cpu->eval();
    dump_at_clk(cpu, &flags);
    cpu->i_clk = 0;
    cpu->eval();
    //dump(cpu);
}

void
dump_ram(Vcpu *cpu) {
    for(int i = 0; i < 0x50; ++i) {
        printf("ram[%04x]: %08x\n", i, cpu->cpu->mem->ram[i]);
    }
}

int
main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    Vcpu *cpu = new Vcpu;

    // Initial eval() for dump_ram to work (this calls readmemh. Note this means
    // we can swap out the assembly program we're testing without needing to 
    // recompile anything).
    cpu->eval();
    dump_ram(cpu);

    for(int k = 0; k < 400; ++k) {
        tick(cpu);
        if(cpu->cpu->state == 3) { /* STATE_HALT */
            printf("     execution halted.\n");
            return 0;
        }
    }
}