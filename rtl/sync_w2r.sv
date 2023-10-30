module sync_w2r #(
  parameter type data_t = logic [7:0]
) (
  input         rclk,
  input         rrst_n,
  input  data_t wptr,
  output data_t rq2_wptr
);
  data_t rq1_wptr;

  always @(posedge rclk or negedge rrst_n)
    if (!rrst_n) {rq2_wptr,rq1_wptr} <= 0;
    else         {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};
endmodule
