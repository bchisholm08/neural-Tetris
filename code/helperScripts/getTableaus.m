%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Returns unique tableau 'sets' for each Tetris piece.
% Tableaus for each piece have 3 conditions:
% 1. fit_reward: fits and completes line
% 2. fit_no_reward: fits but does not complete
% 3. no_fit: does not fit at all
% 
% Tableaus share a common 'garbage' condition, that being an empty tableau frame 
%-------------------------------------------------------
function tableaus = getTableaus(window, expParams)

% can use this code chunk to delete tableaus from the environment if they already
% exist. As I modify tableaus, this is an important 
    tableauPath = fullfile(pwd, 'tableaus.mat');
    % need to check one directory up as well 
if exist(tableauPath, 'file')
    delete(tableauPath);
    fprintf('Deleted existing tableau file: %s\n', tableauPath);
end

screenX = expParams.screen.width;
screenY = expParams.screen.height;
cx = expParams.screen.center(1);
cy = expParams.screen.center(2);
w = expParams.screen.width;
h = expParams.screen.height;

% pull real window and dimensions

% for building tableaus
blockSize = expParams.visual.blockSize; % single piece-section (px)
border = expParams.visual.border;     % border width (px)

tableaus = struct('piece', {}, 'condition', {}, 'board', {});

%% ==== I PIECE ==== PID: 1
tableaus(end+1) = struct('piece', 'I', 'condition', 'fit_complete', 'board', ...
   [1 0 1 1 1 1 1 1 1 1; ...
    1 0 1 1 1 1 1 1 1 1; ...
    1 0 1 1 1 1 1 1 1 1; ...
    1 0 1 1 1 1 1 1 1 1]);

tableaus(end+1) = struct('piece', 'I', 'condition', 'fit_does_not_complete', 'board', ...
   [1 1 0 0 0 0 1 1 1 1; ...
    1 0 1 1 1 1 0 1 1 1; ...
    1 1 0 1 1 1 1 0 1 1; ...
    1 1 1 1 0 1 1 1 0 1]);

tableaus(end+1) = struct('piece', 'I', 'condition', 'does_not_fit', 'board', ...
   [1 0 1 0 1 0 1 0 0 0; ...
    1 1 1 1 1 1 1 1 1 1; ...
    1 1 1 1 0 1 1 1 1 1; ...
    1 1 0 1 1 1 1 1 1 1]);

%% ==== Z PIECE ==== PID: 2
tableaus(end+1) = struct('piece', 'Z', 'condition', 'fit_complete', 'board', ...
   [1 1 1 0 0 0 1 1 1 1; ...
    1 1 1 1 0 0 1 1 1 1; ...
    1 1 0 1 1 1 1 1 0 1; ...
    1 0 1 1 1 0 1 1 1 1]);

tableaus(end+1) = struct('piece', 'Z', 'condition', 'fit_does_not_complete', 'board', ...
   [1 1 1 0 0 0 1 1 1 1; ...
    1 0 1 1 0 0 1 0 1 1; ...
    1 1 1 1 0 1 1 1 0 1; ...
    1 1 1 1 1 1 1 1 1 1]);

tableaus(end+1) = struct('piece', 'Z', 'condition', 'does_not_fit', 'board', ...
   [0 0 1 1 1 0 1 0 1 0; ...
    1 1 1 1 1 0 1 1 1 1; ...
    1 0 1 0 1 1 1 0 1 1; ...
    1 1 1 1 1 1 1 1 1 1]);

%% ==== O PIECE ==== PID: 3
tableaus(end+1) = struct('piece', 'O', 'condition', 'fit_complete', 'board', ...
   [1 0 0 1 1 1 1 1 1 1; ...
    1 0 0 1 1 1 1 0 1 1; ...
    1 1 1 0 1 0 1 1 1 1; ...
    1 1 1 1 0 1 1 1 0 1]);

tableaus(end+1) = struct('piece', 'O', 'condition', 'fit_does_not_complete', 'board', ...
   [0 0 1 1 1 1 0 0 1 0; ...
    1 1 1 1 0 1 0 0 1 1; ...
    1 1 0 1 1 1 1 1 1 1; ...
    1 1 1 1 1 1 1 1 0 1]);

tableaus(end+1) = struct('piece', 'O', 'condition', 'does_not_fit', 'board', ...
   [1 0 1 0 1 0 0 0 1 0; ...
    1 1 0 1 1 0 1 0 1 1; ...
    1 1 0 1 1 1 0 1 1 1; ...
    1 1 1 1 0 1 1 1 1 1]);

%% ==== S PIECE ==== PID: 4
tableaus(end+1) = struct('piece', 'S', 'condition', 'fit_complete', 'board', ...
   [1 1 0 0 0 1 1 1 1 1; ...
    1 1 0 0 1 1 1 1 1 1; ...
    1 1 1 1 1 1 1 1 0 1; ...
    1 1 1 1 1 1 0 1 1 1]);

tableaus(end+1) = struct('piece', 'S', 'condition', 'fit_does_not_complete', 'board', ...
   [1 1 0 0 0 1 1 1 0 1; ...
    1 1 0 0 1 1 0 1 0 1; ...
    1 1 1 1 1 0 1 1 1 1; ...
    1 1 1 0 1 1 1 1 1 1]);

tableaus(end+1) = struct('piece', 'S', 'condition', 'does_not_fit', 'board', ...
   [0 0 1 0 1 0 0 1 0 0; ...
    1 1 1 0 1 0 1 1 1 1; ...
    1 0 1 1 1 1 1 1 1 1; ...
    1 1 1 1 1 1 1 1 1 1]);

%% ==== J PIECE ==== PID: 5
tableaus(end+1) = struct('piece', 'J', 'condition', 'fit_complete', 'board', ...
   [1 1 1 1 0 0 0 1 1 1; ...
    1 1 1 1 1 1 0 1 1 1; ...
    1 1 0 1 1 1 1 1 1 0; ...
    1 1 1 1 0 1 1 1 1 1]);

tableaus(end+1) = struct('piece', 'J', 'condition', 'fit_does_not_complete', 'board', ...
   [1 1 1 0 0 1 0 0 1 0; ...
    1 1 1 1 1 0 1 1 1 1; ...
    1 1 0 1 1 0 1 0 1 1; ...
    1 1 1 1 1 1 1 1 1 0]);

tableaus(end+1) = struct('piece', 'J', 'condition', 'does_not_fit', 'board', ...
   [0 1 0 1 0 1 0 1 0 0; ...
    1 1 0 1 1 0 1 1 1 1; ...
    1 1 0 1 1 1 0 1 0 1; ...
    1 1 1 1 1 1 1 1 1 1]);

%% ==== L PIECE ==== PID: 6
tableaus(end+1) = struct('piece', 'L', 'condition', 'fit_complete', 'board', ...
   [1 1 1 1 0 0 0 1 1 1; ...
    1 1 1 1 0 1 1 1 1 1; ...
    1 1 0 1 1 1 0 1 0 1; ...
    1 1 1 1 1 1 1 1 1 1]);

tableaus(end+1) = struct('piece', 'L', 'condition', 'fit_does_not_complete', 'board', ...
   [1 1 0 0 1 1 1 0 0 0; ...
    1 1 0 0 0 1 1 1 1 1; ...
    1 1 1 1 1 1 0 1 1 1; ...
    1 1 1 1 1 1 1 1 1 1]);

tableaus(end+1) = struct('piece', 'L', 'condition', 'does_not_fit', 'board', ...
   [1 0 0 0 1 0 0 0 1 0; ...
    1 1 1 0 1 1 1 1 1 1; ...
    1 0 1 1 1 0 1 1 0 1; ...
    1 1 1 1 1 1 1 1 1 1]);

%% ==== T PIECE ==== PID: 7
tableaus(end+1) = struct('piece', 'T', 'condition', 'fit_complete', 'board', ...
   [1 1 1 0 0 0 1 1 1 1; 
    1 1 1 1 0 1 1 1 1 1; ...
    1 1 1 1 1 1 1 0 1 1; ...
    1 0 0 0 1 1 1 1 1 1]);

tableaus(end+1) = struct('piece', 'T', 'condition', 'fit_does_not_complete', 'board', ...
   [1 0 0 1 1 1 1 0 0 1; ...
    1 1 1 1 0 1 1 1 0 1; ...
    1 1 1 0 1 1 0 1 1 1; ...
    1 1 1 1 1 1 1 1 1 1]);

tableaus(end+1) = struct('piece', 'T', 'condition', 'does_not_fit', 'board', ...
   [0 0 1 0 0 1 0 0 1 0; ...
    1 1 1 1 1 1 1 1 1 1; ...
    1 1 0 1 0 1 1 0 1 1; ...
    1 1 1 1 1 0 1 1 1 1]);
%================================
%================================
%% create textures to pass to expParams
for t = 1:length(tableaus)
    board = tableaus(t).board;
    [rows, cols] = size(board);

    padding = 5;  % space between pieces and border
    imgHeight = rows * blockSize + 2 * padding;
    imgWidth  = cols * blockSize + 2 * padding;
   % =============== FIX ME CHUNK
    % build new img matrix for blocks + white border
img = zeros(imgHeight, imgWidth, 3, 'uint8');

blockCol = reshape(uint8(expParams.colors.white),1,1,3);  
% blockCol = expParams.colors.white;  causes errors no uint8
for r = 1:rows
    for c = 1:cols
        if board(r,c) == 1
            rowStart = padding + (r-1)*blockSize + 1;
            colStart = padding + (c-1)*blockSize + 1;
            rowPixels = rowStart+border : rowStart+blockSize-border;
            colPixels = colStart+border : colStart+blockSize-border;
            img(rowPixels, colPixels, :) = repmat(blockCol, numel(rowPixels), numel(colPixels));
        end
    end
end

% draw 3-sided border 
borderGray = reshape(uint8(expParams.colors.gray),1,1,3);          % white [255 255 255] 
img(end-border+1:end,     :, :) = repmat(borderGray, border,    imgWidth);  % bottom
img(:, 1:border,          :) = repmat(borderGray, imgHeight,  border);    % left
img(:, end-border+1:end,  :) = repmat(borderGray, imgHeight,  border);    % right

% make PTB texture
tex = Screen('MakeTexture', window, img);

    texRect = [0 0 size(img, 2) size(img, 1)];
    tableauRect = CenterRectOnPoint(texRect, screenX/2, screenY - size(img,1)/2 - 40);

    tableaus(t).tex = tex;
    tableaus(t).rect = tableauRect;
end

%% add garbage tableau to each piece
pieceNames = {'I', 'Z', 'O', 'S', 'J', 'L', 'T'};
garbageBoard = zeros(4, 10);  % empty board 

for i = 1:length(pieceNames)
    tableaus(end+1) = struct( ...
        'piece', pieceNames{i}, ...
        'condition', 'garbage', ...
        'board', garbageBoard, ...
        'tex', [], ...
        'rect', [] ...
        );
end

newStartIdx = length(tableaus) - numel(pieceNames) + 1;
for t = newStartIdx:length(tableaus)
    rows = size(tableaus(t).board,1);
    cols = size(tableaus(t).board,2);

    padding = 5;
    imgH = rows * blockSize + 2*padding;
    imgW = cols * blockSize + 2*padding;
    img  = zeros(imgH, imgW, 3);  % black

% exclude top edge 
% bottom 
img(end-border+1:end, :, :)      = 1;
% left edge
img(:, 1:border,     :)          = 1;
% right edge
img(:, end-border+1:end, :)      = 1;

    % make texture
    tex    = Screen('MakeTexture', window, uint8(img*255)); % coding to white? 
    texRect = [0 0 imgW imgH];
    tableauRect = CenterRectOnPoint(texRect, cx, screenY - imgH/2 - 40);

    tableaus(t).tex  = tex;
    tableaus(t).rect = tableauRect;
end
% save tableaus to environment
save('tableaus.mat', 'tableaus');
end