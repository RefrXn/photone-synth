module reset_delay(clk_50m,rst_n);    //复位延时65536*20ns
   input clk_50m;
   output rst_n;
   reg [15:0]cnt;
   reg rst_n;
  
   always@(posedge clk_50m)
   begin
      if(cnt<16'hffff)
      begin
        cnt<=cnt+1;
        rst_n<=0;
      end
      else
        rst_n<=1;       
   end
endmodule
