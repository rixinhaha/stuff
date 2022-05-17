
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SYSU
// Engineer: liuzs
// 
// Create Date: 2018/12/03 21:37:38
// Design Name: 
// Module Name: ov7670_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ov7670_top(
input  clk100,
input  OV7670_VSYNC, //SCCB???????????
input  OV7670_HREF,  //SCCB???????????
input  OV7670_PCLK,  //??????
output OV7670_XCLK,  //???????
output OV7670_SIOC, 
inout  OV7670_SIOD,
input [7:0] OV7670_D, //?????

output[3:0] LED,
output[3:0] vga_red,
output[3:0] vga_green,
output[3:0] vga_blue,
output vga_hsync, //????
output vga_vsync, //???
input btn,
output pwdn,
output reset
);
wire [16:0] frame_addr;
wire [16:0] capture_addr;   
//wire  capture_we;  
wire  config_finished;  
wire  clk25; 
wire  clk50;     
wire  resend;        
wire [11:0] frame_pixel;  
wire [11:0]  data_12;

//vga
wire hsync;
wire vsync;
wire [9:0] sx;
wire [9:0] sy;
wire display_enable;
reg valid_address;
  
assign pwdn = 0; //0??????1??????
assign reset = 1;
  

assign LED = {3'b0,config_finished};
assign  	OV7670_XCLK = clk25;  
debounce   btn_debounce(
		.clk(clk50),
		.i(btn),
		.o(resend)
);
 
 vga   vga_display (
		.clk25       (clk25),
		.vga_red    (vga_red),
		.vga_green   (vga_green),
		.vga_blue    (vga_blue),
		.vga_hsync   (vga_hsync),
		.vga_vsync  (vga_vsync),
		.HCnt       (),
		.VCnt       (),

		.frame_addr   (frame_addr),
		.frame_pixel  (frame_pixel)
 );




//always @(*) begin
//    valid_address = (sx >= 128 && sx < 304) && (sy >= 200 && sy < 344);
//end



//always @(posedge clk25) begin
//    if (de && valid_address) begin
        
//    end
//end
 
 blk_mem_gen_0 u_frame_buffer(
		.clka (OV7670_PCLK),
		.wea  (1'b1),
		.addra (capture_addr),
		.dina  (data_12),

		.clkb   (clk25),
		.addrb (frame_addr),
		.doutb (frame_pixel)
 );
 

 ov7670_capture capture(         //??ov7670?????
 		.pclk  (OV7670_PCLK),    //??????
 		.vsync (OV7670_VSYNC),   //???
 		.href  (OV7670_HREF),    //???? 
 		.d     ( OV7670_D),      //??????
 		.addr  (capture_addr),   //??????
 		.dout( data_12),         //12?????
 		.we   ()
 	);
 
I2C_AV_Config IIC(                 //???SCCB?????
 		.iCLK   ( clk25),          //??25MHz??
 		.iRST_N (! resend),        //??
 		.Config_Done ( config_finished),    //?ov7670??????????????config_finished??
 		.I2C_SDAT  ( OV7670_SIOD),   //???? 
 		.I2C_SCLK  ( OV7670_SIOC),   //??????
 		.LUT_INDEX (),
 		.I2C_RDATA ()
 		); 
		
clk_wiz_0 clk_div(
		.clk_in1 (clk100),
		.clk_out1  (clk50),
		.clk_out2 (clk25)
);

endmodule