function tetrisParams = tetrisInitialize(windowPtr, windowRect)
    % TETRISINITIALIZE Sets up the game state and parameters
    
    tetrisParams.windowPtr = windowPtr;
    tetrisParams.windowRect = windowRect;
    
    tetrisParams.boardRows = 20;
    tetrisParams.boardCols = 10;
    tetrisParams.blockSize = 30;  % in pixels
    
    % Board: store as a 2D matrix of values, 0 = empty
    tetrisParams.board = zeros(tetrisParams.boardRows, tetrisParams.boardCols);
    

    tetrisParams.blockMonoChrome = [ 
    211 211 211;    
    ];

    % Colors, speeds, etc.
    tetrisParams.blockColors = [
        255 0   0;   % Red
        0   255 0;   % Green
        0   0   255; % Blue
        255 255 0;   % Yellow
        255 128 0;   % Orange
        128 0   128; % Purple
        0   255 255; % Cyan
    ];
    
    tetrisParams.dropInterval = 0.8;  % seconds per drop
    tetrisParams.lastDropTime = GetSecs;

    % Current piece storage
    tetrisParams.currentBlock = [];
    tetrisParams.currentRow = 1;
    tetrisParams.currentCol = floor(tetrisParams.boardCols / 2);
    tetrisParams.currentColor = 1;  % placeholder
    tetrisParams.gameOver = false;
    tetrisParams.score = 0;
    tetrisParams.linesCleared = 0;
    
    % (New) random rotation toggle
    tetrisParams.useRandomRotation = true;
    
    % Generate initial block
    [tetrisParams.currentBlock, tetrisParams.currentColor] = generateBlock(tetrisParams.useRandomRotation);
end
