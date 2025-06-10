%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: 
%                            
%-------------------------------------------------------
function [window, windowRect, expParams, ioObj, address, eyetracker] = initExperiment(subjID, demoMode, p1Flag)
% Initializes PTB, EEG (if enabled), Tobii tracker (if enabled), and experiment parameters
% Designed to be called once by a wrapper script.

% default output args
window = [];
windowRect = [];
ioObj = [];
address = [];
eyetracker = [];

expParams = struct(); % Initialize main params structure

%% paths 
fprintf('Preparing paths and directories...\n\n');

% The p1Flag is kept for now as the wrapper passes it as 1.
% primary role is to set expParams.p1Flag if needed elsewhere.
% if p1Flag
%     expParams.p1Flag = 1; 
% else
%     expParams.p1Flag = 0; 
% end   NO LONGER NEEDED--ALL PX() SCRIPTS HAVE 0/1 FLAGS 

% some paths can interfere with us in CATSS 
if isfolder('C:\CATSS_Booth2')
    rmpath('C:\CATSS_Booth2');
    disp('Removed C:\CATSS_Booth2 from path.');
end
if isfolder('R:\cla_psyc_oxenham_labscripts\scripts\')
    rmpath('R:\cla_psyc_oxenham_labscripts\scripts\');
    disp('Removed R:\cla_psyc_oxenham_labscripts\scripts\ from path.');
end
if isfolder('P:\scripts') || isfolder('P:\afc\scripts')
    rmpath(genpath('P:\scripts'));
    rmpath('P:\afc\scripts');
    disp('Removed P:\scripts and P:\afc\scripts from path.');
end

try

    % should really use relative instead of absolute paths 
    currentScriptPath = matlab.desktop.editor.getActiveFilename;
  
    % if isempty(currentScriptPath) && ~isdeployed % In case running not from editor
    %      currentScriptPath = which(mfilename); % Fallback if not in editor
    % end
    helperScriptsFolder = fileparts(currentScriptPath);
    homeCodeFolder = fileparts(helperScriptsFolder);
    mainExperimentHomeDir = fileparts(homeCodeFolder); 
    % if isempty(mainExperimentHomeDir) || strcmp(mainExperimentHomeDir, homeCodeFolder) % Check if derivation went as expected
    %         warning('Could not determine mainExperimentHomeFolder. Double-check script location.');
    %         mainExperimentHomeDir = fileparts(pwd); 
    % end
catch
    error("initExperiment encountered an error constructing filepaths")
end

% Define paths to tools and data relative to the main experiment folder
tobiiSDKPath = fullfile(homeCodeFolder, 'tools', 'tobiiSDK');

% line below had an extra 
helperScriptsPath = fullfile(homeCodeFolder, 'helperScripts'); 

% fix path? 
baseDataDir = fullfile(mainExperimentHomeDir, 'data');
eegHelperPath = fullfile(mainExperimentHomeDir,'tools', 'matlab_port_trigger');
tittaPath = fullfile(mainExperimentHomeDir, 'tools','tittaMaster');

% get paths we need 
if ~contains(path, eegHelperPath)
    addpath(eegHelperPath);
end
if ~contains(path, tittaPath)
    addpath(tittaPath);
end

disp(['Main experiment folder detected as: ', mainExperimentHomeDir]);
disp(['Added to path (helperScripts): ', helperScriptsPath]);
disp(['Base data directory set to: ', baseDataDir]);
disp(['Added to path (Tobii SDK): ', tobiiSDKPath]);
disp(['Added to path (Titta): ', tittaPath]);
disp(['Added to path (EEG Helper): ', eegHelperPath]);

expParams.baseDataDir = baseDataDir;
expParams.subjPaths.subjRootDir = fullfile(expParams.baseDataDir, subjID);
expParams.subjPaths.eyeDir = fullfile(expParams.subjPaths.subjRootDir, 'eyeData');
expParams.subjPaths.behavDir = fullfile(expParams.subjPaths.subjRootDir, 'behavioralData');
expParams.subjPaths.miscDir = fullfile(expParams.subjPaths.subjRootDir, 'misc');

% check existence and create if not found 
if ~exist(expParams.subjPaths.subjRootDir, 'dir'), mkdir(expParams.subjPaths.subjRootDir); end
if ~exist(expParams.subjPaths.eyeDir, 'dir'), mkdir(expParams.subjPaths.eyeDir); end
if ~exist(expParams.subjPaths.behavDir, 'dir'), mkdir(expParams.subjPaths.behavDir); end
if ~exist(expParams.subjPaths.miscDir, 'dir'), mkdir(expParams.subjPaths.miscDir); end

if ~exist(expParams.subjPaths.subjRootDir, 'dir')
    error('Failed to create subject''s root directory @: %s', expParams.subjPaths.subjRootDir);
end
fprintf('Paths and directories set up successfully.\n');

% exp color settings 
expParams.colors.white = [255 255 255];
expParams.colors.black = [0 0 0];
expParams.colors.gray  = [127 127 127];
expParams.colors.red   = [255 0 0];
expParams.colors.green = [0 255 0];
expParams.colors.piece = [127 127 127]; % exp gray
expParams.colors.background = [0 0 0];  % black background

% init ptb 
fprintf('Initializing Psychtoolbox...\n\n\n');
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, expParams.colors.background);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);

Screen('TextFont', window, 'Courier New'); % Default font
Screen('TextSize', window, 36); % Default text size
HideCursor;
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% save screen info to our exp. params 
expParams.window = window;
expParams.screen.windowRect = windowRect; % save windowRect     
expParams.screen.width = screenXpixels;
expParams.screen.height = screenYpixels;
expParams.screen.center = [xCenter, yCenter];
expParams.screen.screenNumber = screenNumber;
expParams.screen.ifi = Screen('GetFlipInterval', window); % save inter-frame interval

fprintf('Psychtoolbox initialized successfully.\n');

% demoMode vs 'real' mode settings 
if demoMode
    fprintf('Running in DEMO MODE.\n');
    % Devices are already pre-initialized to empty
    Screen('Preference', 'SkipSyncTests', 2); 

    % demoMode blocks / trials 
    expParams.p1.options.blocks = 4;
    expParams.p1.options.trialsPerBlock = 5;
    expParams.p1.options.totalP1Trials = expParams.p1.options.blocks * expParams.p1.options.trialsPerBlock;
    expParams.p1.options.sectionDoneFlag = 0; % initialize this flag as zero, and change later! 

    expParams.p2.options.blocks = 7;
    expParams.p2.options.trialsPerBlock = 6; %  MUST BE A MULTIPLE OF 6 FOR EXP TO WORK
    expParams.p2.options.totalP2Trials = expParams.p2.options.blocks * expParams.p2.options.trialsPerBlock;
    expParams.p2.options.sectionDoneFlag = 0;
    % expParams.p3.options.blocks = ; 
    % expParams.p3.options.trialsPerBlock = ; 
    % expParams.p3.options.totalP3Trials = ; 

    expParams.p4.options.blocks = 7;
    expParams.p4.options.trialsPerBlock = 10;
    expParams.p4.options.totalP4Trials = expParams.p4.options.blocks * expParams.p4.options.trialsPerBlock;
    expParams.p4.options.sectionDoneFlag = 0;
    
    expParams.p5.options.gamesAllowed = 2;

else % EXPERIMENT MODE
    fprintf('Running REAL EXPERIMENT MODE.\n');
    Screen('Preference', 'SkipSyncTests', 0); % Strict sync tests

    % set up tobii 
    try
        fprintf('Initializing Tobii Eye Tracker...\n');
        Tobii = EyeTrackingOperations();
        eyetracker_address = 'tet-tcp://169.254.6.40'; % tobii address 
        fprintf('Attempting connection to Tobii at %s...\n', eyetracker_address);
        eyetracker = Tobii.get_eyetracker(eyetracker_address);

        if isa(eyetracker, 'EyeTracker')
            fprintf('Successfully connected to Tobii Eye Tracker:\n');
            disp(['  Address:          ' eyetracker.Address]);
            disp(['  Name:             ' eyetracker.Name]);
            disp(['  Serial Number:    ' eyetracker.SerialNumber]);
            disp(['  Model:            ' eyetracker.Model]);
            disp(['  Firmware Version: ' eyetracker.FirmwareVersion]);
            disp(['  Runtime Version:  ' eyetracker.RuntimeVersion]);

            % cal tobii (in REAL exp mode. acts as our initial calibration
            
            expParams.Tobii_info.screen_pixels = [screenXpixels, screenYpixels];
            fprintf('Beginning Initial Tobii Calibration...\n');
            expParams.Tobii_info.calResult = calibrateTobii(window, windowRect, eyetracker, expParams); % Pass expParams
            fprintf('Tobii calibration completed.\n');
        else
            error('Failed to get a valid EyeTracker object.');
        end
    catch tobiiME
        warning('Tobii Eye Tracker initialization or calibration failed: %s\nAttempting to continue without eye tracking.', tobiiME.message);
        eyetracker = []; % Ensure eyetracker is empty if setup fails
    end

    % EEG trigs 
    try
        fprintf('Initializing EEG trigger system (io64)...\n');
        ioObj = io64;
        status = io64(ioObj); % eeg interface
        if status == 0 % 0 = good io64 status
            address = hex2dec('3FF8'); % Parallel port address
            io64(ioObj, address, 0); % Send a reset trigger (0)
            fprintf('EEG trigger system initialized successfully. Port: %s, Address: %s\n', 'LPT1 equivalent', dec2hex(address));
        else
            error('Failed to initialize LPT port via io64. Status: %d', status);
        end
    catch eegME
        warning('EEG trigger system (io64) initialization failed: %s\nAttempting to continue without EEG triggers.', eegME.message);
        ioObj = []; % Ensure ioObj is empty if setup fails
        address = [];
    end

    % Real experiment parameters for sections
    expParams.p1.options.blocks = 7;
    expParams.p1.options.trialsPerBlock = 70;
    expParams.p1.options.totalP1Trials = expParams.p1.options.blocks * expParams.p1.options.trialsPerBlock;
    expParams.p1.options.sectionDoneFlag = 0;
    % p1, 490 total trials 

    expParams.p2.options.blocks = 7;
    expParams.p2.options.trialsPerBlock = 210; %  MUST BE A MULTIPLE OF 6 FOR EXP TO WORK (fit / partial fit / does not fit) 
    expParams.p2.options.totalP2Trials = expParams.p2.options.blocks * expParams.p2.options.trialsPerBlock;
    expParams.p2.options.sectionDoneFlag = 0;
    % p2, 1470 total trials

    % expParams.p3.options.blocks = ; 
    % expParams.p3.options.trialsPerBlock = ; 
    % expParams.p3.options.totalP3Trials = expParams.p3.options.blocks * expParams.p3.options.trialsPerBlock; 

    expParams.p4.options.blocks = 7; 
    expParams.p4.options.trialsPerBlock = 50;
    expParams.p4.options.totalP4Trials = expParams.p4.options.blocks * expParams.p4.options.trialsPerBlock;
    expParams.p4.options.sectionDoneFlag = 0;
    % p4, 350 total trials 

    % this will be changed to TIME allowed. Once completing the other
    % sections of the experiment, some amount of our three hours remains,
    % and we'll just use all of that for 
    expParams.p5.options.gamesAllowed = 6;
   
    %FIXME: Add time ceiling for games allowed. i.e. if our overall experiment 
    % time is over 3hrs, force end screen, or something. Will probably need
    % to add something to p1 that adds a `expStartTimestamp` or something.
    % Then when we get to p5, we can use whatever that time difference is
    % from three hours (or other time ceiling) to give a countdown timer. I
    % personally think it would be alright to leave the timer in the upper
    % corner of the screen--will have to ask JP 

end % end demoMode block handling 

%% handle demoMode timing 
% timing params 

%{
moved from original p1 script, pass with expParams 
        fixationDuration = 0.5; % Duration of initial fixation
        stimulusDuration = 0.1; % How long the piece is visible (100ms)
        itiDuration = 0.7 + rand * 0.4; % Random ITI duration (700-1100ms)
keep ITI to each respective script for rng 
%}

% in MS  
expParams.rule.fixationDuration = 0.5;
expParams.rule.stimulusDuration = 0.1; 

% at some point the duplicate below existed, obviously I want to use the
% expParams.rule above. Noticed 6/10/2025
% expParams.fixation.durationSecs = 0.5; % fixation duration

if demoMode
    % in seconds 
    expParams.rule.minBlockBreakTime = 0;    
    expParams.rule.maxBlockBreakTime = 300;  
    expParams.rule.minInterExpBreakTime = 0; 
    expParams.rule.maxInterExpBreakTime = 300; 
else
    expParams.rule.minBlockBreakTime = 30;   
    expParams.rule.maxBlockBreakTime = 120;  
    expParams.rule.minInterExpBreakTime = 30;
    expParams.rule.maxInterExpBreakTime = 180;
end

% Fixation params 
expParams.fixation.size = 20; % pixels for cross arms
expParams.fixation.lineWidth = 4; % in pixels
expParams.fixation.color = expParams.colors.white;
expParams.fixation.type = 'cross'; % 'dot' / 'cross'

% set up keyboard 
KbName('UnifyKeyNames');
expParams.keys.left    = KbName('LeftArrow');
expParams.keys.right   = KbName('RightArrow');
expParams.keys.down    = KbName('DownArrow');
expParams.keys.up      = KbName('UpArrow');
expParams.keys.space   = KbName('space');
expParams.keys.enter   = KbName('Return'); 
expParams.keys.escape  = KbName('ESCAPE');
expParams.keys.p       = KbName('p'); % pause
expParams.keys.r       = KbName('r'); % experiment keycode 

% store info 
expParams.subjID = subjID;
expParams.demoMode = demoMode;
expParams.initExperimentTimestamp = datestr(now, 'yyyymmdd_HHMMSS');

fprintf(['=============================\n' ...
    'initExperiment successfully initialized experiment.\n' ...
    '=============================\n']);
end