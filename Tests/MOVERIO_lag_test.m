clear all; sca;

screenNumber = 2;
framesWhiteOn = 6;
framesBlackOn = 6;
numFlashes = 40;

ioObj = io64();
status = io64(ioObj);
port = hex2dec('c100');
io64(ioObj,port,0);

Screen('Preference', 'SkipSyncTests', 1);

blackIndex = BlackIndex(screenNumber);
whiteIndex = WhiteIndex(screenNumber);
w = Screen('OpenWindow',screenNumber);
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

anotherCycle = 1;

black_tex = Screen('MakeTexture',w,repmat(blackIndex,screenYpixels,screenXpixels,3));
white_tex = Screen('MakeTexture',w,repmat(whiteIndex,screenYpixels,screenXpixels,3));

input('ENTER to start');

while(anotherCycle)
    
    for iFlash = 1:numFlashes
        anotherCycle = 0;

        Screen('DrawTexture',w,white_tex);
        Screen('Flip',w);
        io64(ioObj,port,255);

        if (framesWhiteOn>1)
            Screen('WaitBlanking', w,framesWhiteOn-1);
        end

        Screen('DrawTexture',w,black_tex);
        Screen('Flip',w);
        io64(ioObj,port,0);

        if (framesBlackOn>1)
            Screen('WaitBlanking', w,framesBlackOn-1);
        end
    end
    
    anotherCycle = input('another? (0=no, 1=yes)');
end

sca;