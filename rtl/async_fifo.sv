module async_fifo #(
  parameter DSIZE = 8,
  parameter ASIZE = 4
) (
  input              rclk,
  input              wclk,
  input              rrst_n,
  input              wrst_n,
  input  [DSIZE-1:0] wdata,
  input              winc,
  input              rinc,
  output [DSIZE-1:0] rdata,
  output             wfull,
  output             rempty
);

  wire [ASIZE-1:0] waddr, raddr;
  wire [ASIZE:0]   wptr, rptr, wq2_rptr, rq2_wptr;

  sync_r2w #(
    .ADDRSIZE (ASIZE)
  ) sync_r2w (
    .wclk     (wclk),
    .wrst_n   (wrst_n),
    .wq2_rptr (wq2_rptr),
    .rptr     (rptr)
  );

  sync_w2r #(
    .ADDRSIZE (ASIZE)
  ) sync_w2r (
    .rclk     (rclk),
    .rrst_n   (rrst_n),
    .rq2_wptr (rq2_wptr),
    .wptr     (wptr)
  );

  fifomem #(DSIZE, ASIZE) fifomem (
    .wclk   (wclk),
    .wclken (winc),
    .rdata  (rdata),
    .wdata  (wdata),
    .waddr  (waddr),
    .raddr  (raddr),
    .wfull  (wfull)
  );

  rptr_empty #(ASIZE) rptr_empty (
    .rclk     (rclk),
    .rrst_n   (rrst_n),
    .rempty   (rempty),
    .raddr    (raddr),
    .rptr     (rptr),
    .rq2_wptr (rq2_wptr),
    .rinc     (rinc)
  );

  wptr_full #(ASIZE) wptr_full (
    .wclk     (wclk),
    .wrst_n   (wrst_n),
    .wfull    (wfull),
    .waddr    (waddr),
    .wptr     (wptr),
    .wq2_rptr (wq2_rptr),
    .winc     (winc)
  );
endmodule
