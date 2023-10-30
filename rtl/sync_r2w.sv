module sync_r2w #(
  parameter type data_t = logic [7:0]
) (
  input         wclk,
  input         wrst_n,
  input  data_t rptr,
  output data_t wq2_rptr
);
  data_t wq1_rptr;

  always @(posedge wclk or negedge wrst_n)
    if (!wrst_n) {wq2_rptr,wq1_rptr} <= 0;
    else         {wq2_rptr,wq1_rptr} <= {wq1_rptr,rptr};
endmodule
