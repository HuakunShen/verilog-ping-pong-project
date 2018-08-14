module part3
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn, ld_x, ld_y, ld_color, enable;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

	process p0(
		.clk(CLOCK_50),
		.enable(enable),
		.resetn(resetn),
		.load_color(ld_color),
		.color_in(SW[9:7]),
		.x_out(x),
		.y_out(y),
		.color_out(colour)
	);

    control c0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.go(!(KEY[1])),
		.enable(enable),
		.ld_color(ld_color),
		.writeEn(writeEn)	
	);
endmodule



module delay_counter(
	input clk, resetn, enable,
	output delay_enable
);
	reg [19:0] count;
	always @(posedge clk) begin
		if (!resetn)
			count <= 20'd833334;
		else if (enable) begin
			if (count == 20'd0)
				count <= 20'd833334;
			else
				count <= count - 1'b1;
		end
	end
		
	assign delay_enable = (count == 20'd0) ? 1 : 0;
	
endmodule


module frame_counter(
	input clk, resetn, enable,
	input [2:0] color_in,
	output frame_enable,
	output [2:0] color_out
);

	reg [3:0] count;
	always @(posedge clk) begin
		if (!resetn)
			count <= 4'b0000;
		else if (enable == 1'b1) begin
			if (count == 4'b1111)
				count <= 4'b0000;
			else
				count <= count + 1'b1;
		end
	end

	assign frame_enable = (count == 4'b1111) ? 1 : 0;
	assign color_out = (count == 4'b1111 || count == 4'b1110) ? 3'b000 : color_in;
endmodule


module x_counter(
	input resetn, enable, direction,
	output reg [7:0] x_pos
);
	always@(negedge enable, negedge resetn) begin
		if (!resetn)
			x_pos <= 8'b0000_0000;
		else begin
			if (direction)
				x_pos <= x_pos + 1'b1;
			else
				x_pos <= x_pos - 1'b1;
		end

	end
	
endmodule


module y_counter(
	input resetn, enable, direction,
	output reg [6:0] y_pos
);
	always@(negedge enable, negedge resetn) begin
		if (!resetn)
			y_pos <= 7'b0111100;
		else begin
			if (direction)
				y_pos <= y_pos + 1'b1;
			else
				y_pos <= y_pos - 1'b1;
		end
	end

endmodule


module r_h(
	input clk, resetn,
	input [7:0] x,
	output reg direction
);
	always @(posedge clk) begin
		if (!resetn)
			direction <= 1;
		else begin
			if (direction) begin
				if (x + 1 > 8'd156)
					direction <= 1'b0;
				else
					direction <= 1;
			end

			else begin
				if (x == 8'b0000_0000)
					direction <= 1'b1;
				else
					direction <= 1'b0;
			end

		end

	end


endmodule


module r_v(
	input clk, resetn,
	input [6:0] y,
	output reg direction
);
	always @(posedge clk) begin
		if (!resetn)
			direction <= 1;
		else begin
			if (direction) begin
				if (y + 1 > 7'd116)
					direction <= 1'b0;
				else
					direction <= 1;
			end

			else begin
				if (y == 7'b0000000)
					direction <= 1'b1;
				else
					direction <= 1'b0;
			end

		end

	end

endmodule


module control(
	input clk, resetn, go,
	output reg enable, ld_color, writeEn);

	reg [2:0] current_state, next_state;

	localparam  LOAD_COLOR = 3'd0,
				LOAD_COLOR_WAIT = 3'd1,
				PLOT = 3'd2;
	//state table
	always @(*) 
	begin: state_table
		case (current_state)
			LOAD_COLOR: next_state = go ? LOAD_COLOR_WAIT : LOAD_COLOR;
			LOAD_COLOR_WAIT: next_state = go ? LOAD_COLOR_WAIT : PLOT;
			PLOT: next_state = PLOT;
			default: next_state = LOAD_COLOR;
		endcase
	end

	//output logic	aka output of datapath control signals
	always @(*)
	begin
		ld_color = 1'b0;
		writeEn = 1'b0;
		enable = 1'b0;

		case (current_state)
			
			LOAD_COLOR: begin
				// ld_color = 1'b1;
			end
			// LOAD_COLOR_WAIT: begin
			// 	ld_color = 1'b1;
			// end
			PLOT: begin
				ld_color = 1'b1;
				writeEn = 1'b1;
				enable = 1'b1;
			end

		endcase

	end

	always @(posedge clk) begin
		if (!resetn)
			current_state <= LOAD_COLOR;
		else
			current_state <= next_state;
	end

endmodule


module datapath(
	input clk, enable, resetn, ld_color,
	input [7:0] x_in, 
	input [6:0] y_in,
	input [2:0] color_in,
	output [7:0] x_out, 
	output [6:0] y_out, 
	output [2:0] color_out
	);

	reg [7:0] x;
	reg [6:0] y;
	reg [2:0] color;

	//reset or load
	always @(posedge clk) begin
		if (!resetn) begin
			x <= 8'b0;
			y <= 7'b0;
			color <= 3'b0;
		end
		else begin
			x <= x_in;
			y <= y_in;
			if (ld_color)
				color <= color_in;
		end
	end

	reg [3:0] counter;
	
	always @(posedge clk) begin
		if (!resetn)
			counter <= 4'b0000;
		else if (counter == 1111)
				counter <= 4'b0000;
		else
				counter <= counter + 1'b1;
	end

	// wire c1, c2, c3, enable_1;
	// counter cr1(clk,resetn,enable,c1);
	// rate_counter rc2(clk,resetn,enable,c2);
	// assign enable_1 = (c2 == 2'b00) ? 1 : 0;
	// counter cr3(clk,resetn,enable_1,c3);

	assign x_out = x + counter[1:0];
	assign y_out = y + counter[3:2];
	assign color_out = color;

	// assign x_out = x + c1;
	// assign y_out = y + c3;
	// assign color_out = color;

	// assign x_out = x;
	// assign y_out = y;
	// assign color_out = color;

endmodule


module process(
	input clk, enable, resetn, load_color, 
	input [2:0] color_in,
	output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] color_out
);

	wire [7:0] x_pos;
	wire [6:0] y_pos;
	wire [19:0] count0;
	wire [3:0] count1;
	wire x_direction, y_direction;
	wire [2:0] color;
	wire delay_enable;
	wire frame_enable;

	delay_counter d_c(.clk(clk), .resetn(resetn), .enable(enable), .delay_enable(delay_enable));
	frame_counter f_c(.clk(clk), .resetn(resetn), .enable(delay_enable), .color_in(color_in), .frame_enable(frame_enable), .color_out(color));
	
	x_counter x_c(.resetn(resetn), .enable(frame_enable), .x_pos(x_pos), .direction(x_direction));
	y_counter y_c(.resetn(resetn), .enable(frame_enable), .y_pos(y_pos), .direction(y_direction));

	r_h register_h(.clk(clk), .resetn(resetn), .x(x_pos), .direction(x_direction));
	r_v register_v(.clk(clk), .resetn(resetn), .y(y_pos), .direction(y_direction));

	datapath data(
		.clk(clk),
		.enable(enable),
		.resetn(resetn), 
		.ld_color(load_color),
		.x_in(x_pos),
		.y_in(y_pos),
		.color_in(color),
		.x_out(x_out),
		.y_out(y_out),
		.color_out(color_out)
		);

endmodule


module counter(clock,reset_n,enable,q);
	input clock,reset_n,enable;
	output reg [1:0] q;

	always @(posedge clock)
	begin
		if(reset_n == 1'b0)
			q <= 2'b00;
		else if(enable == 1'b1)
		begin
		  if(q == 2'b11)
			  q <= 2'b00;
		  else
			  q <= q + 1'b1;
		end
   end
endmodule


module rate_counter(clock,reset_n,enable,q);
		input clock;
		input reset_n;
		input enable;
		output reg [1:0] q;

		always @(posedge clock)
		begin
			if(reset_n == 1'b0)
				q <= 2'b11;
			else if(enable ==1'b1)
			begin
			   if ( q == 2'b00 )
					q <= 2'b11;
				else
					q <= q - 1'b1;
			end
		end
endmodule
