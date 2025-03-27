function cleanupError(TDT,err)

PsychPortAudio('Stop',...                       % stop playback/recording
    TDT.pahandle,...                        % audio device handle
    1);

PsychPortAudio('Close',TDT.pahandle);