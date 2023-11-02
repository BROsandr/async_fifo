module fifomem #(
  parameter type         data_t     = logic [7:0], // Memory data word width
  parameter int unsigned ADDR_WIDTH = 8            // Number of mem address bits
) (
  input                   clk_w_i,
  input                   w_clk_en_i,
  input  data_t           w_data_i,
  input  [ADDR_WIDTH-1:0] w_addr_i,
  input  [ADDR_WIDTH-1:0] r_addr_i,
  input                   w_full_i,
  output data_t           r_data_o
);

`ifdef VENDORRAM
  // instantiation of a vendor's dual-port RAM
  vendor_ram mem (
    .clk      (clk_w_i),
    .wclken_n (w_full_i),
    .wclken   (w_clk_en_i),
    .dout     (r_data_o),
    .din      (w_data_i),
    .waddr    (w_addr_i),
    .raddr    (r_addr_i)
  );
`else
  // RTL Verilog memory model
  localparam int unsigned DEPTH = 1 << ADDR_WIDTH;
  typedef data_t          mem_t [0:DEPTH-1];
  mem_t                   mem;

  assign r_data_o = mem[r_addr_i];

  always @(posedge clk_w_i)
    if (w_clk_en_i && !w_full_i) mem[w_addr_i] <= w_data_i;
`endif
endmodule
