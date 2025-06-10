%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: 
%                            
%-------------------------------------------------------
function p4(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker)
% p4: 4-AFC task where participant matches a stimulus piece to one of four
% tableaus belonging to a block-specific "target piece".
% This version integrates all logic directly into the main function.

try
    %% --- Section 1: Setup and Pre-Generate Stimulus Sequence ---
    fprintf('p4: Initializing and pre-generating stimulus sequence...\n');
    
    % Display instructions for Part 4
    p4instruct(window, expParams);      %

    keyControlInstruct(window, expParams); % FIXME 
    
    % Load textures for all pieces and tableaus
    tableaus = getTableaus(window, expParams); %
    pieces = getTetrino(expParams);           %

    % --- Integrated Stimulus Sequence Generation ---
    pieceNames = {pieces.name};
    nPieces = length(pieceNames);
    numBlocks = expParams.p4.options.blocks;
    trialsPerBlock = expParams.p4.options.trialsPerBlock;
    totalTrials = numBlocks * trialsPerBlock;

    conditions = {'fit_complete', 'fit_does_not_complete', 'does_not_fit', 'garbage'};
    
if mod(trialsPerBlock, 2) ~= 0
    error('p4: trialsPerBlock must be even for a 50/50 split.');
end
numMatchTrialsPerBlock = trialsPerBlock / 2; % 50% match trials
numNonMatchTrialsPerBlock = trialsPerBlock / 2; % 50% non-match trials

stimulusSequence = repmat(struct(), totalTrials, 1);
    
    shuffledBlockOrder = randperm(nPieces);
    overallTrialCounter = 0;

    for b = 1:numBlocks
        targetPieceName = pieceNames{shuffledBlockOrder(b)};
        
        stimulusPiecesForBlock = cell(trialsPerBlock, 1);
        stimulusPiecesForBlock(1:numMatchTrialsPerBlock) = {targetPieceName};
        
        nonMatchingPieceOptions = pieceNames(~strcmp(pieceNames, targetPieceName));
        if numNonMatchTrialsPerBlock > 0
            tempNonMatchList = cell(1, numNonMatchTrialsPerBlock);
            for i = 1:numNonMatchTrialsPerBlock
                tempNonMatchList{i} = nonMatchingPieceOptions{mod(i-1, length(nonMatchingPieceOptions)) + 1};
            end
            stimulusPiecesForBlock(numMatchTrialsPerBlock+1 : end) = tempNonMatchList(randperm(length(tempNonMatchList)));
        end
        stimulusPiecesForBlock = stimulusPiecesForBlock(randperm(trialsPerBlock)); % Final shuffle

        for t = 1:trialsPerBlock
            overallTrialCounter = overallTrialCounter + 1;
            stimulusPieceNameForTrial = stimulusPiecesForBlock{t};
            isMatchTrial = strcmp(stimulusPieceNameForTrial, targetPieceName);

            if isMatchTrial
                correctCondition = 'fit_complete';
                eventType = 'afc_match_trial'; % NOTE: Ensure 'afc_match_trial' is in getTrig.m
            else
                correctCondition = 'garbage';
                eventType = 'afc_nonmatch_trial'; % NOTE: Ensure 'afc_nonmatch_trial' is in getTrig.m
            end
            eegTrigger = getTrig(stimulusPieceNameForTrial, eventType); %
            
            shuffledConditions = conditions(randperm(length(conditions)));
            positionKeys = {'up', 'down', 'left', 'right'};
            
            tableauPositions = struct();
            for k=1:length(positionKeys)
                tableauPositions.(positionKeys{k}) = shuffledConditions{k};
            end
            
            correctResponseKey = positionKeys{strcmp(shuffledConditions, correctCondition)};
            
            stimulusSequence(overallTrialCounter).blockNum = b;
            stimulusSequence(overallTrialCounter).trialNumWithinBlock = t;
            stimulusSequence(overallTrialCounter).targetPieceName = targetPieceName;
            stimulusSequence(overallTrialCounter).stimulusPieceName = stimulusPieceNameForTrial;
            stimulusSequence(overallTrialCounter).isMatch = isMatchTrial;
            stimulusSequence(overallTrialCounter).eegTrigger = eegTrigger;
            stimulusSequence(overallTrialCounter).tableauPositions = tableauPositions;
            stimulusSequence(overallTrialCounter).correctResponseKey = correctResponseKey;
        end
    end
    fprintf('p4: Pre-generated stimulus sequence created with %d total trials.\n', totalTrials);
    
    % Pre-allocate a struct array to hold the results of each trial
    results = repmat(struct(), length(stimulusSequence), 1);
    
%% --- Section 2: Execute the Pre-Generated Sequence ---
     fprintf('p4: Starting experiment trials...\n');

score = 0; % Initialize score
currentBlock = 0;

for i = 1:length(stimulusSequence)
    trialInfo = stimulusSequence(i);

    % --- Handle Start-of-Block Tasks ---
    if trialInfo.blockNum ~= currentBlock
        if currentBlock > 0 && ~demoMode
            pupilFileName = fullfile(expParams.subjPaths.eyeDir, sprintf('%s_p4_pupil_block%02d.mat', subjID, currentBlock));
            save(pupilFileName, 'blockGazeData', '-v7.3');
            fprintf('p4: Saved pupillometry data for block %d.\n', currentBlock - 1);
        end
        currentBlock = trialInfo.blockNum;
        fprintf('\n--- Starting Block %d: Tableau set for piece "%s" ---\n', currentBlock, trialInfo.targetPieceName);

        % Draw the constant tableau set for this block
        screenW = expParams.screen.windowRect(3);
        screenH = expParams.screen.windowRect(4);
        positions.up = CenterRectOnPoint(tableaus(1).rect, screenW/2, screenH*0.25);
        positions.down = CenterRectOnPoint(tableaus(1).rect, screenW/2, screenH*0.75);
        positions.left = CenterRectOnPoint(tableaus(1).rect, screenW*0.25, screenH/2);
        positions.right = CenterRectOnPoint(tableaus(1).rect, screenW*0.75, screenH/2);

        Screen('FillRect', window, expParams.colors.background);
        tableauFields = fieldnames(trialInfo.tableauPositions);
        for j = 1:length(tableauFields)
            positionKey = tableauFields{j};
            tableauCondition = trialInfo.tableauPositions.(positionKey);
            tableauStruct = tableaus(strcmp({tableaus.piece}, trialInfo.targetPieceName) & strcmp({tableaus.condition}, tableauCondition));
            Screen('DrawTexture', window, tableauStruct.tex, [], positions.(positionKey));
        end
        Screen('Flip', window); % Present the constant tableau set
        WaitSecs(1.5); % Give participant time to view the initial set

        if currentBlock > 1, take5Brubeck(window, expParams); end
        if ~demoMode
            eyetracker.get_gaze_data();
            blockGazeData = struct('DeviceTimeStamp',{}, 'Left',{}, 'Right',{}, 'Pupil',{});
        end
    end

    % --- Execute a Single Trial ---

    % 1. FIXATION PERIOD
    % Draw the constant tableaus, then the fixation cross over them
    for j = 1:length(tableauFields)
        positionKey = tableauFields{j};
        tableauCondition = trialInfo.tableauPositions.(positionKey);
        tableauStruct = tableaus(strcmp({tableaus.piece}, trialInfo.targetPieceName) & strcmp({tableaus.condition}, tableauCondition));
        Screen('DrawTexture', window, tableauStruct.tex, [], positions.(positionKey));
    end
    drawFixation(window, windowRect, expParams.fixation.color);
    fixationOnset = Screen('Flip', window);
    WaitSecs(expParams.fixation.durationSecs);

    % 2. PIECE PRESENTATION
    % Draw the constant tableaus, then the piece over them
    stimulusPieceTex = pieces(strcmp({pieces.name}, trialInfo.stimulusPieceName)).tex;
    for j = 1:length(tableauFields)
        positionKey = tableauFields{j};
        tableauCondition = trialInfo.tableauPositions.(positionKey);
        tableauStruct = tableaus(strcmp({tableaus.piece}, trialInfo.targetPieceName) & strcmp({tableaus.condition}, tableauCondition));
        Screen('DrawTexture', window, tableauStruct.tex, [], positions.(positionKey));
    end
    pieceRect = CenterRectOnPoint(pieces(strcmp({pieces.name}, trialInfo.stimulusPieceName)).rect, screenW/2, screenH/2);
    Screen('DrawTexture', window, stimulusPieceTex, [], pieceRect);
    [~, stimOnset] = Screen('Flip', window);
    if ~demoMode && ~isempty(ioObj), io64(ioObj, address, trialInfo.eegTrigger); end


responseKey = '';
rt = NaN;
keyPressTime = -1;
startTime = stimOnset; % Start RT timer from stimulus onset
timeoutDuration = 3.0; % 3 seconds

while (GetSecs - startTime) < timeoutDuration
    [keyIsDown, pressTime, keyCode] = KbCheck(-1);
    if keyIsDown
        if keyCode(expParams.keys.up), responseKey = 'up'; keyPressTime = pressTime; break;
        elseif keyCode(expParams.keys.down), responseKey = 'down'; keyPressTime = pressTime; break;
        elseif keyCode(expParams.keys.left), responseKey = 'left'; keyPressTime = pressTime; break;
        elseif keyCode(expParams.keys.right), responseKey = 'right'; keyPressTime = pressTime; break;
        elseif keyCode(expParams.keys.escape), responseKey = 'escape'; keyPressTime = pressTime; break;
        end
    end
end

if ~isempty(responseKey) % A key was pressed
    rt = keyPressTime - startTime;
    KbReleaseWait(-1);
else % The loop timed out
    responseKey = 'timeout';
    rt = NaN;
end

WaitSecs(1.0);

% 5. FEEDBACK PERIOD
% Determine if the collected response was correct
isCorrect = strcmp(responseKey, trialInfo.correctResponseKey);
if strcmp(responseKey, 'timeout'), isCorrect = false; end % Timeout is always incorrect

% Now, prepare the feedback frame
% Draw the constant tableaus again on the hidden buffer
for j = 1:length(tableauFields)
    positionKey = tableauFields{j};
    tableauCondition = trialInfo.tableauPositions.(positionKey);
    tableauStruct = tableaus(strcmp({tableaus.piece}, trialInfo.targetPieceName) & strcmp({tableaus.condition}, tableauCondition));
    Screen('DrawTexture', window, tableauStruct.tex, [], positions.(positionKey));
end

% Set text properties for the feedback symbol
Screen('TextSize', window, 100);
Screen('TextFont', window, 'Arial');

%  *** THIS IS THE MISSING LOGIC ***
if isCorrect
    % Draw green '+' directly in the center of the screen
    DrawFormattedText(window, '+', 'center', 'center', expParams.colors.green);
    % Update score only on correct trials
    if trialInfo.isMatch, score = score + 100; else, score = score + 50; end
else
    % Draw red 'X' directly in the center of the screen
    DrawFormattedText(window, 'X', 'center', 'center', expParams.colors.red);
end

% Draw the score below the center, only with feedback
showScore(window, score, expParams);

% Reset text size for any subsequent text drawing
Screen('TextSize', window, 24);

% Flip the screen to show the feedback and score
Screen('Flip', window);
WaitSecs(1.0); % 6. FEEDBACK DWELL (1 sec)

    % 8. DATA COLLECTION AND LOGGING (during ITI)
    if ~demoMode
        gazeThisStep = eyetracker.get_gaze_data();
        if ~isempty(gazeThisStep)
            blockGazeData = [blockGazeData; gazeThisStep];
        end
    end

results(i).block = currentBlock;
results(i).trial_overall = i;
results(i).trial_in_block = trialInfo.trialNumWithinBlock;
results(i).targetPieceName_block = trialInfo.targetPieceName;
results(i).stimulusPieceName = trialInfo.stimulusPieceName;
results(i).isMatch = trialInfo.isMatch;
results(i).tableauPositions = trialInfo.tableauPositions; % Add this important field
results(i).responseKey = responseKey;
results(i).correctResponseKey = trialInfo.correctResponseKey; % Add this important field
results(i).RT = rt;
results(i).isCorrect = isCorrect;
results(i).score = score;
results(i).eegTrigger = trialInfo.eegTrigger;

    WaitSecs(0.8 + rand * 0.4); % Remainder of ITI
end

% --- Final save for last block's pupil data and all behavioral data ---
if ~demoMode && exist('blockGazeData', 'var')
    pupilFileName = fullfile(expParams.subjPaths.eyeDir, sprintf('%s_p4_pupil_block%02d.mat', subjID, currentBlock));
    save(pupilFileName, 'blockGazeData', '-v7.3');
    fprintf('p4: Saved pupillometry data for final block %d.\n', currentBlock);
end

fprintf('p4: Section complete. Saving all behavioral data...\n');
expParams.p4.stimulusSequence = stimulusSequence;
saveDat('p4_behavioral', subjID, results, expParams, demoMode);

catch ME
        % The catch block logs the specific error and re-throws it to the wrapper
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    fprintf(2, 'ERROR IN SCRIPT: %s\n', ME.stack(1).file);
    fprintf(2, 'Function: %s, Line: %d\n', ME.stack(1).name, ME.stack(1).line);
    fprintf(2, 'Error Message: %s\n', ME.message);
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    rethrow(ME); % Let the wrapper handle the main cleanup
end