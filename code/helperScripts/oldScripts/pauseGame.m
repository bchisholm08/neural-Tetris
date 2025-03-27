function pauseGame(windowPtr)
    DrawFormattedText(windowPtr, 'Game Paused. Press any key to resume...', 'center', 'center', [255 255 255]);
    Screen('Flip', windowPtr);

    % Wait until no keys are pressed
    while KbCheck; end
    
    % Now wait for a new key press to resume
    while true
        [keyIsDown, ~, ~] = KbCheck;
        if keyIsDown
            break;
        end
        WaitSecs(0.01);
    end
end
