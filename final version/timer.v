module timer_s(
    input clk, resetn, enable, 
    input [25:0] dividend,
    output time_up
);
    reg [25:0] count;
    wire [25:0] check_value;
    assign check_value = 26'd50000000 / dividend;

    always @(posedge clk) begin
        if (!resetn)
			count <= check_value;
		else if (enable) begin
			if (count == 26'd0)
				count <= check_value;
			else
				count <= count - 1'b1;
		end
    end
    assign time_up = (count == 26'd0) ? 1 : 0;
endmodule



module timer_l(
    input clk, resetn, enable, 
    input [25:0] dividend,
    output time_up
);
    reg [25:0] count;
    wire [25:0] initial_value, check_value;
    assign initial_value = 26'd50000000;
    assign check_value = initial_value / dividend;


     
    always @(posedge clk) begin
        if (!resetn)
			count <= check_value;
		else if (enable) begin
			if (count == 26'd0)
				count <= check_value;
			else
				count <= count - 1'b1;
		end
    end
    assign time_up = ((count >= 26'd0) & (count <= check_value / 2)) ? 1 : 0;
endmodule
