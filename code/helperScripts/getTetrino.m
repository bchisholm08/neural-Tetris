%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Returns textures of the seven Tetris pieces we use 
%                            
%-------------------------------------------------------
function pieces = getTetrino(params)
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

    pieces = struct('tex', {}, 'rect', {}, 'pID', {}, 'name', {});
    blockSize = 50; % single piece-section (px) 
    border = 2;     % border width (px)

    for p = 1:length(shapes)
        shape = shapes{p};
        [height, width] = size(shape);

        % image with black background color
        img = zeros(height * blockSize, width * blockSize, 3);

        for row = 1:height
            for col = 1:width
                if shape(row, col) == 1
                    rowStart = (row - 1) * blockSize + 1;
                    colStart = (col - 1) * blockSize + 1;

                    innerRow = rowStart + border : rowStart + blockSize - border;
                    innerCol = colStart + border : colStart + blockSize - border;

                    color = reshape(params.colors.piece, 1, 1, 3);
                    img(innerRow, innerCol, :) = repmat(color, length(innerRow), length(innerCol), 1);
                end
            end
        end

        pieces(p).tex = Screen('MakeTexture', params.window, img);
        pieces(p).rect = [0 0 width * blockSize height * blockSize];
        pieces(p).pID = p;                % define piece ID
        pieces(p).name = pieceNames{p};   % char  label
    end
end
