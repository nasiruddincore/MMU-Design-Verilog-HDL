module tlb #(
  parameter VAW=32, PAW=32, ASIDW=8, SETS=16, WAYS=4
)(
  input  wire                 clk, rst_n, en,
  input  wire [VAW-13:0]      vpn,
  input  wire [ASIDW-1:0]     asid,
  output reg                  hit,
  output reg  [PAW-13:0]      ppn,
  output reg                  perm_r, perm_w, perm_x, perm_u, valid,
  input  wire                 refill,
  input  wire [VAW-13:0]      rf_vpn,
  input  wire [ASIDW-1:0]     rf_asid,
  input  wire [PAW-13:0]      rf_ppn,
  input  wire                 rf_r, rf_w, rf_x, rf_u, rf_v
);
  localparam IDXW = $clog2(SETS);
  wire [IDXW-1:0] idx = vpn[IDXW-1:0];

  reg [VAW-13:0]   tag [0:SETS-1][0:WAYS-1];
  reg [ASIDW-1:0]  tag_asid[0:SETS-1][0:WAYS-1];
  reg              vbit[0:SETS-1][0:WAYS-1];
  reg [PAW-13:0]   data_ppn[0:SETS-1][0:WAYS-1];
  reg              pR[0:SETS-1][0:WAYS-1], pW[0:SETS-1][0:WAYS-1], pX[0:SETS-1][0:WAYS-1], pU[0:SETS-1][0:WAYS-1];

  integer w;
  always @(*) begin
    hit=1'b0; ppn='0; perm_r=0; perm_w=0; perm_x=0; perm_u=0; valid=0;
    for(w=0; w<WAYS; w=w+1) begin
      if(vbit[idx][w] && tag[idx][w]==vpn && tag_asid[idx][w]==asid) begin
        hit=1'b1; ppn=data_ppn[idx][w];
        perm_r=pR[idx][w]; perm_w=pW[idx][w]; perm_x=pX[idx][w]; perm_u=pU[idx][w]; valid=1'b1;
      end
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      integer i,j; for(i=0;i<SETS;i=i+1) for(j=0;j<WAYS;j=j+1) vbit[i][j]<=1'b0;
    end else if(en && refill) begin
      tag[idx][0] <= rf_vpn; // Direct mapped refill for simplicity in demo
      tag_asid[idx][0] <= rf_asid;
      data_ppn[idx][0] <= rf_ppn;
      pR[idx][0] <= rf_r; pW[idx][0] <= rf_w; pX[idx][0] <= rf_x; pU[idx][0] <= rf_u;
      vbit[idx][0] <= rf_v;
    end
  end
endmodule