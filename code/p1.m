function p1()
%{
1) Gather subject ID and create folder / directory for them 

2) Connect to, calibrate, and utilize eye tracking data 

3) Connect to and trigger BioSemi EEG system

4) P1() EXPERIMENT
Display 7 tetris pieces in a block / trial loop, using a mean ITI 1sec 

During experiment:
send TDT triggers for EEG 
record eye tracking data 

Implement demoMode to lets us test the behavioral section of the
experiment. This should bypass tobii and EEG, but display and record
info for the behavioral part. 

Take demoMode input (1/0) and deal with Tobii, TDT, and Biosemi/EEG 

When demoMode = 0;


When demoMode = 1; 

%}

demoMode = 1;  % Set to `true` if you want to bypass EEG and eye tracking


clear all;
sca;

%{
===============
S1 OPTIONS
decide blocks and trials/block 
s1-piece presentation = 40 presentations of 7 pieces = 280 total trials 
280 = 
exp: Blocks = 3; 
Trials = 20;

Present the 5 original tetris pieces, each ~60 times with EEG recording, focused on capturing the moment of piece presentation. 
Presentation of the stimuli will be brief (~100ms, or 5-6 frames at 60Hz).
Inter-trial intervals will be random (uniform distribution), between 800ms - 1200ms (mean of 1 second). 
60 repetitions of each piece x 7 pieces x 1100 ms (presentation + ITI) = ~5.5 minutes. 

%}

% For data collection: 
% 
%
s1nBlocks = 2;
s1presentationsPerBlock = 10;
%============================================================

% In CATSS, some functions that can interfere with my code 
if isfolder('C:\CATSS_Booth2')
    rmpath('C:\CATSS_Booth2');
end

if isfolder('R:\cla_psyc_oxenham_labscripts\scripts\')
    rmpath('R:\cla_psyc_oxenham_labscripts\scripts\')
end

if isfolder('P:\scripts') || isfolder('P:\afc\scripts')
    rmpath(genpath('P:\scripts'));
    rmpath('P:\afc\scripts');
end

% Get the path of the current script
% currentScriptPath = mfilename('fullpath');

currentScriptPath = matlab.desktop.editor.getActiveFilename;
% Get the folder containing the current script
codeFolder = fileparts(currentScriptPath);

% Go up one level from /code/ to get tableaus 
mainFolder = fileparts(codeFolder);

% get tobiiSKD functions
tobiiSDKPath = fullfile(mainFolder, 'tools', 'tobiiSDK');
addpath(tobiiSDKPath);

% Define paths to the helperScripts and dataCollection folders
helperScriptsPath = fullfile(mainFolder, 'code', 'helperScripts');
baseDataDir = fullfile(mainFolder, 'data');

% Add both folders to the MATLAB path
addpath(helperScriptsPath, baseDataDir);

% confirmation
disp(['Added to path: ', helperScriptsPath]);
disp(['Added to path: ', baseDataDir]);
disp(['Added to path: ', tobiiSDKPath]);

% Check if the .mat file already exists in the current folder
if exist('tableaus.mat', 'file') == 2
    disp('Tableau.mat file already exists. Skipping the creation process.');
else
    disp('Tableau .mat file DOES NOT exist. Creating .mat file now.');
    tableau;

end

try % ends 144, main trial loop?
    % Subject input
    subjID = input('Enter subject ID (e.g., P01): ', 's');
    demoMode = input('Enable demo mode? (1 = yes, 0 = no): ');

    %% Set up some eyetracker stuff
    trackingMode = 'human'; % For Tobii Pro Spectrum ['human', 'monkey', 'great_ape']; changes the illumination model of Tobii.
    whichTracker = 'Tobii Pro Spectrum';
    eyetrackerSamplerate = 300; 

    %{
=================================
Here I think I should do an overall calibration before 
anything else. Establishing and setting up Tobii / Tita here 
may be most convienent 
=================================
    
    % unsure if there is any methodological reason for 300Hz sampling,except that the CATSS website says its the highest sample rate. 
    % Would really like to know (a kinesiologist or something) the time scale that pupil dialation occurs at. Could email a UMN expert
    %}

% Initialize experiment. This returns a lot of the 'stuff' PTB needs
[window, windowRect, expParams] = initExperiment(subjID, demoMode);

% Initialize EEG and Eye Tracker inline
if demoMode
    ioObj = [];
    address = [];
    eyetracker = [];
else
    % EEG Trigger Setup
    ioObj = io64;
    status = io64(ioObj);
    address = hex2dec('3FF8');
    
% Tobii Eye Tracker
Tobii = EyeTrackingOperations();
eyetracker_address = 'tet-tcp://169.254.6.40';
eyetracker = Tobii.get_eyetracker(eyetracker_address);
    
    if isa(eyetracker, 'EyeTracker')
        fprintf('Tobii initialized at %s\n', eyetracker.Address);
    else
        error('Tobii not found!');
    end
end % end demo mode handling 

    % Create directory structure
    % original path baseDataDir = 'C:\Users\chish071\Desktop\tetris\data';
    % try to use relative not absolute paths so this program doesn't crash
    rootDir = fullfile(baseDataDir, 'subjData', subjID);
    if ~exist(rootDir, 'dir')
        mkdir(rootDir);
        arrayfun(@(x) mkdir(fullfile(rootDir, sprintf('p%d', x))), 1:4);
        mkdir(fullfile(rootDir, 'misc'));
    end

    % check for dir creation
    if ~exist(rootDir, 'dir')
        error('Failed to create directory: %s', rootDir);
    end

    %% Add in instruction screen(s), and practice blocks...
    p1instruct(window, expParams);
    %FIXME add practice blocks and practice instructions?

    pieces = getTetrino(expParams);
    nPieces = 7; % standard # of tetrino
    
% preallocate data struct for subj 
    data = struct('block', [], 'trial', [], 'piece', [], 'onset', []);

    for block = 1:s1nBlocks
        %% Randomize piece order within block
        pieceOrder = repmat(1:nPieces, 1, s1presentationsPerBlock);
         
        pieceOrder = pieceOrder(randperm(length(pieceOrder)));

        for t = 1:s1presentationsPerBlock
            %% Fixation
             Screen('FillRect', window, expParams.colors.background); % Clear screen to background
            drawFixation(window, windowRect, expParams.fixation.color); % Draw cross in white
            fixationOnset = Screen('Flip', window); % Display fixation
            WaitSecs(0.5); % Show fixation for 500ms before stimulus
            %% Present piece
            pieceID = pieceOrder(t);  % Use actual piece ID
            Screen('DrawTexture', window, pieces(pieceID).tex);
            [~, stimOnset] = Screen('Flip', window, fixationOnset + 0.8 + rand*0.4);

            %% Send EEG trigger
            if ~demoMode && ~isempty(ioObj)
                io64(ioObj, address, pieceID); % Trigger for pieceID
            end

            %% Collect Tobii data
            gazeData = []; % Initialize to empty
            if ~demoMode
                gazeData = eyetracker.get_gaze_data(); % Get data since last call
            end

            %% Log data
            data(end).block = block;
            data(end).trial = t;
            data(end).piece = pieceID;
            data(end).onset = stimOnset;
            data(end).eegTrigger = pieceID;
            data(end).gazeData = gazeData; % Handles demoMode gracefully

            %% handle ITI
            WaitSecs(0.1);  % 100ms presentation
            Screen('Flip', window);
            WaitSecs(0.7 + rand*0.4);  % 800-1200ms ITI
        end
        %% Break betwixt blocks
        if block < s1nBlocks
            take5Brubeck(window, expParams);
        end
    end % S1 block end
    %% Save Section 1 data
    saveDat('p1', subjID, data, expParams, demoMode);
    sca;          % Close PTB, screan clear
    Priority(0);  % Reset priority of matlab
    ShowCursor;   % Restore cursor
    rethrow(ME);  % Show error details
%====================================================================
    catch ME
    sca;          % Close PTB, screan clear
    Priority(0);  % Reset priority of matlab
    ShowCursor;   % Restore cursor


    % neat trick that can make matlab jump to a the line where the
    % crash occurred:
    
    % hEditor = matlab.desktop.editor.getActive;
    % hEditor.goToLine(whathappened.stack(end).line)
    % commandwindow;  % Courtesy of JM :)
% =======================================================================
end % try [i.e. experiment] end
end % p1() end