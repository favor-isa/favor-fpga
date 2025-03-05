module cpu(input wire i_clk, output wire o_led);

    reg mem_read = 1;
    reg [13:0] mem_address = 14'b0;

    /* verilator lint_off UNUSEDSIGNAL */
    wire [31:0] mem_value;
    /* verilator lint_on UNUSEDSIGNAL */

    memory mem(i_clk, mem_read, mem_address, mem_value);

    // probably incorrect, oh well
    // parameter CLOCK_FREQ = 50_000_000;
    parameter COUNT_VALUE = 12_499_499;

    reg [24:0] count_value_reg;
    // reg        led_reg = 1'b0;
    // reg [3:0]  tick_reg = 4'b0;

    always @(posedge i_clk) begin
        if (count_value_reg <= COUNT_VALUE) begin
            count_value_reg <= count_value_reg + 1'b1;
            //mem_read <= 1'b0;
        end
        else begin
            count_value_reg <= 25'b0;
            mem_read <= 1'b1;
            mem_address <= mem_address + 14'b1;
        end
    end
        
    assign o_led = mem_value[0];
endmodule
