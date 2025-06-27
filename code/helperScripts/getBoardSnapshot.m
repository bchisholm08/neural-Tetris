%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
%
% Description: Purpose of this script is to get a list of 1's and 0's of
% the tetris board, for what spaces are occupied or not.
%
% In addition to recording what spaces are filled, we need to know if an
% EEG trigger was sent in that frame. These will be NaN when no trigger is sent.
% Finally, we will use the third column for a clock. Specifically, we will
% use the PTB clock to sync up our data posthoc.
%
%-------------------------------------------------------
function  snapshot = getBoardSnapshot(boardMatrix, currentTrigger)

snapshot.board = boardMatrix;
snapshot.trigger = currentTrigger;
snapshot.timestamp = GetSecs;
end