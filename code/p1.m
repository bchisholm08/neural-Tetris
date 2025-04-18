function p1(subjID, demoMode)
% piece presentation
sca;

%{

Implement demoMode to lets us test the behavioral section of the
experiment. This should bypass tobii and EEG, but display and record
info for the behavioral part. 
 
for when this is an actual function within the humanTetris wrapper, may
want to handle subjID and demoMode input here. i.e.

if nargin < 2 
subjID = input('Enter subject ID (e.g., P01): ', 's');
demoMode = input('Enable demo mode? (1 = yes, 0 = no): ');
end 
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
 % allow wrapper to supply subjID/demoMode, otherwise default
if nargin < 1
subjID = input('Enter a subjID (e.g. ''P01''): ', 's');
end
if nargin < 2
demoMode = 1;   % default to demo mode
end
%==================
% TRIALS AND BLOCKS 
s1nBlocks = 4;
s1presentationsPerBlock = 5;
%==================
% In CATSS some functions can interfere with my code 
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

% Get the path of the current script, add scripts we need 
currentScriptPath = matlab.desktop.editor.getActiveFilename;
codeFolder = fileparts(currentScriptPath);
mainFolder = fileparts(codeFolder);
tobiiSDKPath = fullfile(mainFolder, 'tools', 'tobiiSDK');
helperScriptsPath = fullfile(mainFolder, 'code', 'helperScripts');
baseDataDir = fullfile(mainFolder, 'data');
eegHelperPath = fullfile(mainFolder,'tools', 'matlab_port_trigger');
tittaPath = fullfile(mainFolder, 'tools','tittaMaster');

addpath(tobiiSDKPath, helperScriptsPath, baseDataDir, eegHelperPath, tittaPath);

% confirm added paths 
disp(['Added to path: ', helperScriptsPath]);
disp(['Added to path: ', baseDataDir]);
disp(['Added to path: ', tobiiSDKPath]);
disp(['Added to path:', tittaPath]);
disp(['Added to path:', eegHelperPath]);

% get some experimenter inputs
% decMode = input('Is Biosemi set to "DECIMAL" for data collection? (1 = yes, 0 = no): ');
% also add in table power cable check 


% Create directory structure
% original path baseDataDir = 'C:\Users\chish071\Desktop\tetris\data';
% try to use relative not absolute paths so this program doesn't crash
rootDir = fullfile(baseDataDir, subjID);

% create subfolders for data 
eyeDir = fullfile(rootDir, 'eyeData');
behavDir = fullfile(rootDir, 'behavioralData');
miscDir = fullfile(rootDir, 'misc');

% create needed subject dirs 
if ~exist(rootDir, 'dir')
    mkdir(rootDir);
end
if ~exist(eyeDir, 'dir')
    mkdir(eyeDir);
end
if ~exist(behavDir, 'dir')
    mkdir(behavDir);
end
if ~exist(miscDir, 'dir')
    mkdir(miscDir);
end
% check 
if ~exist(rootDir, 'dir')
    error('Failed to create root directory: %s', rootDir);
end

%{
calling initExperiment below does a few useful things. 

Firstly, it will handle sync testing and initialize PTB.
After this, there are a handful of options for the `expParams` structure that is passed around.
This is to not clog up main experiment scripts, but also have consistent expParams passed between sections. 

Finally it will handle demo mode, and if demo mode is false, it will 
open the parallel port for BioSemi, and complete an initial calibration of Tobii. 

At the end, it returns needed info back to our experiment to get running. 
%}

[window, windowRect, expParams, ioObj, address, eyetracker] = initExperiment(subjID, demoMode, baseDataDir);

try % ends 144, main experiment loop

% unsure if there is any methodological reason for 300Hz sampling,except that the CATSS website says its the highest sample rate. 
% Would really like to know (a kinesiologist or something) the time scale that pupil dialation occurs at. Could email UMN expert

%% Add in instruction screen (practice blocks?) 
p1instruct(window, expParams);
%FIXME add practice blocks and practice instructions?
pieces = getTetrino(expParams);
nPieces = length(pieces); 
% preallocate data struct for subj 
nTrialsTotal = s1nBlocks * s1presentationsPerBlock;
data = repmat(struct('block', [], 'trial', [], 'piece', [], ...
                 'fixationOnset', [], 'onset', [], ...
                 'eegTrigger', [], 'gazeData', []), ...
                 nTrialsTotal, 1);

% do randomization and determine order of presentation etc. Adding this into our data struct would allow for us
% to perform checks throughout the experiment that values are lining up as
% we expect, i.e. trial #10 is actually pID5 as intended

pieceOrder = randi(nPieces, 1, nTrialsTotal);
if length(pieceOrder) ~= nTrialsTotal
    error('Mismatch: pieceOrder (%d) DNE expected trial count (%d)', ...
           length(pieceOrder), nTrialsTotal);
end

for block = 1:s1nBlocks
    for t = 1:s1presentationsPerBlock
% clear gaze buffer before collecting data 
if ~demoMode 
eyetracker.get_gaze_data(); % flush buffer 
end 
    % Fixation
    Screen('FillRect', window, expParams.colors.background); % Clear screen to background
    drawFixation(window, windowRect, expParams.fixation.color); % Draw cross in white
    fixationOnset = Screen('Flip', window); % Display fixation
    WaitSecs(0.5); % Show fixation for 500ms before stimulus

    %% Present piece
    pieceID = pieceOrder((block - 1) * s1presentationsPerBlock + t);
    Screen('DrawTexture', window, pieces(pieceID).tex);
    [~, stimOnset] = Screen('Flip', window, fixationOnset + 0.8 + rand*0.4);

    %% Send EEG trigger 
    % since we have info from initExp, shouldn't have to do ~demo
    % etc. 
    eegTrigger = pieceID * 10;  % 'Piece Alone' triggers: I=10, Z=20, ..., T=70
    if ~demoMode && ~isempty(ioObj)
        io64(ioObj, address, eegTrigger);
    end
    %FIXME EEG TRIGGER FUNCTION 
    % trigger sanity check 
    fprintf('B#/T# = %d/%d | pID = %d | trigger = %d\n', block, t, pieceID, eegTrigger);
    % Collect Tobii data
    gazeData = []; % Initialize to empty
    if ~demoMode
        gazeData = eyetracker.get_gaze_data(); % Get data since last call
    end

    %% Log data
    trialIndex = (block - 1) * s1presentationsPerBlock + t;
    data(trialIndex).block = block;
    data(trialIndex).trial = t;
    data(trialIndex).piece = pieceID;
    data(trialIndex).onset = stimOnset;
    data(trialIndex).eegTrigger = eegTrigger;
    data(trialIndex).fixationOnset = fixationOnset;
    data(trialIndex).trialDuration = stimOnset - fixationOnset;
    data(trialIndex).gazeData = gazeData;

    %% handle ITI
    WaitSecs(0.1); % piece display for 100ms  
    Screen('Flip', window); % offset piece 

    %FIXME the ITI is a crucial time where we need to name and save the
    %pupil data. Important! Make effecient as well...
trialData = struct();
trialData.block          = block;
trialData.trial          = t;
trialData.pieceID        = pieceID;
trialData.gazeData       = gazeData;
trialData.onset          = stimOnset; 
trialData.nSamples       = length(gazeData);
trialData.eegTrigger = eegTrigger;  % same as data(trialIndex)
trialData.fixationOnset  = fixationOnset;
trialData.saveTimestamp  = datestr(now);  % or datestr(now)
% call preprocessing function 
trialData = preprocessGazeData(trialData);

pupilFileName = fullfile(eyeDir, sprintf('%s_trial%03d_block%02d.mat', subjID, t, block));
save(pupilFileName, 'trialData', '-v7');
fprintf('Trial %d: gaze samples = %d\n\n', t, length(gazeData));

WaitSecs(0.7 + rand*0.4);  % 800-1200ms ITI

    end
    %% give participants a break betwixt blocks
    if block < s1nBlocks
        take5Brubeck(window, expParams);
    end
end % S1 block end
%% Save data
 %% Save behavioral data @ end
expParams.pieceOrder = pieceOrder;
expParams.timestamp = datestr(now, 'yyyymmdd_HHMMSS');
saveDat('p1', subjID, data, expParams, demoMode);

sca;          
Priority(0); 
ShowCursor;
Screen('CloseAll') % clean up
%====================================================================
catch ME
sca;          % Close PTB, screan clear
Priority(0);  % Reset priority of matlab
ShowCursor;   % Restore cursor
rethrow(ME);  % Show error details
Screen('CloseAll')
%% call expBreakscreen() to save data and help transition to next section

% neat trick that can make matlab jump to a the line where the
% crash occurred:

% hEditor = matlab.desktop.editor.getActive;
% hEditor.goToLine(whathappened.stack(end).line)
% commandwindow;  % Courtesy JM :)
% =======================================================================
end % try [i.e. experiment] end
end % p1() end