// Part 2 skeleton

module game
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
		VGA_B,   						//	VGA Blue[9:0]
		LEDR
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


	output [9:0] LEDR;		//test with leds



	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn, ld_top, ld_bottom, ld_left, ld_right, ld_color;

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
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	// datapath d0(...);
	datapath d0(
		.clk(CLOCK_50),
        .enable(writeEn),
		.color_in(SW[9:7]),
		.resetn(resetn),
		.ld_top(ld_top),
		.ld_bottom(ld_bottom),
		.ld_left(ld_left),
		.ld_right(ld_right),
		.x_out(x),
		.y_out(y),
		.color_out(colour)
	);
    // Instansiate FSM control
    // control c0(...);
	wire hold;
    control c0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.go(!KEY[1]),
		.ld_top(ld_top),
		.ld_bottom(ld_bottom),
		.ld_left(ld_left),
		.ld_right(ld_right),
		.writeEn(writeEn),
		.hold(hold)
	);
	assign LEDR[9] = hold;
	assign LEDR[0] = ld_top;
	assign LEDR[1] = ld_bottom;
	assign LEDR[2] = writeEn;
endmodule



module delay_counter(
	input clk, reset, enable,
	output delay_enable
);
	reg [19:0] count;
	always @(posedge clk) begin
		if (!reset)
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




module one_sec_counter(
    input clk60, reset, enable,
    output one_sec
);
    reg [5:0] count;
    always @(posedge clk60)
    begin
        if (!reset)
            count <= 6'd60;
        else if (enable)
        begin
            if (count == 6'd0)
                count <= 6'd60;
            else
                count <= count - 1'b1;
        end
    end
    assign one_sec = (count == 6'd0) ? 1 : 0;
endmodule






module control(
	input clk, resetn, go,
	output reg ld_top, ld_bottom, ld_left, ld_right, writeEn,
	output hold
	);

	wire enable, delay_enable; 
	assign enable = writeEn;
	delay_counter dc0(clk, resetn, enable, delay_enable);        //count 1/60 sec
    one_sec_counter oc0(delay_enable, resetn, enable, hold);     // count 1sec, hold change every 1 sec

	
	reg [3:0] current_state, next_state;
	localparam  TOP = 4'd0,
				TOP_WAIT = 4'd1,
				BOTTOM = 4'd2,
				BOTTOM_WAIT = 4'd3,
				LEFT = 4'd4,
				LEFT_WAIT = 4'd5,
				RIGHT = 4'd6,
				RIGHT_WAIT = 4'd7;
	//reset
	always @(posedge clk) begin
		if (!resetn)
			current_state <= TOP;
		else
			current_state <= next_state;
	end

	//state table
	always @(*) 
	begin: state_table
		case (current_state)
			TOP: next_state = hold ? TOP_WAIT : TOP;
			TOP_WAIT: next_state = hold ? TOP_WAIT : BOTTOM;
			BOTTOM: next_state = hold ? BOTTOM_WAIT : BOTTOM;
			BOTTOM_WAIT: next_state = hold ? BOTTOM_WAIT : LEFT;
			LEFT: next_state = hold ? LEFT_WAIT : LEFT;
			LEFT_WAIT: next_state = hold ? LEFT_WAIT : RIGHT;
			RIGHT: next_state = hold ? RIGHT_WAIT : RIGHT;
			RIGHT_WAIT: next_state = RIGHT_WAIT;
			default: next_state = TOP;
		endcase
	end

	//output logic	aka output of datapath control signals
	always @(*)
	begin
		ld_top = 1'b0;
		ld_bottom = 1'b0;
		ld_left = 1'b0;
		ld_right = 1'b0;						
		writeEn = 0;

		case (current_state)
			TOP: begin 
				ld_top = 1'b1;
				ld_bottom = 1'b0;
				writeEn = 1'b1;
			end
			TOP_WAIT: begin
				ld_top = 1'b1;
				ld_bottom = 1'b0;
				writeEn = 1'b1;								
			end
			BOTTOM: begin
				writeEn = 1;
				ld_top = 1'b0;
				ld_bottom = 1'b1;
			end
			BOTTOM_WAIT: begin
				writeEn = 1;
				ld_top = 1'b0;
				ld_bottom = 1'b1;
			end
			LEFT: begin
				writeEn = 1;
				ld_left = 1'b1;
			end
			LEFT_WAIT: begin
				writeEn = 1;
				ld_left = 1'b1;
			end
			RIGHT: begin
				writeEn = 1;
				ld_right = 1'b1;
			end
			RIGHT_WAIT: begin
				writeEn = 1;
				ld_right = 1'b1;
			end
		endcase
	end

endmodule


module datapath(
	input clk, enable, resetn, ld_top, ld_bottom, ld_left, ld_right,
	input [2:0] color_in,
	output [7:0] x_out, 
	output [6:0] y_out, 
	output [2:0] color_out
	);

	reg [7:0] x;
	reg [6:0] y;
	reg [2:0] color;


	always @(posedge clk) begin
		if (!resetn) begin
			x <= 8'b0;
			y <= 7'b0;
			color <= 3'b0;
		end
		else begin
			if (ld_top || ld_left) begin
				y <= 7'd20;
				x <= 8'd15;
				color <= 3'b111;
			end
			else if (ld_bottom) begin
				x <= 8'd15;
				y <= 7'd105;
				color <= 3'b111;
			end
			else if (ld_right) begin
				x <= 8'd140;
				y <= 7'd20;
				color <= 3'b111;																								
			end
		end
	end


	reg [7:0] counter;
	//counter
	always @(posedge clk) begin
		if (!resetn)
			counter <= 8'd0;
		else begin
			if (enable) begin
				if(ld_left || ld_right) 
				begin
					if (counter < 7'd85)
						counter <= counter + 1'b1;	
					else
						counter <= 7'd0;															
				end
				else 
					begin				
						if(counter < 8'd125)
							counter <= counter + 1'b1;
						else
							counter <= 8'd0;
					end
			end
        end
    end

	
	reg [7:0] x_temp;
	reg [6:0] y_temp;
	always @(*) begin
		x_temp = (ld_top || ld_bottom) ? (x + counter[7:0]) : x;
		y_temp = (ld_left || ld_right) ? (y + counter[7:0]) : y;
	end
	assign x_out = x_temp;
	assign y_out = y_temp;
	assign color_out = color;

endmodule


