function tableaus = getTableaus()
    % Initialize structure
    tableaus = struct('piece', {}, 'board', {}, 'condition', {});

    % ================== I-PIECE ==================
    % 1. FIT + REWARD
    board = [...
        0 0 0 0 0 0 0 0 0 0; % Row 1
        0 0 0 0 0 0 0 0 0 0; % Row 2
        0 0 0 0 0 0 0 0 0 0; % Row 3
        0 0 0 0 0 0 0 0 0 0; % Row 4
        0 0 0 0 0 0 0 0 0 0; % Row 5
        0 0 0 0 0 0 0 0 0 0; % Row 6
        0 0 0 0 0 0 0 0 0 0; % Row 7
        0 0 0 0 0 0 0 0 0 0; % Row 8
        0 0 0 0 0 0 0 0 0 0; % Row 9
        0 0 0 0 0 0 0 0 0 0; % Row 10
        0 0 0 0 0 0 0 0 0 0; % Row 11
        0 0 0 0 0 0 0 0 0 0; % Row 12
        0 0 0 0 0 0 0 0 0 0; % Row 13
        1 1 1 1 1 1 1 1 1 1; % Floor
        1 1 1 1 1 1 1 1 1 1];% Floor
    board(10:13, 4) = 0; % Vertical I-piece slot
    tableaus(end+1) = struct('piece', 'I', 'board', board, 'condition', 'fit_reward');

    % 2. FIT NO REWARD
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(5:8, 4) = 0; % Higher vertical slot
    tableaus(end+1) = struct('piece', 'I', 'board', board, 'condition', 'fit_no_reward');

    % 3. NO FIT
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(10:13, 4) = 0;
    board(12, 4) = 1; % Block in middle
    tableaus(end+1) = struct('piece', 'I', 'board', board, 'condition', 'no_fit');

    % 4. GARBAGE
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    % Manual garbage pattern
    board(5,1) = 0;  % Single holes in each column
    board(7,2) = 0;
    board(9,3) = 0;
    board(6,4) = 0;
    board(8,5) = 0;
    board(10,6) = 0;
    board(12,7) = 0;
    board(11,8) = 0;
    board(7,9) = 0;
    board(9,10) = 0;
    tableaus(end+1) = struct('piece', 'I', 'board', board, 'condition', 'garbage');

    % ================== Z-PIECE ==================
    % 1. FIT + REWARD
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 1 1 0 0 0 0; % Z-shape
        0 0 0 1 1 0 0 0 0 0; % Z-shape
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    tableaus(end+1) = struct('piece', 'Z', 'board', board, 'condition', 'fit_reward');

    % 2. FIT NO REWARD
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 1 1 0 0 0 0; % Higher Z-shape
        0 0 0 1 1 0 0 0 0 0; % Higher Z-shape
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    tableaus(end+1) = struct('piece', 'Z', 'board', board, 'condition', 'fit_no_reward');

    % 3. NO FIT
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 1 1 0 0 0 0;
        0 0 0 1 1 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(12,5) = 1; % Block critical spot
    tableaus(end+1) = struct('piece', 'Z', 'board', board, 'condition', 'no_fit');

    % 4. GARBAGE
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    % Manual garbage pattern
    board(5,2) = 0;
    board(7,4) = 0;
    board(9,6) = 0;
    board(11,8) = 0;
    board(13,10) = 0;
    board(6,1) = 0;
    board(8,3) = 0;
    board(10,5) = 0;
    board(12,7) = 0;
    board(14,9) = 0;
    tableaus(end+1) = struct('piece', 'Z', 'board', board, 'condition', 'garbage');

    % ================== O-PIECE ==================
    % 1. FIT + REWARD
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(11:12, 4:5) = 0; % 2x2 square
    tableaus(end+1) = struct('piece', 'O', 'board', board, 'condition', 'fit_reward');

    % Continue this exact pattern for remaining pieces/conditions...
    % [S, J, L, T pieces would follow same structure]
    % ================== S-PIECE ==================
    % 1. FIT + REWARD
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(12,5:6) = 0;  % S-shape
    board(13,4:5) = 0;  % S-shape
    tableaus(end+1) = struct('piece', 'S', 'board', board, 'condition', 'fit_reward');

    % 2. FIT NO REWARD
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(6,5:6) = 0;  % Higher S-shape
    board(7,4:5) = 0;  % Higher S-shape
    tableaus(end+1) = struct('piece', 'S', 'board', board, 'condition', 'fit_no_reward');

    % 3. NO FIT
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(12,5:6) = 0;
    board(13,4:5) = 0;
    board(13,5) = 1;  % Block critical spot
    tableaus(end+1) = struct('piece', 'S', 'board', board, 'condition', 'no_fit');

    % 4. GARBAGE
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    % Manual garbage pattern
    board(5,3) = 0;
    board(7,5) = 0;
    board(9,7) = 0;
    board(11,9) = 0;
    board(6,2) = 0;
    board(8,4) = 0;
    board(10,6) = 0;
    board(12,8) = 0;
    board(7,1) = 0;
    board(9,10) = 0;
    tableaus(end+1) = struct('piece', 'S', 'board', board, 'condition', 'garbage');

    % ================== J-PIECE ==================
    % 1. FIT + REWARD
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(11:13,5) = 0; % Vertical
    board(13,6) = 0;    % Right hook
    tableaus(end+1) = struct('piece', 'J', 'board', board, 'condition', 'fit_reward');

    % 2. FIT NO REWARD
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(5:7,5) = 0;   % Higher vertical
    board(7,6) = 0;     % Higher hook
    tableaus(end+1) = struct('piece', 'J', 'board', board, 'condition', 'fit_no_reward');

    % 3. NO FIT
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(11:13,5) = 0;
    board(13,6) = 0;
    board(12,5) = 1;  % Block vertical
    tableaus(end+1) = struct('piece', 'J', 'board', board, 'condition', 'no_fit');

    % 4. GARBAGE
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    % Manual garbage pattern
    board(5,1) = 0;
    board(7,3) = 0;
    board(9,5) = 0;
    board(11,7) = 0;
    board(13,9) = 0;
    board(6,2) = 0;
    board(8,4) = 0;
    board(10,6) = 0;
    board(12,8) = 0;
    board(14,10) = 0;
    tableaus(end+1) = struct('piece', 'J', 'board', board, 'condition', 'garbage');

    % ================== L-PIECE ==================
    % 1. FIT + REWARD
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(11:13,5) = 0; % Vertical
    board(13,4) = 0;    % Left hook
    tableaus(end+1) = struct('piece', 'L', 'board', board, 'condition', 'fit_reward');

    % 2. FIT NO REWARD
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(5:7,5) = 0;   % Higher vertical
    board(7,4) = 0;     % Higher hook
    tableaus(end+1) = struct('piece', 'L', 'board', board, 'condition', 'fit_no_reward');

    % 3. NO FIT
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(11:13,5) = 0;
    board(13,4) = 0;
    board(12,5) = 1;  % Block vertical
    tableaus(end+1) = struct('piece', 'L', 'board', board, 'condition', 'no_fit');

    % 4. GARBAGE
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    % Manual garbage pattern
    board(5,9) = 0;
    board(7,7) = 0;
    board(9,5) = 0;
    board(11,3) = 0;
    board(13,1) = 0;
    board(6,8) = 0;
    board(8,6) = 0;
    board(10,4) = 0;
    board(12,2) = 0;
    board(14,10) = 0;
    tableaus(end+1) = struct('piece', 'L', 'board', board, 'condition', 'garbage');

    % ================== T-PIECE ==================
    % 1. FIT + REWARD
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(12,4:6) = 0; % Horizontal
    board(13,5) = 0;   % Center
    tableaus(end+1) = struct('piece', 'T', 'board', board, 'condition', 'fit_reward');

    % 2. FIT NO REWARD
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(6,4:6) = 0;  % Higher horizontal
    board(7,5) = 0;    % Higher center
    tableaus(end+1) = struct('piece', 'T', 'board', board, 'condition', 'fit_no_reward');

    % 3. NO FIT
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    board(12,4:6) = 0;
    board(13,5) = 0;
    board(12,5) = 1;  % Block center
    tableaus(end+1) = struct('piece', 'T', 'board', board, 'condition', 'no_fit');

    % 4. GARBAGE
    board = [...
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 0 0 0;
        1 1 1 1 1 1 1 1 1 1;
        1 1 1 1 1 1 1 1 1 1];
    % Manual garbage pattern
    board(5,2) = 0;
    board(7,4) = 0;
    board(9,6) = 0;
    board(11,8) = 0;
    board(13,10) = 0;
    board(6,1) = 0;
    board(8,3) = 0;
    board(10,5) = 0;
    board(12,7) = 0;
    board(14,9) = 0;
    tableaus(end+1) = struct('piece', 'T', 'board', board, 'condition', 'garbage');
    save('tableaus.mat', 'tableaus');
end