function take5Brubeck(window, params)
    % Break parameters (customizable)
    minBreakTime = 5;  % Minimum break time (seconds)
    maxBreakTime = 300;  % Maximum break time (seconds)
    startTime = GetSecs;
    
    while GetSecs - startTime < maxBreakTime
        elapsed = GetSecs - startTime;
        remaining = max(minBreakTime - elapsed, 0);
        
        % Display break message
        breakText = sprintf('Take a break!\n\nTime remaining: %d seconds\n\nPress SPACE to continue.', ceil(remaining));
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
        
        % Check for early exit (only allowed after minBreakTime)
        [~, ~, keyCode] = KbCheck;
        if elapsed >= minBreakTime && keyCode(KbName('Space'))
            break;
        end
    end
end