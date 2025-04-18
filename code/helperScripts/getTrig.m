function trig = getTrig(piece, eventType)
% Returns the EEG trigger code based on the piece and experimental condition.
%
% INPUTS:
%   piece      - Character indicating the Tetris piece ('I','Z','O','S','J','L','T')
%   eventType  - String specifying the condition:
%                'alone', 'fit_reward', 'fit_no_reward', 
%                'garbage', 'afc_correct', 'afc_incorrect'
%
% OUTPUT:
%   trig       - EEG trigger code (integer)

    % Validate piece
    validPieces = {'I','Z','O','S','J','L','T'};
    if ~ismember(piece, validPieces)
        error('Invalid piece ID: %s. Must be one of %s.', piece, strjoin(validPieces, ', '));
    end

    % Define piece base trigger offsets
    baseCodes = containers.Map( ...
        {'I','Z','O','S','J','L','T'}, ...
        [10, 20, 30, 40, 50, 60, 70]);

    % Define event type offsets
    eventOffsets = containers.Map( ...
        {'alone', 'fit_reward', 'fit_no_reward', 'no_fit', 'garbage' 'afc_correct', 'afc_incorrect'}, ...
        [0,       1,            2,               3,         4,             5,          6 ]);

    % Validate event type
    if ~isKey(eventOffsets, eventType)
        error('Invalid eventType: %s. Must be one of: %s.', ...
              eventType, strjoin(keys(eventOffsets), ', '));
    end

    % Compute trigger
    trig = baseCodes(piece) + eventOffsets(eventType);
end
