module alarm( seth, setm, sets, enable, clk, rst, alarmrst, soundoffbutton, clockhour, clockmin, clocksec, sound);
input [14:0] seth;
input [17:0] setm;
input [17:0] sets;
input [2:0] enable;
input clk, rst, alarmrst, soundoffbutton;
input [4:0] hour;
input [5:0] min, sec;

output reg sound;

wire [2:0] match;

reg [1:0]state;
reg [2:0]alarmtrigger;

parameter IDLE=2'b00, ALARMON=2'b01, ALARMOFF=2'b10;
parameter SOUNDON=1'b1, SOUNDOFF=1'b0;

assign match[0] = enable[0] && (hour==seth[4:0]) && (min==setm[5:0]) && (sec==sets[5:0]);
assign match[1] = enable[1] && (hour==seth[9:5]) && (min==setm[11:6]) && (sec==sets[11:6]);
assign match[2] = enable[2] && (hour==seth[14:10]) && (min==setm[17:12]) && (sec==sets[17:12]);

always@(posedge clk or posedge alarmrst)
begin
if(alarmrst)
begin
sound<=SOUNDOFF;
state<=IDLE;
alarmtrigger<=3'b0;
end
else
begin
alarmtrigger<= alarmtrigger | match;
case(state)
IDLE:begin
      sound<=SOUNDOFF;
if((match[0] && !alarmtrigger[0]) || (match[1] && !alarmtrigger[1]) || (match[2] && !alarmtrigger[2]))
      state<=ALARMON;
  end

ALARMON: begin
         sound<=SOUNDON;
         if(soundoffbutton)
          state<=ALARMOFF;
          end

ALARMOFF: begin
          sound<=SOUNDOFF;
          state<=IDLE;
          end
default:
begin
sound<=SOUNDOFF;
state<=IDLE;
end
endcase
end
end
endmodule
