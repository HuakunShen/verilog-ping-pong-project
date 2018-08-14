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
		LEDR,
		HEX3,
		HEX1
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
	output [6:0] 	HEX3;
	output [6:0]	HEX1;

	output [9:0] LEDR;		//test with leds

	wire [3:0] score1, score2;
	assign score1 = 4'd0;
	assign score2 = 4'd0;
	hex_decoder hex3(score1, HEX3);
	hex_decoder hex0(score2, HEX1);


	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn, ld_top, ld_bottom, ld_left, ld_right, ld_color, enable;

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

	wire [7:0] x_p;
	wire [6:0] y_p;
	wire [2:0] color_p;	
	process p0(
	.clk(CLOCK_50), 
	.enable(enable), 
	.resetn(resetn), 
	.ld_color(ld_color), 
	.color_in(SW[9:7]),
	.x_out(x_p),
	.y_out(y_p),
	.color_out(color_p)
	);

	wire [7:0] x_b;
	wire [6:0] y_b;
	wire [2:0] color_b;
	border_datapath d0(
		.clk(CLOCK_50),
        .enable(writeEn),
		.resetn(resetn),
		.ld_top(ld_top),
		.ld_bottom(ld_bottom),
		.ld_left(ld_left),
		.ld_right(ld_right),
		.x_out(x_b),
		.y_out(y_b),
		.color_out(color_b)
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
		.ld_color(ld_color),		
		.enable(enable),
		.hold(hold)
	);
	assign LEDR[0] = ld_top;
	assign LEDR[1] = ld_bottom;
	assign LEDR[2] = ld_left;
	assign LEDR[3] = ld_right;
	assign LEDR[4] = enable;
	assign LEDR[9] = hold;


	reg [7:0] x_temp;
	reg [6:0] y_temp;
	reg [2:0] color_temp;
	always @(*) begin
		if (ld_color) begin
			x_temp = x_p ;
			y_temp = y_p;
			color_temp = color_p;					
		end		
		else begin
			x_temp = x_b;
			y_temp = y_b;
			color_temp = color_b;
		end
	end	

	assign x = x_temp;
	assign y = y_temp;
	assign colour = color_temp;	
 	
endmodule


module control(
	input clk, resetn, go,
	output reg ld_top, ld_bottom, ld_left, ld_right, writeEn, ld_color, enable,
	output hold
	);

	wire delay_enable;
	// delay_counter dc0(clk, resetn, enable, delay_enable);        //count 1/60 sec
    // one_sec_counter oc0(delay_enable, resetn, enable, hold);     // count 1sec, hold change every 1 sec
	delay_counter dc0(.clk(clk), .resetn(resetn), .enable(writeEn), .delay_enable(delay_enable));        //count 1/60 sec
    one_sec_counter o0(.clk60(delay_enable), .resetn(resetn), .enable(writeEn), .one_sec(hold));         // count 1sec, hold change every 1 sec
	
	
	reg [3:0] current_state, next_state;
	localparam  TOP = 4'd0,
				TOP_WAIT = 4'd1,
				BOTTOM = 4'd2,
				BOTTOM_WAIT = 4'd3,
				LEFT = 4'd4,
				LEFT_WAIT = 4'd5,
				RIGHT = 4'd6,
				RIGHT_WAIT = 4'd7,
				// LD_COLOR = 4'd8,       // part3 starts...  
				// LD_COLOR_WAIT = 4'd9,
				PLOT = 4'd8;

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
			RIGHT: next_state = go ? RIGHT_WAIT : RIGHT;
			RIGHT_WAIT: next_state = go ? RIGHT_WAIT : PLOT;
			// LD_COLOR: next_state = PLOT;
			// LD_COLOR_WAIT: next_state = go ? LD_COLOR_WAIT : PLOT;
			PLOT: next_state = PLOT;
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
		writeEn = 1'b0;
		ld_color = 1'b0;
		enable = 1'b0;

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
				writeEn = 1'b1;
				ld_top = 1'b0;
				ld_bottom = 1'b1;
			end
			BOTTOM_WAIT: begin
				writeEn = 1'b1;
				ld_top = 1'b0;
				ld_bottom = 1'b1;
			end
			LEFT: begin
				writeEn = 1'b1;
				ld_left = 1'b1;
			end
			LEFT_WAIT: begin
				writeEn = 1'b1;
				ld_left = 1'b1;
			end
			RIGHT: begin
				writeEn = 1'b1;
				ld_right = 1'b1;
			end
			RIGHT_WAIT: begin
				writeEn = 1'b1;
				ld_right = 1'b1;
			end
			// LD_COLOR: begin
			// 	ld_color = 1'b1;
			// 	writeEn = 1'b1;
			// 	enable = 1'b1;
			// end
			// LD_COLOR_WAIT: begin
			// 	// ld_color = 1'b1;
			// end
			PLOT: begin
				ld_color = 1'b1;
				writeEn = 1'b1;
				enable = 1'b1;
			end
		endcase
	end

endmodule


module border_datapath(
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
				x <= 8'd50;
				y <= 7'd10;
				color <= 3'b111;
			end
			else if (ld_bottom) begin
				x <= 8'd50;
				y <= 7'd110;
				color <= 3'b111;
			end
			else if (ld_right) begin
				x <= 8'd110;
				y <= 7'd10;
				color <= 3'b111;																								
			end
		end
	end


	reg [7:0] counter;
	//counter
	always @(posedge clk) 
	begin
		if (!resetn)
			counter <= 8'd0;
		else begin
			if (enable) 
			begin
				if(ld_left || ld_right) 
				begin
					if (counter < 8'd100)
						counter <= counter + 1'b1;	
					else
						counter <= 7'd0;															
				end
				else 
					begin				
						if(counter < 8'd60)
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


module one_sec_counter(
    input clk60, resetn, enable,
    output one_sec
);
    reg [5:0] count;
    always @(posedge clk60)
    begin
        if (!resetn)
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

// part3 
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
	assign color_out = (count == 4'b1111) ? 3'b000 : color_in;
	// assign color_out = (count == 4'b1111) ? 3'b000 : color_in;
endmodule


module x_counter(
	input resetn, enable, direction,
	output reg [7:0] x_pos
);
	always@(negedge enable, negedge resetn) begin
		if (!resetn)
			x_pos <= 8'd60;
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
			y_pos <= 7'd60;
		else begin
			if (direction)
				y_pos <= y_pos + 2'd2;
			else
				y_pos <= y_pos - 2'd2;
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
			direction <= 1'b1;
		else begin
			if (direction) begin
				if (x + 3 > 8'd109)
					direction <= 1'b0;
				else
					direction <= 1'b1;
			end
			else begin
				if (x - 3 < 8'd51)
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
			direction <= 0;
		else begin
			if (direction) begin
				if (y + 3 > 7'd107)
					direction <= 1'b0;
				else
					direction <= 1'b1;
			end
			else begin
				if (y - 3 < 7'd12)
					direction <= 1'b1;
				else
					direction <= 1'b0;
			end
		end
	end

endmodule


module draw(
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



	reg [1:0] counter;
	
	always @(posedge clk) begin
		if (!resetn)
			counter <= 2'b00;
		else if (counter == 2'b11)
				counter <= 2'b00;
		else
				counter <= counter + 1'b1;
	end

	assign x_out = x + counter[0];
	assign y_out = y + counter[1];
	assign color_out = color;

	// reg [3:0] counter;
	
	// always @(posedge clk) begin
	// 	if (!resetn)
	// 		counter <= 4'b0000;
	// 	else if (counter == 4'b1111)
	// 			counter <= 4'b0000;
	// 	else
	// 			counter <= counter + 1'b1;
	// end

	// assign x_out = x + counter[1:0];
	// assign y_out = y + counter[3:2];
	// assign color_out = color;

	// assign x_out = x;
	// assign y_out = y;
	// assign color_out = color;


endmodule


module process(
	input clk, enable, resetn, ld_color, 
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

	delay_counter d_c(
		.clk(clk), 
		.resetn(resetn), 
		.enable(enable), 
		.delay_enable(delay_enable)
		);

	frame_counter f_c(
		.clk(clk), 
		.resetn(resetn), 
		.enable(delay_enable), 
		.color_in(color_in), 
		.frame_enable(frame_enable), 
		.color_out(color)
		);
	
	x_counter x_c(
		.resetn(resetn), 
		.enable(frame_enable), 
		.x_pos(x_pos), 
		.direction(x_direction)
		);

	y_counter y_c(
		.resetn(resetn), 
		.enable(frame_enable), 
		.y_pos(y_pos), 
		.direction(y_direction)
		);

	r_h register_h(
		.clk(clk), 
		.resetn(resetn), 
		.x(x_pos), 
		.direction(x_direction)
		);

	r_v register_v(
		.clk(clk), 
		.resetn(resetn), 
		.y(y_pos), 
		.direction(y_direction)
		);

	draw data(
		.clk(clk),
		.enable(enable),
		.resetn(resetn), 
		.ld_color(ld_color),
		.x_in(x_pos),
		.y_in(y_pos),
		.color_in(color),
		.x_out(x_out),
		.y_out(y_out),
		.color_out(color_out)
		);

endmodule
