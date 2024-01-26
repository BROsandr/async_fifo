module async_fifo #(
  parameter type         data_t = logic [7:0],
  parameter int unsigned DEPTH  = 8
) (
  input         clk_r_i,
  input         clk_w_i,
  input         rst_r_ni,
  input         rst_w_ni,
  input  data_t w_data_i,
  input         w_en_i,
  input         r_en_i,
  output data_t r_data_o,
  output        w_full_o,
  output        r_empty_o
);

  localparam int unsigned        ADDR_WIDTH = (DEPTH > 4) ? $clog2(DEPTH) : 3;
  typedef logic [ADDR_WIDTH-1:0] addr_t;
  typedef logic [ADDR_WIDTH  :0] gray_t;

  addr_t w_addr, r_addr;
  gray_t w_ptr, r_ptr, w2r_ptr, r2w_ptr;

  sync #(
    .data_t (gray_t)
  ) r2w_sync (
    .clk_i  (clk_w_i),
    .rst_ni (rst_w_ni),
    .in_i   (r_ptr),
    .out_o  (r2w_ptr)
  );

  sync #(
    .data_t (gray_t)
  ) w2r_sync (
    .clk_i  (clk_r_i),
    .rst_ni (rst_r_ni),
    .in_i   (w_ptr),
    .out_o  (w2r_ptr)
  );

  fifomem #(
    .data_t     (data_t),
    .ADDR_WIDTH (ADDR_WIDTH)
  ) fifomem (
    .clk_w_i    (clk_w_i),
    .w_clk_en_i (w_en_i),
    .w_data_i   (w_data_i),
    .w_addr_i   (w_addr),
    .r_addr_i   (r_addr),
    .w_full_i   (w_full_o),
    .r_data_o   (r_data_o)
  );

  r_ptr_empty #(
    .ADDR_WIDTH (ADDR_WIDTH)
  ) r_ptr_empty (
    .clk_r_i   (clk_r_i),
    .rst_r_ni  (rst_r_ni),
    .w2r_ptr_i (w2r_ptr),
    .r_en_i    (r_en_i),
    .r_empty_o (r_empty_o),
    .r_addr_o  (r_addr),
    .r_ptr_o   (r_ptr)
  );

  w_ptr_full #(
    .ADDR_WIDTH (ADDR_WIDTH)
  ) w_ptr_full (
    .clk_w_i   (clk_w_i),
    .rst_w_ni  (rst_w_ni),
    .r2w_ptr_i (r2w_ptr),
    .w_en_i    (w_en_i),
    .w_full_o  (w_full_o),
    .w_addr_o  (w_addr),
    .w_ptr_o   (w_ptr)
  );
endmodule
