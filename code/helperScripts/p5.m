%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
% 
% ADAPTED FOR NOEL LAB RESEARCH FROM:
% Matt Fig (2025). Tetris for MATLAB (https://www.mathworks.com/matlabcentral/fileexchange/34513-tetris-for-matlab), MATLAB Central File Exchange. Retrieved May 7, 2025.
% 
% Description: A mostly self contained (i.e. not many outside function
% calls--many local functions) version of Tetris modified for our
% experiment interests in participant performance, and focused on 
% accurate data collection
%
%-------------------------------------------------------
function p5(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker)
try
    %% set up & instruct 
    p5StartTimestamp = datetime("now");

    fprintf('p5: Initializing Tetris game environment...\n');

    % Display instructions for Part 5
    p5instruct(window, expParams); %

    % local EEG trigger map for p5, no getTrig for this section 
    p5_triggers = containers.Map(...
        {'game_start', 'game_over', 'piece_spawn', 'piece_lock', ...
         'key_press_left', 'key_press_right', 'key_press_up_rotate', 'key_press_down_softdrop', ...
         'line_clear_1', 'line_clear_2', 'line_clear_3', 'line_clear_4'}, ...
        {101, 102, 103, 104, ...
         111, 112, 113, 114, ...
         121, 122, 123, 124});
    
    % init struct 
    S = struct(); % to store game state 

    %FIXME add in code that will save board state anytime it changes  
    
    % piece and board 
    S.boardMatrix = zeros(10, 20); % 10 wide by 20 high board 

    S.pieceColors = {[1 0 0], [0 1 0], [0 0 1], [1 1 0], [1 0 1], [0 1 1], [1 0.5 0]}; % I, T, L, J, Z, S, O; same ordering 
    
    S.pieceDefs = {[194:197],[184 185 186 195],[184 185 186 196],...
                   [184 185 186 194],[194 195 185 186],[184 195 185 196], [185 186 195 196]};

    S.pointsVector = [100 300 500 800]; % reg tetris points for 1, 2, 3, or 4 lines cleared 
    S.levelFactor = .625;  % speed factor per level
    
    S.linesForLevelUp = 5; % change level every 5 lines

    % init logs 
    eventLog = {}; % cell array for time events 
    

    numGames = expParams.p5.options.gamesAllowed;
    %% GAME LOOP 
    for gameNum = 1:numGames
        
        % init new game
        % fprintf('p5: Starting Game %d of %d...\n', gameNum, numGames);
        % have this deal with TIME and not the num of games 
        
        % reset game state vars
        S.boardMatrix(:) = false;
        S.currentLevel = 1;
        S.currentLines = 0;
        S.currentScore = 0;
        S.gameOver = false;
        S.currentPiece = []; % indices of current falling piece
        S.currentPieceID = 0;
        S.nextPieceID = ceil(rand*7); % pre-determine first piece randomly s
        
        % save game start 
        logEvent('game_start', gameNum, '');
        
        % game countdown screen
        DrawFormattedText(window, sprintf('Get Ready!\n\nGame %d', gameNum), 'center', 'center', [255 255 255]);
        Screen('Flip', window);
        WaitSecs(2);

        % begin pupillometry collection for game block
        if ~demoMode, eyetracker.get_gaze_data(); end 
        blockGazeData = struct('DeviceTimeStamp',{}, 'Left',{}, 'Right',{}, 'Pupil',{});

        % init game elements
        spawnNewPiece(); % spawn first piece
        
        lastDropTime = GetSecs;
        
        % single game loop 
        while ~S.gameOver
             
            
            % --- 1. Check for Pause ---
            % This function will pause if 'p' is pressed and return the duration.
            pauseDuration = handlePause(window, expParams.keys);
            if pauseDuration > 0
                % Add the pause duration to our timer to "stop the clock"
                lastDropTime = lastDropTime + pauseDuration;
            end

            % handle key board input 
            handleInput();
            
            %  update the state of the game 
            dropInterval = (S.levelFactor ^ (S.currentLevel - 1));
            if (GetSecs - lastDropTime) > dropInterval
                movePiece(0, -1); % Attempt to move piece down
                lastDropTime = GetSecs; % Reset timer AFTER the drop
            end
            
            % draw it all up 
            drawGameState();
            
            % flip 
            Screen('Flip', window);
        end % end single game loop
        
        % end of a single game 
        logEvent('game_over', S.currentScore, S.currentLines);
        
        % save pupillometry data for this game
        if ~demoMode
            pupilFileName = fullfile(expParams.subjPaths.eyeDir, sprintf('%s_p5_pupil_game%d.mat', subjID, gameNum));
            blockGazeData = [blockGazeData; eyetracker.get_gaze_data()]; % add on final samples
            save(pupilFileName, 'blockGazeData', '-v7.3');
            fprintf('p5: Saved pupillometry data for game %d.\n', gameNum);
        end

        % 6.11.25 FIXME add in "wait for the next game to begin" while under the
        % game time ceiling. Once < a certain threshold, just give "wait
        % for game to end" message 
        DrawFormattedText(window, sprintf('Game Over!\n\nFinal Score: %d\n\nPlease wait.....', S.currentScore), 'center', 'center', [255 0 0]);
        Screen('Flip', window);
        WaitSecs(4); 
        
        if gameNum < numGames
            betweenSectionBreakScreen(window, expParams); 
        end
    end

    %% save all behavioral data for this section 
    fprintf('p5: All games complete. Saving event data...\n');
    expParams.rule.initExperiment_expMasterEndTime = datetime('now');
    expParams.rule.initExperiment_expMasterEndTime.Format = 'HH:mm:ss_M/d/yy';
    expParams.p2.options.sectionDoneFlag = 1; 
    saveDat('p5_events', subjID, eventLog, expParams, demoMode);
    
catch ME
    % The catch block logs the specific error and re-throws it to the wrapper
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    fprintf(2, 'ERROR IN SCRIPT: p5.m\n');
    fprintf(2, 'Function: %s, Line: %d\n', ME.stack(1).name, ME.stack(1).line);
    fprintf(2, 'Error Message: %s\n', ME.message);
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    rethrow(ME);
end

%% subfunctions for p5, keep program contained 
% various scripts I wrote, drafted, or built with help from Gemini ai to help
% with running the game 

    function logEvent(eventType, val1, val2)
        % Helper to log events and send triggers
        eventLog = [eventLog; {GetSecs, eventType, val1, val2}];
        if ~demoMode && ~isempty(ioObj) && isKey(p5_triggers, eventType)
            io64(ioObj, address, p5_triggers(eventType));
        end
    end

    function spawnNewPiece()
        S.currentPieceID = S.nextPieceID;
        S.nextPieceID = ceil(rand*7); % Choose the next piece
        S.currentPiece = S.pieceDefs{S.currentPieceID};
        S.currentRotation = 1;
        
        % Check for game over condition
        if any(S.boardMatrix(S.currentPiece))
            S.gameOver = true;
            return;
        end
        
        S.boardMatrix(S.currentPiece) = S.currentPieceID; % Place piece on board matrix
        logEvent('piece_spawn', S.currentPieceID, '');
    end

    function handleInput()
        [keyIsDown, ~, keyCode] = KbCheck(-1);
        if keyIsDown
            if keyCode(expParams.keys.left)
                logEvent('key_press_left', '', '');
                movePiece(-1, 0);
            elseif keyCode(expParams.keys.right)
                logEvent('key_press_right', '', '');
                movePiece(1, 0);
            elseif keyCode(expParams.keys.down)
                logEvent('key_press_down_softdrop', '', '');
                movePiece(0, -1);
                lastDropTime = GetSecs; % Reset drop timer
            elseif keyCode(expParams.keys.up)
                logEvent('key_press_up_rotate', '', '');
                rotatePiece();
            elseif keyCode(expParams.keys.escape)
                S.gameOver = true; % Allow user to quit game
            end
            WaitSecs(0.08); % A small delay to debounce key presses
        end
    end

   function didMove = movePiece(colOffset, rowOffset)
    
    % Get the current row positions of all blocks in the piece
    currentRows = rem(S.currentPiece - 1, 10) + 1;
    
    % --- BOUNDARY CHECK ---
    % If trying to move left (colOffset = -1) but already at the left wall (min(rows) is 1)
    if colOffset < 0 && min(currentRows) == 1
        return; % Abort the move entirely
    end
    % If trying to move right (colOffset = 1) but already at the right wall (max(rows) is 10)
    if colOffset > 0 && max(currentRows) == 10
        return; % Abort the move entirely
    end
    % --- END BOUNDARY CHECK ---

    % Erase current piece from board
    S.boardMatrix(S.currentPiece) = 0;
    
    % Calculate new proposed position
    newPiece = S.currentPiece + colOffset + (rowOffset * 10);
    
    % Check for collisions with other pieces or the bottom of the board
    cols = ceil(newPiece/10);
    
    didMove = true;
    if any(cols < 1) || any(S.boardMatrix(newPiece))
        % Collision detected, move is invalid
        newPiece = S.currentPiece; % Revert to old position
        didMove = false;
    end
    
    % Redraw piece in its new (or old) position
    S.boardMatrix(newPiece) = S.currentPieceID;
    S.currentPiece = newPiece;
    
    % If movement was down and it failed, the piece has locked
    if rowOffset < 0 && ~didMove
        logEvent('piece_lock', S.currentPieceID, '');
        checkForLineClears();
        spawnNewPiece();
    end
end

function rotatePiece()
    % This function correctly rotates a piece by treating its blocks as
    % a set of coordinates relative to a pivot point.
    
    % --- Step 1: Get current piece's local coordinates ---
    % Use the 2nd block of the piece as the pivot point for rotation.
    pivotPointIndex = S.currentPiece(2);
    
    % Convert the pivot's linear index to its board [row, col] position.
    % Remember: in our 10x20 grid, 'row' is the x-position (1-10) and 'col' is the y-position (1-20).
    pivotCol = floor((pivotPointIndex - 1) / 10) + 1;
    pivotRow = rem(pivotPointIndex - 1, 10) + 1;
    
    % Get the [row, col] coordinates of all blocks in the current piece.
    currentCols = floor((S.currentPiece - 1) / 10) + 1;
    currentRows = rem(S.currentPiece - 1, 10) + 1;
    
    % Get the coordinates relative to the pivot point. This is the key step.
    relativeRows = currentRows - pivotRow;
    relativeCols = currentCols - pivotCol;
    
    % --- Step 2: Apply Rotation ---
    % Define the 90-degree clockwise rotation matrix for [row, col] coordinates.
    rotMatrix = [0 -1; 1 0];
    
    % Assemble coordinates as a 2xN matrix where each column is [row; col].
    relativeCoords = [relativeRows; relativeCols];
    
    % Apply rotation: NewCoords = RotationMatrix * OldCoords
    newRelativeCoords = rotMatrix * relativeCoords;
    
    % --- Step 3: Calculate New Board Position and Check for Collisions ---
    % Translate the new relative coordinates back to the board's absolute grid.
    newAbsRows = round(newRelativeCoords(1,:)) + pivotRow;
    newAbsCols = round(newRelativeCoords(2,:)) + pivotCol;
    
    % Convert the new absolute [row, col] coordinates back to linear indices.
    newPieceIndices = (newAbsCols - 1) * 10 + newAbsRows;
    
    % --- Step 4: Update Board State ---
    % First, erase the current piece from the board to check for collisions.
    S.boardMatrix(S.currentPiece) = 0;
    
    % Check if the new position is valid (within bounds and not colliding with other pieces).
    isValidMove = all(newAbsRows >= 1) && all(newAbsRows <= 10) && ...
                  all(newAbsCols >= 1) && all(newAbsCols <= 20) && ...
                  ~any(S.boardMatrix(newPieceIndices));
                  
    if isValidMove
        % No collision, update to the new rotated position.
        S.currentPiece = newPieceIndices;
    end
    
    % Redraw the piece in its final position (either the new rotated one or the original).
    S.boardMatrix(S.currentPiece) = S.currentPieceID;
end

    function checkForLineClears()
        fullRows = find(all(S.boardMatrix, 1)); % Find row indices that are full
        numCleared = length(fullRows);
        
        if numCleared > 0
            % Log event and send trigger
            logEvent(sprintf('line_clear_%d', numCleared), numCleared, '');
            
            % Update score and lines
            S.currentLines = S.currentLines + numCleared;
            S.currentScore = S.currentScore + (S.pointsVector(numCleared) * S.currentLevel);
            
            % Clear rows and shift board down
            S.boardMatrix(:, fullRows) = []; % Delete full rows
            S.boardMatrix = [S.boardMatrix, zeros(10, numCleared)]; % Add empty rows at the top
            
            % Check for level up (can likely comment out...) 
            if floor(S.currentLines / S.linesForLevelUp) >= S.currentLevel
                S.currentLevel = S.currentLevel + 1;
            end
        end
    end

    function drawGameState()
        % Draws the current board state, score, and other info.
        
        % Board parameters
        boardWidth = 10;
        boardHeight = 20;
        blockSize = 30; % pixels
        boardOutlineWidth = 5;
        
        boardRectX = (windowRect(3) - boardWidth*blockSize)/2;
        boardRectY = (windowRect(4) - boardHeight*blockSize)/2;
        
        boardRect = [boardRectX, boardRectY, boardRectX + boardWidth*blockSize, boardRectY + boardHeight*blockSize];
        
        % Draw board outline
        Screen('FrameRect', window, [255 255 255], boardRect, boardOutlineWidth);
        
        % Draw the pieces on the board
        for r = 1:boardHeight
            for c = 1:boardWidth
                if S.boardMatrix(c, r)
                    % Determine which piece this block belongs to (this requires more advanced state tracking)
                    % For now, draw all blocks with a default color
                    blockColor = [128 128 128]; % Default gray
                    
                    blockX = boardRectX + (c-1)*blockSize;
                    blockY = boardRectY + (boardHeight-r)*blockSize; % Y is inverted in PTB
                    blockRect = [blockX, blockY, blockX+blockSize, blockY+blockSize];
                    Screen('FillRect', window, blockColor, blockRect);
                    Screen('FrameRect', window, [0 0 0], blockRect, 1); % Black border for blocks
                end
            end
        end
        
        % Draw Score, Level, Lines
        scoreText = sprintf('Score: %d\nLevel: %d\nLines: %d', S.currentScore, S.currentLevel, S.currentLines);
        DrawFormattedText(window, scoreText, boardRect(3) + 20, boardRect(2), [255 255 255]);
    end % draw game state function end 
end % p5 function end 