%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Gives P2 stimuli, Tetris pieces in their context, i.e. their
% respective tableaus, or not. Focused on getting evoked response from
% congruent and non-congruent piece/tableau stimuli
%
%-------------------------------------------------------
function p2(subjID, demoMode, expParams, ioObj, address, eyetracker)


    window     = expParams.screen.window;
    windowRect = expParams.screen.windowRect;
    cx = expParams.screen.center(1);
    cy = expParams.screen.center(2);
    w = expParams.screen.width;
    h = expParams.screen.height;



try % begin try for experiment after init exp
% begin eye tings

gazeFile = fullfile(expParams.subjPaths.eyeDir, ...
            sprintf('%s_p2_gaze.mat', subjID));

% — a) init gaze buffer with both timestamps —
blockGazeData = struct( ...
'SystemTimeStamp',{}, ...  % Tobii SDK clock
'DeviceTimeStamp',{}, ...  % Tobii device clock
'GazeX',           {}, ...
'GazeY',           {}, ...
'PupilDiaL',       {}, ...
'PupilDiaR',       {} );
    tRecordingStart = NaN;
    tRecordingEnd   = NaN;

if ~demoMode
    % — b) subscribe & flush any errors —
    subResult = eyetracker.get_gaze_data();
    if isa(subResult,'StreamError')
        warning('Tobii subscription error: %s', subResult.Message);
    end
    pause(0.2);                   % let the stream start
    eyetracker.get_gaze_data();   % clear junk

    % — c) mark "recording" start with timestamp only —
    % tRecordingStart = eyetracker.get_system_time_stamp();
    tGameStart      = GetSecs;
end


if ~demoMode
    % flush stray samples & catch errors
    raw0 = eyetracker.get_gaze_data();
    if isa(raw0,'StreamError')
        warning('Pre-loop gaze flush error: %s', raw0.Message);
    end
end	




    %% Section 2: Tableaus and contexts
    fprintf('p2: Initializing and pre-generating stimulus sequence...\n');
    p2instruct(window, expParams)

    % tableaus is a 1x28 struct of all piece tableaus (7 x 4) & get pieces, 1x7 struct of same
    tableaus = getTableaus(window, expParams); % uses expParams to
    for t = 1:numel(tableaus)
        if ~isfield(tableaus(t),'tex') || isempty(tableaus(t).tex)
            error('getTableaus didn''t build texture for entry %d!', t)
        end
    end
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

    % creation of stimuli 'phases' within blocks
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

    % initialize a block struct for pupil data
    % blockGazeData = struct('DeviceTimeStamp',{}, 'Left',{}, 'Right',{}, 'Pupil',{});

    % mega stimulus sequence loop 
    % FIXME add quartile breaks? 
    for i = 1:length(stimulusSequence) % use 'i' counter for stimuli
        % begin pupillometry data collection 

if ~demoMode
    raw = eyetracker.get_gaze_data();
    if isa(raw,'StreamError')
        warning('Mid-loop gaze error: %s', raw.Message);
        raw = [];
    end
    for i = 1:numel(raw)
        s = raw(i);

        blockGazeData(end+1) = struct( ...
    'SystemTimeStamp', s.SystemTimeStamp, ...
    'DeviceTimeStamp', s.DeviceTimeStamp, ...
    'GazeX',           s.LeftEye.GazePoint.OnDisplayArea(1), ...
    'GazeY',           s.LeftEye.GazePoint.OnDisplayArea(2), ...
    'PupilDiaL',       s.LeftEye.Pupil.Diameter, ...
    'PupilDiaR',       s.RightEye.Pupil.Diameter ...
);

    end
end	
        trialInfo = stimulusSequence(i); % get curr 'i' from stimuli

        % --- Handle Start-of-Block Tasks (e.g., break, setting current tableau texture) ---
        if trialInfo.blockNum ~= currentBlock || trialInfo.phaseNum ~= currentPhase
            if trialInfo.blockNum ~= currentBlock
                currentBlock = trialInfo.blockNum;
                fprintf('\n--- Starting Block %d: Tableau set for piece "%s" ---\n', currentBlock, trialInfo.tableauPieceName);
                if currentBlock > 1, take5Brubeck(window, expParams); end
            end
            currentPhase = trialInfo.phaseNum;
            tableauToDisplay = tableaus(strcmp({tableaus.piece}, trialInfo.tableauPieceName) & strcmp({tableaus.condition}, trialInfo.tableauConditionDisplayed));
            fprintf('--- Starting Phase %d: Displaying "%s" tableau ---\n', currentPhase, trialInfo.tableauConditionDisplayed);
        end

        % get struct w/ piece texture
        stimulusPieceStruct = pieces(strcmp({pieces.name}, trialInfo.stimulusPieceName));

        % 1. Fixation Period (Tableau + Fixation)

        Screen('DrawTexture', window, tableauToDisplay.tex, [], tableauToDisplay.rect);

        % draw fixation ontop of tableau
        drawFixation(window, expParams.screen.windowRect, expParams);

        % show tableau and fixation
        fixationOnset = Screen('Flip', window);

        % pause script, leave fixation on screen
        iti = expParams.p2.options.itiFcn();
        WaitSecs(iti);



        % 2. Stimulus Presentation (Tableau + Piece)

        % draw tableau for phase, calculate piece centering. Draw stimulus
        Screen('DrawTexture', window, tableauToDisplay.tex, [], tableauToDisplay.rect);
        stimulusPieceRect = CenterRectOnPoint(stimulusPieceStruct.rect, cx,cy);

        % draw stimulus ontop of tableau
        Screen('DrawTexture', window, stimulusPieceStruct.tex, [], stimulusPieceRect);

        % flip buffers when fixation ends. Record time of appearance
        stimOnset = Screen('Flip', window);

        % send EEG trigger immediately after piece presentation
        if ~demoMode && ~isempty(ioObj), io64(ioObj, address, trialInfo.eegTrigger); end

        % tableau and piece are visible. Pause script for stimulus presentation duration
        WaitSecs(expParams.p2.options.stimulusDuration);

        % 3. Inter-Trial Interval (ITI) (Tableau + Fixation)

        % prepare ITI on buffer, draw constant tableau for phase
        Screen('DrawTexture', window, tableauToDisplay.tex, [], tableauToDisplay.rect);

        % draw fixation ontop of tableau
        drawFixation(window, expParams.screen.windowRect, expParams);

        % flip buffers once fixation duration ends. Replace stimulus w/ fixation
        Screen('Flip', window);

        % 4. Data Collection (during ITI)
    
    

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

        % before we wait for the ITI, check for a pause
        handlePause(window, expParams.keys);

        % FIXME TIMING BUG 
        WaitSecs(0.7 + rand * 0.4); % Remainder of ITI
        % append recent gazeData 


        

end % end of stimulus sequence 

        %% --- Save BEHAVIORAL data at the very end ---
        fprintf('p2: Section complete. Saving behavioral data...\n');
        expParams.p2.stimulusSequence = stimulusSequence;
        expParams.p2.options.sectionDoneFlag = 1;

    % save data at the very end
    saveDat('p2', subjID, blockData, expParams, demoMode);

    if ~demoMode
        % — final pull & error‐check —
        rawF = eyetracker.get_gaze_data();
        if isa(rawF,'StreamError')
            warning('Final gaze error: %s', rawF.Message);
            rawF = [];
        end

        for i = 1:numel(rawF)
            s = rawF(i);

            % handle possible missing eye data
            if isfield(s, 'LeftEye') && ~isempty(s.LeftEye) && isfield(s.LeftEye, 'GazePoint') && isfield(s.LeftEye.GazePoint, 'OnDisplayArea')
                gazeX = s.LeftEye.GazePoint.OnDisplayArea(1);
                gazeY = s.LeftEye.GazePoint.OnDisplayArea(2);
                pupL  = s.LeftEye.Pupil.Diameter;
            else
                gazeX = NaN;
                gazeY = NaN;
                pupL  = NaN;
            end

            if isfield(s, 'RightEye') && ~isempty(s.RightEye) && isfield(s.RightEye, 'Pupil')
                pupR = s.RightEye.Pupil.Diameter;
            else
                pupR = NaN;
            end

            blockGazeData(end+1) = struct( ...
                'SystemTimeStamp', s.SystemTimeStamp, ...
                'DeviceTimeStamp', s.DeviceTimeStamp, ...
                'GazeX',           gazeX, ...
                'GazeY',           gazeY, ...
                'PupilDiaL',       pupL, ...
                'PupilDiaR',       pupR ...
                );
        end


        % — stop recording & stamp Tobii clock at end —
        % eyetracker.stop_recording();
        % tRecordingEnd = eyetracker.get_system_time_stamp();
        tRecordingEnd = GetSecs;
    else
        WaitSecs(1);  % demo stub
        tRecordingEnd = GetSecs;
    end
	
	
    % — compute QC loss metrics —
    lossL = mean([blockGazeData.PupilDiaL] == 0);
    lossR = mean([blockGazeData.PupilDiaR] == 0);
	
	
	% save gaze file 
    save(gazeFile, ... % named @ top of script 
        'blockGazeData', ...
        'tRecordingStart', ...
        'tRecordingEnd', ...
        'lossL', 'lossR', ...
        'demoMode', ...
        '-v7.3');


catch ME
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    fprintf(2, 'ERROR IN SCRIPT: p2.m\n');
    fprintf(2, 'Function: %s, Line: %d\n', ME.stack(1).name, ME.stack(1).line);
    fprintf(2, 'Error Message: %s\n', ME.message);
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    rethrow(ME);
end % try end
end % function end