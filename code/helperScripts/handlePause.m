%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.10.2025
%
% Description: 
%                            
%-------------------------------------------------------
function [startTime] = handlePause(keys, window, startTime)
    % This function checks for a pause key press. If detected, it pauses the
    % experiment and adjusts the trial's startTime to account for the pause duration.
    
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    if keyIsDown && keyCode(keys.p)
        
        pauseStartTime = GetSecs; % Record when the pause began
        
        % Draw pause screen (adapted from old pauseGame.m)
        Screen('TextSize', window, 32);
        Screen('TextFont', window, 'Arial');
        DrawFormattedText(window, 'Game Paused\n\nPress any key to resume...', 'center', 'center', [255 255 255]);
        Screen('Flip', window);
        
        KbWait(-1, 2); % Wait for any key press to resume
        
        % Adjust the original trial's startTime by the duration of the pause
        pauseDuration = GetSecs - pauseStartTime;
        startTime = startTime + pauseDuration;
        
        % Wait for key release to prevent an immediate re-pause
        KbReleaseWait(-1); 
    end
end

%{ 
NOTES ON HOW TO IMPLEMENT IN A SCRIPT--do this l8r 

Step B: Call handlePause from within your trial loops.
In scripts like p4.m and p5.m that have response timeouts or other timers, you need to call this function inside your response collection loop.

Example for p4.m:
In your response collection loop (around line 170), add the call to handlePause.

REPLACE THIS (in p4.m):
Matlab

% Original response loop
while (GetSecs - startTime) < timeoutDuration
    [keyIsDown, pressTime, keyCode] = KbCheck(-1);
    if keyIsDown
        if keyCode(expParams.keys.up), responseKey = 'up'; keyPressTime = pressTime; break;
        % ... other keys ...
        end
    end
end

WITH THIS:
Matlab

% Corrected response loop with pause functionality
while (GetSecs - startTime) < timeoutDuration
    % --- Call handlePause on every loop iteration ---
    % It adjusts 'startTime' if a pause occurs, so the timeout is not affected.
    [startTime] = handlePause(expParams.keys, window, startTime);
    
    [keyIsDown, pressTime, keyCode] = KbCheck(-1);
    if keyIsDown
        if keyCode(expParams.keys.up), responseKey = 'up'; keyPressTime = pressTime; break;
        % ... other keys ...
        elseif keyCode(expParams.keys.escape), responseKey = 'escape'; keyPressTime = pressTime; break;
        end
    end
end


========================================
Step B: Update humanTetrisWrapper.m to handle the custom error.
We will modify the main catch ME block in your wrapper to look for this specific error identifier.

Action: In humanTetrisWrapper.m, modify the catch ME block.

REPLACE THIS (in humanTetrisWrapper.m):
Matlab

catch ME
    % ... (existing cleanup code) ...
    rethrow(ME);
end

WITH THIS:
Matlab

catch ME
    % --- Main Experiment Catch Block ---

    if strcmp(ME.identifier, 'USER_QUIT:ExperimentHalted')
        % This was a deliberate quit by the experimenter
        fprintf('\n\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
        fprintf('Experiment halted by user (Escape key pressed).\n');
        fprintf('Attempting to save any data collected so far...\n');
        
        % Try to save any data that exists in the base workspace from the pX script that was running
        try
            % Check which script was running and save its data
            if exist('results', 'var') % p4 saves 'results'
                saveDat('p4_behavioral_INCOMPLETE', subjID, results, expParams, demoMode);
            elseif exist('data', 'var') % p1 saves 'data'
                saveDat('p1_INCOMPLETE', subjID, data, expParams, demoMode);
            elseif exist('eventLog', 'var') % p5 saves 'eventLog'
                saveDat('p5_events_INCOMPLETE', subjID, eventLog, expParams, demoMode);
            end
            fprintf('Incomplete data saved successfully.\n');
        catch saveME
            fprintf(2, 'Could not save data after quit command. Error: %s\n', saveME.message);
        end

        fprintf('Graceful shutdown complete.\n');
        fprintf('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\n');
    else
        % This was an unexpected code error
        fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
        fprintf(2, 'UNEXPECTED ERROR IN SCRIPT: %s\n', ME.stack(1).file);
        fprintf(2, 'Function: %s, Line: %d\n', ME.stack(1).name, ME.stack(1).line);
        fprintf(2, 'Error Message: %s\n', ME.message);
        fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
        rethrow(ME); % Rethrow the unexpected error
    end

    % --- Final Cleanup ---
    sca;
    ShowCursor;
    Priority(0);
    % Add other cleanup (Tobii, EEG) here if needed
end

%}