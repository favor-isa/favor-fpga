#include <stdio.h>
#include <stdlib.h>
//#include "Vcpu.h"
//#include "Vcpu_cpu.h"
//#include "Vcpu_memory.h"
#include "Vuart_tx.h"
#include "Vuart_tx_uart_tx.h"
#include "verilated.h"

void
dump_at_clk(Vuart_tx *uart_tx) {
    printf("%d | %c%d | %d [%d]\n", uart_tx->i_clk, uart_tx->i_char, uart_tx->i_write, uart_tx->o_tx, uart_tx->o_busy);
}

char data[] = "horse";
int data_idx = 0;

void
tick(Vuart_tx *uart_tx) {
    uart_tx->eval();
    dump_at_clk(uart_tx);
    uart_tx->i_clk = 1;
    uart_tx->eval();

    if(uart_tx->o_busy) {
        uart_tx->i_write = 0;
    }
    else {
        uart_tx->i_write = 1;
        uart_tx->i_char = data[data_idx];
        data_idx = (data_idx + 1) % 5;
        printf("  .    .   expect: 0 ");
        for(int i = 0; i < 8; ++i) {
            printf("%c", ((uart_tx->i_char >> i) & 1) ? '1' : '0');
        }
        printf(" 0\n");
    }

    dump_at_clk(uart_tx);
    uart_tx->i_clk = 0;
    uart_tx->eval();
}

int
main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);

    Vuart_tx *tx = new Vuart_tx;

    
    tx->i_char = '?';

    for(int k = 0; k < (Vuart_tx_uart_tx::CLKS_PER_BIT + 1) * 10 * 5; ++k) {
        tick(tx);
        
    }
}