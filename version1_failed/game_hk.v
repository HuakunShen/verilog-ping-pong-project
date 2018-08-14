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
	
	wire reset;
	assign reset = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn, ld_x, ld_y, ld_color, enable;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(reset),
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


    wire b_top, b_bottom;

	datapath data0(
		.clk(CLOCK_50),
		.reset(reset),
        .enable(enable),
        .b_top(b_top),
        .b_bottom(b_bottom),
		.x_out(x),
		.y_out(y),
		.color_out(colour)
	);



    control c0(
		.clk(CLOCK_50),
		.reset(reset),
		.go(!(KEY[1])),
        .b_top(b_top),
        .b_bottom(b_bottom),
		.writeEn(writeEn),
        .enable(enable)	
	);
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
    input clk, reset, go,
    output reg b_top, b_bottom, writeEn, enable
);
    reg [3:0] current_state, next_state;
    wire hold, delay_enable;

    delay_counter dc0(clk, reset, enable, delay_enable);        //count 1/60 sec
    one_sec_counter o0(delay_enable, reset, enable, hold);         // count 1sec, hold change every 1 sec


    localparam  START = 4'd0,
                START_WAIT = 4'd1,
                BORDER_TOP = 4'd2,
                BORDER_TOP_WAIT = 4'd3,
                BORDER_BOTTOM = 4'd4;

    //reset
	always @(posedge clk) begin
		if (!resetn)
			current_state <= START;
		else
			current_state <= next_state;
	end

    always @(*)
    begin: state_table
        case (current_state)
            START: next_state = go ? START_WAIT : START;
            START_WAIT: next_state = go ? START_WAIT : BORDER_TOP;
            BORDER_TOP: next_state = go ? BORDER_TOP_WAIT : BORDER_TOP;
            BORDER_TOP_WAIT: next_state = go ? BORDER_TOP_WAIT : BORDER_BOTTOM;
        endcase
    end

    always @(*)
    begin
        b_top = 1'b0;
        b_bottom = 1'b0;
        writeEn = 1'b0;
        enable = 1'b0;

        case (current_state)
            START: begin
            end
            START_WAIT: begin
            end
            BORDER_TOP: begin
                enable = 1'b1;
                b_top = 1'b1;
                b_bottom = 1'b0;
                writeEn = 1'b1;
            end
            BORDER_TOP_WAIT: begin
                enable = 1'b1;
                b_top = 1'b1;
                b_bottom = 1'b0;
                writeEn = 1'b1;
            end
            BORDER_BOTTOM: begin
                enable = 1'b1;
                b_top = 1'b0;
                b_bottom = 1'b1;
                writeEn = 1'b1;
            end
        endcase

    end

endmodule



module x_counter(
    input clk60, enable, reset, b_top, b_bottom,
    output reg [7:0] x_out
);
    reg [7:0] x_initial_pos;
    always @(*)
    begin
        if (b_top || b_bottom)
            x_initial_pos = 8'd15;
    end
    
    always @(posedge clk60) begin
        if (!reset)
            x_out <= x_initial_pos;
        else if (enable) begin
            if (b_top || b_bottom) begin
                if (x_out < 140)
                    x_out <= x_out + 1'b1;
            end
            
        end
    end

endmodule


module y_counter(
    input clk60, enable, reset, b_top, b_bottom, 
    output reg [6:0] y_out
);

    always @(*)
    begin
        if (b_top)
            y_out = 7'd20;
        else if (b_bottom)
            y_out = 7'd105;
    end




	// reg [6:0] y_initial_pos;
    // always @(*)
    // begin
    //     if (b_top)
    //         y_initial_pos = 7'd20;
    //     else if (b_bottom)
    //         y_initial_pos = 7'd105;
    // end
    
    // always @(posedge clk60) begin
    //     if (!reset)
    //         y_out <= y_initial_pos;
    //     else if (b_top) begin
    //         y_out <= 7'd20;
    //     end
    //     else if (b_bottom) begin
    //         y_out <= 7'd105;
    //     end
    // end


endmodule


module datapath(
    input clk, reset, enable, b_top, b_bottom,
    output [7:0] x_out,
    output [6:0] y_out,
    output [2:0] color_out
);
    wire delay_enable;
    wire [7:0] x_pos;
    wire [6:0] y_pos;


    delay_counter d_c(  
        .clk(clk), 
        .reset(reset), 
        .enable(enable), 
        .delay_enable(delay_enable)
        );



    x_counter x_c0(
        .clk60(delay_enable),
        .enable(enable),
        .b_top(b_top),
        .b_bottom(b_bottom),
        .x_out(x_pos)
    );


    y_counter y_c0(
        .clk60(delay_enable),
        .enable(enable),
        .b_top(b_top),
        .b_bottom(b_bottom),
        .y_out(y_pos)
    );



    assign x_out = x_pos;
    assign y_out = y_pos;
    assign color_out = 3'b111;


    // draw d0(
    //     .clk(delay_enable),
    //     .reset(reset),
    //     .b_top(b_top),
    //     .b_bottom(b_bottom),
    //     .x_in(x_pos),
    //     .y_in(y_pos),
    //     .color_in(3'b001),
    //     .x_out(x_out),
    //     .y_out(y_out),
    //     .color_out(color_out)
    // );

endmodule



module draw(
    input clk, reset, b_top, b_bottom,
    input [7:0] x_in, 
	input [6:0] y_in,
	input [2:0] color_in,
	output [7:0] x_out, 
	output [6:0] y_out, 
	output reg [2:0] color_out
);
    always @(*)
    begin
        if (b_top || b_bottom)
            color_out = 3'b111;

    end
    
    assign x_out = x_in;
    assign y_out = y_in;

endmodule