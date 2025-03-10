/* verilator lint_off UNUSEDSIGNAL */

`default_nettype none

module cpu(input wire i_clk, output wire o_led);

    reg mem_read = 1;
    reg [13:0] mem_address /* verilator public */ = 14'b0;

    
    wire [31:0] mem_value /* verilator public */;
    reg [63:0] pc /* verilator public */ = 0;

    wire dcd_valid /* verilator public */;
    wire [3:0] dcd_to_state /* verilator public */;
    wire dcd_decode;

    memory mem(i_clk, mem_read, mem_address, mem_value) ;

    /* General purpose registers */
    reg [2047:0] gpr /* verilator public */;

    `include "cpustate.vinc"

    /* The current state that the CPU is in. */
    reg [3:0]  state /* verilator public */ = STATE_FETCH;

    wire [63:0] dcd_src1;
    wire [63:0] dcd_src2;
    wire [4:0]  dcd_dst;
    wire [3:0]  dcd_alu_op;

    reg  [3:0]  alu_op = 0;
    wire [1:0]  alu_sz = 0;
    reg  [63:0] alu_src1 = 0;
    reg  [63:0] alu_src2 = 0;
    wire [63:0] alu_dest;

    reg  [4:0]  reg_dst;

    decoder dec(
        .i_clk(i_clk),
        .i_insn(mem_value),
        .i_gpr(gpr),

        .o_valid(dcd_valid),
        .o_to_state(dcd_to_state),

        .o_alu_op(dcd_alu_op),
        .o_sz(alu_sz),
        .o_src1(dcd_src1),
        .o_src2(dcd_src2),
        .o_dst(dcd_dst)
    );

    alu alu(
        .i_op(alu_op),
        .i_sz(alu_sz),
        .i_src1(alu_src1),
        .i_src2(alu_src2),
        .o_dest(alu_dest)
    );

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
                // The decoder handles most of the heavy lifting here. We just
                // store the decoded state so we can refer to it later, even if
                // we do additional memory reads.
                state <= dcd_to_state;

                alu_src1 <= dcd_src1;
                alu_src2 <= dcd_src2;
                alu_op   <= dcd_alu_op;
                reg_dst <= dcd_dst;
            end
            STATE_EXECUTE: begin
                // By now the ALU should have computed the new value. So,
                // update it.
                gpr[{ reg_dst, 6'b0 } +: 64] <= alu_dest;
                state <= STATE_FETCH;
            end
            STATE_SRC1_TO_DST: begin
                gpr[{ reg_dst, 6'b0 } +: 64] <= alu_src1;
                state <= STATE_FETCH;
            end
        endcase

        gpr[63:0] <= 64'b0;
    end
        
    assign o_led = state[1];
endmodule
