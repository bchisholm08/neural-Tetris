function tetrisWrapper
    % tetrisWrapper - Main script to run the Tetris experiment.
    %
    % This script demonstrates the combined start/stop approach for both
    % EEG and Tobii. Make sure you have StartStopEEG.m and StartStopTobii.m
    % in your scripts/ folder, along with all other necessary Tetris 
    % functions.
  
  demo = 0; 
%{ 
DEMO MODE 
    demo mode. Build out later... useful for debugging and what not, now
    it's just important to get the code running 
    This is the only "setting" in the function. When set to 0, runs experiment as 
    normal. If 1, the following is different: 
        - Does not record EEG or pupillometry data, uses 'dummy'  
        - Prompts the user for a directory to store the data in 
        - 
%}
if demo
    fprintf('Very nice demo mode!\n');
    userResponse = input('### DEMO MODE ACTIVE ###. \nDo you wish to proceed? (y/n): ', 's');
    if strcmpi(userResponse, 'y')
        disp('Proceeding with demo mode...');
        % fill in the blanks here once we get the full game running... 
    elseif strcmpi(userResponse, 'n')
        disp('Exiting demo mode...');
        % return to exit loop...? 
        return;
    else
        disp('Invalid input. Exiting demo mode...');
        return;
    end
end

    % Add tetris scripts 
    clear all; 
    sca;
    scriptsFolder = fullfile(pwd, 'scripts');
    addpath(scriptsFolder);

    % depending on how precise timing needs to be, we can override sync to
    % avoid some PTB errors. Important to know HOW imprecise this lets
    % timing be 
    Screen('Preference', 'SkipSyncTests', 0);

    try
        % ========== GET EXPERIMENT INFO ==========
        subjID = input('Please enter participant ID (e.g., "S01"): ', 's');
        if isempty(subjID)
            subjID = 'Unknown';
        end

        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        logFilename = sprintf('TetrisLog_%s_%s.csv', subjID, timestamp);

        % ========== SETUP PSYCHTOOLBOX ==========
        AssertOpenGL;
        KbName('UnifyKeyNames');
        Screen('Preference', 'SkipSyncTests', 2);  % If needed for quick testing

           % force PTB to run on 'main monitor' which is always monitor 1? 
        screenNumber = max(Screen('Screens'));  % Force primary display

        % deal with refresh rate and screens...  
        % Screen('Preference', 'FrameRate', 60);
try
    [windowPtr, rect] = PsychImaging('OpenWindow', screenNumber, 0);
catch ME
    error('Failed to open Psychtoolbox window: %s', ME.message);
end
       
% perform a check of window ptr, for debugging. 
        disp(['Window Pointer: ', num2str(windowPtr)]);  % Debugging print

if isempty(windowPtr) || windowPtr <= 0
    error('Failed to open Psychtoolbox window. windowPtr is invalid.');
end

        % ========== SHOW INSTRUCTIONS ==========
        showInstructions(windowPtr);
       
        % ========== START EEG ==========
        eegHandle = handleEEG('Start');  % This will return a handle (dummy or real)
        
        % ========== START TOBII ==========
        tobiiHandle = handlePupils('Start');  % Also returns a handle

        % ========== INITIALIZE TETRIS GAME ==========
        tetrisParams = tetrisInitialize(windowPtr, rect);

        % Create a simple event log (cell array)
        eventLog = {};
        eventLog(end+1,:) = {'TimeStamp', 'EventType', 'Details'};

        % Game Loop
[score, linesCleared, eventLog] = gameLoop(...
    tetrisParams, ...
    @(action, eegHandle) handleEEG(action, eegHandle), ...
    @(action, pupilHandle) handlePupils(action, pupilHandle), ...
    eventLog);
        % Stop EEG  
        handleEEG('stop', eegHandle);
        
        % Stop Tobii
     %   handlePupils('stop', tobiiHandle);

        % Subject log
        saveLog(logFilename, eventLog);

        % ========== CLOSE PSYCHTOOLBOX ==========
        sca;
        
        % ========== PRINT SUMMARY ==========
        fprintf('Tetris experiment finished.\n');
        fprintf('Final Score: %d | Lines Cleared: %d\n', score, linesCleared);
        fprintf('Event log saved to: %s\n', logFilename);

    catch ME
        % In case of error, clean up gracefully
    sca;
    % below line crashes, but shouldn't. Not really worth fixing now... 
    % PsychImaging('Close');
    rethrow(ME);

        % Try stopping EEG if started
        if exist('eegHandle','var')
            handleEEG('stop', eegHandle);
        end

        % Try stopping Tobii if started
        if exist('tobiiHandle','var')
            handlePupils('stop', tobiiHandle);
        end

        % Rethrow error for debugging
        rethrow(ME);
    end
end
