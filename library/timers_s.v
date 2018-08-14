



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














module timer_1_1_s(
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
    assign time_up = (count == 26'd0) ? 1 : 0;
endmodule



module timer_1_2_s(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    always @(posedge clk) begin
        if (!resetn)
			count <= 26'd25000000;
		else if (enable) begin
			if (count == 26'd0)
				count <= 26'd25000000;
			else
				count <= count - 1'b1;
		end
    end
    assign time_up = (count == 26'd0) ? 1 : 0;
endmodule




module timer_1_4_s(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    always @(posedge clk) begin
        if (!resetn)
			count <= 26'd12500000;
		else if (enable) begin
			if (count == 26'd0)
				count <= 26'd12500000;
			else
				count <= count - 1'b1;
		end
    end
    assign time_up = (count == 26'd0) ? 1 : 0;
endmodule



module timer_1_8_s(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    always @(posedge clk) begin
        if (!resetn)
			count <= 26'd625000;
		else if (enable) begin
			if (count == 26'd0)
				count <= 26'd625000;
			else
				count <= count - 1'b1;
		end
    end
    assign time_up = (count == 26'd0) ? 1 : 0;
endmodule



module timer_1_32_s(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    always @(posedge clk) begin
        if (!resetn)
			count <= 26'd1562500;
		else if (enable) begin
			if (count == 26'd0)
				count <= 26'd1562500;
			else
				count <= count - 1'b1;
		end
    end
    assign time_up = (count == 26'd0) ? 1 : 0;
endmodule




module timer_1_64_s(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    always @(posedge clk) begin
        if (!resetn)
			count <= 26'd781250;
		else if (enable) begin
			if (count == 26'd0)
				count <= 26'd781250;
			else
				count <= count - 1'b1;
		end
    end
    assign time_up = (count == 26'd0) ? 1 : 0;
endmodule






module timer_1_100_s(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    always @(posedge clk) begin
        if (!resetn)
			count <= 26'd500000;
		else if (enable) begin
			if (count == 26'd0)
				count <= 26'd500000;
			else
				count <= count - 1'b1;
		end
    end
    assign time_up = (count == 26'd0) ? 1 : 0;
endmodule



module timer_1_200_s(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    always @(posedge clk) begin
        if (!resetn)
			count <= 26'd250000;
		else if (enable) begin
			if (count == 26'd0)
				count <= 26'd250000;
			else
				count <= count - 1'b1;
		end
    end
    assign time_up = (count == 26'd0) ? 1 : 0;
endmodule






module timer_1_500_s(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    always @(posedge clk) begin
        if (!resetn)
			count <= 26'd100000;
		else if (enable) begin
			if (count == 26'd0)
				count <= 26'd100000;
			else
				count <= count - 1'b1;
		end
    end
    assign time_up = (count == 26'd0) ? 1 : 0;
endmodule



module timer_1_1000_s(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    always @(posedge clk) begin
        if (!resetn)
			count <= 26'd50000;
		else if (enable) begin
			if (count == 26'd0)
				count <= 26'd50000;
			else
				count <= count - 1'b1;
		end
    end
    assign time_up = (count == 26'd0) ? 1 : 0;
endmodule




module timer_1_5000_s(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    always @(posedge clk) begin
        if (!resetn)
			count <= 26'd10000;
		else if (enable) begin
			if (count == 26'd0)
				count <= 26'd10000;
			else
				count <= count - 1'b1;
		end
    end
    assign time_up = (count == 26'd0) ? 1 : 0;
endmodule




module timer_1_10000_s(
    input clk, resetn, enable,
    output time_up
);
    reg [25:0] count;
    always @(posedge clk) begin
        if (!resetn)
			count <= 26'd5000;
		else if (enable) begin
			if (count == 26'd0)
				count <= 26'd5000;
			else
				count <= count - 1'b1;
		end
    end
    assign time_up = (count == 26'd0) ? 1 : 0;
endmodule