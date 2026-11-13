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
