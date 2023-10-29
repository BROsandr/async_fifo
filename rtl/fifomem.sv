module fifomem #(
  parameter DATASIZE = 8, // Memory data word width
  parameter ADDRSIZE = 4  // Number of mem address bits
) (
  input                 wclk,
  input                 wclken,
  input  [DATASIZE-1:0] wdata,
  input  [ADDRSIZE-1:0] waddr,
  input  [ADDRSIZE-1:0] raddr,
  input                 wfull,
  output [DATASIZE-1:0] rdata
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
  localparam DEPTH = 1<<ADDRSIZE;
  reg [DATASIZE-1:0] mem [0:DEPTH-1];

  assign rdata = mem[raddr];

  always @(posedge wclk)
    if (wclken && !wfull) mem[waddr] <= wdata;
`endif
endmodule
