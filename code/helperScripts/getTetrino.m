%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Returns textures of the seven Tetris pieces we use 
%                            
%-------------------------------------------------------
function pieces = getTetrino(expParams)
    % PIECE IDS
    % I = 1, Z = 2, O = 3, S = 4, J = 5, L = 6, T = 7
    shapes = {
        [1 1 1 1];               % I (pID = 1)
        [1 1 0; 0 1 1];          % Z (pID = 2)
        [1 1; 1 1];              % O (pID = 3)
        [0 1 1; 1 1 0];          % S (pID = 4)
        [1 0 0; 1 1 1];          % J (pID = 5)
        [0 0 1; 1 1 1];          % L (pID = 6)
        [1 1 1; 0 1 0];          % T (pID = 7)
    };

    pieceNames = {'I', 'Z', 'O', 'S', 'J', 'L', 'T'};

    % pieces = struct('tex', {}, 'rect', {}, 'pID', {}, 'name', {});
    pieces = struct('tex', {}, 'rect', {}, 'pID', {}, 'name', {}, 'shape', {}, 'coords', {}, 'pivot', {});
    blockSize = expParams.visual.blockSize; 
    border = expParams.visual.border;     % border width (px)

    for p = 1:length(shapes)
        shape = shapes{p};
        [height, width] = size(shape);

        % store the raw shape matrix
        pieces(p).shape = shape;

        % precompute the [row,col] of every filled block
        [rIdx, cIdx]   = find(shape);
        pieces(p).coords = [rIdx, cIdx];

        % define a rotation pivot (you can adjust if you want a different pivot)
        pieces(p).pivot = ceil([height, width] / 2);

        % image with black background color
        img = zeros(height * blockSize, width * blockSize, 3, 'uint8');

        for row = 1:height
            for col = 1:width
                if shape(row, col) == 1
                    rowStart = (row - 1) * blockSize + 1;
                    colStart = (col - 1) * blockSize + 1;

                    innerRow = rowStart + border : rowStart + blockSize - border;
                    innerCol = colStart + border : colStart + blockSize - border;

                    color = reshape(uint8(expParams.colors.white), 1, 1, 3);

                    img(innerRow, innerCol, :) = repmat(color, length(innerRow), length(innerCol), 1);
                end
            end
        end
        
        pieces(p).shape  = shape;                          % matrix
        [r,c]            = find(shape);
        pieces(p).coords = [r, c];                         % 4×2 list
        pieces(p).pivot  = ceil(size(shape)/2);            % center of shape

        pieces(p).tex = Screen('MakeTexture', expParams.screen.window, img);
        pieces(p).rect = [0 0 width * blockSize height * blockSize];
        pieces(p).pID = p;                % define piece ID
        pieces(p).name = pieceNames{p};   % char  label
    end
end
