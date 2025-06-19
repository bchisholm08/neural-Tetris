%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Between PX() scripts we want a break screen different than
% the block break screen. 
%                            
%-------------------------------------------------------


% --- Helper Function for Inter-Experiment Breaks (unchanged from previous) ---
function betweenSectionBreakScreen(window, expParams)
    % interExpScreen displays a break screen with a timer.
    % It uses the existing PTB window and expParams for timing and colors.

    % Ensure consistent text settings
    Screen('TextSize', window, 28);
    Screen('TextFont', window, 'Arial'); % Ensure font is consistent

    minBreakTime = expParams.rule.minBlockBreakTime; % Use minimum block break as general inter-exp break
    maxBreakTime = expParams.rule.maxBlockBreakTime; % Use maximum block break as general inter-exp break

    startTime = GetSecs;
    
    KbName('UnifyKeyNames');
    spaceKey = KbName('SPACE');

    while (GetSecs - startTime) < maxBreakTime
        elapsed = GetSecs - startTime;
        remainingRequired = max(0, minBreakTime - elapsed);
        remainingMax = max(0, maxBreakTime - elapsed);

           % NOTE: fixed 6/5/25, issue passing strings to ptb window. ' and
           % " or single and double quotes makes a difference for ptb and
           % what it does internalyl to the text string 
        breakText = sprintf('You''ve reached a SECTION break!! \n\n Required Break Time Remaining: %d seconds\n\n\n Maximum Break Time Remaining: %d seconds\n\n\n', ceil(remainingRequired), ceil(remainingMax));
        
        % Only allow continue after min break
        if remainingRequired <= 0
            breakText = [breakText, 'Press SPACE to continue when ready!'];
        else
            breakText = [breakText, 'Please wait to proceed....'];
        end
        
        % add in string check for previous issue with crashes 
        if isstring(breakText)
            breakText = char(breakText);
        end

        Screen('FillRect', window, expParams.colors.background); % clear 
        DrawFormattedText(window, breakText, 'center', 'center', expParams.colors.white);
        
        % simple progress bar 
        barWidth = 400;
        barHeight = 20;
        barPos = [expParams.screen.center(1) - barWidth/2, expParams.screen.height*0.7, ...
                  expParams.screen.center(1) + barWidth/2, expParams.screen.height*0.7 + barHeight];
      
        progress = min(elapsed / maxBreakTime, 1); % progress against max break time
        
        Screen('FillRect', window, [0.5 0.5 0.5], barPos); % bar background 
        Screen('FillRect', window, [0 1 0], [barPos(1), barPos(2), barPos(1) + barWidth*progress, barPos(4)]); % fill w/ progress 

        Screen('Flip', window);

        % if min time has elapsed, check for continuation 
        [keydown, ~, keyCode] = KbCheck;
        if keydown && keyCode(spaceKey) && (elapsed >= minBreakTime)
            break;
        end
        WaitSecs(0.01); 
    end
    % clear screen once break is over 
    Screen('FillRect', window, expParams.colors.background);
    Screen('Flip', window);
end