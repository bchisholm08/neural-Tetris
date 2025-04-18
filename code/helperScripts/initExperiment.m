function [window, windowRect, expParams, ioObj, address, eyetracker] = initExperiment(subjID, demoMode, baseDataDir)

% Initializes PTB, EEG (if enabled), Tobii tracker (if enabled), and experiment parameters
%
% INPUTS:
%   subjID   - subject ID string (e.g., 'P01')
%   demoMode - 1 if testing without EEG/Eye Tracker, 0 if real session
%
% OUTPUTS:
%   window       - PTB window handle
%   windowRect   - PTB window rectangle
%   params       - experiment settings and constants
%   ioObj        - I/O object for EEG triggers (empty in demoMode)
%   address      - EEG parallel port address (empty in demoMode)
%   eyetracker   - Tobii object (empty in demoMode)

    %% --- Sync test handling ---
    if demoMode
        Screen('Preference', 'SkipSyncTests', 2);  % more lenient
    else
        Screen('Preference', 'SkipSyncTests', 0);  % strict mode
    end

    %% --- PTB Initialization ---
    PsychDefaultSetup(2);
    screens = Screen('Screens');
    screenNumber = max(screens);
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, 0.5);  % gray background
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    [xCenter, yCenter] = RectCenter(windowRect);
    Screen('TextSize', window, 36);
    HideCursor;
    topPriorityLevel = MaxPriority(window);
    Priority(topPriorityLevel);


    %% --- Exp Params --- 
    expParams.rule.minBreakTime = 0;
    expParams.rule.maxBreakTime = 300;
    %% --- Colors ---
    expParams.colors.white = [255 255 255];
    expParams.colors.black = [0 0 0];
    expParams.colors.gray  = [127 127 127];
    expParams.colors.red   = [255 0 0];
    expParams.colors.green = [0 255 0];
    expParams.colors.piece = [127 127 127]; % experimental gray
    expParams.colors.background = [0 0 0];

    % Normalized [0–1] colors
    expParams.colors.norm.white = [1 1 1];
    expParams.colors.norm.black = [0 0 0];
    expParams.colors.norm.gray  = [0.5 0.5 0.5];

    %% --- Fixation ---
    expParams.fixation.size = 20;
    expParams.fixation.color = [255 255 255]; % white
    expParams.fixation.type = 'cross';

    %% --- Keys ---
    KbName('UnifyKeyNames');
    expParams.keys.left    = KbName('LeftArrow');
    expParams.keys.right   = KbName('RightArrow');
    expParams.keys.down    = KbName('DownArrow');
    expParams.keys.up      = KbName('UpArrow');
    expParams.keys.space   = KbName('space');
    expParams.keys.p       = KbName('P');
    expParams.keys.escape  = KbName('ESCAPE');
    expParams.keys.r       = KbName('R');

    %% --- Screen Parameters ---
    expParams.window = window;
    expParams.screen.width = screenXpixels;
    expParams.screen.height = screenYpixels;
    expParams.center = [xCenter, yCenter];
    expParams.subjID = subjID;
    expParams.demoMode = demoMode;
    expParams.timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    
    %% -- Paths --- 
    expParams.baseDataDir = baseDataDir;  % necessary for file saves

    %% --- EEG Setup ---

if demoMode
    ioObj = [];
    address = [];
else
    ioObj = io64;
    status = io64(ioObj);
    address = hex2dec('3FF8');  % default parallel port address
end

if demoMode
        eyetracker = [];
    else
        % Single-file Tobii Pro SDK usage
        Tobii = EyeTrackingOperations();

        % Insert the actual IP you see in Windows "Network & Sharing Center" (or from a known config)
        eyetracker_address = 'tet-tcp://169.254.6.40';

        fprintf('Attempting to connect to Tobii at %s...\n', eyetracker_address);
        eyetracker = Tobii.get_eyetracker(eyetracker_address);

        if isa(eyetracker, 'EyeTracker')
           fprintf('Successfully connected to Tobii:\n');
           disp(['  Address:          ' eyetracker.Address]);
           disp(['  Name:             ' eyetracker.Name]);
           disp(['  Serial Number:    ' eyetracker.SerialNumber]);
           disp(['  Model:            ' eyetracker.Model]);
           disp(['  Firmware Version: ' eyetracker.FirmwareVersion]);
           disp(['  Runtime Version:  ' eyetracker.RuntimeVersion]);

           % Optionally calibrate:
            screen_pixels = [screenXpixels, screenYpixels];
            calResult = calibrateTobii(window, windowRect, eyetracker, expParams);           
        else
           error('Tobii EyeTracker could not be initialized (handle invalid).');
        end
end
end % end function 
