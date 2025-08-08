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
% init empty outputs
window = [];
windowRect = [];
ioObj = [];
address = [];
eyetracker = [];

expParams = struct(); % Initialize main params structure
% store some info
expParams.subjID = subjID;
expParams.demoMode = demoMode;

% set ITI here
itiFcn = @() 1.0 + rand * 0.2;  % ITI between 1000–1200 ms
expParams.p1.options.itiFcn = itiFcn;
expParams.p2.options.itiFcn = itiFcn;
expParams.p4.options.itiFcn = itiFcn;
%{
call below code chunk to get ITI based on function handle, versus typing
itiDuration = expParams.p<X>.options.itiFcn();  % Get ITI
WaitSecs(itiDuration);            % Wait duration
%}

expParams.rule.initExperiment_expMasterBeginTime = datetime('now');
expParams.rule.initExperiment_expMasterBeginTime.Format = 'HH:mm:ss_M/d/yy';

expParams.rule.initExperiment_expMasterEndTime = []; % initialize as empty, store once finished. add to clean up of p5

%expParams.rule.maxExperimentTime = 180; % in minutes. Be wary of conversions and formatting throughout the code...ultimately this will be used to cap P5 play time

expParams.rule.keyRepeatInterval = 0.10; % plugging this into a WaitSecs() call can help the CPU and keyboard debouncing

%% exp color settings
expParams.colors.white = [255 255 255];
expParams.colors.black = [0 0 0];
expParams.colors.gray  = [127 127 127];
expParams.colors.red   = [255 0 0];
expParams.colors.green = [0 255 0];
% expParams.colors.piece = [255 255 255]; % [127 127 127]; % exp gray
expParams.colors.background = [0 0 0];  % black background
expParams.visual.pieceColor = uint8([64 64 64]);

pieceNames = {'I','Z','O','S','J','L','T'};
for i = 1:numel(pieceNames)
    expParams.colors.pieces.(pieceNames{i}) = expParams.visual.pieceColor;
end

%% exp fixation params
expParams.fixation.size = 10; % in pixels for cross arms
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

%% paths

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
try % try to get initial paths
    % This initial path detection is a one-time necessary step.
    tempPath = fileparts(which(mfilename('fullpath')));
    % temp path runs as: Z:\13-humanTetris\code\helperScripts
    addpath(tempPath);
catch
    error('initExperiment:PathError', '!!!!!!!!!!!!\nCould not find helperScripts. \nPlease run from correct directory\n!!!!!!!!!!!!');
end

% helper path finder
mainExperimentHomeDir   = pathsAndPlaces(0); % 0 = project root
codeDir                 = pathsAndPlaces(1); % 1 = code folder
baseDataDir             = pathsAndPlaces(2); % 2 = data folder
% toolsDir                = pathsAndPlaces(3); % 3 = tools folder

% Define paths to tools and data relative to the main experiment folder
tobiiSDKPath = fullfile(mainExperimentHomeDir, 'tools', 'tobiiSDK');

% fix this path?
% baseDataDir = fullfile(mainExperimentHomeDir, 'data');
eegHelperPath = fullfile(mainExperimentHomeDir,'tools', 'matlab_port_trigger');
tittaPath = fullfile(mainExperimentHomeDir, 'tools','tittaMaster');

if ~contains(path, eegHelperPath)
    addpath(eegHelperPath);
end

if ~contains(path, tittaPath)
    addpath(tittaPath);
end

%% assign & build directories to exp params
expParams.baseDataDir = baseDataDir;
expParams.subjPaths.subjRootDir = fullfile(expParams.baseDataDir, subjID);
expParams.subjPaths.eyeDir = fullfile(expParams.subjPaths.subjRootDir, 'eyeData');
expParams.subjPaths.behavDir = fullfile(expParams.subjPaths.subjRootDir, 'behavioralData');
expParams.subjPaths.boardData = fullfile(expParams.subjPaths.subjRootDir, 'boardSnapshots');
expParams.subjPaths.miscDir = fullfile(expParams.subjPaths.subjRootDir, 'misc');

% check existence of above directories and create if not found
if ~exist(expParams.subjPaths.subjRootDir, 'dir')
    mkdir(expParams.subjPaths.subjRootDir);
end
if ~exist(expParams.subjPaths.eyeDir, 'dir')
    mkdir(expParams.subjPaths.eyeDir);
end
if ~exist(expParams.subjPaths.behavDir, 'dir')
    mkdir(expParams.subjPaths.behavDir);
end
if ~exist(expParams.subjPaths.boardData, 'dir')
    mkdir(expParams.subjPaths.boardData)
end
if ~exist(expParams.subjPaths.miscDir, 'dir')
    mkdir(expParams.subjPaths.miscDir)
end
if ~exist(expParams.subjPaths.subjRootDir, 'dir')
    error('Failed to create subject''s root directory @: %s', expParams.subjPaths.subjRootDir);
end

disp(['Main experiment folder set as: ', mainExperimentHomeDir]);
disp(['Added to path (helperScripts): ', codeDir]);
disp(['Base data directory set to: ', baseDataDir]);
disp(['Added to path (Tobii SDK): ', tobiiSDKPath]);
% disp(['Added to path (Titta): ', tittaPath]);
disp(['Added to path (EEG Helper): ', eegHelperPath]);

% % % if demoMode % extra demo mode file pathway check, so many past errors / problems with creating incorrect directories
% % %     while true
% % %         % user confirmation
% % %         prompt = 'Proceed with displayed filepathways? (Y/N): ';
% % %         response = strtrim(input(prompt, 's'));
% % %         % Check response
% % %         if strcmpi(response, 'Y') || strcmpi(response, 'Yes')
% % %             % If 'Y' or 'Yes', break the loop and continue with the script
% % %             fprintf('Paths confirmed. Continuing...\n');
% % %             break;
% % %         elseif strcmpi(response, 'N') || strcmpi(response, 'No')
% % %             % If 'N' or 'No', throw an error to abort the experiment safely
% % %             error('Experiment aborted by user at path confirmation.');
% % %         else
% % %             % If the input is invalid, inform the user and ask again
% % %             fprintf('Invalid input. Please enter Y or N.\n');
% % %         end
% % %     end
% % % end % file path check

% section flags
expParams.p1.options.sectionDoneFlag = 0;
expParams.p2.options.sectionDoneFlag = 0;
% % % expParams.p4.options.sectionDoneFlag = 0;
expParams.p5.options.sectionDoneFlag = 0;

if demoMode
    Screen('Preference', 'SkipSyncTests', 2);  % loose
else
    Screen('Preference', 'SkipSyncTests', 0);  % strict
end

% block size parameters
% pixel size of the tableau "frame" (width, height)
expParams.visual.tableauSize = [600 450];
% how much of that frame the piece should fill (0 < scale ≤ 1)
expParams.visual.pieceScale  = 0.8;
expParams.visual.blockSize = 50;
expParams.visual.border = 2;
expParams.visual.boardH = 20;
expParams.visual.boardW = 10;
%% initialize PTB screen and save info to expParams
PsychDefaultSetup(2); % general PTB set up, no sync test

screens = Screen('Screens');
screenNumber = max(screens);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, expParams.colors.background);

% save these into expParams below
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);

Screen('TextFont', window, 'Arial'); % Default font
Screen('TextSize', window, 36); % Default text size
HideCursor;
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

expParams.screen.window = window;
expParams.screen.windowRect = windowRect;
expParams.screen.width = screenXpixels;
expParams.screen.height = screenYpixels;
expParams.screen.center = [xCenter, yCenter];
tw = expParams.visual.tableauSize(1);
th = expParams.visual.tableauSize(2);
cx = expParams.screen.center(1);
cy = expParams.screen.center(2);
% new parameter for centering
expParams.visual.tableauRect = CenterRectOnPoint([0 0 tw th], cx, cy);

expParams.screen.screenNumber = screenNumber;
expParams.screen.ifi = Screen('GetFlipInterval', expParams.screen.window); % save inter-frame interval

fprintf('======================\n\nPsychtoolbox initialized successfully.\n======================\n\n');

%% demoMode vs experiment 'real' data collection settings
% from here below we have a big 'if/else/end' that first tries to
% initialize the experiment with demoMode settings. If demoMode is false,
% we'll go on to the 'real' set up section
if demoMode
    % needed in P5 expParams struct. Will need to make sure we're not
    % overriding any assignments in the first parts of the experiment
    expParams.ioObj = [];
    expParams.address = [];
    expParams.eyeTracker = [];
    % expParams.gameCount = 0;

    %% demoMode timings
    % % expParams.rule.minBlockBreakTime = 0;
    % % expParams.rule.maxBlockBreakTime = 300;
    % % expParams.rule.minInterExpBreakTime = 0;
    % % expParams.rule.maxInterExpBreakTime = 300;

    expParams.rule.minBlockBreakTime = 10;
    expParams.rule.maxBlockBreakTime = 60;
    expParams.rule.minInterExpBreakTime = 30;
    expParams.rule.maxInterExpBreakTime = 50;

    % timings in MS
    % p1
    expParams.p1.options.stimulusDuration = 0.1;
    expParams.p1.options.fixationDuration = 0.5;
    % p2
    expParams.p2.options.stimulusDuration = 0.1;
    expParams.p2.options.fixationDuration = 0.5;

    % % % expParams.p4.options.blocks = 7;
    % % % expParams.p4.options.trialsPerBlock = 50;
    % % % expParams.p4.options.totalP4Trials = expParams.p4.options.blocks * expParams.p4.options.trialsPerBlock;
    % % % % p4, 350 total trials

    % % % % in seconds
    % % % expParams.p5.options.totalTime = 4500; % 4500s = 75min
    % % % expParams.p5.options.phaseOne = 1500; % 1500s = 25min (1/3rd of P5 time)

    expParams.p5.options.totalTime = 240; % 4 MIN TOTAL
    expParams.p5.options.phaseOne = 120; % 2 MIN OF PLAYING

    % other p5 options
    expParams.p5.saveBoardSnapShot = 1; % manual setting, will save boardsnap shots to designated folder
    expParams.p5.gameplayCount = 0;
    expParams.p5.replayCount = [];
    expParams.p5.blockSize = expParams.visual.blockSize; % global


    expParams.p1.options.blocks = 4;
    expParams.p1.options.trialsPerBlock = 5;
    expParams.p1.options.totalP1Trials = expParams.p1.options.blocks * expParams.p1.options.trialsPerBlock;

    expParams.p2.options.blocks = 7;
    expParams.p2.options.trialsPerBlock = 6; %  MUST BE A MULTIPLE OF 6 FOR EXP TO WORK
    expParams.p2.options.totalP2Trials = expParams.p2.options.blocks * expParams.p2.options.trialsPerBlock;

    % other p5 options
    expParams.p5.saveBoardSnapShot = 1; % manual setting, will save boardsnap shots to designated folder
    expParams.p5.gameplayCount = 0; % init for later counting...
    expParams.p5.replayCount = [];
else
    %% REAL EXPERIMENT MODE
    %% timings
    expParams.rule.minBlockBreakTime = 5;
    expParams.rule.maxBlockBreakTime = 30;
    expParams.rule.minInterExpBreakTime = 15;
    expParams.rule.maxInterExpBreakTime = 60;

    % % expParams.rule.minBlockBreakTime = 0;
    % % expParams.rule.maxBlockBreakTime = 300;
    % % expParams.rule.minInterExpBreakTime = 0;
    % % expParams.rule.maxInterExpBreakTime = 300;
    % below all in MS
    % p1
    expParams.p1.options.stimulusDuration = 0.1;
    expParams.p1.options.fixationDuration = 0.5;
    % p2
    expParams.p2.options.stimulusDuration = 0.1;
    expParams.p2.options.fixationDuration = 0.5;
    % % % % p4
    % % % expParams.p4.options.fixationDuration = 0.5;
    % % % expParams.p4.options.respTimeout = 1.75; % seconds, how long the subj has to respond before timeout

    %% init tobii
    try
        fprintf('Beginning Tobii Initialization...\n');
        Tobii = EyeTrackingOperations();

        eyetracker_address = 'tet-tcp://169.254.6.40';
        eyetracker = Tobii.get_eyetracker(eyetracker_address);

        % Confirm eyetracker is valid
        if isempty(eyetracker) || ~isprop(eyetracker, 'SerialNumber')
            error('Tobii tracker handle invalid or not connected.');
        end

        % Print tracker info
        fprintf('Connected to Tobii Eye Tracker:\n');
        disp(['  Address:          ' eyetracker.Address]);
        disp(['  Name:             ' eyetracker.Name]);
        disp(['  Serial Number:    ' eyetracker.SerialNumber]);
        disp(['  Model:            ' eyetracker.Model]);
        disp(['  Firmware Version: ' eyetracker.FirmwareVersion]);
        disp(['  Runtime Version:  ' eyetracker.RuntimeVersion]);

        % Screen size info for calibration
        expParams.Tobii_info.screen_pixels = [expParams.screen.width, expParams.screen.height];

        % Try calibration
        fprintf('Beginning Initial Tobii Calibration...\n');
        try
            expParams.Tobii_info.calResult = calibrateTobii(window, windowRect, eyetracker, expParams);
        catch calErr
            warning('Calibration failed: %s', calErr.message);
            expParams.Tobii_info.calResult = [];
        end

    catch tobiiME
        error('Tobii Eye Tracker initialization failed: %s', tobiiME.message);
    end

    %% init EEG
    try
        fprintf('Initializing EEG trigger system (io64)...\n');
        ioObj = io64;
        status = io64(ioObj); % eeg interface
        if status == 0 % 0 = good io64 status
            address = hex2dec('3FF8'); % CATSS lab port address LPT3
            io64(ioObj, address, 0); % Send a reset trigger (0)
            fprintf('EEG trigger system initialized successfully. Port: %s, Address: %s\n', 'LPT1 equivalent', dec2hex(address));
            expParams.ioObj = ioObj;
        else
            error('Failed to initialize LPT port via io64. Status: %d', status);
        end
    catch eegME
        warning('EEG trigger system (io64) initialization failed: %s\nAttempting to continue without EEG triggers.', eegME.message);
        ioObj = []; % empty ioObj if setup fails
        address = [];
    end

    % playOneGame hotfix from struct error
    expParams.ioObj = ioObj;
    expParams.address = address;
    expParams.eyeTracker =  eyetracker;

    %% real exp trials and blocks
    expParams.p1.options.blocks = 7;
    expParams.p1.options.trialsPerBlock = 50; % reduced from 70 to 50 8/8/25
    expParams.p1.options.totalP1Trials = expParams.p1.options.blocks * expParams.p1.options.trialsPerBlock;
    % p1, 490 total trials, 15 or so min


    expParams.p2.options.blocks = 7;
    expParams.p2.options.trialsPerBlock = 180; %  MUST BE A MULTIPLE OF 3 FOR EXP TO WORK; 3 conditions (fit / partial fit / does not fit)
    expParams.p2.options.totalP2Trials = expParams.p2.options.blocks * expParams.p2.options.trialsPerBlock;
  
    % p2, 1260 total trials. Originally 210 trials per block, which is
    % almost an hour. This should be closer to 30 min

    % in seconds
    expParams.p5.options.totalTime = 4200; % 4200; % 4200s = 70min
    expParams.p5.options.phaseOne =  1200; % 1500s = 20min (1/3rd of total P5 time)

    % other p5 options
    expParams.p5.saveBoardSnapShot = 1; % manual setting, save boardsnap shots to designated folder
    expParams.p5.gameplayCount = 0;
    expParams.p5.replayCount = [];
    expParams.p5.blockSize = expParams.visual.blockSize; % global

end % end demoMode/realMode difference  handling

% silly string
if expParams.demoMode
    sillyStringBoi = "DEMO MODE";
else; sillyStringBoi = "REAL ~~DEAL~~ DATA COLLECTION";
end

fprintf(['\n\n=============================\n' ...
    'initExperiment successfully initialized experiment in %s' ...
    '\n\n=============================\n'], sillyStringBoi);
end

