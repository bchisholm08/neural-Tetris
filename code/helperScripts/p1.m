%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: First section of the human tetris experiment. This section
% is focused on obtaining evoked responses to each of the tetris pieces.
% Each piece is presented 
%                            
%-------------------------------------------------------
function p1(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker)

try %% main exp. try/C
%% instruction screen call 
p1instruct(window, expParams);

pieces = getTetrino(expParams);
nPieces = length(pieces); 

presentationPieceOrder = randi(nPieces, 1, expParams.p1.options.totalP1Trials);
% returns random list of numbers from 1 to 7, for the number of totalP1Trials input 

if length(presentationPieceOrder) ~= expParams.p1.options.totalP1Trials
    % fatal experiment error, cgit aannot continue 
    error('ERROR: pieceOrder (%d) DNE expected trial count (%d)', length(presentationPieceOrder), expParams.p1.options.totalP1Trials);
end

%% block loop       should really have a break at AT LEAST halfway thru 490 trials...let subjects rest their eyes etc. 
for block = 1:expParams.p1.options.blocks

% init block struct 
blockGazeData = struct('DeviceTimeStamp',{}, 'Left',{}, 'Right',{}, 'Pupil',{});

%% trial loop
for t = 1:expParams.p1.options.trialsPerBlock
    
    % --- Get Trial Information ---
    trialIndex = (block - 1) * expParams.p1.options.trialsPerBlock + t;
    pieceID = presentationPieceOrder(trialIndex);
    pieceName = pieces(pieceID).name; % More direct way to get piece name
    eegTrigger = getTrig(pieceName, 'alone'); 

    % pull ITI into script 
    iti = expParams.p1.options.itiFcn();
    itiDuration = iti; 

    % --- 1. Fixation Period ---
    if ~demoMode 
        eyetracker.get_gaze_data(); % Flush buffer before the trial begins
    end
    
    % Prepare the fixation cross frame in the back buffer
    drawFixation(window, windowRect, expParams); %
    % Flip to show the fixation cross and get its onset time
    fixationOnset = Screen('Flip', window);
    
    % Wait for the duration of the fixation period
    WaitSecs(expParams.p1.options.fixationDuration);

    % --- 2. Stimulus Presentation ---
    % Prepare the piece frame in the back buffer
    Screen('DrawTexture', window, pieces(pieceID).tex);
    % Flip at the exact moment the fixation period ends. This swaps the fixation
    % for the piece instantly. Record the timestamp of this event.
    stimOnset = Screen('Flip', window);
    
    % Send EEG trigger precisely at stimulus onset
    if ~demoMode && ~isempty(ioObj)
        io64(ioObj, address, eegTrigger);
    end
    
    % fixme (rm piece letter? I would like all the user output formatted the same 
    fprintf('B#%d/T#%d | pID = %d (%s) | eegTrig = %d\n', block, t, pieceID, pieceName, eegTrigger);
    
    % piece is on screen. pause for length of presentation duration.
    WaitSecs(expParams.p1.options.stimulusDuration);

    % --- 3. Inter-Trial Interval (ITI) ---
    % Prepare the ITI frame (which is just the fixation cross again)
    drawFixation(window, windowRect, expParams); %
    % Flip at the exact moment the stimulus duration ends. This swaps the
    % piece for the fixation cross instantly.
    itiOnset = Screen('Flip', window);
    
    % --- 4. Data Collection and Logging (during the ITI) ---
    % Now that all critical timing is done, collect gaze data and log everything.
    gazeData = [];
    if ~demoMode
        gazeData = eyetracker.get_gaze_data();
    end
    
    % Log behavioral data for this trial.  
    % ordering is directly reflected in .csv file 
    data(trialIndex).block = block;
    data(trialIndex).trial = t;
    data(trialIndex).pieceID = pieceID;
    data(trialIndex).pieceName = pieceName;
    data(trialIndex).fixationOnset = fixationOnset;
    data(trialIndex).stimOnset = stimOnset;
    data(trialIndex).itiOnset = itiOnset; 
    data(trialIndex).eegTrigger = eegTrigger;
    data(trialIndex).trialDuration = stimOnset - fixationOnset;
    % We are now doing block-wise pupil saving, so we don't save gazeData here.
    
    % Append gaze data to the block-wise accumulator (as per your requirement)
    if ~demoMode && ~isempty(gazeData)
        blockGazeData = [blockGazeData; gazeData];
    end

    % during this time check for pause 
    handlePause(window, expParams.keys);

    % The fixation cross is now on screen. Wait for the rest of the ITI.
    WaitSecs(itiDuration);
    
end % --- End of trial loop --- 
    %% give participants a break betwixt blocks
    if block < expParams.p1.options.blocks
        % save dat first 
        if ~demoMode
            pupilFileName = fullfile(expParams.subjPaths.eyeDir, sprintf('%s_p1_block%02d_pupilDat.mat', subjID, block));
            save(pupilFileName, 'blockGazeData', '-v7.3');
            fprintf('p1: Saved pupillometry data for block %d.\n', block);
        end

        % take5Brubeck(window, expParams);
    
    end % loop used to be for saving WHILE a break is given, now is just for saving with no break 
end % p1 block end

%  if last block, ensure save pupil data 
if ~demoMode
    pupilFileName = fullfile(expParams.subjPaths.eyeDir, sprintf('%s_p1_block%02d_pupilDat.mat', subjID, block));
    save(pupilFileName, 'blockGazeData', '-v7.3');
    fprintf('p1: Saved pupillometry data for final block %d.\n', block);
end

% expParams.pieceOrder = presentationPieceOrder;

% not sure if this will be useful or not--too simple to NOT include 
expParams.p1.options.sectionDoneFlag = 1;

% save data 
saveDat('p1', subjID, data, expParams, demoMode);

catch ME % get MException object
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    fprintf(2, 'ERROR IN SCRIPT: %s\n', ME.stack(1).file); % where error occurred
    fprintf(2, 'Function: %s, Line: %d\n', ME.stack(1).name, ME.stack(1).line); % function name with line
    fprintf(2, 'Error Message: %s\n', ME.message);
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    
    rethrow(ME); % rethrow error for wrapper 
end % try exp end
end % p1 end