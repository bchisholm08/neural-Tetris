function pieces = getTetrino(params)
    % Generates tetrinos based on input & experiment parameters 
    shapes = {
        [1 1 1 1],        % I (4x1)
        [1 1; 1 1],       % O (2x2)
        [1 1 1; 0 1 0],   % T (3x3)
        [0 1 1; 1 1 0],   % S (3x3)
        [1 1 0; 0 1 1],   % Z (3x3)
        [1 0 0; 1 1 1],   % J (3x3)
        [0 0 1; 1 1 1]    % L (3x3)
    };
    
    pieces = struct('tex', {}, 'rect', {});
    blockSize = 40; % Each block is 40x40 pixels 
    border = 2;     % pixel border width 
    
    for p = 1:length(shapes)   
        shape = shapes{p};
        [height, width] = size(shape);
        
        % Initialize image with background color (black)
        img = zeros(height*blockSize, width*blockSize, 3);
        
        for row = 1:height
            for col = 1:width
                if shape(row, col) == 1
                    % Calculate block position
                    rowStart = (row-1)*blockSize + 1;
                    colStart = (col-1)*blockSize + 1;
                    
                    % Fill inner region (excluding border)
                    innerRow = rowStart + border : rowStart + blockSize - border;
                    innerCol = colStart + border : colStart + blockSize - border;
                    
                    % Apply piece color
                    color = reshape(params.colors.piece, 1, 1, 3);
                    img(innerRow, innerCol, :) = repmat(color, length(innerRow), length(innerCol), 1);
                end
            end
        end
        
        % Create texture and store dimensions
        pieces(p).tex = Screen('MakeTexture', params.window, img);
        pieces(p).rect = [0 0 width*blockSize height*blockSize]; % [x1 y1 x2 y2]
    end
end