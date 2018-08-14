module erase_all(
    input clk, resetn, enable,
    output [7:0] x_out,
    output [6:0] y_out,
    output [2:0] color_out
);
    reg [15:0] counter;
    always @(posedge clk) begin
        if (!resetn)
            counter <= 16'd0;
        else begin
            if (counter == 16'd65530)
                counter <= 16'd0;
            else
                counter <= counter + 1'b1;
        end
    end
    assign x_out = (counter[15:8] > 8'd160) ? 8'd160 : counter[15:8];
    assign y_out = (counter[7:0] > 7'd120) ? 7'd120 : counter[7:0];
    assign color_out = 3'b000;
endmodule