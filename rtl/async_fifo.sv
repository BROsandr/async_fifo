module async_fifo #(
  parameter type         data_t = logic [7:0],
  parameter int unsigned DEPTH  = 8
) (
  input         rclk,
  input         wclk,
  input         rrst_n,
  input         wrst_n,
  input  data_t wdata,
  input         winc,
  input         rinc,
  output data_t rdata,
  output        wfull,
  output        rempty
);

  localparam int unsigned        ADDR_WIDTH = $clog2(DEPTH);
  typedef logic [ADDR_WIDTH-1:0] addr_t;
  typedef logic [ADDR_WIDTH  :0] gray_t;

  addr_t waddr, raddr;
  gray_t wptr, rptr, wq2_rptr, rq2_wptr;

  sync_r2w #(
    .data_t (gray_t)
  ) sync_r2w (
    .wclk     (wclk),
    .wrst_n   (wrst_n),
    .wq2_rptr (wq2_rptr),
    .rptr     (rptr)
  );

  sync_w2r #(
    .data_t (gray_t)
  ) sync_w2r (
    .rclk     (rclk),
    .rrst_n   (rrst_n),
    .rq2_wptr (rq2_wptr),
    .wptr     (wptr)
  );

  fifomem #(
    .data_t     (data_t),
    .ADDR_WIDTH (ADDR_WIDTH)
  ) fifomem (
    .wclk   (wclk),
    .wclken (winc),
    .rdata  (rdata),
    .wdata  (wdata),
    .waddr  (waddr),
    .raddr  (raddr),
    .wfull  (wfull)
  );

  rptr_empty #(
    .ADDR_WIDTH (ADDR_WIDTH)
  ) rptr_empty (
    .rclk     (rclk),
    .rrst_n   (rrst_n),
    .rempty   (rempty),
    .raddr    (raddr),
    .rptr     (rptr),
    .rq2_wptr (rq2_wptr),
    .rinc     (rinc)
  );

  wptr_full #(
    .ADDR_WIDTH (ADDR_WIDTH)
  ) wptr_full (
    .wclk     (wclk),
    .wrst_n   (wrst_n),
    .wfull    (wfull),
    .waddr    (waddr),
    .wptr     (wptr),
    .wq2_rptr (wq2_rptr),
    .winc     (winc)
  );
endmodule
