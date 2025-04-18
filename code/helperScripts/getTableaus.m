function tableaus = getTableaus(window,expParams)
    % Returns tableaus for each piece under 3 conditions:
    % 1. fit_reward: fits and completes line
    % 2. fit_no_reward: fits but does not complete
    % 3. no_fit: does not fit at all

    %{
can use this code chunk to delete tableaus from the environment if they already
exist. 
    tableauPath = fullfile(pwd, 'tableaus.mat');
    if exist(tableauPath, 'file')
        delete(tableauPath);
        fprintf('Deleted existing tableau file: %s\n', tableauPath);
    end
    %} 
    screenX = expParams.screen.width;
    screenY = expParams.screen.height;
    % for building tableaus     
    blockSize = 50; % single piece-section (px) 
    border = 2;     % border width (px)

    tableaus = struct('piece', {}, 'condition', {}, 'board', {});

    %% ==== I PIECE ==== 1 1 1 1 1 1 1 1 1 1 
    tableaus(end+1) = struct('piece', 'I', 'condition', 'fit_reward', ...
        'board', [0 0 0 0 1 1 1 1 0 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);
    tableaus(end+1) = struct('piece', 'I', 'condition', 'fit_no_reward', ...
        'board', [0 1 0 0 0 1 0 0 0 0; 0 1 0 0 0 1 0 0 0 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);
    tableaus(end+1) = struct('piece', 'I', 'condition', 'no_fit', ...
        'board', [1 0 1 0 0 0 1 0 0 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);

    %% ==== Z PIECE ====
    tableaus(end+1) = struct('piece', 'Z', 'condition', 'fit_reward', ...
        'board', [0 1 1 0 1 1 0 0 0 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);
    tableaus(end+1) = struct('piece', 'Z', 'condition', 'fit_no_reward', ...
        'board', [0 0 1 1 0 1 1 0 0 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);
    tableaus(end+1) = struct('piece', 'Z', 'condition', 'no_fit', ...
        'board', [0 1 0 0 1 0 0 0 0 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);

    %% ==== O PIECE ====
    tableaus(end+1) = struct('piece', 'O', 'condition', 'fit_reward', ...
        'board', [0 0 0 1 1 1 1 0 0 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);
    tableaus(end+1) = struct('piece', 'O', 'condition', 'fit_no_reward', ...
        'board', [0 0 1 1 1 1 0 0 0 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);
    tableaus(end+1) = struct('piece', 'O', 'condition', 'no_fit', ...
        'board', [1 0 1 0 1 0 1 0 0 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);

    %% ==== S PIECE ====
    tableaus(end+1) = struct('piece', 'S', 'condition', 'fit_reward', ...
        'board', [1 1 0 0 0 1 1 0 0 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);
    tableaus(end+1) = struct('piece', 'S', 'condition', 'fit_no_reward', ...
        'board', [1 0 0 1 1 0 0 1 1 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);
    tableaus(end+1) = struct('piece', 'S', 'condition', 'no_fit', ...
        'board', [0 0 1 0 0 1 0 0 0 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);

    %% ==== J PIECE ====
    tableaus(end+1) = struct('piece', 'J', 'condition', 'fit_reward', ...
        'board', [0 0 1 0 0 0 1 1 1 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);
    tableaus(end+1) = struct('piece', 'J', 'condition', 'fit_no_reward', ...
        'board', [1 1 1 0 0 1 0 0 1 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);
    tableaus(end+1) = struct('piece', 'J', 'condition', 'no_fit', ...
        'board', [0 0 0 1 0 0 0 1 0 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);

    %% ==== L PIECE ====
    tableaus(end+1) = struct('piece', 'L', 'condition', 'fit_reward', ...
        'board', [0 0 1 1 1 0 0 0 1 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);
    tableaus(end+1) = struct('piece', 'L', 'condition', 'fit_no_reward', ...
        'board', [0 0 1 1 0 0 1 1 0 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);
    tableaus(end+1) = struct('piece', 'L', 'condition', 'no_fit', ...
        'board', [1 0 0 0 1 0 0 0 1 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);

    %% ==== T PIECE ====
    tableaus(end+1) = struct('piece', 'T', 'condition', 'fit_reward', ...
        'board', [0 1 1 1 0 1 0 0 0 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);
    tableaus(end+1) = struct('piece', 'T', 'condition', 'fit_no_reward', ...
        'board', [1 1 1 0 1 1 1 0 0 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);
    tableaus(end+1) = struct('piece', 'T', 'condition', 'no_fit', ...
        'board', [0 0 1 0 0 1 0 0 1 0; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1]);

for t = 1:length(tableaus)
        board = tableaus(t).board;
        [rows, cols] = size(board);

        img = zeros(rows * blockSize, cols * blockSize, 3);

        for r = 1:rows
            for c = 1:cols
                if board(r, c) == 1
                    rowStart = (r - 1) * blockSize + 1;
                    colStart = (c - 1) * blockSize + 1;

                    rowPixels = rowStart + border : rowStart + blockSize - border;
                    colPixels = colStart + border : colStart + blockSize - border;

                    color = reshape(expParams.colors.piece, 1, 1, 3);
                    img(rowPixels, colPixels, :) = repmat(color, length(rowPixels), length(colPixels), 1);
                end
            end
        end

        tex = Screen('MakeTexture', window, img * 255);
        texRect = [0 0 size(img, 2) size(img, 1)];
        tableauRect = CenterRectOnPointd(texRect, screenX/2, screenY - size(img,1)/2 - 40);

        tableaus(t).tex = tex;
        tableaus(t).rect = tableauRect;
    end

    % add garbage tableau to each of the 7 pieces 
    pieceNames = {'I', 'Z', 'O', 'S', 'J', 'L', 'T'};
    garbageBoard = ones(4, 10);  % fully filled board

    for i = 1:length(pieceNames)
        tableaus(end+1) = struct( ...
            'piece', pieceNames{i}, ...
            'condition', 'garbage', ...
            'board', garbageBoard, ...
            'tex', [], ...
            'rect', [] ...
        );
    end

    % get PTB garb textures 
    newStartIdx = length(tableaus) - length(pieceNames) + 1;
    for t = newStartIdx:length(tableaus)
        board = tableaus(t).board;
        [rows, cols] = size(board);

        img = zeros(rows * blockSize, cols * blockSize, 3);

        for r = 1:rows
            for c = 1:cols
                if board(r, c) == 1
                    rowStart = (r - 1) * blockSize + 1;
                    colStart = (c - 1) * blockSize + 1;

                    rowPixels = rowStart + border : rowStart + blockSize - border;
                    colPixels = colStart + border : colStart + blockSize - border;

                    color = reshape(expParams.colors.piece, 1, 1, 3);
                    img(rowPixels, colPixels, :) = repmat(color, length(rowPixels), length(colPixels), 1);
                end
            end
        end

        tex = Screen('MakeTexture', window, img * 255);
        texRect = [0 0 size(img, 2) size(img, 1)];
        tableauRect = CenterRectOnPointd(texRect, screenX/2, screenY - size(img,1)/2 - 40);

        tableaus(t).tex = tex;
        tableaus(t).rect = tableauRect;
    end

% save 
    save('tableaus.mat', 'tableaus');
end