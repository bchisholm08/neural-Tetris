%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Instructions for P5, natural Tetris play
%                             ↑ ↓ ← →
%-------------------------------------------------------
function p5instruct(window, expParams)
    cx = expParams.screen.center(1);
    cy = expParams.screen.center(2);
    % scr 1 
    tVal = expParams.p5.options.totalTime/60;
    txt1 = sprintf(['Play Section of the Tetris Experiment\n\n' ...
        'During this section of the experiment, your task is to play regular Tetris!\n\nThe game will look different, but the objective and controls remain the same.\n' ...
        'You will be allowed to play games of Tetris for %d total minutes. \n\nScore as many points as possible in each game! \n\nPress `SPACE` to proceed...\n'],tVal); 

% special options for first set of directions... 
Screen('TextSize', window, 30);
Screen('TextFont', window, 'Arial');
% copy below for more 
DrawFormattedText(window, txt1, 'center', 'center', [1 1 1]);
Screen('Flip', window);
waitForSpace();

% scr 2 
txt2 = sprintf(['Carefully review controls below....\n\n' ...
    '   `UP ARROW` ↑ will rotate pieces clockwise\n' ...
    '   `LEFT ARROW`   ←  will move a piece to the left \n' ...
    '   `RIGHT ARROW`   →  will move a piece to the right \n' ...
    '   `DOWN ARROW`   ↓  will move a piece downwards\n\n' ...
    'Press `SPACE` when you''re ready to proceed \n to the first game!\n\nOtherwise, flip the buzzer to notify the experimenter']);
DrawFormattedText(window, txt2, 'center', 'center', [1 1 1]);
Screen('Flip', window);
waitForSpace();

% scr 3
% % % txt3 = sprintf(['Ready to proceed to the first game?\n\n' ...
% % %     'Press SPACE to begin\n\n\n' ...
% % %     'Otherwise, flip the buzzer to notify the experimenter']);
% % % DrawFormattedText(window, txt3, 'center', 'center', [1 1 1]);
% % % Screen('Flip', window);
% % % waitForSpace();
end   