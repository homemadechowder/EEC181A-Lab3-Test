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
	input [0:0] reset_n
	// input [0:0] ready,
	// output reg [0:0] done = 0
	);

	reg [3:0] state1 = 4'b0;
	reg [3:0] state2 = 4'b0;
	reg [15:0] value1 = 16'b0;
	reg [15:0] value2 = 16'b0;
	reg [0:0] readcomplete = 1'b0;

	always @ (posedge clk)
	begin
		case(state1 [3:0])
			// Order two input from min to max
			// Send read instructions for first value
			4'b0000:
			begin
				write_n [0:0] <= 1'b1;
				read_n [0:0] <= 1'b0;
				address [31:0] <= 0;
				chipselect [0:0] <= 1'b1;
				byteenable [1:0] <= 2'b11;
				if(!waitrequest)
				begin
					state1 [3:0] <= 4'b0001;
				end
			end
			// Send read instructions for second value
			4'b0001:
			begin
				address [31:0] <= 1;
				if(!waitrequest)
				begin
					state1 [3:0] <= 4'b0010;
				end
			end
			// Compare the two values, determine if switch necessary
			4'b0010:
			begin
				if(readcomplete)
				begin
					read_n [0:0] <= 1'b1;
					if(value1 [15:0] > value2 [15:0])
					begin
						state1 [3:0] <= 4'b0011;
					end
					else
					begin
						state1 [3:0] <= 4'b0000;
					end
				end
			end
			
			// Switch values in SDRAM
			// Write value2 to SDRAM_BASE + 0
			4'b0011:
			begin
				write_n [0:0] <= 1'b0;
				address [31:0] <= 0;
				writedata [15:0] <= value2 [15:0];
				if(!waitrequest)
				begin
					state1 [3:0] <= 4'b0100;
				end
			end
			// Write value1 to SDRAM_BASE + 1
			4'b0100:
			begin
				address [31:0] <= 1;
				writedata [15:0] <= value1 [15:0];
				if(!waitrequest)
				begin
					state1 [3:0] <= 4'b0000;
				end
			end
		endcase

		// Store readdata into local registers
		case(state2 [3:0])
			4'b0000:
			begin
				readcomplete [0:0] <= 1'b0;
				if(readdatavalid)
				begin
					value1 [15:0] <= readdata [15:0];
					state2 [3:0] <= 4'b0001;
				end
			end
			4'b0001:
			begin
				if(readdatavalid)
				begin
					value2 [15:0] <= readdata [15:0];
					state2 [3:0] <= 4'b0000;
					readcomplete [0:0] <= 1'b1;
				end
			end
		endcase
	end

endmodule
