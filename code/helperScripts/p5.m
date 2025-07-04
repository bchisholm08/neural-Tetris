function p5(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker)
try
    if demoMode
        ShowCursor;
    end

    %% INSTRUCTIONS
    %fprintf('p5: Initializing Tetris game environment...\n');
    p5instruct(window, expParams);

    %% set up
    phaseOne     = expParams.p5.options.phaseOne;
    totalTime    = expParams.p5.options.totalTime;
    snapshotFiles = {};                      % to collect all played games

    tmp = struct('gameNum',      0, ...
                 'fileName',     '', ...
                 'usedForReplay', false);
    % …then make it 0×0 by slicing out everything
    activSessionInfo = tmp([]); 

    gameCount = 1; % expParams.p5.gameplayCount
    % ADD IN: expParams.p5.replayCount
    expParams.p5.gameplayCount = gameCount;

    t0 = GetSecs;
    % where paths of saved game board matrices will be
    pastBoardsPath = expParams.subjPaths.boardData;

    %% PHASE 1 - play for 10 minutes
    while (GetSecs - t0) < phaseOne % for game intro time
        expParams.p5.gameplayCount = gameCount;
        [playFile, newInfo] = playOneTetrisGame(expParams);

        if demoMode
            disp(class(newInfo));   % should print "struct"
            disp(size(newInfo));    % should be 1×1
            if ~isstruct(newInfo)
                error('playOneTetrisGame did *not* return a struct for activInfo!');
            end
        end


    snapshotFiles{end+1}    = playFile;
    activSessionInfo(end+1) = newInfo;

    % now bump your counter
    gameCount = gameCount + 1;
    end

    %% TRANSITION PHASE - forced playback
    firstIdx = randi(numel(snapshotFiles));
    fprintf(['Initial Play Phase Over... \n\n' ...
        '=====================\n' ...
        'Replaying Game #%d of %d...\n=====================\n\n\n\n'], firstIdx, numel(snapshotFiles));

    activSessionInfo(firstIdx).usedForReplay = true;
    playBackGame(activSessionInfo(firstIdx).fileName, expParams);
    expParams.p5.sessionInfo = activSessionInfo;

    %% PHASE 2 - play for remainder
    t1          = GetSecs;
    remainder   = totalTime - phaseOne;

    while (GetSecs - t1) < remainder

        if rand < 0.5 % rand (0--1)
            expParams.p5.gameplayCount = gameCount;
            [filePlayMain, newInfo] = playOneTetrisGame(expParams);
        
            snapshotFiles{end+1}    = filePlayMain;
            activSessionInfo(end+1) = newInfo;
        
            gameCount = gameCount + 1;
        
        else

            % find all not yet replayed
            unusedIdx = find(~[activSessionInfo.usedForReplay]);
            if isempty(unusedIdx)
                % if you ever exhaust them, reset flags:
                [activSessionInfo.usedForReplay] = deal(false);
                unusedIdx = 1:numel(activSessionInfo);
            end
            sel = unusedIdx(randi(numel(unusedIdx)));
            activSessionInfo(sel).usedForReplay = true;        
            fprintf('Replaying game #%d (%s)\n', activSessionInfo(sel).gameNum, activSessionInfo(sel).fileName);
            playBackGame(activSessionInfo(sel).fileName, expParams);
        end
    end
    %% save and clean up
    fprintf('\n==========================\n\np5: Section complete. Saving data...\n==========================\n\n');
    expParams.p5.gameplayCount = gameCount - 1;
    expParams.p5.sessionInfo = activSessionInfo;
    saveDat('p5_events', subjID, eventLog, expParams, demoMode);

catch ME
    fprintf(2, 'ERROR IN p5 at %s:%d -- %s\n', ME.stack(1).name, ME.stack(1).line, ME.message);
    rethrow(ME);
end % try end
end % p5 function end
