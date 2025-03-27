function p5instruct(window, params)
    % Display experiment instructions
    p5instructions = ['Welcome to the Part Five of the Human Tetris Experiment!\n\n' ...
        'During this section of the experiment,\n\n...\n\n...\n\n...\n\n...'];

    Screen('TextSize', window, 24);
    Screen('TextFont', window, 'Arial');
    DrawFormattedText(window, p5instructions, 'center', 'center', [1 1 1]);
    Screen('Flip', window);
    
    % Wait for key press
    KbStrokeWait;
end