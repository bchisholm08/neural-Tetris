function p4instruct(window, params)
    % Display experiment instructions
    p4instructions = ['Welcome to the Part Four of the Human Tetris Experiment!\n\n' ...
        'During this section of the experiment,\n\n...\n\n...\n\n...\n\n...'];

    Screen('TextSize', window, 24);
    Screen('TextFont', window, 'Arial');
    DrawFormattedText(window, p4instructions, 'center', 'center', [1 1 1]);
    Screen('Flip', window);
    
    % Wait for key press
    KbStrokeWait;
end