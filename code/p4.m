function p4(subjID, demoMode)
% 4-AFC piece + tableau matching task with reward/garbage logic
sca;
if nargin < 1
subjID = input('Enter a subjID (e.g. ''P01''): ', 's');
end
if nargin < 2
demoMode = 1;   % default to demo mode
end
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


rootDir = fullfile(baseDataDir, subjID);

function mkdirIfNeeded(pathStr)
if ~exist(pathStr, 'dir')
        mkdir(pathStr);
end; end;
mkdirIfNeeded(rootDir);
mkdirIfNeeded(fullfile(rootDir, 'eyeData'));
mkdirIfNeeded(fullfile(rootDir, 'behavioralData'));
mkdirIfNeeded(fullfile(rootDir, 'misc'));
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

%% ====== Build blocks 
pieceNames = {'I','Z','O','S','J','L','T'};
nPieces = length(pieceNames);
targetPieceIDs = [];
sideLabels = {'left','right','bottom','garbage'};
afcs = perms(1:4);  % 24 permutations of 4 positions
afcRotations = {};
targetPieceIDs = [];

for i = 1:nPieces
    permIdx = randperm(size(afcs,1), 4);  % choose 4 permutations randomly
    for j = 1:4
        idxRow = afcs(permIdx(j), :);  % e.g., [3 1 4 2]
        afcRotations{end+1} = sideLabels(idxRow);  % maps indices back to 'left', etc.
        targetPieceIDs(end+1) = i;
    end
end

%% ====== RUN BLOCKS ======
try
    screenW = windowRect(3);
   screenH = windowRect(4);
tableaus = getTableaus(window, expParams);
pieces   = getTetrino(expParams);
nRepsPerPiece = 30;
nBlocks       = 28;
score         = 0;

% Block loop 
 for block = 1:nBlocks
% Reset per‑block str
blockData.trials = struct();
correctCount = 0;    
totalTrials  = 0;    

% Determine this block target
targetPiece = pieceNames{targetPieceIDs(block)};
rotation    = afcRotations{block};

% find tableaus 
tbl_idx    = strcmp({tableaus.piece}, targetPiece);
rewardT    = tableaus(tbl_idx & strcmp({tableaus.condition}, 'fit_reward'));
fitT       = tableaus(tbl_idx & strcmp({tableaus.condition}, 'fit_no_reward'));
nofitT     = tableaus(tbl_idx & strcmp({tableaus.condition}, 'no_fit'));
garbageT   = tableaus(tbl_idx & strcmp({tableaus.condition}, 'garbage'));

% deal with rand trial order 
pieceOrder = repmat(1:nPieces, 1, nRepsPerPiece);
pieceOrder = pieceOrder(randperm(length(pieceOrder)));

for t = 1:length(pieceOrder)
  pieceID   = pieceOrder(t);
  pieceName = pieceNames{pieceID};
  
  % determine EEG event
  if strcmp(pieceName,targetPiece)
    eventType = 'afc_correct';
  else
    eventType = 'afc_incorrect';
  end
  eegTrigger = getTrig(pieceName, eventType);

  % draw options + piece
  Screen('FillRect', window, expParams.colors.background);
  % draw each option from options.(side) 
  pieceRect = CenterRectOnPointd(pieces(pieceID).rect, screenW/2, screenH/2);
  Screen('DrawTexture', window, pieces(pieceID).tex, [], pieceRect);

  % flip + log
  [~, stimOnset] = Screen('Flip', window);
  fprintf('B#/T# = %d/%d | Tableau: %s | Stim: %s | EEG = %d\n', block, t, targetPiece, pieceName, eegTrigger);

  % collect gaze
  gazeData = [];
  if ~demoMode
    gazeData = eyetracker.get_gaze_data('from', stimOnset);
  end

  % get response
  startTime = GetSecs;
  responseSide = '';
  while isempty(responseSide)
    [kd,~,kc] = KbCheck;
    if kd
      if kc(expParams.keys.left),   responseSide='left';   end
      if kc(expParams.keys.right),  responseSide='right';  end
      if kc(expParams.keys.down),   responseSide='bottom'; end
      if kc(expParams.keys.up),     responseSide='garbage';end
    end
  end
  RT = GetSecs - startTime;

  % accuracy & scoring
  correct     = strcmp(responseSide, correctSide);
  totalTrials = totalTrials + 1;
  if correct
    correctCount = correctCount + 1;
    score = score + 1;
  else
    score = score - 1;
  end

  % build trial struct
  trial.block       = block;
  trial.trial       = t;
  trial.piece       = pieceName;
  trial.targetPiece = targetPiece;
  trial.response    = responseSide;
  trial.correct     = correct;
  trial.RT          = RT;
  trial.eegTrigger  = eegTrigger;
  trial.gazeData    = gazeData;

  % append
  if block==1 && t==1
    blockData.trials = trial;
  else
    blockData.trials(end+1) = trial;
  end

    if correct
        feedbackColor = [0 255 0];    % green for correct
    else
        feedbackColor = [255 0 0];    % red for incorrect
    end

    % show feedback fullscreen
    Screen('FillRect', window, feedbackColor);
    Screen('Flip', window);
    WaitSecs(0.25);                   % 250 ms feedback

    % clear feedback & run inter‐trial interval
    Screen('FillRect', window, expParams.colors.background);
    Screen('Flip', window);
    WaitSecs(0.8 + rand * 0.4);       % 800–1200 ms ITI
end


% save block dat 
sectionName = sprintf('p4_block%02d', block);  % << LINE 113
saveDat(sectionName, subjID, blockData, expParams, demoMode);
% block‑level accuracy:
fprintf('Block %d accuracy: %.1f%%\n', block, 100*correctCount/totalTrials);

if block < nBlocks, take5Brubeck(window, expParams); end
end      % end block loop

% clean 
if ~demoMode, tetio_disconnectTracker(); end
Priority(0); ShowCursor; sca; Screen('CloseAll');
catch ME
sca; Priority(0); ShowCursor; rethrow(ME);
end
end            