%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Handles displaying P1 experiment instructions 
%                            
%-------------------------------------------------------
function p1instruct(window, expParams)
    % Display experiment instructions
    p1instructions = sprintf(['Welcome to the Part One of the Human Tetris Experiment! ' ...
        '\n\n During this section of the experiment you will be presented with pieces from the game of tetris \n\n while EEG and pupillometry data are collected.\n\n\n ' ...
        'YOU HAVE NO ACTIVE TASK AT THIS TIME\n ' ...
        '\n\n Press SPACE to proceed...']);
    
    Screen('TextSize', window, 30);
    Screen('TextFont', window, 'Arial');
    DrawFormattedText(window, p1instructions, 'center', 'center', [1 1 1]);
    Screen('Flip', window);
    waitForSpace();

txt4 = sprintf(['Ready to proceed to the first trial?\n\n' ...
    'Press SPACE to begin\n\n\n' ...
    'Otherwise, flip the buzzer to speak with the experimenter']);
DrawFormattedText(window, txt4, 'center', 'center', [1 1 1]);
Screen('Flip', window);
waitForSpace();

end