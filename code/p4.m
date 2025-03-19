function p4()
    % Load subject data
    subjID = input('Enter subject ID: ', 's');
    [window, ~, params] = experiment_init(subjID);
    
    % Section 5: Tetris Gameplay
    disp('Starting Section 5: Tetris Gameplay');
    board = zeros(params.board.visible_height, params.board.width);
    score = 0;
    lines = 0;
    gameData = struct('time', [], 'score', [], 'lines', []);
    
    startTime = GetSecs;
    while GetSecs < startTime + 1800 % 30 minutes
        % Game logic
        [board, score, lines] = update_game(board, score, lines);
        
        % Draw board
        draw_board(window, board, params);
        Screen('Flip', window);
        
        % Log data
        gameData(end+1) = struct(...
            'time', GetSecs,...
            'score', score,...
            'lines', lines);
        
        % Handle input
        process_input();
    end
    save(fullfile('Participants', subjID, 'p4', 'tetris.mat'), 'gameData');
    
    % Cleanup
    sca;
end