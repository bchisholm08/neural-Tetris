%{
PIECE # KEY:
I Piece = 1 
Z Piece = 2 
O Piece = 3 
S Piece = 4 
J Piece = 5 
L Piece = 6
T Piece = 7
%} 

% Define tableau dimensions
bHeight = 15; % Visible rows
bWidth = 10;

%{
Each piece needs ONE corresponding tableau that is its MATCH.
Every piece also needs an associated NON-MATCH tableau. If I'm clever maybe
I can just use combinations of the other tableaus somehow. 

In the 4-AFC condition, each piece needs the matching tableau,
non-match (possible move exists but is not optimal), and a garbage where
the piece does not fit at all. 

Template board w/ zeroes. Two "floor rows" that stay  
board = [
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
0     0     0     0     0     0     0     0     0     0
1     1     1     1     1     1     1     1     1     1
1     1     1     1     1     1     1     1     1     1
];

%} 
% Define tableau dimensions
bHeight = 15; % Visible rows
bWidth = 10;

% Initialize tableaus structure
tableaus = struct(...
    'piece', {},...
    'board', {},...
    'condition', {}...
);

%% ------------- I-Piece -------------
piece = 'I';
% Fit + Reward
board = ones(bHeight, bWidth);
board(10:13, 3) = 0;    % Vertical slot for I-Piece
board(14:15, :) = 1;    % Floor
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit_reward');

% Fit (No Reward)
board = zeros(bHeight, bWidth);
board(18:21, 5) = 1;   % Blocks above slot
board(22:25, 5) = 0;   % Vertical slot (no line clear)
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit');

% Doesn’t Fit
board = ones(bHeight, bWidth);
board(10:13, 3) = 0;   % Vertical slot
board(13, 3) = 1;      % Block at the bottom
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'no_fit');

% Garbage
board = ones(bHeight, bWidth);
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'garbage');

%% ------------- Z-Piece -------------
piece = 'Z';
% Fit + Reward (staggered hole)
board = ones(bHeight, bWidth);
board(13, 5:6) = 0;    % Top row of Z
board(14, 6:7) = 0;    % Bottom row of Z
board(15, :) = 1;      % Floor
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit_reward');

% Fit (No Reward)
board = ones(bHeight, bWidth);
board(8, 3:4) = 0;     % Higher staggered hole
board(9, 4:5) = 0;
board(10:15, :) = 1;   % Support below
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit');

% Doesn’t Fit
board = ones(bHeight, bWidth);
board(13, 5:6) = 0;
board(14, 6:7) = 0;
board(13, 5) = 1;      % Block one cell
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'no_fit');

% Garbage
board = ones(bHeight, bWidth);
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'garbage');

%% ------------- O-Piece -------------
piece = 'O';
% Fit + Reward (2x2 hole)
board = ones(bHeight, bWidth);
board(13:14, 5:6) = 0; % 2x2 hole
board(15, :) = 1;      % Floor
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit_reward');

% Fit (No Reward)
board = ones(bHeight, bWidth);
board(8:9, 4:5) = 0;  % Higher 2x2 hole
board(10:15, :) = 1;   % Support below
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit');

% Doesn’t Fit
board = ones(bHeight, bWidth);
board(13:14, 5:6) = 0;
board(13, 5) = 1;      % Block one corner
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'no_fit');

% Garbage
board = ones(bHeight, bWidth);
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'garbage');

%% ------------- S-Piece -------------
piece = 'S';
% Fit + Reward (mirror of Z)
board = ones(bHeight, bWidth);
board(13, 6:7) = 0;    % Top row of S
board(14, 5:6) = 0;    % Bottom row of S
board(15, :) = 1;      % Floor
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit_reward');

% Fit (No Reward)
board = ones(bHeight, bWidth);
board(8, 4:5) = 0;     % Higher staggered hole
board(9, 3:4) = 0;
board(10:15, :) = 1;   % Support below
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit');

% Doesn’t Fit
board = ones(bHeight, bWidth);
board(13, 6:7) = 0;
board(14, 5:6) = 0;
board(14, 5) = 1;      % Block one cell
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'no_fit');

% Garbage
board = ones(bHeight, bWidth);
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'garbage');

%% ------------- J-Piece -------------
piece = 'J';
% Fit + Reward (L-shape)
board = ones(bHeight, bWidth);
board(12:14, 5) = 0;   % Vertical slot
board(14, 6) = 0;      % Horizontal slot
board(15, :) = 1;      % Floor
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit_reward');

% Fit (No Reward)
board = ones(bHeight, bWidth);
board(7:9, 4) = 0;     % Higher L-shape
board(9, 5) = 0;
board(10:15, :) = 1;   % Support below
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit');

% Doesn’t Fit
board = ones(bHeight, bWidth);
board(12:14, 5) = 0;
board(14, 6) = 0;
board(14, 5) = 1;      % Block vertical slot
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'no_fit');

% Garbage
board = ones(bHeight, bWidth);
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'garbage');

%% ------------- L-Piece -------------
piece = 'L';
% Fit + Reward (mirror of J)
board = ones(bHeight, bWidth);
board(12:14, 6) = 0;   % Vertical slot
board(14, 5) = 0;      |_ Horizontal slot
board(15, :) = 1;      % Floor
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit_reward');

% Fit (No Reward)
board = ones(bHeight, bWidth);
board(7:9, 7) = 0;     % Higher L-shape
board(9, 6) = 0;
board(10:15, :) = 1;   % Support below
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit');

% Doesn’t Fit
board = ones(bHeight, bWidth);
board(12:14, 6) = 0;
board(14, 5) = 0;
board(14, 6) = 1;      % Block vertical slot
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'no_fit');

% Garbage
board = ones(bHeight, bWidth);
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'garbage');

%% ------------- T-Piece -------------
piece = 'T';
% Fit + Reward (T-slot)
board = ones(bHeight, bWidth);
board(13, 5:7) = 0;    | Horizontal slot
board(14, 6) = 0;       | Vertical slot
board(15, :) = 1;      % Floor
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit_reward');

% Fit (No Reward)
board = ones(bHeight, bWidth);
board(8, 4:6) = 0;     % Higher T-slot
board(9, 5) = 0;
board(10:15, :) = 1;   % Support below
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'fit');

% Doesn’t Fit
board = ones(bHeight, bWidth);
board(13, 5:7) = 0;
board(14, 6) = 0;
board(14, 6) = 1;      % Block center
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'no_fit');

% Garbage
board = ones(bHeight, bWidth);
tableaus(end+1) = struct('piece', piece, 'board', board, 'condition', 'garbage');

% Save tableaus
save('tableaus.mat', 'tableaus');