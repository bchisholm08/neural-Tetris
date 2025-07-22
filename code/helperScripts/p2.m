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
    gazeFile = fullfile(expParams.subjPaths.eyeDir, sprintf('%s_p2_gaze.mat', subjID));

    % init gaze
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
        % open Tobii & flush errors
        subResult = eyetracker.get_gaze_data();
        if isa(subResult,'StreamError')
            warning('Tobii subscription error: %s', subResult.Message);
        end
        pause(0.2);                   % stack samples
        eyetracker.get_gaze_data();   % clear junk

        % mark start
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

    % check div
    if mod(expParams.p2.options.trialsPerBlock, numConditions) ~= 0
        error('p2: trialsPerBlock (%d) must be divisible by the number of conditions (%d).', expParams.p2.options.trialsPerBlock, numConditions);
    end

    trialsPerConditionPhase = expParams.p2.options.trialsPerBlock / numConditions;

    if mod(trialsPerConditionPhase, 2) ~= 0
        error('p2: trialsPerConditionPhase (%d) must be an even number for a 50/50 split.', trialsPerConditionPhase);
    end

    % "congruent" and "non congruent" trials
    numTargetTrials = trialsPerConditionPhase / 2;
    numNonTargetTrials = trialsPerConditionPhase / 2;

    % preallocate and build
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
    % assert stim seq expParams trial total
    % assert();
    %% Execute Sequence ---
    fprintf('p2: Beginning data collection...\n');

    % init blockData for behavioral data
    blockData = repmat(struct(), length(stimulusSequence), 1);

    currentBlock = 0; % track block changes
    currentPhase = 0; % track phase

    % initialize a block struct for pupil data
    % blockGazeData = struct('DeviceTimeStamp',{}, 'Left',{}, 'Right',{}, 'Pupil',{});

    % mega stimulus sequence loop
    % FIXME add quartile breaks?
    trig = getTrig("section_start");
    fprintf(['section_start trigger sent: %d\n'],trig);
    if ~demoMode && ~isempty(ioObj)
        io64(ioObj, address, trig);
    end
    WaitSecs(1);

    % pre-allocate with the right length
    nTrials    = length(stimulusSequence);
    trialDur   = zeros(1, nTrials);

ifi     = expParams.screen.ifi;                     % single‐frame duration
fixDur  = expParams.p2.options.fixationDuration;    % 0.5 s
stimDur = expParams.p2.options.stimulusDuration;    % 0.1 s

    for i = 1:length(stimulusSequence) % use 'i' counter for stimuli
        % begin pupillometry data collection

        % lets check timings...

        tStart = tic;

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


        % start of block tasks
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

% fixation 
Screen('DrawTexture', window, tableauToDisplay.tex,   [], tableauToDisplay.rect);
drawFixation(window, windowRect, expParams);
fixationOnset = Screen('Flip', window);    % appears now

% stim 
Screen('DrawTexture', window, tableauToDisplay.tex,   [], tableauToDisplay.rect);
stimulusPieceRect = CenterRectOnPoint(stimulusPieceStruct.rect, cx,cy);
Screen('DrawTexture', window, stimulusPieceStruct.tex, [], stimulusPieceRect);
stimOnset = Screen('Flip', window, fixationOnset + fixDur - ifi/2);

% send trig at stim 
if ~demoMode && ~isempty(ioObj)
    io64(ioObj, address, trialInfo.eegTrigger);
end

% re fixate 
Screen('DrawTexture', window, tableauToDisplay.tex,   [], tableauToDisplay.rect);
drawFixation(window, windowRect, expParams);
itiDur = Screen('Flip', window, stimOnset + stimDur - ifi/2);

% keep iti 
itiDur = expParams.p2.options.itiFcn();  
WaitSecs(itiDur);


        % collect data in ITI
        % Log BEHAVIORAL data
        blockData(i).block = trialInfo.blockNum;
        blockData(i).trial = trialInfo.trialNumOverall;
        blockData(i).tableauPiece = trialInfo.tableauPieceName;
        blockData(i).tableauCondition = trialInfo.tableauConditionDisplayed;
        blockData(i).stimulusPiece = trialInfo.stimulusPieceName;
        blockData(i).isMatch = trialInfo.isMatch;
        blockData(i).fixationOnset = fixationOnset;
        blockData(i).itiLen = itiDur;
        blockData(i).stimOnset = stimOnset;
        blockData(i).eegTrigger = trialInfo.eegTrigger;

        % before ITI, check for pause
        handlePause(window, expParams.keys);

        % append recent gazeData
        trialDur(i) = toc(tStart);
    end % end of stimulus sequence

    %% save BEHAVIORAL data at the very end
    trig = getTrig('section_end');
    fprintf(['section_end trigger sent: %d\n'],trig);
    if ~demoMode && ~isempty(ioObj)
        io64(ioObj, address, trig);
    end
    WaitSecs(2);
    fprintf('p2: Section complete. Saving behavioral data...\n');
    expParams.p2.stimulusSequence = stimulusSequence;
    expParams.p2.options.sectionDoneFlag = 1;

    % save data at the very end
    saveDat('p2', subjID, blockData, expParams, demoMode);

    expParams.timing.p2 = trialDur;
    save(fullfile(expParams.subjPaths.miscDir,'p2_timingInfo.mat'),'trialDur');


    if ~demoMode
        % final data and light error handling
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

        % stop recording, get stamp
        % eyetracker.stop_recording();
        % tRecordingEnd = eyetracker.get_system_time_stamp();
        tRecordingEnd = GetSecs;
    else
        WaitSecs(1);  % demo stub
        tRecordingEnd = GetSecs;
    end

    % qc
    lossL = mean([blockGazeData.PupilDiaL] == 0);
    lossR = mean([blockGazeData.PupilDiaR] == 0);


    % save gaze file
    save(gazeFile, ...
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