// Samuel Sugimoto, Chen Xie
// EEC181A, W'16
// Group Name: Units
// Lab 3, sdram_master_v2.v

module sdram_master_v2(
	input clk,
	output reg [0:0] read_n = 1,
	output reg [0:0] write_n = 1,
	output reg [0:0] chipselect,
	input [0:0] waitrequest,
	output reg [31:0] address = 0,
	output reg [1:0] byteenable,
	input [0:0] readdatavalid,
	input [15:0] readdata,
	output reg [15:0] writedata,
	input [0:0] reset_n,
	input [0:0] ready,
	output reg [0:0] done = 0,
	output [31:0] hex_led,
	input [9:0] switch,
	output reg [15:0] dataout = 0
	);

	reg [3:0] state1 = 4'b0;
	reg [3:0] state2 = 4'b0;
	reg [15:0] value1 = 16'b0;
	reg [15:0] value2 = 16'b0;
	reg [0:0] readcomplete = 1'b0;
	reg [31:0] addr = 0;
	reg [0:0] waitlow = 1'b0;
	//reg [31:0] addr = 0;
	reg [31:0] data [9:0] = 0;
	reg [3:0]  counter = 0;
	assign hex_led [3:0] = value1 [3:0];
	assign hex_led [7:4] = value2 [3:0];
	assign hex_led [11:8] = state1 [3:0];
	assign hex_led [15:12] = state2 [3:0];
	assign hex_led [19:16] = addr [3:0];
	assign hex_led [23:20] = 4'b0000;
	assign hex_led [24] = ready;
	assign hex_led [25] = done;
	assign hex_led [26] = readcomplete;
	assign hex_led [27] = waitlow;
	assign hex_led [31:28] = 4'b0000;
	
	// Modify State
	always @ (posedge clk)
	begin
		case(state1 [3:0])
			4'b0000:
			begin
				if(ready)
				begin
					state1 [3:0] <= 4'b0001;
				end
			end
			4'b0001:
			begin
				if(readcomplete)
				begin
					state1 [3:0] <= 4'b0010;
				end
			end
			4'b0010:
			begin
				
			end
		endcase
	end

	always @ (posedge clk)
	begin
		case(state1 [3:0])
			4'b0001:
			begin
				read_n <= 0;
				write_n <= 1;
				byteenable <= 2'b11;
				chipselect <= 1'b1;
				address <= (waitrequest == 0) ? addr : address;
				addr <= (addr <10 && waitrequest == 0) ? addr + 1: addr;
			end
		endcase
	end

	always @ (posedge clk)
	begin
		data [counter [3:0]] <= (readdatavalid) ? readdata : 0;
		counter [3:0] <= (readdatavalid) ? counter [3:0] + 1 : counter [3:0];
		readcomplete <= (counter [3:0] > 9) ? 1 : readcomplete;
	end

	always @ (posedge clk)
	begin
		dataout [15:0] <= data [switch[3:0]];
	end


	/*always @ (posedge clk)
	begin
		case(state1 [3:0])
			// Order two input from min to max
			// Wait for ready read
			4'b0000:
			begin
				if(ready == 1'b1)
				begin
					state1 [3:0] <= 4'b0001;
				end
			end
			4'b0001:
			begin
				byteenable <= 2'b11;
				chipselect <= 1;
				write_n <= 1;
				read_n  <= addr < 10 ? 0 : 1;
				address <= (waitrequest == 0) ? addr : address;
				addr <= (waitrequest == 0) ? addr + 1 : addr;
				done <= (addr >= 10) ? 1'b1 : 1'b0;
				state1 [3:0] <= (waitrequest == 0) ? 4'b0010 : state1;
			end
			4'b0010:
			begin
				
			end
		endcase
	end

	always @ (posedge clk)
	begin
		new_data <= (readdatavalid) ? readdata : new_data;
		rx_counter <= (readdatavalid) ? rx_counter + 1 : rx_counter;
	end*/

	/*always @ (posedge clk)
	begin
		case(state1 [3:0])
			// Order two input from min to max
			// Wait for ready read
			4'b0000:
			begin
				if(ready == 1'b1)
				begin
					state1 [3:0] <= 4'b0001;
				end
			end
			// Send read instructions for first value
			4'b0001:
			begin
				readcomplete [0:0] = 1'b0;
				write_n [0:0] <= 1;
				read_n [0:0] <= 0;
				byteenable <= 2'b11;
				chipselect <= 1'b1;
				waitlow <= (waitrequest == 0) ? 1'b1 : waitlow;
				address <= (waitrequest == 0) ? addr : address;
				addr <= (addr < 10 && waitrequest == 0) ? addr + 1 : addr;
				state1 <= (waitrequest == 0) ? 4'b0010 : state1;
				byteenable <= 2'b11;
				chipselect <= 1;
				write_n <= 1;
				read_n  <= 0;
				waitlow <= (waitrequest == 0) ? 1'b1 : waitlow;
				address <= (waitrequest == 0) ? addr : address;
				addr <= (waitrequest == 0) ? addr + 1 : addr;
				state1 <= (waitrequest == 0) ? 4'b0010 : state1;
			end
			// Send read instructions for second value
			4'b0010:
			begin
				//address [31:0] <= 1;
				if(waitrequest == 0)
				begin
					state1 [3:0] <= 4'b0011;
				end
			end
			// Compare the two values, determine if switch necessary
			4'b0011:
			begin
				if(readcomplete == 1)
				begin
					read_n [0:0] <= 1'b1;
					if(value1 [15:0] > value2 [15:0])
					begin
						state1 [3:0] <= 4'b0100;
					end
					else
					begin
						state1 [3:0] <= 4'b0000;
						done <= 1'b1;
					end
				end
			end
			
			// Switch values in SDRAM
			// Write value2 to SDRAM_BASE + 0
			4'b0100:
			begin
				write_n [0:0] <= 1'b0;
				address [31:0] <= 0;
				writedata [15:0] <= value2 [15:0];
				if(waitrequest == 0)
				begin
					state1 [3:0] <= 4'b0101;
				end
			end
			// Write value1 to SDRAM_BASE + 1
			4'b0101:
			begin
				address [31:0] <= 1;
				writedata [15:0] <= value1 [15:0];
				if(waitrequest == 0)
				begin
					state1 [3:0] <= 4'b0000;
					done <= 1'b1;
				end
			end
		endcase

		// Store readdata into local registers
		case(state2 [3:0])
			4'b0000:
			begin
				readcomplete [0:0] <= 1'b0;
				if(readdatavalid == 1)
				begin
					value1 [15:0] <= readdata [15:0];
					state2 [3:0] <= 4'b0001;
				end
			end
			4'b0001:
			begin
				if(readdatavalid == 1)
				begin
					value2 [15:0] <= readdata [15:0];
					state2 [3:0] <= 4'b0000;
					readcomplete [0:0] <= 1'b1;
				end
			end
		endcase
	end*/
	

endmodule
