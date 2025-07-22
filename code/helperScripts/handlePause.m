%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.10.2025
%
% Description: 
%                            
%-------------------------------------------------------
function pauseDuration = handlePause(window, keys)
    % This function checks for the pause key. If pressed, it presents a
    % pause screen with options to resume or quit the experiment.
    % It returns the total duration of the pause if the experiment is resumed.
    
    pauseDuration = 0; 
    [~, ~, keyCode] = KbCheck(-1);

    if keyCode(keys.p) % check p 
        
        pauseStartTime = GetSecs;
        
        % new pause directions 
        Screen('TextSize', window, 32);
        Screen('TextFont', window, 'Arial');
        pauseText = 'Experiment Paused\n\nPress ENTER to continue\n\nPress ESC to quit';
        DrawFormattedText(window, pauseText, 'center', 'center', [255 255 255]);
        Screen('Flip', window);
        
        KbReleaseWait(-1); % Wait for p to be released
        
        % wait 
        while true
            [keyIsDown, ~, keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(keys.enter) 
                    break; % exit while to resume
                    
                elseif keyCode(keys.escape) % User quit
                    % Throw error up to wrapper 
                    error('USER_QUIT:ExperimentHalted', 'User pressed Escape key to quit from pause menu.');
                end
            end
            WaitSecs(0.01); % Small wait to prevent hogging the CPU
        end
        
        KbReleaseWait(-1); % wait for resume 
        
        % get pause length 
        pauseDuration = GetSecs - pauseStartTime;
    end
end