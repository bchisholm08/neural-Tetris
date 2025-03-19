function p1instruct(window, params)
    % Display experiment instructions
    p1instructions = ['Welcome to the Part One of the Human Tetris Experiment!\n\n' ...
        'During this section of the experiment,\n\n...\n\n...\n\n...\n\n...'];

    Screen('TextSize', window, 24);
    Screen('TextFont', window, 'Arial');
    DrawFormattedText(window, p1instructions, 'center', 'center', [1 1 1]);
    Screen('Flip', window);
    
    % Wait for key press
    KbStrokeWait;
end