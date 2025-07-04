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

% begin w/ empty output
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
% now can call code chunk below to get ITI based on function handle instead
% of having to type it in each PX() script... 
%{
itiDuration = expParams.p<X>.options.itiFcn();  % Get ITI
WaitSecs(itiDuration);            % Wait duration
%}

% expParams.initExperimentTimestamp = datestr(now, 'yyyymmdd_HHMMSS'); %
% timestamp will be useful for P5... hopefully 
expParams.rule.initExperiment_expMasterBeginTime = datetime('now');
expParams.rule.initExperiment_expMasterBeginTime.Format = 'HH:mm:ss_M/d/yy';

expParams.rule.initExperiment_expMasterEndTime = []; % initialize as empty, store once finished. add to clean up of p5 

expParams.rule.maxExperimentTime = 180; % in minutes. Be wary of conversions and formatting throughout the code...ultimately this will be used to cap P5 play time 

%% exp color settings
expParams.colors.white = [255 255 255];
expParams.colors.black = [0 0 0];
expParams.colors.gray  = [127 127 127];
expParams.colors.red   = [255 0 0];
expParams.colors.green = [0 255 0];
expParams.colors.piece = [127 127 127]; % exp gray
expParams.colors.background = [0 0 0];  % black background

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
try % try to get initial paths 
    % This initial path detection is a one-time necessary step.
    tempPath = fileparts(which(mfilename('fullpath')));
    % temp path runs as: Z:\13-humanTetris\code\helperScripts
    addpath(tempPath);
catch
    error('initExperiment:PathError', '!!!!!!!!!!!!\nCould not find helperScripts. \nPlease run from correct directory\n!!!!!!!!!!!!');
end

% --- Use pathsAndPlaces() to define all critical folder locations ---
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
% disp(['Added to path (Titta): ', tittaPath]);
disp(['Added to path (EEG Helper): ', eegHelperPath]);

if demoMode % extra demo mode file pathway check, so many past errors / problems with creating incorrect directories 
    while true
        % user confirmation
        prompt = 'Proceed with displayed filepathways? (Y/N): ';
        response = strtrim(input(prompt, 's'));

        % Check response
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
end % file path check 

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

% flags
expParams.p1.options.sectionDoneFlag = 0;
expParams.p2.options.sectionDoneFlag = 0;
% % % expParams.p4.options.sectionDoneFlag = 0;
expParams.p5.options.sectionDoneFlag = 0;

if demoMode
    Screen('Preference', 'SkipSyncTests', 2);  % loose 
else
    Screen('Preference', 'SkipSyncTests', 0);  % strict
end

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
expParams.screen.screenNumber = screenNumber;
expParams.screen.ifi = Screen('GetFlipInterval', expParams.screen.window); % save inter-frame interval

fprintf('Psychtoolbox initialized successfully.\n');

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
    expParams.rule.minBlockBreakTime = 0;
    expParams.rule.maxBlockBreakTime = 300;
    expParams.rule.minInterExpBreakTime = 0;
    expParams.rule.maxInterExpBreakTime = 300;

    % timings below in MS
    % p1 
    expParams.p1.options.stimulusDuration = 0.1; 
    expParams.p1.options.fixationDuration = 0.5; 
    % p2 
    expParams.p2.options.stimulusDuration = 0.1;
    expParams.p2.options.fixationDuration = 0.5; 
    % p 4 
    % % % expParams.p4.options.stimulusDuration = 0.1;
    % % % expParams.p4.options.fixationDuration = 0.5; 
    % % % expParams.p4.options.respTimeout = 1.5; % seconds, how long the subj has to respond. NOTE: Look closely @ how iti & flip are calculated, and if this 'remainder' or 'idle

    % demoMode blocks / trials
    expParams.p1.options.blocks = 4;
    expParams.p1.options.trialsPerBlock = 5;
    expParams.p1.options.totalP1Trials = expParams.p1.options.blocks * expParams.p1.options.trialsPerBlock;

    expParams.p2.options.blocks = 7;
    expParams.p2.options.trialsPerBlock = 6; %  MUST BE A MULTIPLE OF 6 FOR EXP TO WORK
    expParams.p2.options.totalP2Trials = expParams.p2.options.blocks * expParams.p2.options.trialsPerBlock;

    % % % expParams.p4.options.blocks = 7;
    % % % expParams.p4.options.trialsPerBlock = 18; % get more presentation in demoMode
    % % % expParams.p4.options.totalP4Trials = expParams.p4.options.blocks * expParams.p4.options.trialsPerBlock;

    % in seconds 
    expParams.p5.options.totalTime = 300; % total time, 10 min demo 
    expParams.p5.options.phaseOne = 150; % force 5 min of play before playbacks ORIGINALLY 600 (cut for testing)
    % other p5 options 
    expParams.p5.saveBoardSnapShot = 1; % manual setting, will save boardsnap shots to designated folder 
    expParams.p5.gameplayCount = 0;
    expParams.p5.replayCount = [];
    expParams.p5.blockSize = 30; % global 
else 
    %% REAL EXPERIMENT MODE
    %% timings 
    expParams.rule.minBlockBreakTime = 30;
    expParams.rule.maxBlockBreakTime = 120;
    expParams.rule.minInterExpBreakTime = 30;
    expParams.rule.maxInterExpBreakTime = 180;

    expParams.rule.minBlockBreakTime = 0;
    expParams.rule.maxBlockBreakTime = 300;
    expParams.rule.minInterExpBreakTime = 0;
    expParams.rule.maxInterExpBreakTime = 300;
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

    %% init experiment tobii
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

            expParams.Tobii_info.screen_pixels = [expParams.screen.width, expParams.screen.height];
            fprintf('Beginning Initial Tobii Calibration...\n');
            % this save below is incorrect--should go to subject database
            expParams.Tobii_info.calResult = calibrateTobii(window, windowRect, eyetracker, expParams); % Pass expParams
            % if calibrationData is empty or something funkywunky happens
            % we need to add a CHECK here for that. 
        else
            error('Failed to get a valid EyeTracker object.');
        end
    catch tobiiME
        error('Tobii Eye Tracker initialization failed: %s', tobiiME.message);
    end

    %% init experiment EEG
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
        ioObj = []; % empty ioObj if setup fails
        address = [];
    end

    %% real exp blocks and trials 
    expParams.p1.options.blocks = 7;
    expParams.p1.options.trialsPerBlock = 70;
    expParams.p1.options.totalP1Trials = expParams.p1.options.blocks * expParams.p1.options.trialsPerBlock;
    % p1, 490 total trials

    expParams.p2.options.blocks = 7;
    expParams.p2.options.trialsPerBlock = 210; %  MUST BE A MULTIPLE OF 3 FOR EXP TO WORK; 3 conditions (fit / partial fit / does not fit)
    expParams.p2.options.totalP2Trials = expParams.p2.options.blocks * expParams.p2.options.trialsPerBlock;
    % p2, 1470 total trials

    % % % expParams.p4.options.blocks = 7;
    % % % expParams.p4.options.trialsPerBlock = 50;
    % % % expParams.p4.options.totalP4Trials = expParams.p4.options.blocks * expParams.p4.options.trialsPerBlock;
    % % % % p4, 350 total trials

    expParams.p5.options.totalTime = 5400; % 90 min        % old 3600; % total time, 60 minutes 
    expParams.p5.options.phaseOne = 600; % 10 min initial playtime to accumulate gameplay  
    % p5, 90 min total. (10 min forced play to begin, 80 min 50/50 play/watch after that time

    % other p5 options 
    expParams.p5.saveBoardSnapShot = 1; % manual setting, will save boardsnap shots to designated folder 
    expParams.p5.gameplayCount = 0;
    expParams.p5.replayCount = [];
    expParams.p5.blockSize = 30; % global 

end % end demoMode/realMode difference  handling

% a silly string
if expParams.demoMode
    sillyStringBoi = "DEMO MODE";
else
    sillyStringBoi = "REAL ~~DEAL~~ DATA COLLECTION";
end
fprintf(['\n\n=============================\n' ...
    'initExperiment successfully initialized experiment in %s' ...
    '\n\n=============================\n'], sillyStringBoi); % this is stupid but I'm keeping it
end