%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: This script handles the general set up of the human tetris
% experiment. The `expParams` struct returned contains vital info used to run
% every section of the experiment. Other outputs help set up PTB and
% our other data collection instruments, Tobii eyetracker and BioSemi EEG.
% First we set up some basic info for our expParams struct, and then remove
% some directories we know can interfere with how our code functions. After
% removing paths, we use pathsAndPlaces to get paths we NEED for the
% experiment. Paths are constructed, and in demoMode a visual check of the
% paths is offered and prompts the user Y/N for continuing with displayed
% paths.
% 
% Neccessary paths and directories are saved into expParams
% Colors are loaded into expParams next. After colors are set, PTB is
% initialized. Importantly, in demoMode PTB is initialized with 'loose'
% synchronization tests. This means reported timings may not be accurate.
% In 'realDealDataMode', PTB completes a 'strict' synchronization test that
% ensures reported and intended timing in the experiment holds true. After
% initializing PTB, we save useful PTB parameters that we need later for
% displaying stimuli, placing things in the right place, etc.
% 
% At this point, PTB is fully initialized. Now we set options for each
% section of the experiment, depending on if we are in demoMode or not.
% This difference affects the number of blocks and trials in each section,
% timings, fixation parameters, and so on. Finally keys are assigned for
% PTB, and then an output is printed to the command window telling the
% experimenter which mode they've initialized in. 
% 
% The expParams structure that is ultimately returned contains: 
%               struct(fields) 
%-------------------------------------------------------
function [window, windowRect, expParams, ioObj, address, eyetracker] = initExperiment(subjID, demoMode)
% Initializes PTB, EEG (if enabled), Tobii tracker (if enabled), and experiment parameters
% Designed to be called once by a overall wrapper script.

% begin w/ empty output args
window = [];
windowRect = [];
ioObj = [];
address = [];
eyetracker = [];

expParams = struct(); % Initialize main params structure
% store info
expParams.subjID = subjID;
expParams.demoMode = demoMode;

% expParams.initExperimentTimestamp = datestr(now, 'yyyymmdd_HHMMSS'); % timestamp will be useful for P5.
expParams.rule.initExperiment_expMasterBeginTime = datetime('now');
expParams.rule.initExperiment_expMasterBeginTime.Format = 'HH:mm:ss_M/d/yy';

expParams.rule.initExperiment_expMasterEndTime = []; % initialize as empty, store once finished

expParams.rule.maxExperimentTime = 180; % in minutes. Be wary of conversions and formatting throughout the code...ultimately this will be used to cap P5

%% paths

% FIXME NOTE I think this script needs to add the directory above to its
% path so that I stop getting 'add to path' errors when running from
% various directories...

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

% Add the helperScripts path FIRST so getProjectPath can be found
try
    % This initial path detection is a one-time necessary step.
    tempPath = fileparts(which(mfilename('fullpath')));

    % temp path runs as: Z:\13-humanTetris\code\helperScripts
    addpath(tempPath);
catch
    error('initExperiment:PathError', 'Could not find the helperScripts folder. Please run from the correct directory.');
end

% --- Use pathsAndPlaces() to define all critical folder locations ---
mainExperimentHomeDir   = pathsAndPlaces(0); % 0 = project root
codeDir                 = pathsAndPlaces(1); % 1 = code folder
baseDataDir             = pathsAndPlaces(2); % 2 = data folder
toolsDir                = pathsAndPlaces(3); % 3 = tools folder

% Define paths to tools and data relative to the main experiment folder
tobiiSDKPath = fullfile(mainExperimentHomeDir, 'tools', 'tobiiSDK');

% line below had an extra
% helperScriptsPath = fullfile(mainExperimentHomeDir, 'helperScripts');

% fix path?
% baseDataDir = fullfile(mainExperimentHomeDir, 'data');
eegHelperPath = fullfile(mainExperimentHomeDir,'tools', 'matlab_port_trigger');
tittaPath = fullfile(mainExperimentHomeDir, 'tools','tittaMaster');

% get paths
if ~contains(path, eegHelperPath)
    addpath(eegHelperPath);
end

if ~contains(path, tittaPath)
    addpath(tittaPath);
end

disp(['Main experiment folder set as: ', mainExperimentHomeDir]);
disp(['Added to path (helperScripts): ', codeDir]);
disp(['Base data directory set to: ', baseDataDir]);
disp(['Added to path (Tobii SDK): ', tobiiSDKPath]);
disp(['Added to path (Titta): ', tittaPath]);
disp(['Added to path (EEG Helper): ', eegHelperPath]);

if demoMode % extra demo mode file pathway check, so many past errors / problems
    while true
        % Ask for user confirmation
        prompt = 'Proceed with displayed filepathways? (Y/N): ';
        response = input(prompt, 's');

        % Check the response
        if strcmpi(response, 'Y') || strcmpi(response, 'Yes')
            % If 'Y' or 'Yes', break the loop and continue with the script
            fprintf('Paths confirmed. Continuing...\n');
            break;
        elseif strcmpi(response, 'N') || strcmpi(response, 'No')
            % If 'N' or 'No', throw an error to abort the experiment safely
            error('Experiment aborted by user at path confirmation.');
        else
            % If the input is invalid, inform the user and ask again
            fprintf('Invalid input. Please enter Y or N.\n');
        end
    end
end

%% build/assign directories to exp params
expParams.baseDataDir = baseDataDir;
expParams.subjPaths.subjRootDir = fullfile(expParams.baseDataDir, subjID);
expParams.subjPaths.eyeDir = fullfile(expParams.subjPaths.subjRootDir, 'eyeData');
expParams.subjPaths.behavDir = fullfile(expParams.subjPaths.subjRootDir, 'behavioralData');
expParams.subjPaths.miscDir = fullfile(expParams.subjPaths.subjRootDir, 'misc');

% check existence of above directories and create if not found
if ~exist(expParams.subjPaths.subjRootDir, 'dir'), mkdir(expParams.subjPaths.subjRootDir); end
if ~exist(expParams.subjPaths.eyeDir, 'dir'), mkdir(expParams.subjPaths.eyeDir); end
if ~exist(expParams.subjPaths.behavDir, 'dir'), mkdir(expParams.subjPaths.behavDir); end
if ~exist(expParams.subjPaths.miscDir, 'dir'), mkdir(expParams.subjPaths.miscDir); end

if ~exist(expParams.subjPaths.subjRootDir, 'dir')
    error('Failed to create subject''s root directory @: %s', expParams.subjPaths.subjRootDir);
end

% REDUNDANT fprintf('Paths and directories set up successfully.\n');

%% exp color settings
expParams.colors.white = [255 255 255];
expParams.colors.black = [0 0 0];
expParams.colors.gray  = [127 127 127];
expParams.colors.red   = [255 0 0];
expParams.colors.green = [0 255 0];
expParams.colors.piece = [127 127 127]; % exp gray
expParams.colors.background = [0 0 0];  % black background

%% init ptb
PsychDefaultSetup(2); %FIXME this depends based on demo or REAL DEAL data mode
screens = Screen('Screens');
screenNumber = max(screens);

%% initialize the screen and save info to our params
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, expParams.colors.background);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);

Screen('TextFont', window, 'Arial'); % Default font
Screen('TextSize', window, 36); % Default text size
HideCursor;
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

expParams.screen.window = window;
expParams.screen.windowRect = windowRect; % save windowRect
expParams.screen.width = screenXpixels;
expParams.screen.height = screenYpixels;
expParams.screen.center = [xCenter, yCenter];
expParams.screen.screenNumber = screenNumber;
expParams.screen.ifi = Screen('GetFlipInterval', expParams.screen.window); % save inter-frame interval

fprintf('Psychtoolbox initialized successfully.\n');

%% overall experiment timings
% in MS
expParams.rule.fixationDuration = 0.5;
expParams.rule.stimulusDuration = 0.1;

%{
moved from original p1 script, pass with expParams 
        fixationDuration = 0.5; % Duration of initial fixation
        stimulusDuration = 0.1; % How long the piece is visible (100ms)
        itiDuration = 0.7 + rand * 0.4; % Random ITI duration (700-1100ms)
keep ITI to each respective script for rng 
%}

% at some point the duplicate below existed, obviously I want to use the
% expParams.rule above. noted 6/10/2025
% expParams.fixation.durationSecs = 0.5; % fixation duration

%% demoMode vs 'real' mode settings
if demoMode

    % loose sync test 
    Screen('Preference', 'SkipSyncTests', 2);

    % timings 
    expParams.rule.minBlockBreakTime = 0;
    expParams.rule.maxBlockBreakTime = 300;
    expParams.rule.minInterExpBreakTime = 0;
    expParams.rule.maxInterExpBreakTime = 300;

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

    expParams.p4.options.respTimeout = 1.75; % seconds, how long the subj has to respond
    expParams.p4.options.blocks = 7;
    expParams.p4.options.trialsPerBlock = 6;
    expParams.p4.options.totalP4Trials = expParams.p4.options.blocks * expParams.p4.options.trialsPerBlock;
    expParams.p4.options.sectionDoneFlag = 0;

    expParams.p5.options.gamesAllowed = 2;
   
else % REAL EXPERIMENT MODE
    %% timings 
    expParams.rule.minBlockBreakTime = 30;
    expParams.rule.maxBlockBreakTime = 120;
    expParams.rule.minInterExpBreakTime = 30;
    expParams.rule.maxInterExpBreakTime = 180;

    fprintf('Running REAL EXPERIMENT MODE.\n');
    Screen('Preference', 'SkipSyncTests', 0); % Strict sync tests

    %% set up tobii
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

            % cal tobii (in REAL exp mode this acts as our initial
            % calibration for the participant. Need to decide about
            % including a gaze fixation or something to help subjects
            % throughout the experiment...?

            expParams.Tobii_info.screen_pixels = [screenXpixels, screenYpixels];
            fprintf('Beginning Initial Tobii Calibration...\n');
            % this save is incorrect--should go to subject database
            expParams.Tobii_info.calResult = calibrateTobii(window, windowRect, eyetracker, expParams); % Pass expParams
            % if calibrationData is empty or something funkywunky happens
            % we need to add a CHECK here for that. 
        else
            error('Failed to get a valid EyeTracker object.');
        end
    catch tobiiME
        error('Tobii Eye Tracker initialization failed: %s', tobiiME.message);
    end

    %% initialize EEG trigger (io64 obj)
    try
        fprintf('Initializing EEG trigger system (io64)...\n');
        ioObj = io64;
        status = io64(ioObj); % eeg interface
        if status == 0 % 0 = good io64 status
            address = hex2dec('3FF8'); % CATSS lab port address LPT3
            io64(ioObj, address, 0); % Send a reset trigger (0)
            fprintf('EEG trigger system initialized successfully. Port: %s, Address: %s\n', 'LPT1 equivalent', dec2hex(address));
        else
            error('Failed to initialize LPT port via io64. Status: %d', status);
        end
    catch eegME
        error('EEG trigger system (io64) initialization failed: %s\nAttempting to continue without EEG triggers.', eegME.message);
        ioObj = []; % Ensure ioObj is empty if setup fails
        address = [];
    end

    %% Real experiment parameters for sections
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

% Fixation params
expParams.fixation.size = 10; % pixels for cross arms
expParams.fixation.lineWidth = 2; % in pixels
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

% just a silly string
if expParams.demoMode
    sillyStringBoi = "DEMO MODE";
else
    sillyStringBoi = "REAL DEAL DATA COLLECTION";
end

fprintf(['=============================\n' ...
    'initExperiment successfully initialized experiment in %s\n' ...
    '=============================\n'], sillyStringBoi);
end