`include "timer.v"
module game(
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
    output  [9:0]   LEDR;
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	

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




	wire left, right;
	assign left = !KEY[3];
	assign right = !KEY[2];

    wire writeEn, ld_x, ld_y, ld_color, enable_color, enable_move;

	datapath_paddle p0(
		.clk(CLOCK_50),
		.resetn(resetn),
        .enable_color(enable_color),
        .enable_move(enable_move),
		.left(left),
		.right(right),
		.x_out(x),
		.y_out(y),		
		.color_out(colour)
	);
    wire hold;
    control_paddle c1(
		.clk(CLOCK_50),
		.resetn(resetn),
		.go(!(KEY[1])),
		.enable_color(enable_color),
        .enable_move(enable_move),
		.writeEn(writeEn),
	);

    // assign LEDR[9] = hold;
    // assign LEDR[0] = enable_color;
    // assign LEDR[1] = enable_move;
    // assign LEDR[2] = writeEn;

endmodule


module control_paddle(
    input clk, resetn, go,
	output reg enable_color, enable_move, writeEn, done
    );
	reg reset_draw_hold;
    wire hold, hold1, draw_hold;
	
	timer_1_10000_l t00(.clk(clk), .resetn(resetn), .enable(1'b1), .time_up(hold));
	timer_1_10000_s t01(.clk(clk), .resetn(resetn), .enable(1'b1), .time_up(hold1));
    timer_1_8_l t1(.clk(clk), .resetn(resetn), .enable(1'b1), .time_up(draw_hold));

	reg [2:0] current_state, next_state;

    always @(posedge clk) begin
		if (!resetn)
			current_state <= ERASE;
		else
			current_state <= next_state;
	end

	localparam  ERASE = 3'd0,
                ERASE_WAIT = 3'd1,
				MOVE = 3'd2,
                MOVE_WAIT = 3'd3,                 
				DRAW = 3'd4,
                DRAW_WAIT = 3'd5,
				DONE = 3'd6;                
	//state table
	always @(*) 
	begin: state_table
		case (current_state)
			ERASE: next_state = hold ? ERASE_WAIT : ERASE;
            ERASE_WAIT: next_state = hold ? ERASE_WAIT : MOVE;
			MOVE: next_state = hold1 ? MOVE_WAIT : MOVE;
            MOVE_WAIT: next_state = hold1 ? MOVE_WAIT : DRAW;                            
			DRAW: next_state = draw_hold ? DRAW : DRAW_WAIT;
            DRAW_WAIT: next_state = draw_hold ? ERASE : DRAW_WAIT;
			// DONE: next_state = start_over ? ERASE : DONE;
			default: next_state = ERASE;
		endcase
	end

	always @(*)
	begin
		writeEn = 1'b0;
		enable_color = 1'b0;
        enable_move = 1'b0;
        writeEn = 1'b0;
		done = 1'b0;
		reset_draw_hold = 1'b0;
		case (current_state)
			
			ERASE: begin
                writeEn = 1'b1;
            end
            ERASE_WAIT: begin
                writeEn = 1'b1;                
            end            
			MOVE: begin
				enable_move = 1'b1;
			end
            MOVE_WAIT: begin
                enable_move = 1'b1;
            end
            DRAW: begin
                enable_color = 1'b1;
                enable_move = 1'b0;
                writeEn = 1'b1;                
            end
            DRAW_WAIT: begin
                enable_color = 1'b1;
                enable_move = 1'b0;
                writeEn = 1'b1; 
            end
			DONE: begin
				done = 1'b1;
			end
		endcase
	end

endmodule



module datapath_paddle(
    input clk, resetn, enable_color, enable_move, left, right,
    output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] color_out
);

    wire [7:0] x_pos;
    wire [6:0] y_pos;
    xy_counter_paddle movement(
        .clk(clk),
        .resetn(resetn),
		.enable_move(enable_move),
		.left(left),
		.right(right),
        .x_out(x_pos),
        .y_out(y_pos)				        
    );

    paddle_draw data(
        .clk(clk),
        .resetn(resetn),
        .x_in(x_pos),
        .y_in(y_pos),
        .x_out(x_out),
        .y_out(y_out)        
    );

    assign color_out = enable_color ? 3'b111 : 3'b000;

endmodule


module paddle_draw(
	input clk, resetn,
	input [7:0] x_in, 
	input [6:0] y_in,
	output [7:0] x_out, 
	output [6:0] y_out
);

	reg [3:0] count;
	
	always @(posedge clk) begin
		if (!resetn)
			count <= 4'b0000;
		else if (count >= 1100)
				count <= 4'b0000;
		else
				count <= count + 1'b1;
	end

	assign x_out = x_in + count[3:0];
	assign y_out = y_in;

endmodule


module xy_counter_paddle(
    input clk, resetn, enable_move, left, right,
    output reg [7:0] x_out,
    output [6:0] y_out
);
    // x_counter    
    always@(posedge enable_move, negedge resetn) begin
            if (!resetn)
                x_out <= 8'd50;
            else begin
                if (right) begin
                    if (x_out + 1 > 8'd156)
                        x_out <= x_out;               
                    else
                        x_out <= x_out + 1'b1;
                end
                else if (left) begin
					if (x_out <= 8'd2)
						 x_out <= x_out;
					else
                    	x_out <= x_out - 1'b1;
            	end
			end
    end
    assign y_out = 7'd60;

endmodule

