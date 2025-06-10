%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: 
%                            
%-------------------------------------------------------
function p2instruct(window, expParams)
    % Display experiment instructions
    p2instructions = sprintf(['Part Two of the Human Tetris Experiment!\n\n\n' ...
        'During this section your task will still be fixating on the center cross\n\n While fixating, pieces will flash in the center of the screen.' ...
        '\n\n Unlike the first section, a TABLEAU will now accompany the pieces. \n\n' ...
        'In our experiment, each of the 7 Tetris peices has a corresponding tableau that they ''complete''. \n\n Pieces will be shown with their matching tableau, and with others in this section\n' ...
        'Your task is to focus on these pieces and tableaus as they appear.\n\n Press SPACE to begin!']);

    Screen('TextSize', window, 30);
    Screen('TextFont', window, 'Arial');
    DrawFormattedText(window, p2instructions, 'center', 'center', [1 1 1]);
    Screen('Flip', window);
    
    % wait for key 
    KbStrokeWait;
end