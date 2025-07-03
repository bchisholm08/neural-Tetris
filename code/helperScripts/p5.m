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
    gameCount = 1; % expParams.p5.gameplayCount
                    % ADD IN: expParams.p5.replayCount 
    expParams.p5.gameplayCount = gameCount; 
    expParams.p5.replayCount = []; 
    % adding above together gives total number of "trials" 

    t0 = GetSecs;
    % where paths of saved game board matrices will be 
    pastBoardsPath = expParams.subjPaths.boardData;
    


    while (GetSecs - t0) < phaseOne % for game intro time 
        % playOneTetrisGame must now return the filename of its .mat snapshot

%        expParams is only var needed for playOneTetrisGame, just recode
%        into script. This assumes it is passed and within scope 
        playFile = playOneTetrisGame(expParams);
        snapshotFiles{end+1} = playFile;
        expParams.p5.gameplayCount = expParams.p5.gameplayCount + 1;
    end

    %% 3. INITIAL REPLAY — pick one at random
    firstIdx = randi(numel(snapshotFiles));
    fprintf(['Initial Play Phase Over... \n\n' ...
        '=====================' ...
        'Replaying Game #%d of %d...\n\n====================='], firstIdx, numel(snapshotFiles));
    playBackGame(snapshotFiles{firstIdx}, expParams);
        % investigate exactly how we get files, and furthermore, that we select
        % WITHOUT replacement. May need to keep an array `log` in
        % expParams, or other local var. Not sure exacltly how dynamic vars
        % would function in that case... 

    %% 4. PHASE 2 — REMAINING TIME, 50/50 PLAY vs REPLAY
    t1          = GetSecs;
    remainder   = totalTime - phaseOne;

    while (GetSecs - t1) < remainder
        if rand < 0.5 % rand (0,1) 
            % play a new game, save it's snapshot 
            [filePlayMain,  activInfo]= playOneTetrisGame(expParams);
            % slightly concerned that the scope of newFile variable may be overrun by the newFile above 
            snapshotFiles{end+1} = filePlayMain;
            gameCount = gameCount + 1; 
            expParams.p5.sectionInfo = activInfo; % keep track of which games we play back, so we can ensure we sample without replacement
        else
           % replay an existing game
            
            pastGameBoardFiles = dir(pastBoardsPath);

            randGameReplay = randi([1, length(pastGameBoardFiles)]); % I think it is ok to do this dynamically. The length will change on each loop... 
            % make sure we do not repeat...must do WITHOUT replacement,
            % somehow
            fprintf("Replaying game ")
            playBackGame(snapshotFiles{randGameReplay}, expParams);
        end
    end
   %  expParams.p5.gameplayCount = gameCount; % save this...
    %% 5. SAVE & FINISH all in scope 
    fprintf('p5: Experiment complete. Saving event data...\n');
    gameCount = expParams.p5.gameplayCount; 
    expParams.p5.replayCount = []; 
    saveDat('p5_events', subjID, eventLog, expParams, demoMode);
    
catch ME
    fprintf(2, 'ERROR IN p5 at %s:%d -- %s\n', ME.stack(1).name, ME.stack(1).line, ME.message);
    rethrow(ME);
end % try end 

    end
