`include "timer.v"
`include "game_ball.v"
`include "game_paddle.v"
`include "game_paddle_top.v"
`include "draw_border.v"
`include "erase_all.v"
`include "game_ball_1.v"
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
		// HEX1,
		HEX2
		// HEX3,
		// HEX4,
		// HEX5
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
	// output  [6:0] 	HEX1;
	output  [6:0] 	HEX2;
	// output  [6:0] 	HEX3;
	// output  [6:0] 	HEX4;
	// output  [6:0] 	HEX5;


	wire resetn;
	assign resetn = SW[0];



	
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

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

	wire left, right, left_top, right_top;
	assign left = !KEY[3];
	assign right = !KEY[2];
	assign left_top = !KEY[1];
	assign right_top = !KEY[0];
    wire paddle_done, ball_done, c;
    
	wire [3:0] player_0_scores, player_1_scores;
	reg [3:0] player_0_score, player_1_score;
	wire end_signal, enable_border, enable_ball;
	control_game(
        .clk(CLOCK_50),
        .resetn(resetn),
        // .go(SW[9]),
		.go(!KEY[1]),
		.difficulty(SW[9]),
		.difficulty_hide(SW[8]),
		.difficulty_paddle_width(SW[6]),
		.AI_mode(SW[5]),
		.restart(restart),
        .left(left),
        .right(right),
		.left_top(left_top),
  		.right_top(right_top),		
        .writeEn(writeEn),
		.more_ball(SW[7]),
        .x_out(x),
        .y_out(y),
        .color_out(colour),
		.player_0_scores(player_0_scores),
		.player_1_scores(player_1_scores),	
		.erase_all(erase_all),
		.end_signal(end_signal),
		.enable_border(enable_border),
		.enable_ball(enable_ball)
    ); 

	assign LEDR[9] = erase_all;
	assign LEDR[8] = end_signal;
	assign LEDR[7] = enable_border;
	assign LEDR[6] = enable_ball;

	
	wire erase_all;
	always @(negedge resetn, posedge player_0_scores, posedge erase_all) begin
		if (!resetn)
			player_0_score <= 3'd0;
		else if (erase_all)
			player_0_score <= 3'd0;
		else
			player_0_score <= player_0_score + 1'b1;
	end
	
	always @(negedge resetn, posedge player_1_scores, posedge erase_all) begin
		if (!resetn)
			player_1_score <= 3'd0;
		else if(erase_all)
			player_1_score <= 3'd0;
		else
			player_1_score <= player_1_score + 1'b1;
	end
	wire restart;
	assign restart = (player_0_score == 3'd7) | (player_1_score == 3'd7);

	hex_decoder h0(player_0_score, HEX0[6:0]);
	hex_decoder h2(player_1_score, HEX2[6:0]);

endmodule


module control_game(
	input clk, resetn, go, difficulty, difficulty_hide, difficulty_paddle_width, AI_mode, restart, left, right, left_top, right_top, more_ball,
	output writeEn,
	output reg [7:0] x_out, 
	output reg [6:0] y_out,
	output reg [2:0] color_out,
	output player_0_scores, player_1_scores,
	output reg erase_all, end_signal, enable_border, enable_ball
    );

	// difficulty paddle length
	wire [3:0] paddle_width;
	assign paddle_width = difficulty_paddle_width ? 4'd8 : 4'd12;


//	reg enable_ball, enable_paddle, enable_border;
	reg enable_paddle;
    wire writeEn0, writeEn1, writeEn2;
    wire enable_color_ball, enable_color_paddle, enable_move_ball, enable_move_paddle;
    wire [7:0] x_ball, x_ball_1, x_paddle; 
	wire [6:0] y_ball, y_ball_1, y_paddle;
	wire [2:0] color_ball, color_ball_1, color_paddle;

	reg [2:0] current_state, next_state;
    always @(posedge clk) begin
		if (!resetn)
			current_state <= END;
		else
			current_state <= next_state;
	end

	localparam  END = 3'd0,
				ERASE_ALL = 3'd1, 
				DRAW_BORDER = 3'd2,
				DRAW_BALL = 3'd3,
				DRAW_BALL_1 = 3'd4,
                DRAW_PADDLE = 3'd5,
				DRAW_PADDLE_TOP = 3'd6;
				
	wire go2;
	timer_s t374(
		.clk(clk),
		.resetn(reset_timer),
		.enable(1'b1),
		.dividend(26'd4),
		.time_up(go2)
	);

	
	always @(*) 
	begin: state_table
		case (current_state)
			END: next_state = go ? ERASE_ALL : END;
			ERASE_ALL: next_state = go2 ? DRAW_BORDER : ERASE_ALL;
			DRAW_BORDER: next_state = draw_done_border ? DRAW_BALL : DRAW_BORDER;
			DRAW_BALL: 
			begin
				if (more_ball)
				next_state = ball_done ? DRAW_BALL_1 : DRAW_BALL;
				else
				next_state = ball_done ? DRAW_PADDLE: DRAW_BALL;
			end
			DRAW_BALL_1: next_state = ball_done_1 ? DRAW_PADDLE : DRAW_BALL_1;
            DRAW_PADDLE: next_state = paddle_done ? DRAW_PADDLE_TOP : DRAW_PADDLE;
			DRAW_PADDLE_TOP: 
			begin
				if (restart)
					next_state = END;
				else
					next_state = paddle_top_done ? DRAW_BALL : DRAW_PADDLE_TOP;
			end 
			
			default: next_state = END;
		endcase
	end

	reg writeEn4;
	reg reset_timer;
	reg enable_paddle_top, enable_erase;
	reg enable_ball_1;

	always @(*)
	begin
        enable_ball = 1'b0;
        enable_paddle = 1'b0;
		enable_border = 1'b0;
		enable_paddle_top = 1'b0;
		erase_all = 1'b0;
		enable_erase = 1'b0;
		reset_timer = 1'b0;
		writeEn4 = 1'b0;
		end_signal = 1'b0;
		enable_ball_1 = 1'b0;

		case (current_state)
			DRAW_BORDER: begin
				enable_border = 1'b1;
			end
			DRAW_BALL: begin
                enable_ball = 1'b1;
            end
            DRAW_PADDLE: begin
                enable_paddle = 1'b1;
            end
			DRAW_PADDLE_TOP: begin
				enable_paddle_top = 1'b1;
			end
			END: begin
				end_signal = 1'b1;
			end
			ERASE_ALL: begin
				reset_timer = 1'b1;
				erase_all = 1'b1;			
				enable_erase = 1'b1;
				writeEn4 = 1'b1;			
			end
			DRAW_BALL_1: begin
				enable_ball_1 = 1'b1;
			end
		endcase
	end

	wire draw_done_border;
	wire [7:0] x_border;
	wire [6:0] y_border;
	wire [2:0] color_border;
	draw_border d0(
		.clk(clk),
		.resetn(resetn),
		.go(enable_border),
		.go2(go2),
		.done(draw_done_border),
		.writeEn(writeEn2),
		.x_out(x_border),
		.y_out(y_border),
		.color_out(color_border)
	);

	wire draw, draw1;
	control_paddle c0(
		.clk(clk), 
		.resetn(resetn), 
		.go(enable_paddle), 
		.draw_done(draw_done1),
		.enable_color(enable_color_paddle), 
		.enable_move(enable_move_paddle), 
		.writeEn(writeEn0), 
		.draw(draw),
		.done(paddle_done)		
		);
	wire draw_done2, enable_color_paddle_top, enable_move_paddle_top, writeEn3, paddle_top_done;
	wire draw2;
	control_paddle_top c2(
		.clk(clk), 
		.resetn(resetn), 
		.go(enable_paddle_top), 
		.draw_done(draw_done2),
		.AI_mode(AI_mode),
		.enable_color(enable_color_paddle_top), 
		.enable_move(enable_move_paddle_top), 
		.writeEn(writeEn3),
		.draw(draw2),
		.done(paddle_top_done)		
		);
	
    
	control_ball c1(
        .clk(clk), 
        .resetn(resetn),
		.difficulty(difficulty), 
        .go(enable_ball),
		.draw_done(draw_done),
        .enable_color(enable_color_ball),
        .enable_move(enable_move_ball),
        .writeEn(writeEn1),
		.draw(draw1),
        .done(ball_done),
		.reset_counter(reset_counter)
        );	
	
	assign writeEn = (writeEn0 | writeEn1 | writeEn2 | writeEn3 | writeEn4 | writeEn5);
	wire draw_done, draw_done1, reset_counter;
	
	wire player_0_scores_0, player_1_scores_0;
	wire x_direction, y_direction;
	datapath_ball p0(
		.clk(clk),
		.resetn(resetn),
        .enable_color(enable_color_ball),
        .enable_move(enable_move_ball),
		.draw(draw1),
		.reset_counter(reset_counter),
		.difficulty_hide(difficulty_hide),
		.x_paddle(x_paddle),
		.x_paddle_top(x_paddle_top),
		.x_out(x_ball),
		.y_out(y_ball),
		.color_out(color_ball),
		.draw_done(draw_done),
		.player_0_scores(player_0_scores_0),
		.player_1_scores(player_1_scores_0),
		.x_direction(x_direction),
		.y_direction(y_direction)
	);

	
	
	wire ball_done_1, draw_done_3, enable_color_ball_1, enable_move_ball_1, writeEn5, draw_3, reset_counter_1;
	control_ball_1 c3(
		.clk(clk), 
		.resetn(resetn), 
		.difficulty(difficulty), 
		.go(enable_ball_1), 
		.draw_done(draw_done_3),
		.enable_color(enable_color_ball_1), 
		.enable_move(enable_move_ball_1), 
		.writeEn(writeEn5), 
		.draw(draw_3),
		.done(ball_done_1), 
		.reset_counter(reset_counter_1)
    );

	wire player_0_scores_1, player_1_scores_1, x_direction_1, y_direction_1;
	datapath_ball_1 p_1(
		.clk(clk), 
		.resetn(resetn), 
		.enable_color(enable_color_ball_1), 
		.enable_move(enable_move_ball_1), 
		.draw(draw_3), 
		.reset_counter(reset_counter_1), 
		.difficulty_hide(difficulty_hide),
		.x_paddle(x_paddle), 
		.x_paddle_top(x_paddle_top),
		.x_out(x_ball_1),
		.y_out(y_ball_1),
		.color_out(color_ball_1),
		.draw_done(draw_done_3), 
		.player_0_scores(player_0_scores_1), 
		.player_1_scores(player_1_scores_1)，
		.x_direction(x_direction_1),
		.y_direction(y_direction_1)
	);

	assign player_0_scores = player_0_scores_0 | player_0_scores_1;
	assign player_1_scores = player_1_scores_0 | player_1_scores_1;

    datapath_paddle p1(
		.clk(clk),
		.resetn(resetn),
        .enable_color(enable_color_paddle),
        .enable_move(enable_move_paddle),
		.left(left),
		.right(right),
		.draw(draw),
		.paddle_width(paddle_width),
		.x_out(x_paddle),
		.y_out(y_paddle),		
		.color_out(color_paddle),
		.draw_done(draw_done1),
	);

	wire [2:0] color_paddle_top;
	wire [7:0] x_paddle_top;
	wire [6:0] y_paddle_top;

	reg AI_left, AI_right;
	always @(*) begin
		if ((y_direction == 1'b0 | y_direction_1 == 1'b0) & (y_ball < 7'd50 | y_ball_1 < 7'd50)) begin
			if ((y_direction == 1'b0 & y_direction_1 == 1'b0) & (y_ball < 7'd50 & y_ball_1 < 7'd50)) begin
				if (y_ball < y_ball_1) begin
					if (x_ball < x_paddle_origin ) begin
						AI_left = 1'b1;
						AI_right = 1'b0;
					end
					else if (x_ball > (x_paddle_origin + (paddle_width / 2) + 2)) begin
						AI_left = 1'b0;
						AI_right = 1'b1;
					end
					else begin
						AI_left = 1'b0;
						AI_right = 1'b0;
					end
				end
				else begin
					if (x_ball_1 < x_paddle_origin ) begin
						AI_left = 1'b1;
						AI_right = 1'b0;
					end
					else if (x_ball_1 > (x_paddle_origin + (paddle_width / 2) + 2)) begin
						AI_left = 1'b0;
						AI_right = 1'b1;
					end
					else begin
						AI_left = 1'b0;
						AI_right = 1'b0;
					end
				end
			end
			else if (y_direction == 1'b0 & y_ball < 7'd50) begin
				if (x_ball < x_paddle_origin ) begin
					AI_left = 1'b1;
					AI_right = 1'b0;
				end
				else if (x_ball > (x_paddle_origin + (paddle_width / 2) + 2)) begin
					AI_left = 1'b0;
					AI_right = 1'b1;
				end
				else begin
					AI_left = 1'b0;
					AI_right = 1'b0;
				end
			end

			else if (y_direction_1 == 1'b0 & y_ball_1 < 7'd50) begin
				if (x_ball_1 < x_paddle_origin ) begin
					AI_left = 1'b1;
					AI_right = 1'b0;
				end
				else if (x_ball_1 > (x_paddle_origin + (paddle_width / 2) + 2)) begin
					AI_left = 1'b0;
					AI_right = 1'b1;
				end
				else begin
					AI_left = 1'b0;
					AI_right = 1'b0;
				end
			end
			end
		else begin
				AI_left = 1'b0;
				AI_right = 1'b0;
		end
	end

	wire left_top_final, right_top_final;
	assign left_top_final = AI_mode ? AI_left : left_top;
	assign right_top_final = AI_mode ? AI_right : right_top;

	wire [7:0] x_paddle_origin;
	datapath_paddle_top p2(
		.clk(clk),
		.resetn(resetn),
        .enable_color(enable_color_paddle_top),
        .enable_move(enable_move_paddle_top),
		.left(left_top_final),
		.right(right_top_final),
		.draw(draw2),
		.paddle_width(paddle_width),
		.x_paddle_origin(x_paddle_origin),
		.x_out(x_paddle_top),
		.y_out(y_paddle_top),		
		.color_out(color_paddle_top),
		.draw_done(draw_done2),
	);

	wire [7:0] x_erase;
	wire [6:0] y_erase;
	wire [2:0] color_erase;				

	erase_all e01(
		.clk(clk),
		.resetn(resetn),
		.enable(1'b1),
		.x_out(x_erase),
		.y_out(y_erase),
		.color_out(color_erase)								
	);

    always @(*) begin
		if (enable_border) begin
			x_out = x_border;
			y_out = y_border;
			color_out = color_border;
		end
		else if (enable_ball) begin
			x_out = x_ball;
			y_out = y_ball;
			color_out = color_ball;
		end
		else if (enable_paddle) begin
			x_out = x_paddle;
			y_out = y_paddle;
			color_out = color_paddle;
		end
		else if (enable_paddle_top) begin
			x_out = x_paddle_top;
			y_out = y_paddle_top;
			color_out = color_paddle_top;			
		end
		else if (enable_erase) begin
			x_out = x_erase;
			y_out = y_erase;
			color_out = color_erase;
		end
		else if (enable_ball_1) begin
			x_out = x_ball_1;
			y_out = y_ball_1;
			color_out = color_ball_1;
    	end
	end

endmodule



