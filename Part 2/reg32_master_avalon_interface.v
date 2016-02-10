// Samuel Sugimoto, Chen Xie
// EEC181A, W'16
// Group Name: Units
// Lab 2, reg32_master_avalon_interface.v

module reg32_master_avalon_interface(
	input clk, 
	input reset_n,
	input waitrequest, 
	output reg [3:0] byteenable, 
	output reg [0:0] read, 
	input [31:0] readdata, 
	output reg [0:0] write, 
	output reg [31:0] writedata, 
	input readdatavalid);

	reg [25:0] counter = 26'b0;
	reg [1:0] state = 2'b00;
	reg [31:0] data = 31'b00;
	always @ (posedge clk)
	begin
		// wait 1 second
		if(counter < 100 && state == 2'b00)
		begin
			counter = counter + 1;
		end
		// 1 second elapsed
		else
		begin
			case(state[1:0])
				// Read-in data, first clock cycle
				2'b00:
				begin
					read [0:0] <= 1;
					byteenable [3:0] <= 4'b1111;
					state <= 2'b01;
				end
				// Read-in data, second clock cycle
				2'b01:
				begin
					data [31:0] <= readdata [31:0] + 1'b1;
					state <= 2'b10;
				end
				// Analyze read-in data
				2'b10:
				begin
					read [0:0] <= 0;
					byteenable [3:0] <= 4'b0000;
					// Data != 0, increment and write back
					if(data [31:0] != 32'b00)
					begin
						write [0:0] <= 1;
						byteenable [3:0] <= 4'b1111;
						writedata [31:0] <= data [31:0];
						state <= 2'b11;
					end
					// Data == 0, do not write
					else
					begin
						state <= 2'b00;
					end
				end

				// Close out write
				2'b11:
				begin
					write [0:0] <= 0;
					byteenable [3:0] <= 4'b0000;
					state <= 2'b00;
				end
			endcase
			counter = 0;
		end
	end
endmodule
