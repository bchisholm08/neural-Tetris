function [snapshotFile, activInfo, eventLog] = playOneTetrisGame(expParams)

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
            sprintf('%s_game%03d_gaze.mat', subjID, gameIdx));

activInfo = struct('gameNum',{},'boardFile',{},'gazeFile',{},'usedForReplay',{});
% get shapes and textures
pieces = getTetrino(expParams);
boardH = 20;
boardW = 10;

S = struct(); % to store game state

% use two matrix design... 
S.lockedMatrix  = zeros(boardH, boardW, 'uint8');   % landed blocks 
S.currentPiece  = [];   % linear indices falling blocks
S.currentPieceID= 0;    % which piece type 

p5_triggers = containers.Map( ...
    {'game_start','game_over','piece_spawn','piece_lock', ...
    'piece_drop', ...                   % ← new
    'key_press_left','key_press_right', ...
    'key_press_up_rotate','key_press_down_softdrop', ...
    'line_clear_1','line_clear_2', ...
    'line_clear_3','line_clear_4'}, ...
    {101,102,103,104,105,111,112,113,114,121,122,123,124});

% FIXME for the replay section; add 100 to the triggers above so 2xx is for replays, 1xx for player control

% init struct

% screw these piece colors, be GRAY! 
S.pieceColors = {[1 0 0], [0 1 0], [0 0 1], [1 1 0], [1 0 1], [0 1 1], [1 0.5 0]}; % I, T, L, J, Z, S, O; same ordering

% S.pieceDefs = {[194:197],[184 185 186 195],[184 185 186 196],...
%     [184 185 186 194],[194 195 185 186],[184 195 185 196], [185 186 195 196]};

S.pointsVector = [100 300 500 800]; % reg tetris points for 1, 2s, 3, or 4 lines cleared
S.levelFactor = .25;  % speed factor per level (omit? Ask JP) ORIGINAL GAME IS .625. Curious if changing to 0 would work 

S.linesForLevelUp = 10; % originally 5 lines. Probably dropping. See above

% init special logs. good reference. save to misc dir
eventLog = struct( ...
    'timestamp',  {}, ...  % MATLAB clock (check if this equals GetSecs() call) 
    'systemTS',   {}, ...  % Tobii SDK clock (different from GetSecs() ) 
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

    % — c) start recording & stamp clocks —
    eyetracker.start_recording();
    tRecordingStart = eyetracker.get_system_time_stamp();
    tGameStart      = GetSecs;
    
end

% save game start
currentEEGTrig = logEvent('game_start');

% game countdown screen
DrawFormattedText(window, sprintf('Get Ready!\n\nGame %d',expParams.p5.gameplayCount), 'center', 'center', [255 255 255]);
% expParams.p5.gameplayCount is able to keep track of game count; i.e. has
% correct scope. Errors about eeg triggers are mostly about scope.
Screen('Flip', window);
WaitSecs(2);

%% after you spawn first piece, snapshot it:
currentEEGTrig = spawnNewPiece();
drawGameState();
Screen('Flip', window);
frameStamp = GetSecs;

visibleBoard = S.lockedMatrix;
visibleBoard(S.currentPiece) = S.currentPieceID;
boardSnapshot(end+1) = struct( ...
    'timestamp', frameStamp, ...          % use the same timestamp you just grabbed
    'board',     visibleBoard, ...        % now includes the falling piece
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


%% now main loop:
while ~S.gameOver

% begin pupillometry collection for game block FIXME WHERE DOES THIS
% END COLLECTION?!?!

% GAZE GRAB ───────────────────────────────────────────────
% — pull & append all samples with error‐check —
if ~demoMode
    raw = eyetracker.get_gaze_data('flat');
    if isa(raw,'StreamError')
        warning('Mid-loop gaze error: %s', raw.Message);
        raw = [];
    end
    for i = 1:numel(raw)
        s = raw(i);
        blockGazeData(end+1) = struct( ...
            'SystemTimeStamp', s.SystemTimeStamp, ...
            'DeviceTimeStamp', s.DeviceTimeStamp, ...
            'GazeX',           s.LeftEye_GazePoint_OnDisplayArea(1), ...
            'GazeY',           s.LeftEye_GazePoint_OnDisplayArea(2), ...
            'PupilDiaL',       s.LeftEye_Pupil_Diameter, ...
            'PupilDiaR',       s.RightEye_Pupil_Diameter ...
        );
    end
end




    % reset frame trigger
    lastEEGTrig    = NaN;
    currentEEGTrig = NaN;

    pauseDur = handlePause(window, expParams.keys);
    if isempty(pauseDur)
         pauseDur = 0; 
    end

    if pauseDur > 0
        lastDropTime = lastDropTime + pauseDur;
    end

    % 2) handle manual input
    [lastEEGTrig, didMove] = handleInput();
    if ~isnan(lastEEGTrig)
        currentEEGTrig = lastEEGTrig;

        if didMove
            % ── redraw right away for horizontal/rotate moves ──
            drawGameState();
            Screen('Flip', window);
            lastDropTime = GetSecs;    % reset your auto‐drop clock
            continue                    % skip straight to next frame
        end
    end

    % 3) automatic drop
    dropInterval = S.levelFactor^(S.currentLevel - 1);
    if (GetSecs - lastDropTime) > dropInterval
        % try to move down one row
        [didMove,tmpTrig] = movePiece(0, -1); % what is tmpTrig output? 
        if didMove
            % on *every* successful drop, send piece_drop
            dropTrig       = logEvent('piece_drop');
            currentEEGTrig = dropTrig;
        elseif ~isnan(tmpTrig)
            % collision→spawn new piece
            currentEEGTrig = tmpTrig;
        end
        lastDropTime = GetSecs;
    end

    
    % 4) draw + snapshot of full visible board (locked + falling)
    drawGameState();
    Screen('Flip', window);
    frameStamp   = GetSecs;

    % Build exactly what was on screen:
    visibleBoard = S.lockedMatrix;                   % all the settled blocks…
    visibleBoard(S.currentPiece) = S.currentPieceID; % …plus the moving piece

    boardSnapshot(end+1) = struct( ...
        'timestamp', frameStamp, ...
        'board',     visibleBoard, ...
        'eegTrigs',  currentEEGTrig ...
    );

    % 5) clear the port
    % WaitSecs(0.002);
        if ~demoMode
    if  ~isempty(ioObj)
        io64(ioObj, address, 0);
    
    end;end

    % debug print
    if demoMode
        fprintf('Trigger: %d at %.4f\n', currentEEGTrig, frameStamp);
    end
end % while end 
 
% end game; so save the rest 

lastEEGTrig = logEvent('game_over', S.currentScore, S.currentLines);
snapshotFile = fullfile(expParams.subjPaths.boardData, sprintf('%s_p5_boardSnapshot_g%02d.mat', subjID, gameIdx));
gazeFile = fullfile(expParams.subjPaths.eyeDir, ...
sprintf('%s_game%03d_gaze.mat', subjID, gameIdx));
visibleBoard = S.lockedMatrix;
visibleBoard(S.currentPiece) = S.currentPieceID;
boardSnapshot(end+1) = struct('timestamp', GetSecs, ...
                               'board',     visibleBoard, ...
                                'eegTrigs',  currentEEGTrig);

fprintf('Saved board snapshot for game %d.\n\n\n', expParams.p5.gameplayCount);
save(snapshotFile, 'boardSnapshot', 'eventLog', '-v7.3');


if ~demoMode
    % — final pull & error‐check —
    rawF = eyetracker.get_gaze_data('flat');
    if isa(rawF,'StreamError')
        warning('Final gaze error: %s', rawF.Message);
        rawF = [];
    end
    for i = 1:numel(raw)
        s = raw(i);
        blockGazeData(end+1) = struct( ...
            'SystemTimeStamp', s.SystemTimeStamp, ...
            'DeviceTimeStamp', s.DeviceTimeStamp, ...
            'GazeX',           s.LeftEye_GazePoint_OnDisplayArea(1), ...
            'GazeY',           s.LeftEye_GazePoint_OnDisplayArea(2), ...
            'PupilDiaL',       s.LeftEye_Pupil_Diameter, ...
            'PupilDiaR',       s.RightEye_Pupil_Diameter ...
        );
    end

    % — stop recording & stamp Tobii clock at end —
    eyetracker.stop_recording();
    tRecordingEnd = eyetracker.get_system_time_stamp();
else
    WaitSecs(1);  % demo stub
    tRecordingEnd = GetSecs;
end

% — compute QC loss metrics —
lossL = mean([blockGazeData.PupilDiaL] == 0);
lossR = mean([blockGazeData.PupilDiaR] == 0);

% — save gaze file every time for QC —
save(gazeFile, ...
     'blockGazeData', ...
     'tRecordingStart', ...
     'tRecordingEnd', ...
     'lossL', 'lossR', ...
     'demoMode', ...
     '-v7.3');


% record game so the wrapper can log it
activInfo(end+1) = struct( ...
'gameNum',      gameIdx, ...
'boardFile',    snapshotFile, ...
'gazeFile',     gazeFile, ...
'usedForReplay', false);


% send game over
DrawFormattedText(window, sprintf('Game Over!\n\nFinal Score: %d\n\nPlease wait.....', S.currentScore), 'center', 'center', [255 0 0]);
Screen('Flip', window);
% dwell (FIXME this should be an expParams rule...)
WaitSecs(4);

catch ME
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    fprintf(2, 'ERROR IN SCRIPT: %s\n', ME.stack(1).file); % where error occurred
    fprintf(2, 'Function: %s, Line: %d\n', ME.stack(1).name, ME.stack(1).line); % function name with line
    fprintf(2, 'Error Message: %s\n', ME.message);
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    
    rethrow(ME); % rethrow error for wrapper 
end % try end (for eye tracker) 

%========================================================
%======================HELPER SCRIPTS====================
%========================================================
    function lastEEGTrig = logEvent(eventType, val1, val2)
        % Helper to (1) record, (2) send, and (3) print every trigger

        if nargin < 2, val1 = ''; end
        if nargin < 3, val2 = ''; end

        % 1) Append to eventLog with Tobii timestamp
        sysTS   = GetSecs;
        tobiiTS = NaN;
        if ~demoMode
            tobiiTS = eyetracker.get_system_time_stamp();
        end
        newEntry = struct( ...
            'timestamp',  sysTS, ...
            'systemTS',   tobiiTS, ...
            'eventType',  eventType, ...
            'val1',       val1, ...
            'val2',       val2  ...
        );
        eventLog(end+1) = newEntry;


        % 2) If this event has an EEG code, send it out
        if isKey(p5_triggers, eventType)
            trigVal = p5_triggers(eventType);

            % ALWAYS send to the port, demoMode or not
            if ~demoMode
            if ~isempty(ioObj)
                io64(ioObj, address, trigVal);
            end;end

            % 3) Print for debugging
            fprintf('[LOGGED] Event: %-15s → %3d @ %.4f\n', ...
                eventType, trigVal, GetSecs);

            lastEEGTrig = trigVal;
        else
            lastEEGTrig = NaN;
        end
    end


function spawnTrig = spawnNewPiece()
    % pick up IDs…
    S.currentPieceID = S.nextPieceID;
    S.nextPieceID    = randi(7);

    % compute new linear indices for the 4 blocks
    shape = pieces(S.currentPieceID).shape;
    [h,w] = size(shape);
    [rIdx,cIdx] = find(shape);
    baseRow = boardH - h + 1;
    baseCol = floor((boardW - w)/2) + 1;
    absRows = baseRow + rIdx-1;
    absCols = baseCol + cIdx-1;
    newIdx  = sub2ind([boardH,boardW], absRows, absCols);

    % spawn‐collision → game over
    if any(S.lockedMatrix(newIdx))
        S.gameOver = true;
        spawnTrig = logEvent('game_over');
        return;
    end

    % record only the falling piece
    S.currentPiece = newIdx;

    % pivot bookkeeping (unchanged)…
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

            % ── reset the drop-timer on any movement ──
            if didMove
                lastDropTime = GetSecs;
            end

            % ── wait for key release to avoid repeats ──
            % KbReleaseWait;
            WaitSecs(0.08);
        end
    end


function [didMove, lastEEGTrig] = movePiece(colOffset, rowOffset)
    didMove     = false;
    lastEEGTrig = NaN;

    % 1) decode current falling piece coords
    [rows, cols] = ind2sub([boardH,boardW], S.currentPiece);

    % 2) proposed positions
    newRows = rows + rowOffset;
    newCols = cols + colOffset;

    % 3) bounds check
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

    % 4) collision vs locked
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

    % 5) valid move → update falling piece
    S.currentPiece = newIdx;
    didMove        = true;

        % ── update pivot so future rotates spin in place ──
    [pr, pc] = ind2sub([boardH,boardW], S.pivotBoardIdx);
    pr_new = pr + rowOffset;
    pc_new = pc + colOffset;
    % only write if still on the board:
    if pr_new >= 1 && pr_new <= boardH && pc_new >= 1 && pc_new <= boardW
        S.pivotBoardIdx = sub2ind([boardH,boardW], pr_new, pc_new);
    else
        % out-of-bounds pivot would crash – so keep old pivot
    end
end

function [didMove, lastEEGTrig] = rotatePiece()
    didMove     = false;
    lastEEGTrig = NaN;

    % (A) Get the four current block positions on the board
    [rows, cols] = ind2sub([boardH, boardW], S.currentPiece);

    % (B) Where is the pivot right now?
    pivotBoardIdx = S.pivotBoardIdx;
    [pRow, pCol]  = ind2sub([boardH, boardW], pivotBoardIdx);

    % (C) Compute each block's offset from the pivot…
    relRows = rows - pRow;
    relCols = cols - pCol;

    % (D) …rotate those offsets 90° CW
    newRelRows = -relCols;
    newRelCols =  relRows;

    % (E) Translate back to absolute board coords
    newRows = pRow + newRelRows;
    newCols = pCol + newRelCols;

    % (F) Bounds‐check: must stay on the board
    if any(newRows < 1) || any(newRows > boardH) || any(newCols < 1) || any(newCols > boardW)
        return
    end

    % (G) Collision‐check against locked blocks
    newIdx = sub2ind([boardH, boardW], newRows, newCols);
    if any(S.lockedMatrix(newIdx))
        return
    end

    % (H) Commit the rotation
    S.currentPiece = newIdx;
    didMove        = true;
    lastEEGTrig    = logEvent('key_press_up_rotate');
end

    function lastEEGTrig =  checkForLineClears()
        lastEEGTrig = nan;

        fullRows = find(all(S.lockedMatrix,2));
        numCleared = numel(fullRows);


        if numCleared > 0
            % 1) send the clear trigger
            lastEEGTrig = logEvent(sprintf('line_clear_%d', numCleared), numCleared, '');

            % 2) update score & lines
            S.currentLines = S.currentLines + numCleared;
            S.currentScore = S.currentScore + S.pointsVector(numCleared)*S.currentLevel;

            % 3) clear and shift the board
            S.lockedMatrix(fullRows,:) = [];
            S.lockedMatrix = [ S.lockedMatrix ; zeros(numCleared, boardW, 'uint8') ];
    
            % 4) level-up if needed
            if floor(S.currentLines/S.linesForLevelUp) >= S.currentLevel
                S.currentLevel = S.currentLevel + 1;
            end
        end

    end % check for line clears end

    function drawGameState()
        boardWidth  = boardW;
        boardHeight = boardH;
        blockSize   =     expParams.p5.blockSize;            % ← hard‐code your desired cell size
        boardOutlineWidth = 5;

        boardRectX = (windowRect(3) - boardWidth*blockSize)/2;
        boardRectY = (windowRect(4) - boardHeight*blockSize)/2;
        boardRect  = [boardRectX, boardRectY, ...
            boardRectX + boardWidth*blockSize, ...
            boardRectY + boardHeight*blockSize];

        Screen('FrameRect', window, [255 255 255], boardRect, boardOutlineWidth);

% 1) draw all locked blocks
for r = 1:boardH
  for c = 1:boardW
    pid = S.lockedMatrix(r,c);
    if pid>0
      x = boardRectX + (c-1)*blockSize;
      y = boardRectY + (boardHeight-r)*blockSize;
      b = [x y x+blockSize y+blockSize];
      Screen('FillRect',  window, [128 128 128], b);
      Screen('FrameRect', window, [0 0 0], b, 1);
    end
  end
end

% 2) overlay falling piece
[rP, cP] = ind2sub([boardH,boardW], S.currentPiece);
for i = 1:numel(rP)
  x = boardRectX + (cP(i)-1)*blockSize;
  y = boardRectY + (boardHeight-rP(i))*blockSize;
  b = [x y x+blockSize y+blockSize];
  Screen('FillRect',  window, [128 128 128], b);
  Screen('FrameRect', window, [0 0 0], b, 1);
end


        scoreText = sprintf('Score: %d\nLevel: %d\nLines: %d', ...
            S.currentScore, S.currentLevel, S.currentLines);
        DrawFormattedText(window, scoreText, boardRect(3)+20, boardRect(2), [255 255 255]);
    end


%===================================
% % % % % % % % % % HOTFIX 
% % % % % % % % % if isempty(activInfo)
% % % % % % % % %     % (should never happen, but just in case)
% % % % % % % % %     activInfo = struct( ...
% % % % % % % % %         'gameNum',       expParams.p5.gameplayCount, ...
% % % % % % % % %         'fileName',      snapshotFile,            ...
% % % % % % % % %         'usedForReplay', false                   ...
% % % % % % % % %     );
% % % % % % % % % else
% % % % % % % % %     % if somehow you have more, return only the last one
% % % % % % % % %     % % %activInfo = activInfo(end);
% % % % % % % % % end

end % function end