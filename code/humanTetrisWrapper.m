%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: 
%                            
%-------------------------------------------------------
function humanTetrisWrapper(subjID, demoMode)
%{
This script acts as a wrapper for the pX() scripts, and handles
passing subjID and centralizing experiment setup/teardown.

Improvements over previous version:
- Calls initExperiment only once to manage PTB window, devices etc 
- Pass PTB window, expParams, and device handles to pX scripts and break screens
- Implements a timed break in interExpScreen using expParams.
- Placeholder for recalibration before Part 4
%}

    % get user inputs, defaults for demoMode 
    if nargin < 1
        subjID = input('Enter a subjID (e.g. ''P01''): ', 's');
    end
    if nargin < 2
        demoMode = 1; % default to demoMode
    end

    % preinit experiment variables 
    window = [];
    windowRect = [];
    expParams = struct(); % init struct
    ioObj = [];         
    address = [];       
    eyetracker = [];    
    %{ 
add a lazy check to fix this bug. 

if not found on path automatically add or something of the sort

initExperiment is not found in the current folder or on the MATLAB path, but exists in:
    Z:\13-humanTetris\code\helperScripts
    %}  


    %% main exp sections block 
    try

        fprintf('Initializing experiment environment...\n');
%{
calling initExperiment below does a few useful things. 

Firstly, it will handle sync testing and initialize PTB.
After this, there are a handful of options for the `expParams` structure that is passed around.
This is to not clog up main experiment scripts, but also have consistent expParams passed between sections. 
%}

        %% call initExperiment
        [window, windowRect, expParams, ioObj, address, eyetracker] = initExperiment(subjID, demoMode, 1);
        %% perform sanity check on initExperiment return 
        if isempty(window) || ~isstruct(expParams) || isempty(fieldnames(expParams))
            error('humanTetrisWrapper:InitializationFailed', 'initExperiment did not return valid window or expParams. Aborting.');
        end
        fprintf('Initialization complete. Beginning experiment.\n\n');

        %% run exp. sections 
        % p1,  piece presentation 
        p1(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker);
        
        % break 1 
        betweenSectionBreakScreen(window, expParams);

        % p2, pieces in context / tableaus 
        p2(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker);
        
        % break 2
        betweenSectionBreakScreen(window, expParams);

        % p3, 4 afc 
        % --- Recalibration before Part 4 ---
        if ~demoMode && ~isempty(eyetracker) % Check eyetracker exists and is not empty
            fprintf('Recalibrating eye tracker before 4-AFC...\n');
            DrawFormattedText(window, 'Preparing for Eye Tracker Recalibration...\n\nPress SPACE to start.', 'center', 'center', expParams.colors.white);
            Screen('Flip', window);
            KbName('UnifyKeyNames');
            spaceKey = KbName('SPACE');
            KbWait(-1, 2); % Wait for key release before proceeding
            while true % Wait for space key
                [~, ~, keyCode] = KbCheck;
                if keyCode(spaceKey)
                    break;
                end
            end
            calibrateTobii(window, windowRect, eyetracker, expParams);
            fprintf('Recalibration complete.\n');
        end
        
        p4(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker);
        
        % break 3
        betweenSectionBreakScreen(window, expParams);

        if ~demoMode && ~isempty(eyetracker) % Check eyetracker exists and is not empty
            fprintf('Recalibrating eye tracker before Part 5...\n');
            DrawFormattedText(window, 'Preparing for Eye Tracker Recalibration...\n\nPress SPACE to start.', 'center', 'center', expParams.colors.white);
            Screen('Flip', window);
            KbName('UnifyKeyNames');
            spaceKey = KbName('SPACE');
            KbWait(-1, 2); % Wait for key release before proceeding
            while true % Wait for space key
                [~, ~, keyCode] = KbCheck;
                if keyCode(spaceKey)
                    break;
                end
            end
            calibrateTobii(window, windowRect, eyetracker, expParams);
            fprintf('Recalibration complete.\n');
        end
        
        % UNCOMMENT THE LINE BELOW TO ACTIVATE p5
        p5(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker);
        
        % --- End Screen ---
        showEndScreen(window, expParams);

    catch ME
        % only the wrapper function should handle catch blocks of errors 

        % clean up ptb when we get an error 
        sca; % Close all Psychtoolbox windows
        ShowCursor; % Restore cursor
        Priority(0); % Reset MATLAB priority
        
        % Check if ioObj exists and is not empty before trying to use it
        if exist('ioObj', 'var') && ~isempty(ioObj)
            % Further check if io64 can be called safely
            % This might depend on how io64 handles an uninitialized/invalid object
            % Assuming io64(ioObj) would error if ioObj is [] but not a proper object
            % A more robust check might involve checking the 'status' from io64 if available
            % or simply ensuring it's a valid object of the expected type.
            % For now, the exist and ~isempty check is a good first step.
            try 
                if io64(ioObj) == 0 % Check if ioObj is valid and connection is open
                    io64(ioObj, address, 0); % Send a zero trigger to reset parallel port
                end
            catch ioCleanupME
                warning('Could not clean up ioObj: %s', ioCleanupME.message);
            end
        end
        
        % Check if eyetracker exists and is not empty before trying to use it
        if exist('eyetracker', 'var') && ~isempty(eyetracker)
            try
                % Assuming tetio_stopTracking, tetio_disconnectTracker, tetio_cleanUp
                % are the correct functions and are on the path.
                % These might need to be called conditionally based on eyetracker state.
                % For example, check if eyetracker is an object and has a 'is_tracking' property
                % if eyetracker.is_tracking % (Example, actual property name may vary)
                %    eyetracker.stop_gaze_data(); 
                % end
                % eyetracker.disconnect();
                
                % Using the functions mentioned in previous version:
                tetio_stopTracking(); % Stop Tobii tracking if active (ensure this is safe to call if not tracking)
                tetio_disconnectTracker(); % Disconnect Tobii
                tetio_cleanUp(); % Clean up Tobii SDK
            catch tetioME
                warning('Tobii cleanup failed: %s', tetioME.message);
            end
        end
        
        % Re-throw the error to display details in the command window
        rethrow(ME);
    end

    % --- Final Cleanup after successful experiment ---
    % If the try block completes successfully, ensure PTB is closed.
    % This is already handled by sca in showEndScreen, but including it here
    % ensures it's always done if showEndScreen wasn't reached or modified.
    sca;
    ShowCursor;
    Priority(0);
end



