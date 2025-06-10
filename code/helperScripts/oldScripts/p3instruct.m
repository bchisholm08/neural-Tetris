%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: 
%                            
%-------------------------------------------------------
function p3instruct(window, params)
    % Display experiment instructions
    p3instructions = ['Welcome to the Part Three of the Human Tetris Experiment!\n\n' ...
        'During this section of the experiment,\n\n...\n\n...\n\n...\n\n...'];

    Screen('TextSize', window, 24);
    Screen('TextFont', window, 'Arial');
    DrawFormattedText(window, p3instructions, 'center', 'center', [1 1 1]);
    Screen('Flip', window);
    
    % Wait for key press
    KbStrokeWait;
end