module cpu(input wire i_clk, output wire o_led);

    reg mem_read = 1;
    reg [13:0] mem_address /* verilator public */ = 14'b0;

    /* verilator lint_off UNUSEDSIGNAL */
    wire [31:0] mem_value /* verilator public */;
    reg [63:0] pc /* verilator public */ = 0;

    wire dcd_valid /* verilator public */;
    wire dcd_halt /* verilator public */;
    wire dcd_decode;
    /** The currently executing instruction. */
   // reg [31:0] insn = 0;
    /* verilator lint_on UNUSEDSIGNAL */

    memory mem(i_clk, mem_read, mem_address, mem_value) ;

    /* General purpose registers */
    reg [63:0] gpr [0:31] /* verilator public */;

    `include "cpustate.vinc"

    /* The current state that the CPU is in. */
    reg [3:0]  state /* verilator public */ = STATE_FETCH;

    // Pass the mem_value directly to the decoder, as the instruction will be
    // available in mem_value once the read is complete.
    assign dcd_decode = (state == STATE_DECODE);
    decoder dec(i_clk, mem_value, dcd_decode, dcd_valid, dcd_halt);

    always @(*) begin
        /* Force the zero register to 0 */
        gpr[0] = 64'b0;
    end

    always @(posedge i_clk) begin
        case(state)
            STATE_FETCH: begin
                // Right now, memory is word-addressed, so we have to give an
                // address in terms of 4bytes.
                // TODO: Make the memory controller have byte-addressable ports
                // or something.
                mem_address <= pc[15:2];
                mem_read <= 1;
                state <= STATE_FETCH_WAIT;
                pc <= pc + 4;
            end
            // BRAM takes exactly one cycle.
            STATE_FETCH_WAIT: begin
                state <= STATE_DECODE;
                mem_read <= 0;
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
