function p5(params, subjID, demoMode)
    % Initialize game state
    board = zeros(params.board.visible_height, params.board.width);
    score = 0;
    lines = 0;
    gameData = struct('time', [], 'score', [], 'lines', []);
    
    % Game loop
    startTime = GetSecs;
    while GetSecs < startTime + 1800 % 30 minutes
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            if keyCode(KbName('LeftArrow'))
                % Move left
            elseif keyCode(KbName('RightArrow'))
                % Move right
            elseif keyCode(KbName('DownArrow'))
                % Move down
            elseif keyCode(KbName('UpArrow'))
                % Rotate
            end
        end
        
        % Update game state
        [board, score, lines] = update_game(board, score, lines);
        
        % Draw board
        draw_board(params.window, board, params);
        Screen('Flip', params.window);
        
        % Log data
        gameData(end+1) = struct(...
            'time', GetSecs,...
            'score', score,...
            'lines', lines);
    end
    
    % Save game data
    save_data('p4', subjID, gameData, params, demoMode);
end