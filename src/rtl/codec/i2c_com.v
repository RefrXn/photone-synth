  //sclk��sdin���ݴ���ʱ����루i2cд���ƴ��룩
module i2c_com(clock_i2c,          //wm8731���ƽӿڴ�������ʱ�ӣ�0-400khz���˴�Ϊ20khz
               rst_n,     
               ack,              //Ӧ���ź�
               i2c_data,          //sdin�ӿڴ����24λ����
               start,             //��ʼ�����־
               tr_end,           //���������־
               cyc_count,   
               i2c_sclk,          //FPGA��wm8731ʱ�ӽӿ�
               i2c_sdat);         //FPGA��wm8731���ݽӿ�
    input [23:0]i2c_data;
    input rst_n;
    input clock_i2c;
    output [5:0]cyc_count;
    output ack;
    input start;
    output tr_end;
    output i2c_sclk;
    inout i2c_sdat;
    reg [5:0] cyc_count;
    reg reg_sdat;
    reg sclk;
    reg ack1,ack2,ack3;
    reg tr_end;
 
   
    wire i2c_sclk;
    wire i2c_sdat;
    wire ack;
   
    assign ack=ack1|ack2|ack3;
    assign i2c_sclk=sclk|(((cyc_count>=4)&(cyc_count<=30))?~clock_i2c:0);
    assign i2c_sdat=reg_sdat?1'bz:0;
   
   
    always@(posedge clock_i2c or  negedge rst_n)
    begin
       if(!rst_n)
       cyc_count<=6'b111111;
       else begin
       if(start==0)
       cyc_count<=0;
       else if(cyc_count<6'b111111)
       cyc_count<=cyc_count+1;
       end
    end
    always@(posedge clock_i2c or negedge rst_n)
    begin
       if(!rst_n)
       begin
          tr_end<=0;
          ack1<=1;
          ack2<=1;
          ack3<=1;
          sclk<=1;
          reg_sdat<=1;
       end
       else
          case(cyc_count)
        0:begin ack1<=1;ack2<=1;ack3<=1;tr_end<=0;sclk<=1;reg_sdat<=1;end
        1:reg_sdat<=0;            //��ʼ����
        2:sclk<=0;
        3:reg_sdat<=i2c_data[23];
        4:reg_sdat<=i2c_data[22];
        5:reg_sdat<=i2c_data[21];
        6:reg_sdat<=i2c_data[20];
        7:reg_sdat<=i2c_data[19];
        8:reg_sdat<=i2c_data[18];
        9:reg_sdat<=i2c_data[17];
        10:reg_sdat<=i2c_data[16];
        11:reg_sdat<=1;                //Ӧ���ź�
       
        12:begin reg_sdat<=i2c_data[15];ack1<=i2c_sdat;end
        13:reg_sdat<=i2c_data[14];
        14:reg_sdat<=i2c_data[13];
        15:reg_sdat<=i2c_data[12];
        16:reg_sdat<=i2c_data[11];
        17:reg_sdat<=i2c_data[10];
        18:reg_sdat<=i2c_data[9];
        19:reg_sdat<=i2c_data[8];
        20:reg_sdat<=1;              //Ӧ���ź�
       
        21:begin reg_sdat<=i2c_data[7];ack2<=i2c_sdat;end
        22:reg_sdat<=i2c_data[6];
        23:reg_sdat<=i2c_data[5];
        24:reg_sdat<=i2c_data[4];
        25:reg_sdat<=i2c_data[3];
        26:reg_sdat<=i2c_data[2];
        27:reg_sdat<=i2c_data[1];
        28:reg_sdat<=i2c_data[0];
        29:reg_sdat<=1;            //Ӧ���ź�
       
        30:begin ack3<=i2c_sdat;sclk<=0;reg_sdat<=0;end
        31:sclk<=1;
        32:begin reg_sdat<=1;tr_end<=1;end
        endcase
       
end
endmodule

