module draw_border(
	input clk, resetn, go, go2,
	output reg writeEn,
    output reg done,
    output reg [7:0] x_out,
    output reg [6:0] y_out,
    output reg [2:0] color_out
    );
    reg [7:0] x;
    reg [6:0] y;
    
	reg [2:0] current_state, next_state;


    always @(posedge clk) begin
		if (!resetn)
			current_state <= WAIT;
		else
			current_state <= next_state;
	end

	localparam  WAIT = 4'd0,
                TOP = 4'd1, 
                LEFT = 4'd2,
				BOTTOM = 4'd3,                 
				RIGHT = 4'd4,
                DONE = 4'd5;
    
    wire top_done, bottom_done, left_done, right_done;
    always @(*)
    begin: state_table
        case (current_state)
            WAIT: next_state = go ? TOP : WAIT;
            TOP: next_state = counter1_done ? LEFT : TOP;
            LEFT: next_state = counter2_done ? BOTTOM : LEFT;
            BOTTOM: next_state = counter1_done ? RIGHT : BOTTOM;
            RIGHT: next_state = counter2_done ? DONE : RIGHT;
            DONE: next_state = go2 ? WAIT : DONE;
		endcase
	end
 
    reg ld_top, ld_bottom, ld_left, ld_right, reset_counter1, reset_counter2;
	always @(*)
	begin
        done = 1'b0;
        ld_top = 1'b0;
        ld_bottom = 1'b0;
        ld_left = 1'b0;
        ld_right = 1'b0;
        reset_counter1 = 1'b0;
        reset_counter2 = 1'b0;
		case (current_state)
			
			TOP: begin
                ld_top = 1'b1;
                reset_counter1 = 1'b1;
                writeEn = 1'b1;
            end
            LEFT: begin
                ld_left = 1'b1;
                reset_counter2 = 1'b1;
                writeEn = 1'b1;
            end
			BOTTOM: begin
                ld_bottom = 1'b1;
                reset_counter1 = 1'b1;
                writeEn = 1'b1;
			end
                       
            RIGHT: begin
                ld_right = 1'b1;
                reset_counter2 = 1'b1;
                writeEn = 1'b1;
            end
            DONE: begin
                done = 1'b1;
            end
		endcase
	end


	always @(posedge clk) begin
		if (!resetn) begin
			x <= 8'b0;
			y <= 7'b0;
		end
		else begin
			if (ld_top || ld_left) begin
				x <= 8'd50;
                y <= 7'd10;
			end
			else if (ld_bottom) begin
				x <= 8'd50;
				y <= 7'd110;
			end
			else if (ld_right) begin
				x <= 8'd110;
				y <= 7'd10;																							
			end
		end
	end


	reg [6:0] counter1;
	//counter
	always @(posedge clk) begin
		if (!reset_counter1)
			counter1 <= 7'd0;
		else begin
            if (counter1 < 7'd60)
                counter1 <= counter1 + 1'b1;	
            else
                counter1 <= 7'd0;
        end
    end
    assign counter1_done = (counter1 == 7'd60);
    reg [7:0] counter2;
    always @(posedge clk) begin
        if (!reset_counter2)
			counter2 <= 8'd0;
        else begin
            if (counter2 < 8'd100)
                counter2 <= counter2 + 1'b1;
            else
                counter2 <= 8'd0;
        end
    end
    assign counter2_done = (counter2 == 8'd100);
	


	always @(*) begin
		x_out = (ld_top || ld_bottom) ? (x + counter1[6:0]) : x;
		y_out = (ld_left || ld_right) ? (y + counter2[7:0]) : y;
        if (ld_top | ld_bottom)
            color_out = (counter1 < 7'd11 | counter1 > 7'd50) ? 3'b111 : 3'b000;
        else
            color_out = 3'b111;
	end

endmodule