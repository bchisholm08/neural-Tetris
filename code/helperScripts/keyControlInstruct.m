%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: 
%                            
%-------------------------------------------------------
function keyControlInstruct(window, expParams)
    
keyboardReminder = sprintf(['As a reminder, you will respond with the arrow keys during this section' ...
'of the experiment. The arrow keys directly correspond to the side of the screen an option is on \n\n' ...
'Use SPACE to continue through break screens.']);
    
    Screen('TextSize', window, 30);
    Screen('TextFont', window, 'Arial');
    DrawFormattedText(window, keyboardReminder, 'center', 'center', [1 1 1]);
    Screen('Flip', window);
    
    % Wait for key press
    KbStrokeWait;
end