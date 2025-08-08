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
% cool code to open all files in directory
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

            prompt3 = 'Is BioSemi recording USB plugged into S27-C? (Y/N): ';
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
    
        HideCursor();

    end % pre-experiment checks

    %% run exp. sections
%    natural tetris play
    p5(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker);

    % break 1

    betweenSectionBreakScreen(window, expParams);

    % add a half way pause screen to switch EEG recording...
    Screen('TextSize', window, 36);
    Screen('TextFont', window, 'Arial');
    
    % % halfMsg = sprintf(['Halfway Reached!\n\n' ...
    % %     'Please wait for experimenter....\n\n']);
    % % DrawFormattedText(window, halfMsg, 'center', 'center', expParams.colors.white);
    % % Screen('Flip', window);
    % % RestrictKeysForKbCheck(KbName('c'));
    % % KbReleaseWait;
    % % KbWait([], 2);
    % % RestrictKeysForKbCheck([]);
    % % KbReleaseWait;
 
    
    doneWithHalfwayBreak = false;

    cKey = KbName('c');

while ~doneWithHalfwayBreak
    % Draw your message
    halfMsg = [ 'Halfway Reached!' newline newline ...
        'Please wait for experimenter...'];
    DrawFormattedText(window, halfMsg, 'center', 'center', expParams.colors.white);
    Screen('Flip', window);
    
    % Restrict so only 'c' is reported
    RestrictKeysForKbCheck(cKey);
    KbReleaseWait;                   % clear out any previous key presses
    
    % Wait until 'c' is pressed (second arg = 2 → ignore key‐up events)
    [secs, keyCode] = KbWait([], 2);
    
    % If it really was 'c', break out
    if keyCode(cKey)
        doneWithHalfwayBreak = true;
    end
    
    RestrictKeysForKbCheck([]);      % lift the restriction
    KbReleaseWait;                   % clear that final key‐up
end


    % % if ~demoMode && ~isempty(eyetracker) % Check calibrationData is not empty
    % %     fprintf('Recalibrating eye tracker before 4-AFC...\n');
    % %     DrawFormattedText(window, 'Preparing for Eye Tracker Recalibration...\n\nPress SPACE to start.', 'center', 'center', expParams.colors.white);
    % %     Screen('Flip', window);
    % %     KbName('UnifyKeyNames');
    % %     spaceKey = KbName('SPACE');
    % %     KbWait(-1, 2); % Wait for key release before proceeding. why not just wait(.5)  ?
    % %     while true % wait for space
    % %         [~, ~, keyCode] = KbCheck;
    % %         if keyCode(spaceKey)
    % %             break;
    % %         end
    % %     end
    % %     calibrateTobii(window, windowRect, eyetracker, expParams);
    % %     fprintf('Recalibration complete.\n');
    % % end



    % p1,  piece presentation
    p1(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker);

    % break 1
    betweenSectionBreakScreen(window, expParams);

    % p2, pieces in tableaus
    p2(subjID, demoMode, expParams, ioObj, address, eyetracker);

    showEndScreen(window, expParams); % thank participant and exit

catch ME

    % clean up ptb if error
    sca;
    ShowCursor;
    Priority(0);
    Screen('CloseAll');

    rethrow(ME);
end

% clean up after exp.
sca;
ShowCursor;
Priority(0);
Screen('CloseAll')
end



