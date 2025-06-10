%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: 
%                            
%-------------------------------------------------------
function showScore(window, score, expParams)
% showScore: Draws the score text centered horizontally, below the middle of the screen.

    % Position the score text horizontally centered, 150 pixels below the vertical center
    xPos = 'center';
    yPos = expParams.screen.center(2) + 150; 
    
    % Set text properties
    Screen('TextSize', window, 32); % Slightly larger for visibility
    Screen('TextFont', window, 'Arial');
    
    % Draw the text
    DrawFormattedText(window, sprintf('Score: %d', score), xPos, yPos, [255 255 255]);
end