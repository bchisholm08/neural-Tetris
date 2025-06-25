%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.19.2025
%
% Description: Function title 
%                            
%-------------------------------------------------------
function waitForSpace()
WaitSecs(0.3); % somehow we skip our first instruction screen, I suspect it's reading the same keyboard input or something?
while true
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('space'))
        break;
    end
end
WaitSecs(0.2);  % avoid accidentally re-reading an input 
end