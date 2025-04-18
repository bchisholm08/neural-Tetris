function take5Brubeck(window, params)

    % adjust these for real experiment, take note of changes in break time for MANUSCRIPT

    % Break parameters (sec)
    minBreakTime = params.rule.minBreakTime;  
    maxBreakTime = params.rule.maxBreakTime; 
    startTime = GetSecs;
    
    while GetSecs - startTime < maxBreakTime
        % calculate useful #'s 
        elapsed = GetSecs - startTime;
        remaining = max(minBreakTime - elapsed, 0);
        
        % break message, display 
        breakText = sprintf(['Take a break!\n\n' ...
    'Required Break Remaining: %d seconds\n' ...
    ''...
    'Maximum Break Time Remaining: %d seconds\n\n' ...
    ''...
    'Press SPACE to continue.'], ceil(remaining), ceil(maxBreakTime - elapsed));
        Screen('TextSize', window, 24);
        DrawFormattedText(window, breakText, 'center', 'center', [1 1 1]);
        
        % Add progress bar
        barWidth = 400;
        barHeight = 20;
        barPos = [params.screen.width/2 - barWidth/2, params.screen.height*0.7, params.screen.width/2 + barWidth/2, params.screen.height*0.7 + barHeight];
        progress = min(elapsed / minBreakTime, 1);
        Screen('FillRect', window, [0.5 0.5 0.5], barPos);
        Screen('FillRect', window, [0 1 0], [barPos(1), barPos(2), barPos(1) + barWidth*progress, barPos(4)]);
        
        Screen('Flip', window);
        
        % Check for early exit (only after minBreakTime)
        [~, ~, keyCode] = KbCheck;
        if elapsed >= minBreakTime && keyCode(KbName('Space'))
            break;
        end
    end
end