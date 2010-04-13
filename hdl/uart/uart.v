module uart #(
  // UART parameters
  parameter BYTESIZE = 8,              // transfer size in bits
  parameter PARITY   = "NONE",         // parity type "EVEN", "ODD", "NONE"
  parameter STOPSIZE = 1,              // number of stop bits
  parameter N_BIT    = 2,              // clock cycles per bit
  parameter N_LOG    = $clog2(N_BIT),  // size of boudrate generator counter
  // Avalon parameters
  parameter AAW = 1,     // address width
  parameter ADW = 32,    // data width
  parameter ABW = ADW/8  // byte enable width
)(
  // system signals
  input                clk,  // clock
  input                rst,  // reset (asynchronous)
  // Avalon MM interface
  input                avalon_read,
  input                avalon_write,
  input      [ADW-1:0] avalon_writedata,
  output     [ADW-1:0] avalon_readdata,
  output               avalon_waitrequest,
  // receiver status
  output reg           status_irq,  // interrupt
  output reg           status_err,  // error
  // UART
  input                uart_rxd,  // receive
  output reg           uart_txd   // transmit
);

// UART transfer length
localparam UTL = BYTESIZE + (PARITY!="NONE") + STOPSIZE;

// parity option
localparam PRT = (PARITY!="ODD");

// Avalon signals
wire avalon_trn_w;
wire avalon_trn_r;

// baudrate signals
reg    [N_LOG-1:0] txd_bdr, rxd_bdr;
reg                txd_ena, rxd_ena;

// UART signals
reg                txd_run, rxd_run;  // transfer run status
reg          [3:0] txd_cnt, rxd_cnt;  // transfer length counter
reg [BYTESIZE-1:0] txd_dat, rxd_dat;  // data shift register
reg                txd_prt, rxd_prt;  // parity register

reg [BYTESIZE-1:0] data;
reg                parity;

//////////////////////////////////////////////////////////////////////////////
// Avalon logic
//////////////////////////////////////////////////////////////////////////////

// avalon transfer status
assign avalon_waitrequest = avalon_read | txd_run;
assign avalon_trn_w = avalon_write & ~avalon_waitrequest;
assign avalon_trn_r = avalon_read  & ~avalon_waitrequest;

//////////////////////////////////////////////////////////////////////////////
// UART transmitter
//////////////////////////////////////////////////////////////////////////////

// baudrate generator from clock (it counts down to 0 generating a baud pulse)
always @ (posedge clk, posedge rst)
if (rst) txd_bdr <= N_BIT-1;
else     txd_bdr <= ~|txd_bdr ? N_BIT-1 : txd_bdr - txd_run;

// enable signal for shifting logic
always @ (posedge clk, posedge rst)
if (rst)  txd_ena <= 1'b0;
else      txd_ena <= (txd_bdr == 'd1);

// bit counter
always @ (posedge clk, posedge rst)
if (rst)             txd_cnt <= 0;
else begin
  if (avalon_trn_w)  txd_cnt <= UTL;
  else if (txd_ena)  txd_cnt <= txd_cnt - 1;
end

// shift status
always @ (posedge clk, posedge rst)
if (rst)             txd_run <= 1'b0;
else begin
  if (avalon_trn_w)  txd_run <= 1'b1;
  else if (txd_ena)  txd_run <= txd_cnt != 4'd0;
end

// data shift register
always @ (posedge clk)
  if (avalon_trn_w)  txd_dat <= avalon_writedata[BYTESIZE-1:0];
  else if (txd_ena)  txd_dat <= {1'b1, txd_dat[BYTESIZE-1:1]};

// parity register
always @ (posedge clk)
  if (avalon_trn_w)  txd_prt <= PRT;
  else if (txd_ena)  txd_prt <= txd_prt ^ txd_dat[0];

// output register
always @ (posedge clk, posedge rst)
if (rst)             uart_txd <= 1'b1;
else begin
  if (avalon_trn_w)  uart_txd <= 1'b0;
  else if (txd_ena)  uart_txd <= ((PARITY!="NONE") & (txd_cnt==STOPSIZE)) ? txd_prt : txd_dat[0];
end

//////////////////////////////////////////////////////////////////////////////
// UART receiver
//////////////////////////////////////////////////////////////////////////////

reg uart_rxd_dly;

// delay uart_rxd and detect a start negative edge
always @ (posedge clk)
uart_rxd_dly <= uart_rxd;

assign rxd_start = uart_rxd_dly & ~uart_rxd;

// baudrate generator from clock (it counts down to 0 generating a baud pulse)
always @ (posedge clk, posedge rst)
if (rst) rxd_bdr <= N_BIT-1;
else begin
  if (rxd_start)  rxd_bdr <= (N_BIT-1)>>1;
  else            rxd_bdr <= ~|rxd_bdr ? N_BIT-1 : rxd_bdr - rxd_run;
end

// enable signal for shifting logic
always @ (posedge clk, posedge rst)
if (rst)  rxd_ena <= 1'b0;
else      rxd_ena <= (rxd_bdr == 'd1);

// bit counter
always @ (posedge clk, posedge rst)
if (rst)             rxd_cnt <= 0;
else begin
  if (avalon_trn_w)  rxd_cnt <= UTL;
  else if (rxd_ena)  rxd_cnt <= rxd_cnt - 1;
end

// shift status
always @ (posedge clk, posedge rst)
if (rst)             rxd_run <= 1'b0;
else begin
  if (avalon_trn_w)  rxd_run <= 1'b1;
  else if (rxd_ena)  rxd_run <= rxd_cnt != 4'd0;
end

// data shift register
always @ (posedge clk)
  if (rxd_ena)       rxd_dat <= {uart_rxd, rxd_dat[BYTESIZE-1:1]};

// parity register
always @ (posedge clk)
  if (rxd_start)     rxd_prt <= PRT;
  else if (rxd_ena)  rxd_prt <= rxd_prt ^ uart_rxd;

assign rxd_end = ~|rxd_cnt & rxd_ena;

// avalon read data and parity error
always @ (posedge clk)
  if (rxd_end) {parity, data} <= {rxd_prt, rxd_dat};

// fifo interrupt status
always @ (posedge clk, posedge rst)
if (rst)                 status_irq <= 1'b0;
else begin
  if (rxd_end)           status_irq <= 1'b1;
  else if (avalon_trn_r) status_irq <= 1'b0;
end

// fifo overflow error
always @ (posedge clk, posedge rst)
if (rst)                 status_err <= 1'b0;
else begin
  if (avalon_trn_r)      status_err <= 1'b0;
  else if (rxd_end)      status_err <= status_irq;
end

assign avalon_readdata = {status_irq, status_err, {ADW-BYTESIZE-3{1'b0}}, parity, data};

endmodule
