clear;
port = hex2dec('c100');
ioObj = io64();
status = io64(ioObj);
% io64(ioObj,port,255);
%For the sake of commenting

io64(ioObj,port,[3 3 3]);

% 
% colors = new byte[3 * 32];
% var zeros = new byte[3 * ((32 + 63) / 64)];
% while (true)
% {
% // all pixels off
% for (int i = 0; i < colors.Length; ++i) colors[i] = (byte)(0x80 | 0);
% // a progressive yellow/red blend
% for (byte i = 0; i < 32; ++i)
% {
% colors[i * 3 + 1] = 0x80 | 32;
% colors[i * 3 + 0] = (byte)(0x80 | (32 - i));
% spi.Write(colors);
% spi.Write(zeros);
% Thread.Sleep(1000 / 32); // march at 32 pixels per second
% }
% }
msg = [1 1 1 1 1 1 1 1 1];
for j=1:3
    for i=1:127
    %     io64(ioObj,port,msg(i));
        for k=1:8
            io64(ioObj,port,0);
        end
    end
        for k=1:8
            io64(ioObj,port,1);
        end
end
numLEDs = 4;
for i=uint16(((numLEDs+31)/32):-1:0)
    io64(ioObj,port,0);
end

for i=uint16(((numLEDs+31)/32)*8:-1:0)
    io64(ioObj,port,2);
    io64(ioObj,port,0);
end

for i=0:1000
    io64(ioObj,port,0);
end
for i=0:1000
    io64(ioObj,port,0);

    io64(ioObj,port,2);

end
io64(ioObj,port,0);
%     (uint16_t i=((numLEDs+31)/32); i>0; i--) spi_out(0);