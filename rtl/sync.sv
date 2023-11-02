module sync #(
  parameter type data_t = logic [7:0]
) (
  input         clk_i,
  input         rst_ni,
  input  data_t in_i,
  output data_t out_o
);
  data_t out_ff2, out_ff;

  always @(posedge clk_i or negedge rst_ni)
    if   (!rst_ni) {out_ff2,out_ff} <= '0;
    else           {out_ff2,out_ff} <= {out_ff, in_i};

  assign out_o = out_ff2;
endmodule
