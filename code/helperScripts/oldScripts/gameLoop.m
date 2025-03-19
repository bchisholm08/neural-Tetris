function [finalScore, finalLines, saveLog] = gameLoop(tetrisParams, handleEEG, handlePupils, saveLog)
% audio settings are being glitchy on remote desktop. This try catch
% bypasses audio set up and lets the game loop proceed without crashing 
try
        InitializePsychSound(1);
        pahandle = PsychPortAudio('Open', [], 1, 1, 44100, 2);
        beepSound = MakeBeep(440, 0.1); % A 440 Hz, 0.1 sec long
        PsychPortAudio('FillBuffer', pahandle, [beepSound; beepSound]);
    catch ME
        warning('PsychPortAudio failed to initialize: %s', ME.message);
        pahandle = []; % Set to empty so we can check before using it
    end
    % Prepare audio for feedback
    % InitializePsychSound(1);
    % pahandle = PsychPortAudio('Open', [], 1, 1, 44100, 2);
    % beepSound = MakeBeep(440, 0.1); % A 440 Hz beep, 0.1 sec
    % PsychPortAudio('FillBuffer', pahandle, [beepSound; beepSound]);
    
    while ~tetrisParams.gameOver
        % =========== 1. Handle user input ===========
        [leftPressed, rightPressed, downPressed, rotatePressed, ...
            quitPressed, pausePressed] = getInput();
        
        if quitPressed
            tetrisParams.gameOver = true;
            % Log "quit" event
            saveLog(end+1,:) = {GetSecs, 'QUIT_PRESSED', ''};
        end
        
        if pausePressed
            % Call the pause screen
            pauseGame(tetrisParams.windowPtr);
            % (You might log this event as well.)
            saveLog(end+1,:) = {GetSecs, 'GAME_PAUSE', ''};
        end
        
        % Move left
        if leftPressed
            tetrisParams = TetrisMoveBlock(tetrisParams, 0, -1);
        end
        % Move right
        if rightPressed
            tetrisParams = TetrisMoveBlock(tetrisParams, 0, 1);
        end
        % Soft drop
        if downPressed
            oldRow = tetrisParams.currentRow;
            tetrisParams = generateBlock(tetrisParams, 1, 0);
            if tetrisParams.currentRow ~= oldRow
                % Log a "piece dropped" event
                saveLog(end+1,:) = {GetSecs, 'PIECE_DROP', 'manual'};
                % EEG trigger example (placeholder)
                % sendEvent(eegHandle, 'PIECE_DROP');
            end
        end
        % Rotate
        if rotatePressed
            rotatedBlock = rot90(tetrisParams.currentBlock);
            % Check collision if we apply the rotation
            if ~TetrisCheckCollision(tetrisParams.board, rotatedBlock, ...
                                     tetrisParams.currentRow, tetrisParams.currentCol)
                tetrisParams.currentBlock = rotatedBlock;
                % Log rotate event
                saveLog(end+1,:) = {GetSecs, 'ROTATE', ''};
            end
        end

        % =========== 2. Automatic drop over time ===========
        currentTime = GetSecs;
        if (currentTime - tetrisParams.lastDropTime) > tetrisParams.dropInterval
            oldRow = tetrisParams.currentRow;
        [tetrisParams.currentBlock, tetrisParams.currentColor] = generateBlock(tetrisParams.useRandomRotation);
            tetrisParams.lastDropTime = currentTime;

            if tetrisParams.currentRow ~= oldRow
                % Log automatic drop
                saveLog(end+1,:) = {GetSecs, 'PIECE_DROP', 'auto'};
                % EEG trigger example (placeholder)
                % sendEvent(eegHandle, 'BLOCK_DROP');
                % Pupillometry read example
                % pupillData = readPupilData(tobiiHandle);
            end
        end

        % =========== 3. Draw everything ===========
[tetrisParams.currentBlock, tetrisParams.currentColor] = generateBlock(tetrisParams.useRandomRotation);

        % =========== 4. Check for game over ===========
        if tetrisParams.gameOver
            DrawFormattedText(tetrisParams.windowPtr, ...
                sprintf('Game Over\nScore: %d\nLines Cleared: %d', ...
                tetrisParams.score, tetrisParams.linesCleared), ...
                'center', 'center', [255 0 0]);
            Screen('Flip', tetrisParams.windowPtr);
            WaitSecs(2);
            break;
        end
        
        % =========== 5. Check for line clears after placing block ===========
        % We do that in TetrisPlaceBlock. But let's see if lines were cleared:
        % If lines are cleared, TetrisPlaceBlock updates tetrisParams.score & linesCleared.
        % Let's detect that event inside TetrisPlaceBlock or here:
        %   (We've chosen inside TetrisPlaceBlock so it’s updated immediately.)

        % CPU-friendly pause
        WaitSecs(0.01);
        
        % If lines have changed, you can log that event in TetrisPlaceBlock or here.
        % We'll do it in TetrisPlaceBlock for immediate logging.
    end
    
    % Close audio
    PsychPortAudio('Close', pahandle);

    finalScore = tetrisParams.score;
    finalLines = tetrisParams.linesCleared;
end
