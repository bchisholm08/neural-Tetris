function p5(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker)
try
    % init event log 
    eventLog = struct('timestamp',{},'systemTS',{},'eventType',{},'val1',{},'val2',{});


    if demoMode
        ShowCursor;
    end

    %% INSTRUCTIONS
    p5instruct(window, expParams);

    %% set up
    phaseOne     = expParams.p5.options.phaseOne;
    totalTime    = expParams.p5.options.totalTime;
    snapshotFiles = {};                      % collect all played games in this 

    tmp = struct('gameNum',0,'boardFile','','gazeFile','','usedForReplay',false);

    % collapse
    activSessionInfo = tmp([]); 

    gameCount = 1;
    expParams.p5.gameplayCount = gameCount;

    t0 = GetSecs;
   
   % unneeded, passed in activ struct:::    pastBoardsPath = expParams.subjPaths.boardData;

    %% PHASE 1 - play for 10 minutes
    while (GetSecs - t0) < phaseOne % for game intro time
        expParams.p5.gameplayCount = gameCount;
        [playFile, newInfo, gameLog] = playOneTetrisGame(expParams);
        assert(isequal(fieldnames(newInfo), fieldnames(tmp)), ...
       'playOneTetrisGame returned unexpected fields');
        eventLog = [eventLog; gameLog(:)];
        snapshotFiles{end+1}    = playFile;
        activSessionInfo(end+1) = newInfo;

    % add up 
    gameCount = gameCount + 1;
    end

    %% TRANSITION PHASE - forced playback
    firstIdx = randi(numel(snapshotFiles));
    fprintf(['\n\n=====================' ...
        'Initial Play Phase Over... \n\n' ...
        '=====================\n' ...
        'Replaying Game #%d of %d...\n=====================\n\n\n\n'], firstIdx, numel(snapshotFiles));
    WaitSecs(1.5) % for me
    activSessionInfo(firstIdx).usedForReplay = true;
    playBackGame(activSessionInfo(firstIdx).boardFile, expParams);
    expParams.p5.sessionInfo = activSessionInfo;

    %% PHASE 2 - play for remainder
    t1          = GetSecs; % continue to fall back on system 
    remainder   = totalTime - phaseOne;

    while (GetSecs - t1) < remainder
        coin = rand(); % uniform [0.1)
        if coin < 0.5 % 
            fprintf(['\n=============================\n'   ...
          'COIN FLIP WAS: %.2f; PLAYING TETRIS\n' ...
          '=============================\n\n', coin]);
            WaitSecs(1.5) % for me
            expParams.p5.gameplayCount = gameCount;
            [playFile, newInfo, gameLog] = playOneTetrisGame(expParams);
            eventLog = [eventLog; gameLog(:)];            % append game's events
            assert(isequal(fieldnames(newInfo), fieldnames(tmp)), ...
       'playOneTetrisGame returned unexpected fields');

            snapshotFiles{end+1}    = playFile;    
            activSessionInfo(end+1) = newInfo;
            gameCount = gameCount + 1;
        else
            fprintf(['\n=============================\n'   ...
          'COIN FLIP WAS: %.2f; WATCHING TETRIS\n' ...
          '=============================\n\n', coin]);
            WaitSecs(1.5) % for me
            % find all not yet replayed
            unusedIdx = find(~[activSessionInfo.usedForReplay]);
            if isempty(unusedIdx)
                % IF we use them all, reset for = prob. 
                [activSessionInfo.usedForReplay] = deal(false);
                unusedIdx = 1:numel(activSessionInfo);
            end
            sel = unusedIdx(randi(numel(unusedIdx)));
            activSessionInfo(sel).usedForReplay = true;        
            fprintf('Replaying game #%d (%s)\n', activSessionInfo(sel).gameNum, activSessionInfo(sel).boardFile);
            playBackGame(activSessionInfo(sel).boardFile, expParams);
        end
    end % end main coin toss loop 
    %% save and clean up
    fprintf('\n==========================\n\np5: Section complete. Saving data...\n==========================\n\n');
    expParams.p5.gameplayCount = gameCount - 1;
    expParams.p5.sessionInfo = activSessionInfo;
    saveDat('p5_events', subjID, eventLog, expParams, demoMode);
    expParams.p5.options.sectionDoneFlag = 1;
catch ME
    fprintf(2, 'ERROR IN p5 at %s:%d -- %s\n', ME.stack(1).name, ME.stack(1).line, ME.message);
    rethrow(ME);
end % try end
end % p5 function end
   