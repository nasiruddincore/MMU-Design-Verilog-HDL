`timescale 1ns/1ps
module mmu_tb;
  reg clk=0, rst_n=0, en=1, translate_en=1;
  reg [19:0] satp_base_ppn = 20'h00010;
  reg [7:0] csr_asid = 8'h11;
  reg req_valid; reg [31:0] req_va; reg [1:0] req_acc; reg req_priv;
  wire rsp_valid; wire [31:0] rsp_pa; wire rsp_fault, rsp_xfault;

  mmu DUT(.clk(clk),.rst_n(rst_n),.en(en),.translate_en(translate_en),
          .satp_base_ppn(satp_base_ppn),.csr_asid(csr_asid),
          .req_valid(req_valid),.req_va(req_va),.req_acc(req_acc),.req_priv(req_priv),
          .rsp_valid(rsp_valid),.rsp_pa(rsp_pa),.rsp_fault(rsp_fault),.rsp_xfault(rsp_xfault));

  always #5 clk=~clk;

  initial begin
    $dumpfile("mmu.vcd"); $dumpvars(0,mmu_tb);
    #50 rst_n=1;
    
    // Test Bypass
    translate_en=0; req_va=32'hCAFEBABE; req_acc=2'b01; req_priv=0; req_valid=1;
    #10 translate_en=1; req_valid=0;

    // Test TLB Miss (Fault)
    #20 req_va=32'h00012000; req_valid=1;
    #10 req_valid=0;

    #100 $finish;
  end
endmodule