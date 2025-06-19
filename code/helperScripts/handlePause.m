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
    
    pauseDuration = 0; % Default to 0 if not paused
    [~, ~, keyCode] = KbCheck(-1);

    if keyCode(keys.p) % Check if the 'p' key (defined in expParams) is down
        
        pauseStartTime = GetSecs; % Record when the pause began
        
        % --- Draw Pause Screen with New Instructions ---
        Screen('TextSize', window, 32);
        Screen('TextFont', window, 'Arial');
        pauseText = 'Experiment Paused\n\nPress ENTER to continue\n\nPress ESC to quit';
        DrawFormattedText(window, pauseText, 'center', 'center', [255 255 255]);
        Screen('Flip', window);
        
        KbReleaseWait(-1); % Wait for the 'p' key to be released
        
        % --- Wait for either ENTER or ESC to be pressed ---
        while true
            [keyIsDown, ~, keyCode] = KbCheck(-1);
            if keyIsDown
                if keyCode(keys.enter) % User wants to continue
                    break; % Exit the while loop to resume
                    
                elseif keyCode(keys.escape) % User wants to quit
                    % Throw a specific error that the main wrapper will catch.
                    % This triggers the graceful shutdown and data saving.
                    error('USER_QUIT:ExperimentHalted', 'User pressed Escape key to quit from pause menu.');
                end
            end
            WaitSecs(0.01); % Small wait to prevent hogging the CPU
        end
        
        KbReleaseWait(-1); % Wait for the resume key (enter) to be released
        
        % Calculate how long the pause lasted
        pauseDuration = GetSecs - pauseStartTime;
    end
end