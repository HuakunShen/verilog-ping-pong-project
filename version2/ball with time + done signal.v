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
        LEDR,
		HEX0,
		HEX1,
		HEX2,
		HEX3
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
	output  [6:0] 	HEX0;
	output  [6:0] 	HEX1;
	output  [6:0] 	HEX2;
	output  [6:0] 	HEX3;
	
//	hex_decoder hex0(x[3:0], HEX0[6:0]);
//	hex_decoder hex1(x[7:4], HEX1[6:0]);
//	hex_decoder hex2(y[3:0], HEX2[6:0]);
//	hex_decoder hex3(y[6:4], HEX3[6:0]);

	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

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


	// wire left, right;
	// assign left = !KEY[3];
	// assign right = !KEY[2];

    wire draw_done, draw, move_done;

    control_ball c1(
        .clk(CLOCK_50), 
        .resetn(resetn), 
        .go(1'b1),
		.draw_done(draw_done),
		.move_done(move_done),
        .enable_color(enable_color_ball),
        .enable_move(enable_move_ball),
        .writeEn(writeEn),
        .draw(draw),
        .done(ball_done)		
        );	


    datapath_ball p0(
		.clk(CLOCK_50),
		.resetn(resetn),
        .enable_color(enable_color_ball),
        .enable_move(enable_move_ball),
		.draw(draw),
		.x_out(x),
		.y_out(y),
		.color_out(colour),
		.draw_done(draw_done),
		.move_done(move_done)
	);
    // assign LEDR[1] = en_pad;
	// assign LEDR[2] = paddle_done;
	assign LEDR[1] = ball_done;
    assign LEDR[0] = move_done;
    
	// assign LEDR[7] = hold;
	// assign LEDR[8] = hold1;
	// assign LEDR[9] = draw_hold;
    // assign LEDR[9] = hold;
    // assign LEDR[0] = enable_color;
    // assign LEDR[1] = enable_move;
    // assign LEDR[2] = writeEn;
endmodule


// ball
module control_ball(
	input clk, resetn, go, draw_done, move_done,
	output reg enable_color, enable_move, writeEn, draw,
    output reg done
    // output hold, hold1
    );
    
    wire hold, hold1;
	
	timer_l t002(
        .clk(clk), 
        .resetn(reset), 
        .enable(1'b1), 
        .dividend(26'd16), 
        .time_up(hold)
        );
    timer_l t003(
        .clk(clk), 
        .resetn(reset1), 
        .enable(1'b1), 
        .dividend(26'd1000000), 
        .time_up(hold1)
        );

	reg [2:0] current_state, next_state;


    always @(posedge clk) begin
		if (!resetn)
			current_state <= DONE1;
		else
			current_state <= next_state;
	end

	localparam  WAIT = 4'd0, 
                ERASE = 4'd1,
				MOVE = 4'd2,                 
				DRAW = 4'd3,
                DONE1 = 4'd4;
	//state table
    
    always @(*)
    begin: state_table
        case (current_state)
            WAIT: next_state = go ? ERASE : WAIT;
            ERASE: next_state = draw_done ? MOVE : ERASE;
            MOVE: next_state = hold1 ? DRAW : MOVE;
            DRAW: next_state = draw_done ? DONE1 : DRAW;
            DONE1: next_state = hold ? WAIT : DONE1;
		endcase
	 end

    reg reset, reset1;
	always @(*)
	begin
		writeEn = 1'b0;
		enable_color = 1'b0;
        enable_move = 1'b0;
        writeEn = 1'b0;
        draw = 1'b0;
        reset = 1'b0;
        done = 1'b0;

		case (current_state)
			WAIT: begin
            end
			ERASE: begin
                writeEn = 1'b1;
                draw = 1'b1;
                // reset_erase_hold = 1'b1;
            end
           
			MOVE: begin
				enable_move = 1'b1;
                reset1 = 1'b1;
                // reset_move_hold = 1'b1;
			end
            
            DRAW: begin
                // reset_draw_hold = 1'b1;
                enable_color = 1'b1;
                writeEn = 1'b1;
                draw = 1'b1;
            end
            DONE1: begin
                done = 1'b1;
                reset = 1'b1;
            end
		endcase
	end

endmodule


module datapath_ball(
    input clk, resetn, enable_color, enable_move, draw,
    output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] color_out,
    output draw_done, move_done
);

    wire [7:0] x_pos;
    wire [6:0] y_pos;
    xy_counter_ball movement(
        .clk(clk),
        .resetn(resetn),
        .enable_move(enable_move),
        .x_out(x_pos),
        .y_out(y_pos)
        // .move_done(move_done)     
    );

    ball_draw data(
        .clk(clk),
        .draw(draw),
        .x_in(x_pos),
        .y_in(y_pos),
        .x_out(x_out),
        .y_out(y_out),
        .done(draw_done)
    );

    assign color_out = enable_color ? 3'b111 : 3'b011;

endmodule


module ball_draw(
	input clk, draw,
	input [7:0] x_in, 
	input [6:0] y_in,
	output [7:0] x_out, 
	output [6:0] y_out,
    output done
);

	reg [3:0] count;
	assign resetn = draw;
	always @(posedge clk) begin
		if (!resetn)
			count <= 4'b0000;
		else if (count == 1111)
			count <= 4'b0000;
		else
			count <= count + 1'b1;
	end
    assign done = (count == 4'b1111);  //// add more time; need reset time
	assign x_out = x_in + count[1:0];
	assign y_out = y_in + count[3:2];

endmodule


module xy_counter_ball(
    input clk, resetn, enable_move,
    output reg [7:0] x_out,
    output reg [6:0] y_out
    // output move_done
);
    // x_counter
    reg done;
    wire enable_move1;
    assign enable_move1 = enable_move;
    always@(posedge enable_move, negedge resetn) begin
        if (!resetn) begin
            x_out <= 8'd50;
            y_out <= 7'd60;
		   end
        else begin
            if (x_direction)
                x_out <= x_out + 1'b1;
            else if (!x_direction)
                x_out <= x_out - 1'b1;
            if (y_direction)
				y_out <= y_out + 1'b1;
			else if (!y_direction)
				y_out <= y_out - 1'b1;
            // done <= 1'b1;
        end
        // else if (!enable_move1)
        //     done <= 1'b0;
    end

    // assign move_done = enable_move & done;
    
    // y_counter
    // always@(posedge enable_move, negedge resetn) begin
	// 	if (!resetn)
			
	// 	else begin
	// 		if (y_direction)
	// 			y_out <= y_out + 1'b1;
	// 		else
	// 			y_out <= y_out - 1'b1;
	// 	end
	// end

    reg x_direction;
    reg y_direction;
    // x_direction
    always @(posedge clk) begin
            if (!resetn)
                x_direction <= 1;
            else 
            begin
                if (x_direction) 
                begin
                    if (x_out + 1'b1 > 8'd156)
                        x_direction <= 1'b0;
                    else
                        x_direction <= 1'b1;
                end

                else
                begin
                    if (x_out == 8'd2)
                        x_direction <= 1'b1;
                    else
                        x_direction <= 1'b0;
                end

            end

        end
    // y_direction
    always @(posedge clk) begin
		if (!resetn)
			y_direction <= 1;
		else begin
			if (y_direction) begin
				if (y_out + 1'b1 > 7'd116)
					y_direction <= 1'b0;
				else
					y_direction <= 1'b1;
			end

			else begin
				if (y_out == 7'b0000000)
					y_direction <= 1'b1;
				else
					y_direction <= 1'b0;
			end

		end

	end

endmodule

