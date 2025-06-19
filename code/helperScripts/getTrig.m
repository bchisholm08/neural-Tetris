%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Gets triggers for P1, P2, and P4. Triggers for P5 gameplay 
% are unique and contained within that specific script. Uses basecode 
% for pieces and depending on the event adds on the offset, giving the
% required trigger. 
%                            
%-------------------------------------------------------
function trig = getTrig(piece, eventType)
%  piece
    validPieces = {'I','Z','O','S','J','L','T'};
    if ~ismember(piece, validPieces)
        error('Invalid piece ID: %s. Must be one of %s.', piece, strjoin(validPieces, ', '));
    end

    % Define piece base trigger offsets
    baseCodes = containers.Map({'I','Z','O','S','J','L','T'}, [10, 20, 30, 40, 50, 60, 70]);

    % event offsets, adding these to offset value gives needed trigger 
 eventOffsets = containers.Map(...
        {'alone', 'fit_complete', 'fit_does_not_complete', 'garbage', 'does_not_fit', 'afc_match_trial', 'afc_nonmatch_trial'}, ...
        [0,        1,              2,                       3,        4,            5,                 6]);

    % check event 
    if ~isKey(eventOffsets, eventType)
        error('Invalid eventType: %s. Must be one of: %s.', ...
              eventType, strjoin(keys(eventOffsets), ', '));
    end

    % return trigger
    trig = baseCodes(piece) + eventOffsets(eventType);
end