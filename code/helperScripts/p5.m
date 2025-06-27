function p5(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker)
try
    %% 1. SETUP & INSTRUCT
    fprintf('p5: Initializing Tetris game environment...\n');
    p5instruct(window, expParams);
    
    %% 2. PHASE 1 — PLAY FOR 10 MINUTES
    phaseOne     = expParams.p5.options.phaseOne;   
    totalTime    = expParams.p5.options.totalTime;  
    snapshotFiles = {};                      % to collect all played games
    playedFilesIndex = {};
    gameCount = 1; 
    t0 = GetSecs;
    % where paths of saved game board matrices will be 
    pastBoardPath = expParams.subjPaths.boardData;
    
    ShowCursor; % keep while debugging......

    while (GetSecs - t0) < phaseOne
        % playOneTetrisGame must now return the filename of its .mat snapshot

%        expParams is only var needed for playOneTetrisGame, just recode
%        into script 
        newFile = playOneTetrisGame(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker, gameCount);
        snapshotFiles{end+1} = newFile;
        gameCount = gameCount + 1;
    end

    %% 3. INITIAL REPLAY — pick one at random
    firstIdx = randi(numel(snapshotFiles));
    fprintf('p5: Phase 1 over. Replaying Game #%d of %d...\n', firstIdx, numel(snapshotFiles));
    playBackGame(snapshotFiles{firstIdx}, window, windowRect);

    %% 4. PHASE 2 — REMAINING TIME, 50/50 PLAY vs REPLAY
    t1          = GetSecs;
    remainder   = totalTime - phaseOne;

    while (GetSecs - t1) < remainder
        if rand < 0.5 % rand (0,1) 
            % — HEADS: play a new game and save its snapshot
            newFile = playOneTetrisGame(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker, gameIdx);
            % slightly concerned that the scope of newFile variable may be overrun by the newFile above 
            snapshotFiles{end+1} = newFile;
            gameCount = gameCount + 1; 
        else
            % — TAILS: replay one of the existing games
            
            pastGameBoardFiles = dir(pastBoardPath);
            randGameReplay = randi([1, len(pastGameBoardFiles)]); % I think it is ok to do this dynamically. The length will change on each loop... 
            % make sure we do not repeat...must do WITHOUT replacement,
            % somehow
            playBackGame(snapshotFiles{randGameReplay}, window, windowRect);
        end
    end
    expParams.options.p5.totalGamesPlayed = gameCount; % save this...
    %% 5. SAVE & FINISH all in scope 
    fprintf('p5: Experiment complete. Saving event data...\n');
    saveDat('p5_events', subjID, eventLog, expParams, demoMode);

catch ME
    fprintf(2, 'ERROR IN p5 at %s:%d -- %s\n', ME.stack(1).name, ME.stack(1).line, ME.message);
    rethrow(ME);
end % try end 
    end
