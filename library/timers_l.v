




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









module timer_1_1_l(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    always @(posedge clk) begin
        if (!resetn)
			count <= 26'd50000000;
		else if (enable) begin
			if (count == 26'd0)
				count <= 26'd50000000;
			else
				count <= count - 1'b1;
		end
    end
    assign time_up = (count >= 1'b0 & count <= 26'd25000000) ? 1 : 0;
endmodule



module timer_1_2_l(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    wire [4:0] dividend;
    assign dividend = 5'd2;
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




module timer_1_4_l(
    input clk, resetn, enable,
    output time_up
);

    reg [25:0] count;
    wire [4:0] dividend;
    assign dividend = 5'd4;
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







module timer_1_8_l(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    wire [4:0] dividend;
    assign dividend = 5'd8;
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



module timer_1_32_l(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    wire [9:0] dividend;
    assign dividend = 10'd32;
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



module timer_1_64_l(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    wire [9:0] dividend;
    assign dividend = 10'd64;
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






module timer_1_100_l(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    wire [9:0] dividend;
    assign dividend = 10'd100;
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



module timer_1_200_l(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    wire [9:0] dividend;
    assign dividend = 10'd200;
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






module timer_1_500_l(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    wire [9:0] dividend;
    assign dividend = 10'd500;
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



module timer_1_1000_l(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    wire [9:0] dividend;
    assign dividend = 10'd1000;
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




module timer_1_5000_l(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    wire [14:0] dividend;
    assign dividend = 15'd5000;
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




module timer_1_10000_l(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    wire [14:0] dividend;
    assign dividend = 15'd10000;
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