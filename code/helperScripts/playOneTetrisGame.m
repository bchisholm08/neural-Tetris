%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 7.8.2025
%
% Description: Facilitates playing one Tetris game, along with eye tracking
% data and EEG triggers when not in demo mode.
%
%-------------------------------------------------------
function [snapshotFile, activInfo, eventLog] = playOneTetrisGame(expParams)
% begin game try
try
    gameIdx = expParams.p5.gameplayCount;

    subjID = expParams.subjID;
    demoMode = expParams.demoMode;
    window = expParams.screen.window;
    windowRect = expParams.screen.windowRect;
    ioObj = expParams.ioObj;
    address = expParams.address;
    eyetracker = expParams.eyeTracker;

    gazeFile = fullfile(expParams.subjPaths.eyeDir, ...
        sprintf('%s_gameplay%03d_gaze.mat', subjID, gameIdx));

    activInfo = struct('gameNum',{},'boardFile',{},'gazeFile',{},'usedForReplay',{});

    % get shapes and textures
    pieces = getTetrino(expParams);
    boardH = expParams.visual.boardH;
    boardW = expParams.visual.boardW;

    S = struct(); % to store game state

    % use two matrix design...
    S.lockedMatrix  = zeros(boardH, boardW, 'uint8');   % landed blocks
    S.currentPiece  = [];   % linear indices falling blocks
    S.currentPieceID= 0;    % piece type

    p5_triggers = containers.Map({'game_start','game_over','piece_spawn','piece_lock', ...
        'piece_drop', 'key_press_left','key_press_right', ...
        'key_press_up_rotate','key_press_down_softdrop', 'line_clear_1','line_clear_2', ...
        'line_clear_3','line_clear_4'}, {101,102,103,104,105,111,112,113,114,121,122,123,124});

    % should be uniform gray
    S.pieceColors = repmat({expParams.visual.pieceColor}, 1, 7);

    S.pointsVector = [100 300 500 800]; % reg tetris points for 1, 2s, 3, or 4 lines cleared
    S.levelFactor = .775;  % speed factor per level (omit? Ask JP) ORIGINAL GAME IS .625. Curious if changing to 0 would work

    S.linesForLevelUp = 5; % originally 5 lines. Probably dropping all together. See above

    % init special logs. good reference. save to misc dir
    eventLog = struct( ...
        'timestamp',  {}, ...  % MATLAB clock (check if this equals GetSecs() call)
        'systemTS',   {}, ...  % system clock (different from GetSecs() )
        'eventType',  {}, ...
        'val1',       {}, ...
        'val2',       {}  ...
        );

    boardSnapshot = struct('timestamp', {}, 'board', {}, 'eegTrigs', {});

    %% initialize a new game
    % reset game state vars
    S.currentLevel = 1;
    S.currentLines = 0;
    S.currentScore = 0;
    S.gameOver = false;
    S.currentPiece = []; % indices of current falling piece
    S.currentPieceID = 0;
    S.nextPieceID = ceil(rand*7); % pre-determine first piece randomly

    % begin eye tings
    % init gaze buffer with both timestamps
    blockGazeData = struct( ...
        'SystemTimeStamp',{}, ...
        'DeviceTimeStamp',{}, ...
        'GazeX',           {}, ...
        'GazeY',           {}, ...
        'PupilDiaL',       {}, ...
        'PupilDiaR',       {} );
    tRecordingStart = NaN;
    tRecordingEnd   = NaN;

    if ~demoMode
        % flush
        subResult = eyetracker.get_gaze_data();
        if isa(subResult,'StreamError')
            warning('Tobii subscription error: %s', subResult.Message);
        end
        pause(0.2);                   % accumulate some samples 
        eyetracker.get_gaze_data();   % clear junk

        % tRecordingStart = eyetracker.get_system_time_stamp();
        tGameStart      = GetSecs;
    end
    % save game start stamp
    currentEEGTrig = logEvent('game_start');

    % game countdown screen
    DrawFormattedText(window, sprintf('Get Ready!\n\nGame %d',expParams.p5.gameplayCount), 'center', 'center', [255 255 255]);
    % expParams.p5.gameplayCount is able to keep track of game count; i.e. has
    % correct scope. Errors about eeg triggers are mostly scope related.
    Screen('Flip', window);
    WaitSecs(2);

    % after first piece is spawned, snapshot it
    currentEEGTrig = spawnNewPiece();
    drawGameState();
    Screen('Flip', window);
    frameStamp = GetSecs;

    visibleBoard = S.lockedMatrix;
    visibleBoard(S.currentPiece) = S.currentPieceID;
    boardSnapshot(end+1) = struct( ...
        'timestamp', frameStamp, ...
        'board',     visibleBoard, ...
        'eegTrigs',  currentEEGTrig ...
        );
    lastDropTime = GetSecs;

    if ~demoMode
        % flush stray samples & catch errors
        raw0 = eyetracker.get_gaze_data();
        if isa(raw0,'StreamError')
            warning('Pre-loop gaze flush error: %s', raw0.Message);
        end
    end
    %% game loop
    while ~S.gameOver

        % GAZE GRAB
        % pull & append our sampled with error check
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
        % reset frame trigger
        lastEEGTrig    = NaN;
        currentEEGTrig = NaN;

        % handle pause
        pauseDur = handlePause(window, expParams.keys);
        if isempty(pauseDur)
            pauseDur = 0;
        end

        if pauseDur > 0
            lastDropTime = lastDropTime + pauseDur;
        end

        % handle manual input
        [lastEEGTrig, didMove] = handleInput();
        if ~isnan(lastEEGTrig)
            currentEEGTrig = lastEEGTrig;

            if didMove
                % redraw horizontal/rotate
                % FIXME: sometimes you can infinitely spin a piece to stall it moving
                % downwards. I assume what I need to do is force the frame change faster
                % than drawGameState does, or give some timer in the functions that
                % actually move the piece?
                drawGameState();
                Screen('Flip', window);

                % supposdly cutting out may help w/ frame issue 
                % % % % lastDropTime = GetSecs;    % reset auto‐drop clock
                % % % % continue                    % skip to next frame
            end
        end

        % automatic drop
        dropInterval = S.levelFactor^(S.currentLevel - 1);
        if (GetSecs - lastDropTime) > dropInterval
            % try to move down one row
            [didMove,tmpTrig] = movePiece(0, -1);
            if didMove
                % on every successful drop send trig
                dropTrig       = logEvent('piece_drop');
                currentEEGTrig = dropTrig;
            elseif ~isnan(tmpTrig)
                % collision, so spawn new piece
                currentEEGTrig = tmpTrig;
            end
            lastDropTime = GetSecs;
        end


        % draw + snapshot full board
        drawGameState();
        Screen('Flip', window);
                % clear the eeg port
        WaitSecs(0.002);
        % send trigger at flip 
        if ~demoMode
            if  ~isempty(ioObj)
                io64(ioObj, address, 0);

            end;end
        frameStamp   = GetSecs;

        % Build screen:
        visibleBoard = S.lockedMatrix;                   % settled blocks
        visibleBoard(S.currentPiece) = S.currentPieceID; % moving piece

        boardSnapshot(end+1) = struct( ...
            'timestamp', frameStamp, ...
            'board',     visibleBoard, ...
            'eegTrigs',  currentEEGTrig ...
            );

        % debug print
        % if demoMode
        %     fprintf('Trigger: %d at %.4f\n', currentEEGTrig, frameStamp);
        % end
    end % while end

    % end game; so save the rest

    lastEEGTrig = logEvent('game_over', S.currentScore, S.currentLines);
    snapshotFile = fullfile(expParams.subjPaths.boardData, sprintf('%s_p5_boardSnapshot_g%02d.mat', subjID, gameIdx));
    visibleBoard = S.lockedMatrix;
    visibleBoard(S.currentPiece) = S.currentPieceID;
    boardSnapshot(end+1) = struct('timestamp', GetSecs, ...
        'board',     visibleBoard, ...
        'eegTrigs',  currentEEGTrig);

    fprintf('Saved board snapshot for game %d.\n\n\n', expParams.p5.gameplayCount);

    if ~demoMode
        % % get final samps w/ light error
        rawF = eyetracker.get_gaze_data();
        if isa(rawF,'StreamError')
            warning('Final gaze error: %s', rawF.Message);
            rawF = [];
        end

        for i = 1:numel(rawF)
            s = rawF(i);

            % handle missing data
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

        % stop recording & stamp Tobii
        % eyetracker.stop_recording();
        % tRecordingEnd = eyetracker.get_system_time_stamp();
        tRecordingEnd = GetSecs;
    else
        WaitSecs(1);  % demo stub
        tRecordingEnd = GetSecs;
    end

    % QC
    lossL = mean([blockGazeData.PupilDiaL] == 0);
    lossR = mean([blockGazeData.PupilDiaR] == 0);

    gazeFile = fullfile(expParams.subjPaths.eyeDir, sprintf('%s_game%03d_gaze.mat', subjID, gameIdx));

    % record game so the wrapper can log it
    activInfo(end+1) = struct( ...
        'gameNum',      gameIdx, ...
        'boardFile',    snapshotFile, ...
        'gazeFile',     gazeFile, ...
        'usedForReplay', false);

    % send game over
    DrawFormattedText(window, sprintf('Game Over!\n\nFinal Score: %d\n\nPlease wait, saving data.....', S.currentScore), 'center', 'center', [255 0 0]);
    Screen('Flip', window);

    % save gaze file
    save(gazeFile, ...
        'blockGazeData', ...
        'tRecordingStart', ...
        'tRecordingEnd', ...
        'lossL', 'lossR', ...
        'demoMode', ...
        '-v7.3');

    save(snapshotFile, 'boardSnapshot', 'eventLog', '-v7.3');

catch ME
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    fprintf(2, 'ERROR IN SCRIPT: %s\n', ME.stack(1).file); % where error occurred
    fprintf(2, 'Function: %s, Line: %d\n', ME.stack(1).name, ME.stack(1).line); % function w/ line
    fprintf(2, 'Error Message: %s\n', ME.message);
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');

    rethrow(ME); % rethrow error for wrapper
end % try end (for eye tracker)

%========================================================
%======================HELPER SCRIPTS====================
%========================================================
    function lastEEGTrig = logEvent(eventType, val1, val2)

        if nargin < 2, val1 = ''; end
        if nargin < 3, val2 = ''; end

        % append to eventLog with Tobii timestamp
        sysTS   = GetSecs;
        tobiiTS = sysTS;
        if ~demoMode
            tobiiTS = GetSecs;
        end
        newEntry = struct( ...
            'timestamp',  sysTS, ...
            'systemTS',   tobiiTS, ...
            'eventType',  eventType, ...
            'val1',       val1, ...
            'val2',       val2  ...
            );
        eventLog(end+1) = newEntry;

        % if event has EEG trig, send it 
        if isKey(p5_triggers, eventType)
            trigVal = p5_triggers(eventType);

            % ALWAYS send to the port, demoMode or not
            if ~demoMode
                if ~isempty(ioObj)
                    io64(ioObj, address, trigVal);
                end;end

            % print for debugging
            if demoMode
            fprintf('[LOGGED] Event: %-15s → %3d @ %.4f\n', eventType, trigVal, GetSecs()); % getsecs call was printing as "ans = " in cmd window. I think calling as a function () fixes this
            end 
            
            lastEEGTrig = trigVal;
        else
            lastEEGTrig = NaN;
        end
    end

    function spawnTrig = spawnNewPiece()
        % pick up IDs…
        S.currentPieceID = S.nextPieceID;
        S.nextPieceID    = randi(7);

        % get linear indices for 4 blocks
        shape = pieces(S.currentPieceID).shape;
        [h,w] = size(shape);
        [rIdx,cIdx] = find(shape);
        baseRow = boardH - h + 1;
        baseCol = floor((boardW - w)/2) + 1;
        absRows = baseRow + rIdx-1;
        absCols = baseCol + cIdx-1;
        newIdx  = sub2ind([boardH,boardW], absRows, absCols);

        % game over check
        if any(S.lockedMatrix(newIdx))
            S.gameOver = true;
            spawnTrig = logEvent('game_over');
            return;
        end

        % record falling piece
        S.currentPiece = newIdx;

        % pivot 
        shapePivot = pieces(S.currentPieceID).pivot;
        pivotRow   = baseRow + shapePivot(1) - 1;
        pivotCol   = baseCol + shapePivot(2) - 1;
        S.pivotBoardIdx = sub2ind([boardH,boardW], pivotRow, pivotCol);

        spawnTrig = logEvent('piece_spawn', S.currentPieceID, '');
    end

    function [lastEEGTrig, didMove] = handleInput()
        lastEEGTrig = NaN;
        didMove     = false;
        [keyIsDown,~,keyCode] = KbCheck(-1);

        if keyIsDown
            if keyCode(expParams.keys.left)
                lastDropTime = GetSecs;
                lastEEGTrig = logEvent('key_press_left');
                [didMove,~] = movePiece(-1,0);

            elseif keyCode(expParams.keys.right)
                lastDropTime = GetSecs;
                lastEEGTrig = logEvent('key_press_right');
                [didMove,~] = movePiece(1,0);

            elseif keyCode(expParams.keys.down)
                lastDropTime = GetSecs;
                lastEEGTrig = logEvent('key_press_down_softdrop');
                [didMove,~] = movePiece(0,-1);

            elseif keyCode(expParams.keys.up)
                lastDropTime = GetSecs;
                % DUPLICATE lastEEGTrig = logEvent('key_press_up_rotate');
                [didMove,lastEEGTrig] = rotatePiece();

            elseif keyCode(expParams.keys.escape)
                lastDropTime = GetSecs;
                S.gameOver = true;
            end

            % reset drop-timer on movement
            if didMove
                lastDropTime = GetSecs;
            end

            %  wait for key release to avoid repeats
            % KbReleaseWait; % prev commented out 
            % WaitSecs(0.08); % cpu bounce 
            WaitSecs(expParams.rule.keyRepeatInterval)
        end
    end

    function [didMove, lastEEGTrig] = movePiece(colOffset, rowOffset)
        didMove     = false;
        lastEEGTrig = NaN;

        % get current falling piece coords
        [rows, cols] = ind2sub([boardH,boardW], S.currentPiece);

        % new coords
        newRows = rows + rowOffset;
        newCols = cols + colOffset;

        % boundary check 
        if any(newRows<1) || any(newRows>boardH) || any(newCols<1) || any(newCols>boardW)
            if rowOffset < 0
                logEvent('piece_lock');              % lock
                S.lockedMatrix(S.currentPiece) = S.currentPieceID;
                checkForLineClears();
                spawnTrig = spawnNewPiece();        % get the new spawn trigger
                lastEEGTrig = spawnTrig;            % return it to the caller
            end

            return
        end

        % collision & locked
        newIdx = sub2ind([boardH,boardW], newRows, newCols);
        if any(S.lockedMatrix(newIdx))
            if rowOffset < 0
                lastEEGTrig = logEvent('piece_lock');
                S.lockedMatrix(S.currentPiece) = S.currentPieceID;
                checkForLineClears();
                spawnNewPiece();
            end
            return
        end

        % update valid moves 
        S.currentPiece = newIdx;
        didMove        = true;

        % udate pivot for rotations 
        [pr, pc] = ind2sub([boardH,boardW], S.pivotBoardIdx);
        pr_new = pr + rowOffset;
        pc_new = pc + colOffset;
        % only write if still on the board:
        if pr_new >= 1 && pr_new <= boardH && pc_new >= 1 && pc_new <= boardW
            S.pivotBoardIdx = sub2ind([boardH,boardW], pr_new, pc_new);
        else
            % OB pivot will crash
        end
    end

    function [didMove, lastEEGTrig] = rotatePiece()
        didMove     = false;
        lastEEGTrig = NaN;

        % get the four current block positions on the board
        [rows, cols] = ind2sub([boardH, boardW], S.currentPiece);

        % get pivot
        pivotBoardIdx = S.pivotBoardIdx;
        [pRow, pCol]  = ind2sub([boardH, boardW], pivotBoardIdx);

        % get block's offset from pivot
        relRows = rows - pRow;
        relCols = cols - pCol;

        % rotate 90 deg CW
        newRelRows = -relCols;
        newRelCols =  relRows;

        % get back to coords
        newRows = pRow + newRelRows;
        newCols = pCol + newRelCols;

        % bounds‐check
        if any(newRows < 1) || any(newRows > boardH) || any(newCols < 1) || any(newCols > boardW)
            return
        end

        % collision check placed blocks
        newIdx = sub2ind([boardH, boardW], newRows, newCols);
        if any(S.lockedMatrix(newIdx))
            return
        end

        % finish rotation 
        S.currentPiece = newIdx;
        didMove        = true;
        lastEEGTrig    = logEvent('key_press_up_rotate');
    end

    function lastEEGTrig =  checkForLineClears()
        lastEEGTrig = nan;

        fullRows = find(all(S.lockedMatrix,2));
        numCleared = numel(fullRows);

        if numCleared > 0
            % send clear trigger
            lastEEGTrig = logEvent(sprintf('line_clear_%d', numCleared), numCleared, '');

            % update score & lines
            S.currentLines = S.currentLines + numCleared;
            S.currentScore = S.currentScore + S.pointsVector(numCleared)*S.currentLevel;

            % clear and shift the board
            S.lockedMatrix(fullRows,:) = [];
            S.lockedMatrix = [ S.lockedMatrix ; zeros(numCleared, boardW, 'uint8') ];

            % check levelup 
            if floor(S.currentLines/S.linesForLevelUp) >= S.currentLevel
                S.currentLevel = S.currentLevel + 1;
            end
        end

    end % check for line clears end

    function drawGameState()
        boardWidth  = boardW;
        boardHeight = boardH;
        blockSize   =     expParams.visual.blockSize;            
        boardOutlineWidth = 5;

        boardRectX = (windowRect(3) - boardWidth*blockSize)/2;
        boardRectY = (windowRect(4) - boardHeight*blockSize)/2;
        boardRect  = [boardRectX, boardRectY, ...
            boardRectX + boardWidth*blockSize, ...
            boardRectY + boardHeight*blockSize];
        getColorIn = expParams.visual.pieceColor;
        Screen('FrameRect', window, getColorIn, boardRect, boardOutlineWidth);

        % 1) draw all locked blocks
        % % for r = 1:boardH
        % %     for c = 1:boardW
        % %         pid = S.lockedMatrix(r,c);
        % %         if pid>0
        % %             x = boardRectX + (c-1)*blockSize;
        % %             y = boardRectY + (boardHeight-r)*blockSize;
        % %             b = [x y x+blockSize y+blockSize];
        % %             Screen('FillRect',  window, [127 127 127], b);
        % %             Screen('FrameRect', window, [0 0 0], b, 1);
        % %         end
        % %     end
        % % end
        for r = 1:boardH
            for c = 1:boardW
                pid = S.lockedMatrix(r,c);
                if pid > 0
                    x = boardRectX + (c-1)*blockSize;
                    y = boardRectY + (boardHeight-r)*blockSize;
                    b = [x y x+blockSize y+blockSize];

                    color = S.pieceColors{pid};  % ← use assigned piece color
                    Screen('FillRect',  window, color, b);
                    Screen('FrameRect', window, [0 0 0], b, 1);
                end
            end
        end



        % 2) overlay falling piece
        % % [rP, cP] = ind2sub([boardH,boardW], S.currentPiece);
        % % for i = 1:numel(rP)
        % %     x = boardRectX + (cP(i)-1)*blockSize;
        % %     y = boardRectY + (boardHeight-rP(i))*blockSize;
        % %     b = [x y x+blockSize y+blockSize];
        % %     Screen('FillRect',  window, [127 127 127], b);
        % %     Screen('FrameRect', window, [0 0 0], b, 1);
        % % end
        color = S.pieceColors{S.currentPieceID};  
        [rP, cP] = ind2sub([boardH,boardW], S.currentPiece);
        for i = 1:numel(rP)
            x = boardRectX + (cP(i)-1)*blockSize;
            y = boardRectY + (boardHeight-rP(i))*blockSize;
            b = [x y x+blockSize y+blockSize];

            Screen('FillRect',  window, color, b);
            Screen('FrameRect', window, [0 0 0], b, 1);
        end

        scoreText = sprintf('Score: %d\nLevel: %d\nLines: %d', S.currentScore, S.currentLevel, S.currentLines);
        DrawFormattedText(window, scoreText, boardRect(3)+20, boardRect(2), [255 255 255]);
    end % draw game state end
end % function end