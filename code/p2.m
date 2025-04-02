function p2()
clear all;
sca;

%{
===============
S1 & S2 OPTIONS

decide blocks and trials/block 

s1-piece presentation = 60 presentations of 7 pieces = 420 total trials 
420 = 
exp: Blocks = 3; 
Trials = 20;


Present the 5 original tetris pieces, each ~60 times with EEG recording, focused on capturing the moment of piece presentation. Presentation of the stimuli will be brief (~100ms, or 5-6 frames at 60Hz). Inter-trial intervals will be random (uniform distribution), between 800ms - 1200ms (mean of 1 second). 60 repetitions of each piece x 5 pieces x 1100 ms (presentation + ITI) = ~5.5 minutes. 



s2-piece presentation with tableau = 30 repetitions 
exp: Blocks = 5; 
Trials = ;


30 repetitions x 5 pieces (this is 1 block) x 5 blocks (tableaus)

===============
%}
s2nBlocks = 4;
s2PresentationsPerBlock = 3;
%============================================================

% In CATSS, some functions that can interfere
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

%{
=================================
%% S1 %%
=================================
%}

% Get the path of the current script
currentScriptPath = mfilename('fullpath');

% Get the folder containing the current script
codeFolder = fileparts(currentScriptPath);

% Go up one level from /code/
mainFolder = fileparts(codeFolder);

% Define paths to the helperScripts and dataCollection folders
helperScriptsPath = fullfile(mainFolder, 'code', 'helperScripts');
baseDataDir = fullfile(mainFolder, 'data');

% Add both folders to the MATLAB path
addpath(helperScriptsPath, baseDataDir);

% Display confirmation
disp(['Added to path: ', helperScriptsPath]);
disp(['Added to path: ', baseDataDir]); 
%{
==========================
%% S2  %%
==========================
    %}
%% Section 2: Tableaus and contexts
fprintf('\n=== Running Section 2 ===\n');
tableaus = getTableaus(); % Load all tableaus
bHeight = 15; % Visible rows
bWidth = 10;

% Convert all tableaus to textures
for t = 1:length(tableaus)
    % Convert the board matrix to a texture
    boardMatrix = tableaus(t).board(1:bHeight,:); % Use only visible rows
  texMat = ones(size(boardMatrix,1), size(boardMatrix,2), 3); % White background
blockMask = repmat(boardMatrix, [1 1 3]); % Create RGB mask
texMat(blockMask == 1) = 0; % Set blocks to black
tableaus(t).tex = Screen('MakeTexture', window, texMat*255, [], [], 2); % High quality texture
end

% Define piece names in order (1-7)
pieceNames = {'I','Z','O','S','J','L','T'};

for block = 1:s2nBlocks
    % initialize struct for block data 
blockData = struct('block', block, 'trials', repmat(struct(...
    'piece', [],...
    'pieceOnset', [],...
    'showTableau', [],...
    'condition', [],...
    'tableauType', [],...
    'delayDuration', [],...
    'gazeData', [],...
    'eegTrigger', []), 1, s2PresentationsPerBlock)); 

for t = 1:s2PresentationsPerBlock
    %% Fixation Cross (500ms)
    Screen('FillRect', window, params.colors.background);
    drawFixation(window, windowRect, params.fixation.color);
    fixationOnset = Screen('Flip', window);
    WaitSecs(0.5);

    %% Randomly select piece and condition
    pieceID = randi(nPieces);
    currentPiece = pieceNames{pieceID};

    % Get all tableaus for this piece
    pieceTableaus = tableaus(strcmp({tableaus.piece}, currentPiece));
    defaultTableau = struct('condition', 'none', 'piece', 'none', 'tex', [], 'board', zeros(bHeight,bWidth));
    %% Determine if we show tableau (50% chance)
    showTableau = rand < 0.5;
    delayDuration = 0.8 + rand*0.4; % Random delay: 0.8-1.2s
        
%% Present Tableau or Blank Screen
% Initialize default tableau structure BEFORE the conditional
currentTableau = struct('condition', 'none', 'piece', 'none', 'tex', []);

if showTableau
    % Randomly select one condition for this piece
    condIdx = randi(length(pieceTableaus));
    currentTableau = pieceTableaus(condIdx); % Override default if showing tableau
    
    % Draw tableau
    Screen('DrawTexture', window, currentTableau.tex);
    tabOnset = Screen('Flip', window, fixationOnset + 0.5);
    pieceTime = tabOnset + delayDuration;
else
    % Show blank screen for the same duration
    Screen('FillRect', window, params.colors.background);
    blankOnset = Screen('Flip', window, fixationOnset + 0.5);
    pieceTime = blankOnset + delayDuration;
end
        
%% Present Piece (centered over tableau/blank)
pieceRect = CenterRectOnPointd(pieces(pieceID).rect,...
windowRect(3)/2, windowRect(4)/2);
Screen('DrawTexture', window, pieces(pieceID).tex, [], pieceRect);

%% Send EEG trigger (add 10 to pieceID when tableau is shown)
triggerValue = []; % Default empty value

%% Send EEG trigger (only if not in demo mode)
if ~demoMode && ~isempty(ioObj)
    triggerValue = pieceID + showTableau*10;
    io64(ioObj, address, triggerValue);
end

%% Flip screen and record timing
[~, pieceOnset] = Screen('Flip', window, pieceTime);
        
%% Collect eye tracking data
gazeData = [];
if ~demoMode
    gazeData = eyetracker.get_gaze_data('from', pieceOnset);
end

%% Log Data
if ~exist('currentTableau', 'var') || isempty(currentTableau)
    error('p1:missingTableau', 'currentTableau not initialized');
end
    
    blockData.trials(t).piece = pieceID;
    blockData.trials(t).pieceOnset = pieceOnset;
    blockData.trials(t).showTableau = showTableau;
    blockData.trials(t).condition = currentTableau.condition;
    blockData.trials(t).tableauType = currentTableau.piece;
    blockData.trials(t).delayDuration = delayDuration;
    blockData.trials(t).gazeData = gazeData;
    blockData.trials(t).eegTrigger = triggerValue;
                
    %% ITI (800-1200ms)
    Screen('FillRect', window, params.colors.background);
    % itiOnset = Screen('Flip', window);
    WaitSecs(0.7 + rand*0.4);
end
    
    %% Save Block Data
    saveDat('p2', subjID, blockData, params, demoMode);
end % block end 

    % Cleanup
    if ~demoMode
        tetio_disconnectTracker();
    end
    sca;

catch ME
    sca;          % Close PTB, screan clear
    Priority(0);  % Reset priority of matlab
    ShowCursor;   % Restore cursor
    rethrow(ME);  % Show error details

    % neat trick that can make matlab jump to a the line where the
    % crash occurred:
    hEditor = matlab.desktop.editor.getActive;
    hEditor.goToLine(whathappened.stack(end).line)
    commandwindow;  % Courtesy of JM :)
end % function end 