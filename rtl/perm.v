module perm_check(
  input  wire priv,           // 0:User, 1:Supervisor
  input  wire acc_load, acc_store, acc_ifetch,
  input  wire pV, pR, pW, pX, pU,
  output wire allow,
  output wire pfault, xfault
);
  wire user_ok = (~priv) ? (pU==1'b1) : 1'b1;
  wire r_ok = acc_load  ? (pR & user_ok) : 1'b1;
  wire w_ok = acc_store ? (pW & user_ok) : 1'b1;
  wire x_ok = acc_ifetch? (pX & user_ok) : 1'b1;

  assign allow  = pV & r_ok & w_ok & x_ok;
  assign pfault = pV & user_ok & ((acc_load  & ~pR) | (acc_store & ~pW));
  assign xfault = pV & user_ok & (acc_ifetch & ~pX);
endmodule