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
    
    pieces = struct('tex', {});
    % editing pixel size manually 
    blockSize = 40; % Each block is 30x30 pixels 
    border = 2;     % 1-pixel border
    
    for p = 1:length(shapes)
        shape = shapes{p};
        [height, width] = size(shape);
        
        % Initialize image with background color (black)
        img = zeros(height*blockSize, width*blockSize, 3);
        
        for rows = 1:height
            for cols = 1:width
                if shape(rows, cols) == 1
                    % Calculate block position
                    rowStart = (rows-1)*blockSize + 1;
                    colStart = (cols-1)*blockSize + 1;
                    
                    % Fill inner region (excluding border) with piece color
                    innerRow = rowStart + border : rowStart + blockSize - border;
                    innerCol = colStart + border : colStart + blockSize - border;
                    
                    % Ensure the color vector is a 1x3 vector
                    color = reshape(params.colors.piece, 1, 1, 3);
                    
                    % Assign the color to the inner region
                    img(innerRow, innerCol, :) = repmat(color, length(innerRow), length(innerCol), 1);
                end
            end
        end
        
        % Create texture
        pieces(p).tex = Screen('MakeTexture', params.window, img);
    end
end