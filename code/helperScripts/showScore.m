%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Show player their score  
%                            
%-------------------------------------------------------
function showScore(window, score, expParams)
    xPos = 'center';
    yPos = expParams.screen.center(2) + 150; 
    
    Screen('TextSize', window, 32); 
    Screen('TextFont', window, 'Arial');
    
     % draw 
    DrawFormattedText(window, sprintf('Score: %d', score), xPos, yPos, [255 255 255]);
end