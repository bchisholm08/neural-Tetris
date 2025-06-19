%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Draws a fixation cross for stimuli 
%                
%-------------------------------------------------------
function drawFixation(window, windowRect, color)

    % both in px; changes size of fixation cross (move to expParams) 
    length = 10;
    thickness = 4; 

    [xCenter, yCenter] = RectCenter(windowRect);
    % horz line (length: 20px, thickness: 8px)
    fixRect = [xCenter-length, yCenter-thickness, xCenter+length, yCenter+thickness];
    Screen('FillRect', window, color, fixRect);
    % vert line (length: 20px, thickness: 8px)
    fixRect = [xCenter-thickness, yCenter-length, xCenter+thickness, yCenter+length];
    Screen('FillRect', window, color, fixRect);
end