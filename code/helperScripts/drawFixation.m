%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Draws a fixation cross for experiments 
%                            
%-------------------------------------------------------
function drawFixation(window, windowRect, color)
    [xCenter, yCenter] = RectCenter(windowRect);
    % horz line (length: 20px, thickness: 4px)
    fixRect = [xCenter-10, yCenter-2, xCenter+10, yCenter+2];
    Screen('FillRect', window, color, fixRect);
    % vert line (length: 20px, thickness: 4px)
    fixRect = [xCenter-2, yCenter-10, xCenter+2, yCenter+10];
    Screen('FillRect', window, color, fixRect);
end