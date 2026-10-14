// tb/mem_bram.v (1-cycle ready BRAM memory model)
module mem_bram #(parameter PAW=32, DEPTH=4096)(
  input  wire          clk,
  input  wire          req,
  input  wire [PAW-1:0] addr,
  output reg           rdy,
  output reg  [31:0]   rdata,
  output reg           err
);
  reg [31:0] mem [0:DEPTH-1];
  
  always @(posedge clk) begin
    rdy <= 1'b0; 
    err <= 1'b0;
    if (req) begin
      rdata <= mem[addr[13+:12]]; // coarse index mapping for demo
      rdy   <= 1'b1;
    end
  end
endmodule