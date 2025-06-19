%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Instructions for P5, natural Tetris section
%                            
%-------------------------------------------------------
function p5instruct(window, expParams)
    % Display experiment instructions
    p5instructions = sprintf(['Part Five of the Human Tetris Experiment\n\n' ...
        'During this section of the experiment, your task is to play regular Tetris!!\n\nThe game will look different, and scoring will work differently, \n\n but the objective and controls ' ...
        'remain the same! \n\n' ...
        'You will be allowed to play %d games of Tetris. Score as many points as possible! \n\nPress `SPACE` to proceed to review of game controls [FIXME] \n'], expParams.p5.options.gamesAllowed);

    Screen('TextSize', window, 30);
    Screen('TextFont', window, 'Arial');
    DrawFormattedText(window, p5instructions, 'center', 'center', [1 1 1]);
    Screen('Flip', window);
    
    % Wait for key press
    KbStrokeWait;
end