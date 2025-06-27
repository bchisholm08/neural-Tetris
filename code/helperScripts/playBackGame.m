function playBackGame(snapshotFile, window, windowRect)

    % FIXME add in expParam window/screen vars 

    % Load snapshot struct from .mat
    data = load(snapshotFile);
    snapshots = data.boardSnapBuffer;  % or change field name accordingly

    % Extract timing
    times = [snapshots.timestamp];
    delays = [0, diff(times)];

    % Set up screen
    blockSize = 30;
    boardX = (windowRect(3) - 10*blockSize)/2;
    boardY = (windowRect(4) - 20*blockSize)/2;

    for k = 1:length(snapshots)
        board = snapshots(k).board;

        % Draw board
        Screen('FillRect', window, [0 0 0]);  % Clear
        for r = 1:20
            for c = 1:10
                if board(c, r)
                    x = boardX + (c-1)*blockSize;
                    y = boardY + (20 - r)*blockSize;
                    blockRect = [x, y, x+blockSize, y+blockSize];
                    Screen('FillRect', window, [255 255 255], blockRect); % color: white
                end
            end
        end
        Screen('Flip', window);

        % Wait for frame delay
        WaitSecs(delays(k));
    end
end
