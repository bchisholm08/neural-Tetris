function p1instruct(window, params)
    % Display experiment instructions
    p1instructions = ['Welcome to the Part One of the Human Tetris Experiment!\n\n' ...
        'During this section of the experiment,\n\nYou will be presented with pieces from the game of tetris \n\nwhile EEG' ...
        ' and pupillometry data is collected.\n\nA break of FIXME seconds is provided between blocks.\n\nEach block will present' ...
        ' FIXME pieces, totalling FIXME trials\n\nThank you for your participation!\n'];
    
    Screen('TextSize', window, 24);
    Screen('TextFont', window, 'Arial');
    DrawFormattedText(window, p1instructions, 'center', 'center', [1 1 1]);
    Screen('Flip', window);
    
    % Wait for key press
    KbStrokeWait;
end