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
    % Display experiment instructions
    txt1 = sprintf(['Final Part of the Human Tetris Experiment\n\n' ...
        'During this section of the experiment, your task is to play regular Tetris!!\n\nThe game will look different, and scoring will work differently, \n\n but the objective and controls ' ...
        'remain the same! \n\n' ...
        'You will be allowed to play games of Tetris. Score as many points as possible! \n\nPress `SPACE` to proceed...\n']); % games allowed will eventually be time controlled 

% special options for first set of directions... 
Screen('TextSize', window, 30);
Screen('TextFont', window, 'Arial');
% copy below for more 
DrawFormattedText(window, txt1, 'center', 'center', [1 1 1]);
Screen('Flip', window);
waitForSpace();

% screen 2 
txt2 = sprintf(['This section has nearly identical game functionality as ''regular'' Tetris.\n\n' ...
    'The `UP ARROW` ↑ will rotate pieces clockwise\n' ...
    'The `LEFT ARROW`   ←  will move a piece to the left \n' ...
    'The `RIGHT ARROW`   →  will move a piece to the right \n\n' ...
    'This game version does NOT include:\n' ...
    '- Piece Slam (with down or space) \n' ...
    '- Piece Preview Window\n\n' ...
    'Press SPACE to proceed...']);
DrawFormattedText(window, txt2, 'center', 'center', [1 1 1]);
Screen('Flip', window);
waitForSpace();

txt4 = sprintf(['Ready to proceed to the first trial?\n\n' ...
    'Press SPACE to begin\n\n\n' ...
    'Otherwise, flip the buzzer to speak with the experimenter']);
DrawFormattedText(window, txt4, 'center', 'center', [1 1 1]);
Screen('Flip', window);
waitForSpace();
end