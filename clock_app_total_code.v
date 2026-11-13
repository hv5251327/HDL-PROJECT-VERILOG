`timescale 1ns/1ps
`define ONESECPULSES 9

module app(select, clk, alarmenable, alarmiphour, alarmipmin, alarmipsec, alarmrst, soundoffbutton, stopwatchstart, stopwatchstop, stopwatchreset,  countdowniphour, countdownipmin, countdownipsec, counterstartbutton, counterrst, lapbutton, rst, settime, initialclockhour, initialclockmin, initialclocksec, sound, ophour, opmin, opsec, laphour, lapmin, lapsec);

input [1:0]select;
input clk, rst, counterstartbutton, counterrst, lapbutton, stopwatchstart, stopwatchstop, stopwatchreset, settime, alarmrst, soundoffbutton;
input [4:0]countdowniphour;
input [5:0]countdownipmin, countdownipsec;
input [14:0] alarmiphour;
input [17:0] alarmipmin;
input [17:0] alarmipsec;
input [2:0] alarmenable;
input [4:0]initialclockhour;
input [5:0] initialclockmin, initialclocksec;

output reg sound;
output reg [4:0]ophour;
output reg [5:0]opmin, opsec;

output  [164:0] laphour;
output  [197:0] lapmin;
output  [197:0] lapsec;

wire alarmsound, countdownsound;

wire [4:0] stophour, clockhour;
wire [5:0] stopmin, clockmin;
wire [5:0] stopsec, clocksec;
 
parameter ALARM=2'b00, STOPWATCH=2'b01, COUNTDOWNTIMER=2'b10, CLOCK=2'b11;

alarm a1( .seth(alarmiphour), .setm(alarmipmin), .sets(alarmipsec), .enable(alarmenable), .clk(clk), .alarmrst(alarmrst), .soundoffbutton(soundoffbutton), .clockhour(clockhour), .clockmin(clockmin), .clocksec(clocksec), .sound(alarmsound));

stopwatch b1( .clk(clk), .start(stopwatchstart), .stop(stopwatchstop), .stopwatchreset(stopwatchreset), .stopwatchh(stophour), .stopwatchm(stopmin), .stopwatchs(stopsec));

countdown c1( .counth(countdowniphour), .countm(countdownipmin), .counts(countdownipsec), .clk(clk), .startbutton(counterstartbutton), .counterrst(counterrst), .lapbutton(lapbutton), .sound(countdownsound), .laph(laphour), .lapm(lapmin), .laps(lapsec));

clock d1( .clk(clk), .rst(rst), .settime(settime), .initialclockhour(initialclockhour), .initialclockmin(initialclockmin), .initialclocksec(initialclocksec), .hour(clockhour), .min(clockmin), .sec(clocksec));


always@(*)
begin
sound=0;
ophour=0;
opmin=0;
opsec=0;

case(select)

ALARM: sound=alarmsound;

STOPWATCH:begin
          sound=0;
          ophour=stophour;
          opmin=stopmin;
          opsec=stopsec;
          end

COUNTDOWNTIMER:sound=countdownsound;            

CLOCK:begin
      sound=0;
      ophour=clockhour;
      opmin=clockmin;
      opsec=clocksec;
      end

default:begin
        sound = 0;
        ophour = 0;
        opmin = 0;
        opsec = 0;
        end

endcase
end
endmodule



module alarm( seth, setm, sets, enable, clk, alarmrst, soundoffbutton, clockhour, clockmin, clocksec, sound);
input [14:0] seth;
input [17:0] setm;
input [17:0] sets;
input [2:0] enable;
input clk, alarmrst, soundoffbutton;
input [4:0] clockhour;
input [5:0] clockmin, clocksec;

output reg sound;

wire [2:0] match;

reg [1:0]state;
reg [2:0]alarmtrigger;

parameter IDLE=2'b00, ALARMON=2'b01, ALARMOFF=2'b10;
parameter SOUNDON=1'b1, SOUNDOFF=1'b0;

assign match[0] = enable[0] && (clockhour==seth[4:0]) && (clockmin==setm[5:0]) && (clocksec==sets[5:0]);
assign match[1] = enable[1] && (clockhour==seth[9:5]) && (clockmin==setm[11:6]) && (clocksec==sets[11:6]);
assign match[2] = enable[2] && (clockhour==seth[14:10]) && (clockmin==setm[17:12]) && (clocksec==sets[17:12]);

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




module stopwatch( clk, start, stop, stopwatchreset, stopwatchh, stopwatchm, stopwatchs);
input clk, start, stop, stopwatchreset;
output reg [4:0]stopwatchh;
output reg [5:0]stopwatchm, stopwatchs;
reg [32:0]counter;

initial
begin
counter<= 0;
stopwatchh<= 0;
stopwatchm<= 0;
stopwatchs<= 0;
end

always @(posedge clk or posedge stopwatchreset)
begin
if(stopwatchreset)
begin
counter<= 0;
stopwatchh<= 0;
stopwatchm<= 0;
stopwatchs<= 0;
end
else if(start && !stop )
begin
if(counter == `ONESECPULSES-1)
begin
counter<= 0;
if(stopwatchs == 59)
begin
stopwatchs<= 0;
if(stopwatchm == 59)
begin
stopwatchm<= 0;
if(stopwatchh == 23)
stopwatchh<= 0;
else
stopwatchh<= stopwatchh + 1'b1;
end
else
stopwatchm<= stopwatchm + 1'b1;
end
else
stopwatchs<= stopwatchs + 1'b1;
end
else
counter<= counter + 1'b1;
end
end
endmodule




module countdown(counth, countm, counts, clk, startbutton, counterrst, lapbutton, sound, laph, lapm, laps);
input [4:0]counth;
input [5:0]countm, counts;
input clk, startbutton, counterrst, lapbutton;
output reg sound;
output reg [164:0] laph;
output reg [197:0] lapm;
output reg [197:0] laps;
reg[32:0] counter;
reg[4:0]h;
reg[5:0]m,s;
reg [5:0]i;
parameter ON=1'b1, OFF=1'b0;

initial
begin
i<=0;
counter<=0;
sound<=OFF;
end

always@(posedge clk or posedge counterrst)
begin
if(counterrst)
begin
counter<=0;
sound<=OFF;
h<=counth;
m<=countm;
s<=counts;
i<=0;
end
else
begin
if(startbutton && !sound)
begin
  if(counter==`ONESECPULSES-1)
    begin
    counter<=0;
    if(s!=0)
       s<=s-1;
    else
      begin
      if(m!=0)
        begin
        m<=m-1;
        s<=59;
        end
      else
        begin
        if(h!=0)
          begin
          h<=h-1;
          m<=59;
          s<=59;
          end
        else
          begin
          sound<=ON;
          counter<=0;
          end
        end
      end
    end
  else
    counter<=counter+1;
end
if(lapbutton && i<33)
begin
laph[i*5 +: 5]<=h;
lapm[i*6 +: 6]<=m;
laps[i*6 +: 6]<=s;
i<=i+1;
end
end
end
endmodule




module clock(clk, rst, settime, initialclockhour, initialclockmin, initialclocksec, hour, min, sec);
input clk,rst,settime;
input [4:0]initialclockhour;
input [5:0] initialclockmin, initialclocksec;
output reg [4:0] hour;
output reg [5:0] min, sec;
reg [26:0] counter;
always @(posedge clk or posedge rst)
begin
if(rst)
begin
counter <= 0;
hour <= 0;
min <= 0;
sec <= 0;
end
else if(settime)
begin
counter<=0;
hour<=initialclockhour;
min<=initialclockmin;
sec<=initialclocksec;
end
else
begin
if(counter == `ONESECPULSES-1)
begin
counter <= 0;
if(sec == 59)
begin
sec <= 0;
if(min == 59)
begin
min <= 0;
if(hour == 23)
hour <= 0;
else
hour <= hour + 1'b1;
end
else
min <= min + 1'b1;
end
else
sec <= sec + 1'b1;
end
else
counter <= counter + 1'b1;
end
end
endmodule
