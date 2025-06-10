%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: 
%                            
%-------------------------------------------------------
function p2(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker)

try % begin try for experiment after init exp
    %% Section 2: Tableaus and contexts
    fprintf('p2: Initializing and pre-generating stimulus sequence...\n');
    p2instruct(window, expParams)

    % tableaus is a 1x28 struct of all piece tableaus (7 x 4) & get pieces, 1x7 struct of same 
    tableaus = getTableaus(window, expParams); % 
    pieces = getTetrino(expParams);

    pieceNames = {'I','Z','O','S','J','L','T'}; % Master list of piece names
    nPieces = length(pieceNames);
   
    numBlocks = expParams.p2.options.blocks;
    trialsPerBlock = expParams.p2.options.trialsPerBlock;

    totalTrials = expParams.p2.options.totalP2Trials;

    tableauConditions = {'fit_complete', 'fit_does_not_complete', 'does_not_fit'};
    numConditions = length(tableauConditions);

    if mod(expParams.p2.options.trialsPerBlock, numConditions) ~= 0
        error('p2: trialsPerBlock (%d) must be divisible by the number of conditions (%d).', expParams.p2.options.trialsPerBlock, numConditions);
    end

    % trials per block = 210, numConditions = 3 
    trialsPerConditionPhase = expParams.p2.options.trialsPerBlock / numConditions;
    
    if mod(trialsPerConditionPhase, 2) ~= 0
        error('p2: trialsPerConditionPhase (%d) must be an even number for a 50/50 split.', trialsPerConditionPhase);
    end

    numTargetTrials = trialsPerConditionPhase / 2;
    numNonTargetTrials = trialsPerConditionPhase / 2;
    
    % Pre-allocate and Build the Sequence
    stimulusSequence = repmat(struct(), totalTrials, 1);
    shuffledBlockOrder = randperm(nPieces);
    overallTrialCounter = 0;

    for b = 1:expParams.p2.options.blocks
        targetPieceName = pieceNames{shuffledBlockOrder(b)};
        shuffledConditionOrder = tableauConditions(randperm(numConditions));
        
        for phase = 1:numConditions
            currentTableauCondition = shuffledConditionOrder{phase};
            
            stimuliForPhase = cell(trialsPerConditionPhase, 1);
            stimuliForPhase(1:numTargetTrials) = {targetPieceName};
            
            nonTargetPieceOptions = pieceNames(~strcmp(pieceNames, targetPieceName));
            tempNonTargetList = cell(1, numNonTargetTrials);
            for i = 1:numNonTargetTrials
                tempNonTargetList{i} = nonTargetPieceOptions{mod(i-1, length(nonTargetPieceOptions)) + 1};
            end
            stimuliForPhase(numTargetTrials+1 : end) = tempNonTargetList;
            
            stimuliForPhase = stimuliForPhase(randperm(trialsPerConditionPhase));
            
            for t = 1:trialsPerConditionPhase
                overallTrialCounter = overallTrialCounter + 1;
                stimulusPieceNameForTrial = stimuliForPhase{t};
                isMatchTrial = strcmp(stimulusPieceNameForTrial, targetPieceName);

                if isMatchTrial, eventType = currentTableauCondition; else, eventType = 'does_not_fit'; end
                currentEEGTrigger = getTrig(stimulusPieceNameForTrial, eventType);
                
                stimulusSequence(overallTrialCounter).blockNum = b;
                stimulusSequence(overallTrialCounter).phaseNum = phase;
                stimulusSequence(overallTrialCounter).trialNumOverall = overallTrialCounter;
                stimulusSequence(overallTrialCounter).tableauPieceName = targetPieceName;
                stimulusSequence(overallTrialCounter).tableauConditionDisplayed = currentTableauCondition;
                stimulusSequence(overallTrialCounter).stimulusPieceName = stimulusPieceNameForTrial;
                stimulusSequence(overallTrialCounter).isMatch = isMatchTrial;
                stimulusSequence(overallTrialCounter).eegTrigger = currentEEGTrigger;
            end
        end
    end
    fprintf('p2: Pre-generated stimulus sequence created with %d total trials.\n', totalTrials);
 
    %% --- Section 2: Execute the Pre-Generated Sequence ---
    fprintf('p2: Beginning experiment and data collection...\n');
    
    % Initialize blockData for behavioral saving
    blockData = repmat(struct(), length(stimulusSequence), 1);

    currentBlock = 0; % track block changes 
    currentPhase = 0; % track phase 

    for i = 1:length(stimulusSequence) % use 'i' counter for stimuli 
        trialInfo = stimulusSequence(i); % get curr 'i' from stimuli 

        % --- Handle Start-of-Block Tasks (e.g., break, setting current tableau texture) ---
if trialInfo.blockNum ~= currentBlock || trialInfo.phaseNum ~= currentPhase
    % This code now runs at the start of a new block OR a new phase within a block.

    if trialInfo.blockNum ~= currentBlock
        % --- This part only runs for a NEW BLOCK ---
        if currentBlock > 0 && ~demoMode
            % Save pupillometry data from the block that just finished
            pupilFileName = fullfile(expParams.subjPaths.eyeDir, sprintf('%s_p2_block%02d_pupilDat.mat', subjID, currentBlock));
            processedGazeData = preprocessGazeData(struct('gazeData', blockGazeData));
            save(pupilFileName, 'processedGazeData', '-v7.3');
            fprintf('p2: Saved pupillometry data for block %d.\n', currentBlock);
        end
        currentBlock = trialInfo.blockNum;
        fprintf('\n--- Starting Block %d: Tableau set for piece "%s" ---\n', currentBlock, trialInfo.tableauPieceName);
        if currentBlock > 1, take5Brubeck(window, expParams); end
        if ~demoMode
            eyetracker.get_gaze_data(); % Flush buffer
            blockGazeData = struct('DeviceTimeStamp',{}, 'Left',{}, 'Right',{}, 'Pupil',{});
        end
    end
       currentPhase = trialInfo.phaseNum;
    % Find the correct tableau texture that will be constant for this phase
    tableauToDisplay = tableaus(strcmp({tableaus.piece}, trialInfo.tableauPieceName) & strcmp({tableaus.condition}, trialInfo.tableauConditionDisplayed));
    fprintf('--- Starting Phase %d: Displaying "%s" tableau ---\n', currentPhase, trialInfo.tableauConditionDisplayed);
end

stimulusPieceStruct = pieces(strcmp({pieces.name}, trialInfo.stimulusPieceName));

% 1. Fixation Period (Tableau + Fixation)
Screen('DrawTexture', window, tableauToDisplay.tex, [], tableauToDisplay.rect);
drawFixation(window, windowRect, expParams.fixation.color);
fixationOnset = Screen('Flip', window);
WaitSecs(expParams.fixation.durationSecs);

% 2. Stimulus Presentation (Tableau + Piece)
Screen('DrawTexture', window, tableauToDisplay.tex, [], tableauToDisplay.rect);
stimulusPieceRect = CenterRectOnPoint(stimulusPieceStruct.rect, windowRect(3)/2, windowRect(4)/2);
Screen('DrawTexture', window, stimulusPieceStruct.tex, [], stimulusPieceRect);
stimOnset = Screen('Flip', window);

if ~demoMode && ~isempty(ioObj), io64(ioObj, address, trialInfo.eegTrigger); end

WaitSecs(expParams.rule.stimulusDuration);

% 3. Inter-Trial Interval (ITI) (Tableau + Fixation)
Screen('DrawTexture', window, tableauToDisplay.tex, [], tableauToDisplay.rect);
drawFixation(window, windowRect, expParams.fixation.color);
Screen('Flip', window);

% 4. Data Collection (during ITI)
if ~demoMode
    gazeData = eyetracker.get_gaze_data();
    if ~isempty(gazeData), blockGazeData = [blockGazeData; gazeData]; end
end

% Log BEHAVIORAL data
blockData(i).block = trialInfo.blockNum;
blockData(i).trial = trialInfo.trialNumOverall;
blockData(i).tableauPiece = trialInfo.tableauPieceName;
blockData(i).tableauCondition = trialInfo.tableauConditionDisplayed;
blockData(i).stimulusPiece = trialInfo.stimulusPieceName;
blockData(i).isMatch = trialInfo.isMatch;
blockData(i).fixationOnset = fixationOnset;
blockData(i).stimOnset = stimOnset;
blockData(i).eegTrigger = trialInfo.eegTrigger;

WaitSecs(0.7 + rand * 0.4); % Remainder of ITI

    
    if ~demoMode
        pupilFileName = fullfile(expParams.subjPaths.eyeDir, sprintf('%s_p2_block%02d_pupilDat.mat', subjID, currentBlock));
        processedGazeData = preprocessGazeData(struct('gazeData', blockGazeData));
        save(pupilFileName, 'processedGazeData', '-v7.3');
        fprintf('p2: Saved pupillometry data for final block %d.\n', currentBlock);
    end

    %% --- Save BEHAVIORAL data at the very end ---
    fprintf('p2: Section complete. Saving behavioral data...\n');
    expParams.p2.stimulusSequence = stimulusSequence;
    saveDat('p2', subjID, blockData, expParams, demoMode);
    end 
catch ME
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    fprintf(2, 'ERROR IN SCRIPT: p2.m\n');
    fprintf(2, 'Function: %s, Line: %d\n', ME.stack(1).name, ME.stack(1).line);
    fprintf(2, 'Error Message: %s\n', ME.message);
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    rethrow(ME);
end % try end 
end % function end 