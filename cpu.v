module cpu(input wire i_clk, output wire o_led);

    reg mem_read = 1;
    reg [13:0] mem_address = 14'b0;

    /* verilator lint_off UNUSEDSIGNAL */
    wire [31:0] mem_value;
    reg [63:0] pc = 0;

    wire dcd_valid;
    wire dcd_halt;
    /** The currently executing instruction. */
   // reg [31:0] insn = 0;
    /* verilator lint_on UNUSEDSIGNAL */

    memory mem(i_clk, mem_read, mem_address, mem_value);

    /* General purpose registers */
    reg [63:0] gpr [0:31];

    `include "cpustate.vinc"

    /* The current state that the CPU is in. */
    reg [3:0]  state = STATE_FETCH;

    // Pass the mem_value directly to the decoder, as the instruction will be
    // available in mem_value once the read is complete.
    decoder dec(i_clk, mem_value, dcd_valid, dcd_halt);

    always @(*) begin
        /* Force the zero register to 0 */
        gpr[0] = 64'b0;
    end

    always @(posedge i_clk) begin
        case(state)
            STATE_FETCH: begin
                mem_address <= pc[13:0];
                mem_read <= 1;
                state <= STATE_DECODE;
                pc <= pc + 4;
            end
            STATE_DECODE: begin
                // The decoder handles most of the heavy lifting here.

                // insn <= mem_value;
                // // Switch on mem_value as it currently holds the insn.
                // case(mem_value[30:29])
                //     2'b00: begin
                //         // 0-argument instruction. 
                //     end
                //     2'b01: begin
                //     end
                //     2'b10: begin
                //     end
                //     2'b11: begin
                //     end
                // endcase
                state <= STATE_EXECUTE;
            end
            STATE_EXECUTE: begin
                state <= STATE_FETCH;

                if (dcd_halt) state <= STATE_HALT;
            end
        endcase
    end
        
    assign o_led = gpr[0][0];
endmodule
