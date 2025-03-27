function tetrisParams = placeBlock(tetrisParams)
    block = tetrisParams.currentBlock;
    rowPos = tetrisParams.currentRow;
    colPos = tetrisParams.currentCol;
    colorIndex = tetrisParams.currentColor;

    [blockRows, blockCols] = size(block);
    for r = 1:blockRows
        for c = 1:blockCols
            if block(r, c) == 1
                boardRow = rowPos + (r - 1);
                boardCol = colPos + (c - 1);
                tetrisParams.board(boardRow, boardCol) = colorIndex;
            end
        end
    end

    oldScore = tetrisParams.score;
    oldLines = tetrisParams.linesCleared;

    [tetrisParams.board, linesCleared] = TetrisClearLines(tetrisParams.board);
    tetrisParams.linesCleared = tetrisParams.linesCleared + linesCleared;
    tetrisParams.score = tetrisParams.score + linesCleared * 100;

    % If linesCleared > 0, you could place an event in eventLog, or handle it outside
    if linesCleared > 0
        % Basic beep or audio feedback can be triggered here, or outside
        % e.g. beep; or advanced: PsychPortAudio call
    end
end
