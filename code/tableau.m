%% Generate and save tableaus.mat
% Define board dimensions
board_height = 25; % Visible rows
board_width = 10;

% Initialize tableaus struct
tableaus = struct(...
    'piece', {},...      % Piece type (e.g., 'I', 'O')
    'board', {},...      % 25x10 matrix (0 = empty, 1 = filled)
    'condition', {}...   % 'fit_reward', 'fit', 'no_fit', 'garbage'
);

%%
% ------------- I-Piece (Vertical Line) -------------
piece = 'I';

% Fit + Reward: Completes a line when placed vertically
board = zeros(board_height, board_width);
board(20:23, 4:7) = 1;       % Partially filled rows
board(22:25, 5) = 0;         % Vertical slot for I-piece (completes line)
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit_reward');

% Fit (No Reward): Fits vertically but doesn’t complete a line
board = zeros(board_height, board_width);
board(18:21, 5) = 1;         % Blocks above the slot
board(22:25, 5) = 0;         % Vertical slot (no line completion)
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit');

% Doesn’t Fit: Partially blocked vertical slot
board = zeros(board_height, board_width);
board(22:25, 5) = 0;         % Vertical slot
board(24, 5) = 1;            % Block at the bottom
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'no_fit');

% Garbage: No valid placement
board = ones(board_height, board_width); % Fully filled board
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'garbage');

%%
% ------------- O-Piece (2x2 Square) -------------
piece = 'O';

% Fit + Reward: Completes a line when placed
board = zeros(board_height, board_width);
board(20:23, 3:6) = 1;       % Partially filled rows
board(22:23, 4:5) = 0;       % 2x2 hole for O-piece (completes line)
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit_reward');

% Fit (No Reward): Fits but doesn’t complete a line
board = zeros(board_height, board_width);
board(22:23, 4:5) = 0;       % 2x2 hole (no line completion)
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit');

% Doesn’t Fit: Partially blocked 2x2 area
board = zeros(board_height, board_width);
board(22:23, 4:5) = 0;       % 2x2 hole
board(22, 4) = 1;            % Block in the hole
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'no_fit');

% Garbage: No valid placement
board = ones(board_height, board_width);
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'garbage');

%%
% ------------- T-Piece (T-Shaped) -------------
piece = 'T';

% Fit + Reward: Completes a line
board = zeros(board_height, board_width);
board(20:23, 4:6) = 1;       % Partially filled rows
board(22:24, 5) = 0;         % Vertical slot for T-piece
board(22, 4:6) = 0;          % Horizontal slot
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit_reward');

% Fit (No Reward): Fits but no line completion
board = zeros(board_height, board_width);
board(22:24, 5) = 0;         % Vertical slot
board(22, 4:6) = 0;          % Horizontal slot
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit');

% Doesn’t Fit: Blocked center
board = zeros(board_height, board_width);
board(22:24, 5) = 0;         % Vertical slot
board(22, 4:6) = 0;          % Horizontal slot
board(23, 5) = 1;            % Blocked center
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'no_fit');

% Garbage: Fully filled board
board = ones(board_height, board_width);
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'garbage');

%%
% ------------- S/Z-Pieces (Mirrored) -------------
% Repeat the same logic for S and Z pieces with mirrored configurations
% ...

%%
% Save all tableaus
save('tableaus.mat', 'tableaus');