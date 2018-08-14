module control_paddle_top(
	input clk, resetn, go, draw_done,
	output reg enable_color, enable_move, writeEn, draw,
    output reg done
    );
    
    wire hold, hold1;
	
	timer_l t002(
        .clk(clk), 
        .resetn(reset), 
        .enable(1'b1), 
        .dividend(26'd32), 
        .time_up(hold)
        );
    timer_l t003(
        .clk(clk), 
        .resetn(reset1), 
        .enable(1'b1),
        .dividend(26'd10000000),
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

		case (current_state)
			WAIT: begin
            end
			ERASE: begin
                writeEn = 1'b1;
                draw = 1'b1;
            end
           
			MOVE: begin
				enable_move = 1'b1;
                reset1 = 1'b1;
			end
            
            DRAW: begin
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


module datapath_paddle_top(
    input clk, resetn, enable_color, enable_move, left, right, draw,
    output [7:0] x_out,
	output [6:0] y_out,
	output [2:0] color_out,
    output draw_done

);

    wire [7:0] x_pos;
    wire [6:0] y_pos;
    xy_counter_paddle_top movement1(
        .clk(clk),
        .resetn(resetn),
		.enable_move(enable_move),
		.left(left),
		.right(right),
        .x_out(x_pos),
        .y_out(y_pos)			        
    );

    paddle_draw_top data1(
        .clk(clk),
        .draw(draw),    
        .x_in(x_pos),
        .y_in(y_pos),
        .x_out(x_out),
        .y_out(y_out),
        .done(draw_done)        
    );

    assign color_out = enable_color ? 3'b010 : 3'b000;

endmodule


module paddle_draw_top(
	input clk, draw,
	input [7:0] x_in, 
	input [6:0] y_in,
	output [7:0] x_out, 
	output [6:0] y_out,
    output done 
);
	wire resetn;
	reg [3:0] count;
	assign resetn = draw;

	always @(posedge clk) begin
		if (!resetn)
			count <= 4'b0000;
		else if (count == 4'b1111)
			count <= 4'b0000;
		else
			count <= count + 1'b1;
	end

    assign done = (count == 4'b1111);
	assign x_out = x_in + count[3:0];
	assign y_out = y_in;

endmodule


module xy_counter_paddle_top(
    input clk, resetn, enable_move, left, right,
    output reg [7:0] x_out,
    output [6:0] y_out
);

    always@(posedge enable_move, negedge resetn) begin
            if (!resetn)
                x_out <= 8'd75;
            else if (enable_move) begin
                if (right) begin
                    if (x_out +5'd17 > 8'd110)
                        x_out <= x_out;               
                    else
                        x_out <= x_out + 1'b1;
                end
                else if (left) begin
					if (x_out <= 8'd51)
						 x_out <= x_out;
					else
                    	x_out <= x_out - 1'b1;
            	end
			end

    end
    assign y_out = 7'd12;

endmodule
