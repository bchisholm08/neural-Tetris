%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Draws a fixation cross for stimuli. Parameters for fixation
% size are in expParams structure 
%                
%-------------------------------------------------------
function drawFixation(window, windowRect, expParams)
    length = expParams.fixation.size;
    thickness = expParams.fixation.lineWidth; 
    color = expParams.fixation.color; 

    [xCenter, yCenter] = RectCenter(windowRect);

    fixRect = [xCenter-length, yCenter-thickness, xCenter+length, yCenter+thickness];
    Screen('FillRect', window, color, fixRect);

    fixRect = [xCenter-thickness, yCenter-length, xCenter+thickness, yCenter+length];
    Screen('FillRect', window, color, fixRect);
end