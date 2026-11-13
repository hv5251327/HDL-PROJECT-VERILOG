'define ONESECPULSES 9
module app(select, clk, alarmenable, alarmiphour, alarmipmin, alarmipsec, alarmrst, soundoffbutton, stopwatchstart, stopwatchstop, stopwatchreset,  countdowniphour, countdownipmin, countdownipsec, counterstartbutton, counterrst, lapbutton, rst, sound, ophour, opmin, opsec, laphour, lapmin, lapsec);

input [1:0]select;
input clk, rst, counterstartbutton, counterrst, lapbutton, stopwatchstart, stopwatchstop, stopwatchreset, alarmrst, soundoffbutton;
input [4:0]countdowniphour;
input [5:0]countdownipmin, countdownipsec;
input [14:0] alarmiphour;
input [17:0] alarmipmin;
input [17:0] alarmipsec;
input [2:0] alarmenable;


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

alarm a1( .seth(alarmiphour), .setm(alarmipmin), .sets(alarmipsec), .enable(alarmenable), .clk(clk), .rst(rst), .alarmrst(alarmrst), .soundoffbutton(soundoffbutton), .sound(alarmsound));

stopwatch b1( .clk(clk), .start(stopwatchstart), .stop(stopwatchstop), .stopwatchreset(stopwatchreset), .stopwatchh(stophour), .stopwatchm(stopmin), .stopwatchs(stopsec));

countdown c1( .counth(countdowniphour), .countm(countdownipmin), .counts(countdownipsec), .clk(clk), .startbutton(counterstartbutton), .counterrst(counterrst), .lapbutton(lapbutton), .sound(countdownsound), .laph(laphour), .lapm(lapmin), .laps(lapsec));

clock d1( .clk(clk), .rst(rst), .hour(clockhour), .min(clockmin), .sec(clocksec));


always@(*)
begin
sound=0;
ophour=0;
opmin=0;
opsec=0;

case(select)

ALARM: sound=alarmsound;

STOPWATCH:begin
          ophour=stophour;
          opmin=stopmin;
          opsec=stopsec;
          end

COUNTDOWNTIMER:sound=countdownsound;            

CLOCK:begin
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
