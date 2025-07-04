%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Handles p2 instructions
%                            
%-------------------------------------------------------
function p2instruct(window, expParams)
    % Display experiment instructions
    txt1 = sprintf(['Pieces in Context Section of the Human Tetris Experiment\n\n\n' ...
        'During this section your task will still be fixating on the center cross\n\n While fixating, pieces will flash in the center of the screen.' ...
        '\n\n Unlike the first section, a TABLEAU will now accompany the pieces. \n\n' ...
        'YOU HAVE NO ACTIVE TASK; FIXATE ON THE CROSS\n\n' ...
        'Press SPACE to proceed... ']);

Screen('TextSize', window, 30);
Screen('TextFont', window, 'Arial');
% copy below for more 
DrawFormattedText(window, txt1, 'center', 'center', [1 1 1]);
Screen('Flip', window);
waitForSpace();
    
% txt2 = sprintf(['In our experiment, each of the 7 Tetris peices has a corresponding tableau that they ''complete''. \n\n' ...
%     'Pieces will be shown with their matching tableau, and with other non-matching tableaus throughout this section.\n' ...
%      'Your task is to focus on these pieces and tableaus as they appear, and focus on the fixation cross.\n\n Press SPACE proceed...']);
% DrawFormattedText(window, txt2, 'center', 'center', [1 1 1]);
% Screen('Flip', window);
% waitForSpace();

    txt4 = sprintf(['Ready to proceed to the first trial?\n\n' ...
    'Press SPACE to begin\n\n\n' ...
    'Otherwise, flip the buzzer to speak with the experimenter']);
DrawFormattedText(window, txt4, 'center', 'center', [1 1 1]);
Screen('Flip', window);
waitForSpace();
end