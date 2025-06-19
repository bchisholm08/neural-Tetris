%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Handles 4-AFC section of the experiment, a unique task where
% pieces are flashed in the center of the screen and four tableaus surround
% the piece. Essentially, the task for the participant is to `match` the piece in the
% center with the tableau in which it would complete the most lines, andd
% therfore score the participant the most points. 
%                            
%-------------------------------------------------------
function p4(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker)
try
    
    % Instructions
    p4instruct(window, expParams);

    %% --- Section 1: Setup and Pre-Generate Stimulus Sequence ---
    fprintf('p4: Initializing and pre-generating stimulus sequence...\n');
    
    % Load textures
    tableaus = getTableaus(window, expParams);
    pieces   = getTetrino(expParams);
    tableauRect = tableaus(1).rect;
    
    % Conditions and helper call
    conditions = {'fit_complete','fit_does_not_complete','does_not_fit','garbage'};
    stimulusSequence = getMyP4Stimuli(pieces, expParams.p4.options, conditions);
    
    % Prep results
    nTrials = numel(stimulusSequence);

window     = expParams.screen.window;
% windowRect = expParams.screen.windowRect;
cx = expParams.screen.center(1);
cy = expParams.screen.center(2);
w = expParams.screen.width;
h = expParams.screen.height;

    positions.up    = CenterRectOnPoint(tableauRect, cx,      0.25 * h);
    positions.down  = CenterRectOnPoint(tableauRect, cx,      0.75 * h);
    positions.left  = CenterRectOnPoint(tableauRect, 0.25*w,  cy);
    positions.right = CenterRectOnPoint(tableauRect, 0.75*w,  cy);

    % Tableau positions (from expParams)
    % positions = expParams.p4.positions;
    

    %% --- Section 2: Execute Trials ---
    score        = 0;
    currentBlock = stimulusSequence(1).blockNum;
    
    for i = 1:nTrials
        trial = stimulusSequence(i);
        
        % If block changed, save gaze from previous block (if needed)
        if trial.blockNum ~= currentBlock
            % e.g. saveBlockGaze(currentBlock, blockGazeData);
            currentBlock = trial.blockNum;
        end
        
        % 1. FIXATION + TABLEAUS
        fields = fieldnames(trial.tableauPositions);
        for f = 1:numel(fields)
            key  = fields{f};
            cond = trial.tableauPositions.(key);
            T    = tableaus(strcmp({tableaus.piece}, trial.targetPieceName) & ...
                            strcmp({tableaus.condition}, cond));
            Screen('DrawTexture', window, T.tex, [], positions.(key));
        end
        drawFixation(window, expParams.screen.windowRect, expParams.fixation.color);
       [~, fixationOnset]=  Screen('Flip', window);
        WaitSecs(expParams.rule.fixationDuration);
        
        % 2. PIECE PRESENTATION
        for f = 1:numel(fields)
            key  = fields{f};
            cond = trial.tableauPositions.(key);
            T    = tableaus(strcmp({tableaus.piece}, trial.targetPieceName) & ...
                            strcmp({tableaus.condition}, cond));
            Screen('DrawTexture', window, T.tex, [], positions.(key));
        end
        pieceTex  = pieces(strcmp({pieces.name}, trial.stimulusPieceName)).tex;
       
    % OLD SCREEN PARAMS pieceRect = CenterRectOnPoint(pieces(strcmp({pieces.name}, trial.stimulusPieceName)).rect, screenW/2, screenH/2);
    pieceRect = CenterRectOnPoint( pieces(strcmp({pieces.name}, trial.stimulusPieceName)).rect, cx, cy);



        Screen('DrawTexture', window, pieceTex, [], pieceRect);
        [~, stimOnset] = Screen('Flip', window);
        if ~demoMode && ~isempty(ioObj)
            io64(ioObj, address, trial.eegTrigger);
        end
        
        % 3. COLLECT RESPONSE
        responseKey = '';
        rt          = NaN;
        startTime   = stimOnset;
        timeout     = expParams.p4.options.respTimeout;
        while GetSecs - startTime < timeout
            handlePause(window, expParams.keys);
            [down, tKey, keyCode] = KbCheck(-1);
            if down
                if keyCode(expParams.keys.up),    responseKey='up';    rt=tKey-startTime; break;
                elseif keyCode(expParams.keys.down),  responseKey='down';  rt=tKey-startTime; break;
                elseif keyCode(expParams.keys.left),  responseKey='left';  rt=tKey-startTime; break;
                elseif keyCode(expParams.keys.right), responseKey='right'; rt=tKey-startTime; break;
                elseif keyCode(expParams.keys.escape)
                    error('USER_QUIT','User pressed ESC.');
                end
            end
        end
        
        % 4. POST-RESPONSE DWELL
        WaitSecs(1.0);
        
        % 5. FEEDBACK
        isCorrect = strcmp(responseKey, trial.correctResponseKey);
        for f = 1:numel(fields)
            key  = fields{f};
            cond = trial.tableauPositions.(key);
            T    = tableaus(strcmp({tableaus.piece}, trial.targetPieceName) & ...
                            strcmp({tableaus.condition}, cond));
            Screen('DrawTexture', window, T.tex, [], positions.(key));
        end
        if isCorrect
            DrawFormattedText(window, '+','center','center', expParams.colors.green);
            score = score + (trial.isMatch * 100 + ~trial.isMatch * 50);
        else
            DrawFormattedText(window, 'X','center','center', expParams.colors.red);
        end
        showScore(window, score, expParams);
        Screen('Flip', window);
        WaitSecs(1.0);
        
        % 6. INTER-TRIAL INTERVAL
        for f = 1:numel(fields)
            key  = fields{f};
            cond = trial.tableauPositions.(key);
            T    = tableaus(strcmp({tableaus.piece}, trial.targetPieceName) & ...
                            strcmp({tableaus.condition}, cond));
            Screen('DrawTexture', window, T.tex, [], positions.(key));
        end
        drawFixation(window, expParams.screen.windowRect, expParams.fixation.color);
        Screen('Flip', window);
        
        % 7. LOG RESULTS

results(i).block = currentBlock;
results(i).trial_overall = i;
results(i).trial_in_block = trial.trialNumWithinBlock;
results(i).targetPieceName_block = trial.targetPieceName;
results(i).stimulusPieceName = trial.stimulusPieceName;
results(i).isMatch = trial.isMatch;
results(i).tableauPositions = trial.tableauPositions; % Add this important field
results(i).responseKey = responseKey;
results(i).correctResponseKey = trial.correctResponseKey; % Add this important field
results(i).RT = rt;
results(i).isCorrect = isCorrect;
results(i).fixationOnset = fixationOnset;
results(i).stimOnset = startTime;
results(i).eegTrigger = trial.eegTrigger;
results(i).score = score;
            
        % (collect gaze data here if desired)
    end
    
    %% --- Section 3: Save Data ---
    if ~demoMode && exist('blockGazeData','var')
        save(fullfile(expParams.subjPaths.eyeDir, sprintf('%s_p4_pupil_block%02d.mat', ...
             subjID, currentBlock)), 'blockGazeData','-v7.3');
    end
    
    expParams.p4.stimulusSequence        = stimulusSequence;
    expParams.p2.options.sectionDoneFlag = 1;
    timestamp = datestr(now, 'yyyymmdd_HHMM');
    saveDat(sprintf('p4_%s', timestamp), subjID, results, expParams, demoMode);
catch ME
    % Error logging
    fprintf(2, 'ERROR in %s at line %d: %s\n', ME.stack(1).file, ME.stack(1).line, ME.message);
    rethrow(ME);
end
