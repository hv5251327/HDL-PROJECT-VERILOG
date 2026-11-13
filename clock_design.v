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
