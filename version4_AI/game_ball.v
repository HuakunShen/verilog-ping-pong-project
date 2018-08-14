module control_ball(
	input clk, resetn, difficulty, go, draw_done,
	output reg enable_color, enable_move, writeEn, draw,
    output reg done, reset_counter
    );
    
    wire hold, hold1;
    wire [25:0] speed;
    assign speed = difficulty ? 26'd35 : 26'd20;
	
	timer_l t002(
        .clk(clk), 
        .resetn(reset), 
        .enable(1'b1), 
        .dividend(speed), 
        .time_up(hold)
        );
    timer_l t003(
        .clk(clk), 
        .resetn(reset1), 
        .enable(1'b1), 
        .dividend(26'd100000), 
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
        reset1 = 1'b0;
        done = 1'b0;
        reset_counter = 1'b0;

		case (current_state)
			WAIT: begin
            end
			ERASE: begin
                writeEn = 1'b1;
                draw = 1'b1;
                reset_counter = 1'b1;
            end
			MOVE: begin
				enable_move = 1'b1;
                reset1 = 1'b1;
            end
            DRAW: begin
                reset_counter = 1'b1;
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
    input clk, resetn, enable_color, enable_move, draw, reset_counter, difficulty_hide,
	input [7:0] x_paddle, x_paddle_top,
    output reg [7:0] x_out,
	output reg [6:0] y_out,
	output reg [2:0] color_out,
    output draw_done, player_0_scores, player_1_scores,
    output x_direction, y_direction
);

    wire [7:0] x_pos;
    wire [6:0] y_pos;
    xy_counter_ball movement(
        .clk(clk),
        .resetn(resetn),
        .enable_move(enable_move),
		.x_paddle(x_paddle),
        .x_paddle_top(x_paddle_top),
        .x_out(x_pos),
        .y_out(y_pos),
        .player_0_scores(player_0_scores),
        .player_1_scores(player_1_scores),
        .x_direction(x_direction),
        .y_direction(y_direction)
    );
 
    wire change_color;
    timer_l t8(clk, resetn, 1'b1, 26'd1, change_color_signal);
    reg [2:0] count1;
    always @(posedge change_color_signal) begin
        if (count1 == 3'b111)
            count1 <= 3'b100;
        else
            count1 <= count1 + 1'b1;
    end


    reg [3:0] count;
	always @(posedge clk) begin
		if (!reset_counter)
			count <= 4'b0000;
		else if (count == 4'b1111)
			count <= 4'b0000;
		else
			count <= count + 1'b1;
	end
    assign draw_done = (count == 4'b1111);  
	// assign x_out = x_pos + count[1:0];
	// assign y_out = y_pos + count[3:2];
    wire one_sec, hide;
    timer_s t111(clk, resetn, 1'b1, 26'd1, one_sec);


    // count 5 sec, for hide signal. output 1 every 5 sec
    reg [2:0] count2;
    always @(posedge one_sec) begin
		if (!resetn)
			count2 <= 3'b000;
		else if (count2 == 3'd5)
			count2 <= 3'd0;
		else
			count2 <= count2 + 1'b1;
	end
    assign hide = (count2 == 3'd5);



    always @(*) begin
        x_out = x_pos + count[1:0];
        y_out = y_pos + count[3:2];
        if (hide & difficulty_hide)
            color_out = 3'b000;
        else if ((count == 4'b0000) | (count[1:0] == 2'b00) | (count[3:2] == 2'b00))
            color_out = 3'b000;
        else
            color_out = enable_color ? count1 : 3'b000;
        
    end



endmodule


module xy_counter_ball(
    input clk, resetn, enable_move,
	input [7:0] x_paddle, x_paddle_top,
    output reg [7:0] x_out,
    output reg [6:0] y_out,
    output reg player_0_scores, player_1_scores,
    output reg x_direction, y_direction
);
    reg done;
    wire reset_top, reset_bottom;
    assign reset_bottom = (y_out + 3'd5 > 7'd110); 
    assign reset_top = (y_out < 7'd12);
    always@(posedge enable_move, negedge resetn) begin
        if (!resetn) begin
            x_out <= 8'd80;
            y_out <= 7'd60;
            player_0_scores = 1'b0;
            player_1_scores = 1'b0;
		   end
        else if (reset_top) begin
            x_out <= 8'd80;
            y_out <= 7'd60;
            player_0_scores = 1'b1;
        end
        else if (reset_bottom) begin
            x_out <= 8'd80;
            y_out <= 7'd60;
            player_1_scores = 1'b1;
        end
        else begin
            player_0_scores = 1'b0;
            player_1_scores = 1'b0;
            if (x_direction)
                x_out <= x_out + 1'b1;
            else if (!x_direction)
                x_out <= x_out - 1'b1;
            if (y_direction)
				y_out <= y_out + 1'b1;
			else if (!y_direction)
				y_out <= y_out - 1'b1;
        end
       
    end
 
    // reg x_direction;
    // reg y_direction;
    always @(posedge clk) begin
            if (!resetn)
                x_direction <= 1'b1;
            else 
            begin
                if (x_direction) 
                begin
                    if (x_out + 2'd3 > 8'd108)
                        x_direction <= 1'b0;
                    else
                        x_direction <= 1'b1;
                end

                else
                begin
                    if (x_out == 8'd51)
                        x_direction <= 1'b1;
                    else
                        x_direction <= 1'b0;
                end

            end

        end
    always @(posedge clk) begin
		if (!resetn)
			y_direction <= 1;
		else begin
			if (y_direction) begin
				if (((y_out + 2'd3 >= 7'd107) & (y_out <=7'd106)) & (((x_out + 3'd3 >= x_paddle) & (x_out <= x_paddle ))    | x_out <= 7'd60 | x_out >= 7'd100)) 
                    y_direction <= 1'b0;
				else
					y_direction <= 1'b1;
			end
			else begin
				if ((y_out <= 7'd12) & (y_out > 7'd10) & (((x_out + 3'd3 >= x_paddle_top) & (x_out <= x_paddle_top))    | x_out <= 7'd60 | x_out >= 7'd100))
					y_direction <= 1'b1;
				else
					y_direction <= 1'b0;
			end
		end
	end
endmodule