module mmu #(
  parameter VAW=32, PAW=32, ASIDW=8, SETS=16, WAYS=4
)(
  input  wire                 clk, rst_n, en, translate_en,
  input  wire [PAW-13:0]      satp_base_ppn,
  input  wire [ASIDW-1:0]     csr_asid,
  input  wire                 req_valid,
  input  wire [VAW-1:0]       req_va,
  input  wire [1:0]           req_acc,      // 00 IF, 01 LD, 10 ST
  input  wire                 req_priv,     // 0 U, 1 S
  output reg                  rsp_valid,
  output reg  [PAW-1:0]       rsp_pa,
  output reg                  rsp_fault, rsp_xfault
);
  wire [VAW-13:0] vpn = req_va[VAW-1:12];
  wire [11:0] off = req_va[11:0];

  wire tlb_hit; wire [PAW-13:0] tlb_ppn; wire pR,pW,pX,pU,pV;
  tlb #(.VAW(VAW),.PAW(PAW),.ASIDW(ASIDW),.SETS(SETS),.WAYS(WAYS)) UTLB (
    .clk(clk), .rst_n(rst_n), .en(en), .vpn(vpn), .asid(csr_asid),
    .hit(tlb_hit), .ppn(tlb_ppn), .perm_r(pR), .perm_w(pW), .perm_x(pX), .perm_u(pU), .valid(pV),
    .refill(1'b0), .rf_vpn('0), .rf_asid('0), .rf_ppn('0), .rf_r(0), .rf_w(0), .rf_x(0), .rf_u(0), .rf_v(0)
  );

  wire acc_if = (req_acc==2'b00), acc_ld=(req_acc==2'b01), acc_st=(req_acc==2'b10);
  wire allow, pf, xf;
  perm_check UPM(.priv(req_priv), .acc_load(acc_ld), .acc_store(acc_st), .acc_ifetch(acc_if),
                 .pV(pV), .pR(pR), .pW(pW), .pX(pX), .pU(pU),
                 .allow(allow), .pfault(pf), .xfault(xf));

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      rsp_valid <= 0; rsp_pa <= 0; rsp_fault <= 0; rsp_xfault <= 0;
    end else if(en && req_valid) begin
      if(!translate_en) begin
        rsp_valid <= 1; rsp_pa <= req_va; rsp_fault <= 0; rsp_xfault <= 0;
      end else if (tlb_hit) begin
        rsp_valid <= 1;
        if(allow) begin rsp_pa <= {tlb_ppn, off}; rsp_fault <= 0; rsp_xfault <= 0; end
        else begin rsp_pa <= 0; rsp_fault <= pf; rsp_xfault <= xf; end
      end else begin
        rsp_valid <= 1; rsp_pa <= 0; rsp_fault <= 1; rsp_xfault <= 0; // Page Fault on TLB Miss for base test
      end
    end else begin
      rsp_valid <= 0;
    end
  end
endmodule