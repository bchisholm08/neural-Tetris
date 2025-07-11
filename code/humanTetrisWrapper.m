%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Helpful wrapper for all experiment sections and
% breakscreens. After getting info needed to begin the experiment, the script
% does an initial call to initExperiment, which gets
% tons of useful information for us and initializes everything we need.
% This script passes subjID and expParams to the different sections, while
% being the arbiter of section breaks as well. Instruction screens are
% called within each Px() script. This wrapper also completes a calibration
% before P4 (4-AFC section) and the final section, P5 (natural tetris
% play). This is all automatically handled by the script. The script also
% helps clean up errors/crashes in a 'graceful' way
%
% Fun code to open all files in directory
% % % files = dir("*.m");
% % % for k = 1:length(files)
% % %     open(files(k).name);
% % % end
%-------------------------------------------------------
function humanTetrisWrapper(subjID, demoMode)
% get user inputs, defaults for demoMode
if nargin < 1
    subjID = input('Enter a subjID (e.g. ''P01''): ', 's');
    subjID = strtrim(subjID); % Remove leading/trailing whitespace
end
if nargin < 2
    demoMode = 1; % default to demoMode if no input
end

% try to prevent some path errors
addpath('Z:\13-humanTetris\code');
addpath("Z:\13-humanTetris\code\helperScripts");

%% main exp sections block
try
    %% call initExperiment
    [window, windowRect, expParams, ioObj, address, eyetracker] = initExperiment(subjID, demoMode);

    % sanity check on initExp struct returned
    if isempty(window) || ~isstruct(expParams) || isempty(fieldnames(expParams))
        error('humanTetrisWrapper:InitializationFailed', 'initExperiment did not return valid window or expParams. Aborting.');
    end

    % final checks when recording in catss
    if ~demoMode
        preCheck = false;
        while ~preCheck
            ShowCursor();

            prompt1 = 'Is the adjustable table unplugged to avoid 60 Hz EEG artifact? (Y/N): ';
            response1 = strtrim(input(prompt1, 's'));

            prompt2 = 'Is speed mode set to FOUR on BioSemi? (Y/N): ';
            response2 = strtrim(input(prompt2, 's'));

            prompt3 = 'Is BioSemi recording USB plugged into S27-B? (Y/N): ';
            response3 = strtrim(input(prompt3, 's'));

            responses = {response1, response2, response3};

            if any(strcmpi(responses, 'N')) || any(strcmpi(responses, 'No'))
                % If any bad response abort
                error('Experiment aborted by user.');
            elseif all(strcmpi(responses, 'Y')) || all(strcmpi(responses, 'Yes'))
                fprintf('Inputs confirmed. Continuing...\n');
                preCheck = true; % exit loop
            else
                fprintf('Invalid input detected. Please answer with Y or N.\n');
            end
            HideCursor();
        end
    end % pre-experiment checks

    %% run exp. sections
    % natural tetris play
    % p5(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker);
    % 
    % % break 1
    % betweenSectionBreakScreen(window, expParams);

    % complete a calibration before going into final half
    if ~demoMode && ~isempty(eyetracker) % Check calibrationData is not empty
        fprintf('Recalibrating eye tracker...\n');
        DrawFormattedText(window, 'Preparing for Eye Tracker Recalibration...\n\nPress SPACE to start.', 'center', 'center', expParams.colors.white);
        Screen('Flip', window);
        KbName('UnifyKeyNames');
        spaceKey = KbName('SPACE');
        KbWait(-1, 2); % Wait for key release before proceeding. why not just wait(.5)  ?
        while true % wait for space
            [~, ~, keyCode] = KbCheck;
            if keyCode(spaceKey)
                break;
            end
        end
        calibrateTobii(window, windowRect, eyetracker, expParams);
        fprintf('Recalibration complete.\n');
    end

    % p1,  piece presentation
    p1(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker);

    % break 1
    betweenSectionBreakScreen(window, expParams);

    % p2, pieces in context / tableaus
    p2(subjID, demoMode, expParams, ioObj, address, eyetracker);

    showEndScreen(window, expParams); % thank participant and exit

    % break 2
    %        betweenSectionBreakScreen(window, expParams);

    % recalibrate before p4
    % FIXME this can probably be accomplished in a more graceful way,
    % like maybe WITHIN THE P4 SCRIPT ITSELF WITH THE CUSTOM CALIBRATION FUNCTION I WROTE

    % if ~demoMode && ~isempty(eyetracker) % Check calibrationData is not empty
    %     fprintf('Recalibrating eye tracker before 4-AFC...\n');
    %     DrawFormattedText(window, 'Preparing for Eye Tracker Recalibration...\n\nPress SPACE to start.', 'center', 'center', expParams.colors.white);
    %     Screen('Flip', window);
    %     KbName('UnifyKeyNames');
    %     spaceKey = KbName('SPACE');
    %     KbWait(-1, 2); % Wait for key release before proceeding. why not just wait(.5)  ?
    %     while true % wait for space
    %         [~, ~, keyCode] = KbCheck;
    %         if keyCode(spaceKey)
    %             break;
    %         end
    %     end
    %     calibrateTobii(window, windowRect, eyetracker, expParams);
    %     fprintf('Recalibration complete.\n');
    % end

catch ME

    % clean up ptb when error
    sca;
    ShowCursor;
    Priority(0);
    Screen('CloseAll');
    % try to clear port if crash
    %  io64(ioObj, address, 0);


    % commented out below code on 6/19. Seems pointless. There is no
    % logical reason to check if EEG port and Tobii work if we've
    % already entered the catchME part of the code. Something else has
    % already gone terribly wrong at that point for a crash to happen.
    % HOWEVER SHOULD KEEP UNTIL REAL EXP MODE WORKS I.E. DO NOT DELTE

    % % Check if ioObj exists and is not empty before trying to use it
    % if exist('ioObj', 'var') && ~isempty(ioObj)
    %     % Further check if io64 can be called safely
    %     % This might depend on how io64 handles an uninitialized/invalid object
    %     % Assuming io64(ioObj) would error if ioObj is [] but not a proper object
    %     % A more robust check might involve checking the 'status' from io64 if available
    %     % or simply ensuring it's a valid object of the expected type.
    %     % For now, the exist and ~isempty check is a good first step.
    %     try
    %         if io64(ioObj) == 0 % Check if ioObj is valid and connection is open
    %             io64(ioObj, address, 0); % Send a zero trigger to reset parallel port
    %         end
    %     catch ioCleanupME
    %         warning('Could not clean up ioObj: %s', ioCleanupME.message);
    %     end
    % end
    %
    % % Check if eyetracker exists and is not empty before trying to use it
    % if exist('eyetracker', 'var') && ~isempty(eyetracker)
    %     try
    %         % Assuming tetio_stopTracking, tetio_disconnectTracker, tetio_cleanUp
    %         % are the correct functions and are on the path.
    %         % These might need to be called conditionally based on eyetracker state.
    %         % For example, check if eyetracker is an object and has a 'is_tracking' property
    %         % if eyetracker.is_tracking % (Example, actual property name may vary)
    %         %    eyetracker.stop_gaze_data();
    %         % end
    %         % eyetracker.disconnect();
    %
    %         % Using the functions mentioned in previous version:
    %         tetio_stopTracking(); % Stop Tobii tracking if active (ensure this is safe to call if not tracking)
    %         tetio_disconnectTracker(); % Disconnect Tobii
    %         tetio_cleanUp(); % Clean up Tobii SDK
    %     catch tetioME
    %         warning('Tobii cleanup failed: %s', tetioME.message);
    %     end
    % end

    % Re-throw the error to display details in the command window
    rethrow(ME);
end

% clean up after exp.
% already handled in showEndScreen, but including here ensures it
% always happens if some other bug occurs
sca;
ShowCursor;
Priority(0);
Screen('CloseAll')
end



