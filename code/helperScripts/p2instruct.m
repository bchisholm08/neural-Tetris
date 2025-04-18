function p2instruct(window, params)
    % Display experiment instructions
    p2instructions = ['Welcome to the Part Two of the Human Tetris Experiment!\n\n' ...
        'During this section of the experiment, you are tasked with continuing to fixate on the center cross\n\n While fixating, a tableau will appear along' ...
        '\n\n with one of the 7 tetris pieces. \n\nEach tetris piece has one corresponding tableau, and will be highlighted in greeen when matched\n\nYour only task is to fixate on the cross and watch the pieces'];

    Screen('TextSize', window, 24);
    Screen('TextFont', window, 'Courier New');
    DrawFormattedText(window, p2instructions, 'center', 'center', [1 1 1]);
    Screen('Flip', window);
    
    % Wait for key press
    KbStrokeWait;
end