%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: 
%                            
%-------------------------------------------------------
function p1instruct(window, expParams)
    % Display experiment instructions
    p1instructions = sprintf(['Welcome to the Part One of the Human Tetris Experiment! ' ...
        '\n\n During this section of the experiment you will be presented with pieces from the game of tetris \n\n while EEG and pupillometry data are collected.\n\n\n ' ...
        'YOU HAVE NO ACTIVE TASK YET\n\n A break of %d ' ...
        'seconds is given between blocks, with a REQUIRED break of %d seconds. \n\nThank you for your participation!!\n\n Press SPACE to begin the experiment'], ...
        expParams.rule.maxBlockBreakTime, expParams.rule.minBlockBreakTime);
    
    Screen('TextSize', window, 30);
    Screen('TextFont', window, 'Arial');
    DrawFormattedText(window, p1instructions, 'center', 'center', [1 1 1]);
    Screen('Flip', window);
    
    % Wait for key press
    KbStrokeWait;
end