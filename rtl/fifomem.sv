module fifomem #(
  parameter type         data_t     = logic [7:0], // Memory data word width
  parameter int unsigned ADDR_WIDTH = 8            // Number of mem address bits
) (
  input                   wclk,
  input                   wclken,
  input  data_t           wdata,
  input  [ADDR_WIDTH-1:0] waddr,
  input  [ADDR_WIDTH-1:0] raddr,
  input                   wfull,
  output data_t           rdata
);

`ifdef VENDORRAM
  // instantiation of a vendor's dual-port RAM
  vendor_ram mem (
    .clk      (wclk),
    .wclken_n (wfull),
    .wclken   (wclken),
    .dout     (rdata),
    .din      (wdata),
    .waddr    (waddr),
    .raddr    (raddr)
  );
`else
  // RTL Verilog memory model
  localparam int unsigned DEPTH = 1 << ADDR_WIDTH;
  typedef data_t          mem_t [0:DEPTH-1];
  mem_t                   mem;

  assign rdata = mem[raddr];

  always @(posedge wclk)
    if (wclken && !wfull) mem[waddr] <= wdata;
`endif
endmodule
