function p2()
% piece in tableau context 
sca;

%{
===============
S2 OPTIONS
s1-piece presentation = 60 presentations of 7 pieces = 420 total trials 
420 = 
exp: Blocks = 3; 
Trials = 20;
each ~60 times with EEG recording, focused on capturing the moment of piece presentation. Presentation of the stimuli will be brief (~100ms, or 5-6 frames at 60Hz). Inter-trial intervals will be random (uniform distribution), between 800ms - 1200ms (mean of 1 second). 60 repetitions of each piece x 5 pieces x 1100 ms (presentation + ITI) = ~5.5 minutes. 
s2-piece presentation with tableau = 30 repetitions 
exp: Blocks = 5; 
Trials = ;

30 repetitions x 5 pieces (this is 1 block) x 5 blocks (tableaus)
%}


%==================
% TRIALS AND BLOCKS
s2nBlocks = 7;
s2presentationsPerBlock = 30;
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
subjID = input('Enter a subjID: ', 's');
demoMode = input('Enable demo mode? (1 = yes, 0 = no): ');

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

try % begin try for experiment after init exp
    %% Section 2: Tableaus and contexts
    p2instruct(window, expParams)
    tableaus = getTableaus(window, expParams); % 

    pieces = getTetrino(expParams);
    nPieces = length(pieces);
    % preallocate data struct for subj
    nTrialsTotal = s2nBlocks * s2presentationsPerBlock;
    
    % Convert all tableaus to textures

blockSize = 50;
border = 2;

[screenX, screenY] = Screen('WindowSize', window);


    % Define piece names in order (1-7)
    pieceNames = {'I','Z','O','S','J','L','T'};

    % Set up block-wise condition structure
    targetPieceIDs = randperm(nPieces);  % Randomize block-wise tableau pieces
    blockData = struct();
    blockData.trials = struct();  % leave empty and grow it safely


   for block = 1:s2nBlocks
    tableauPieceID = targetPieceIDs(block);       % which piece's tableau to show this block
    tableauPieceName = pieceNames{tableauPieceID};  % e.g., 'I'

    % Always use this tableau (e.g., I-fit_reward)
    matchingTableaus = tableaus(strcmp({tableaus.piece}, tableauPieceName) & ...
                                strcmp({tableaus.condition}, 'fit_reward'));
    if isempty(matchingTableaus)
        error('No tableau found for piece %s under fit_reward', tableauPieceName);
    end
    currentTableau = matchingTableaus(1);  % only need one, fixed for block

    for t = 1:s2presentationsPerBlock
        pieceID = randi(nPieces);  % vary the stimulus piece each trial
        pieceName = pieceNames{pieceID};

        % Gaze buffer flush
        if ~demoMode
            eyetracker.get_gaze_data();
        end

        % Fixation
        Screen('FillRect', window, expParams.colors.background);
        drawFixation(window, windowRect, expParams.fixation.color);
        fixationOnset = Screen('Flip', window);
        WaitSecs(0.5);

        % Draw tableau and piece
        Screen('DrawTexture', window, currentTableau.tex, [], currentTableau.rect);
        pieceRect = CenterRectOnPointd(pieces(pieceID).rect, ...
                                       windowRect(3)/2, windowRect(4)/2);

        % EEG trigger
        currentCond = 'contextual';  % or 'context_block'
        eegTrigger = getTrig(pieceName, 'fit_reward');  % mapping remains clear
        if ~demoMode && ~isempty(ioObj)
            io64(ioObj, address, eegTrigger);
        end

% Draw piece
Screen('DrawTexture', window, pieces(pieceID).tex, [], pieceRect);

% If the trial is a match, draw a green square outline around it
if strcmp(pieceName, tableauPieceName)
    highlightColor = [0 255 0];     % bright green (RGB)
    highlightSize = 150;            % width/height of highlight box in px
    borderThickness = 8;            % outline weight

    % Define a centered square around the piece's draw point
    [cx, cy] = RectCenter(windowRect);  % screen center
    highlightRect = CenterRectOnPointd([0 0 highlightSize highlightSize], cx, cy);

    Screen('FrameRect', window, highlightColor, highlightRect, borderThickness);
end

      
        [~, stimOnset] = Screen('Flip', window);

        fprintf('B#/T# = %d/%d | Tableau: %s | Stim: %s | EEG = %d\n', ...
            block, t, tableauPieceName, pieceName, eegTrigger);

        % Eye tracking
        gazeData = [];
        if ~demoMode
            gazeData = eyetracker.get_gaze_data('from', stimOnset);
        end

        % Log trial
        trial.block = block;
        trial.trial = t;
        trial.piece = pieceName;
        trial.contextPiece = tableauPieceName;
        trial.condition = currentCond;
        trial.fixationOnset = fixationOnset;
        trial.stimOnset = stimOnset;
        trial.eegTrigger = eegTrigger;
        trial.gazeData = gazeData;
        trial.isMatch = strcmp(pieceName, tableauPieceName);  % useful in later analysis
        trial.nSamples = length(gazeData);

        if t == 1 && block == 1
            blockData.trials = trial;
        else
            blockData.trials(end+1) = trial;
        end

        pupilFileName = fullfile(eyeDir, sprintf('%s_p2_trial%03d_block%02d.mat', subjID, t, block));
        save(pupilFileName, 'trial', '-v7');

        % ITI
        Screen('FillRect', window, expParams.colors.background);
        WaitSecs(0.7 + rand*0.4);
    end % trial loop end 

    % call Brubreck! 

    saveDat('p2', subjID, blockData, expParams, demoMode);
   end % block loop end 

    % Cleanup
    if ~demoMode
        tetio_disconnectTracker();
    end
    Priority(0);
    ShowCursor;
    sca;
    Screen('CloseAll')
catch ME
    sca;          % Close PTB, screan clear
    Priority(0);  % Reset priority of matlab
    ShowCursor;   % Restore cursor
    rethrow(ME);  % Show error details
    Screen('CloseAll')
    % neat trick that can make matlab jump to a the line where the
    % crash occurred:
    hEditor = matlab.desktop.editor.getActive;
    hEditor.goToLine(whathappened.stack(end).line)
    commandwindow;  % Courtesy of JM :)
end % function end