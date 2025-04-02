% OLD FUNCTION; DO NOT USE
function tableaus = generateTableaus()
    % Define tableau dimensions
    bHeight = 15;
    bWidth = 10;
    
    % Initialize structure
    tableaus = struct('piece', {}, 'board', {}, 'condition', {});
    
    % Define pieces and conditions
    pieces = {'I','Z','O','S','J','L','T'};
    conditions = {'fit_reward', 'fit', 'no_fit', 'garbage'};
    
    % Generate tableaus for each piece and condition
    for p = 1:length(pieces)
        for c = 1:length(conditions)
            % Create appropriate board configuration
            board = createBoardConfig(pieces{p}, conditions{c}, bHeight, bWidth);
            tableaus(end+1) = struct('piece', pieces{p}, ...
                                    'board', board, ...
                                    'condition', conditions{c});
        end
    end
end

function board = createBoardConfig(piece, condition, height, width)
    % Implementation of board creation logic
    board = ones(height, width); % Default to garbage
    % Add your specific board configurations here
    % (Use your existing getTableaus.m logic)
end