function [blockMatrix, colorIndex] = generateBlock(useRandomRotation)
    if nargin < 1
        useRandomRotation = false;
    end

    % Define standard Tetris pieces (7 typical shapes)
    blocks = {
        [1 1 1 1],                    % I
        [1 1; 1 1],                   % O
        [0 1 0; 1 1 1],               % T
        [0 1 1; 1 1 0],               % S
        [1 1 0; 0 1 1],               % Z
        [1 0 0; 1 1 1],               % J
        [0 0 1; 1 1 1]                % L
    };

    randIndex = randi(length(blocks));
    blockMatrix = blocks{randIndex};
    colorIndex = randIndex;  % same index to pick color

    % (New) Optionally rotate the block randomly if requested
    if useRandomRotation
        rotations = randi(4)-1;  % 0 to 3
        for i = 1:rotations
            blockMatrix = rot90(blockMatrix);
        end
    end
end
