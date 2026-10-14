// rtl/ptw.v (1-level Page-Table Walker FSM)
module ptw #(
  parameter VAW=32, PAW=32
)(
  input  wire         clk, rst_n, en,
  input  wire         miss_req,
  input  wire [VAW-13:0] miss_vpn,
  input  wire [7:0]   miss_asid,
  input  wire [PAW-13:0] satp_base_ppn,
  // memory read port
  output reg          mem_req,
  output reg  [PAW-1:0] mem_addr,
  input  wire         mem_rdy,
  input  wire [31:0]  mem_rdata,
  input  wire         mem_err,
  // refill out
  output reg          rf_valid,
  output reg  [VAW-13:0] rf_vpn,
  output reg  [7:0]   rf_asid,
  output reg  [PAW-13:0] rf_ppn,
  output reg          rf_r, rf_w, rf_x, rf_u, rf_v,
  output reg          bus_fault
);
  // Icarus-compatible state encoding
  localparam [1:0] IDLE = 2'b00,
                   READ = 2'b01,
                   OUT  = 2'b10;
  reg [1:0] st;
  
  wire [PAW-1:0] pte_addr = {satp_base_ppn, 12'b0} + {miss_vpn, 2'b00};

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin st <= IDLE; mem_req <= 0; rf_valid <= 0; bus_fault <= 0; end
    else if(en) begin
      rf_valid <= 0; bus_fault <= 0;
      case(st)
        IDLE: if(miss_req) begin mem_req <= 1; mem_addr <= pte_addr; st <= READ; end
        READ: if(mem_rdy) begin
                mem_req <= 0;
                if(mem_err) begin bus_fault <= 1; st <= IDLE; end
                else begin
                  rf_vpn  <= miss_vpn; rf_asid <= miss_asid;
                  rf_ppn  <= mem_rdata;
                  rf_v    <= mem_rdata[11];
                  rf_r    <= mem_rdata[10];
                  rf_w    <= mem_rdata[9];
                  rf_x    <= mem_rdata[8];
                  rf_u    <= mem_rdata[7];
                  rf_valid<= 1'b1; st <= OUT;
                end
              end
        OUT:  st <= IDLE;
        default: st <= IDLE;
      endcase
    end
  end
endmodule