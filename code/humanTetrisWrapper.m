function humanTetrisWrapper(subjID)

    if nargin < 1
        subjID = input('Enter subject ID (e.g., ''P01''): ', 's');
    end

    try
        % Part 1: Piece presentation
        p1(subjID);                            
        interExp;

        % Part 2: Piece + tableau
        p2(subjID);                           
        interExp;

        % Part 3
        % p3(subjID);
        interExp;

        % % Part 4: 4‑AFC matching
        p4(subjID);
        interExp;

        % Part 5: play tetris
        % p5(subjID);
        
        showEndScreen;

    catch ME
        % make PTB clean up 
        sca; ShowCursor; Priority(0);
        clear("Screens")
        rethrow(ME);
    end
end


function interExp()
    PsychDefaultSetup(2);
    screens    = Screen('Screens');
    screenNum  = max(screens);
    [win, ~]  = PsychImaging('OpenWindow', screenNum, 0.5);  % gray bg
    Screen('TextSize', win, 28);
    DrawFormattedText(...
        win, ...
        'Take a break! \n\nPress SPACE to continue.', ...
        'center', 'center', [255 255 255]);
    Screen('Flip', win);
    KbName('UnifyKeyNames');
    spaceKey = KbName('SPACE');
    while true
        [keydown, ~, keyCode] = KbCheck;
        if keydown && keyCode(spaceKey)
            break;
        end
    end
    sca;
end

function showEndScreen()
    PsychDefaultSetup(2);
    screens    = Screen('Screens');
    screenNum  = max(screens);
    [win, ~] = PsychImaging('OpenWindow', screenNum, 0.5);
    Screen('TextSize', win, 28);
    DrawFormattedText(...
        win, ...
        'Experiment complete! \n\nThank you for your participation. \n\nPress SPACE to exit.', ...
        'center', 'center', [255 255 255]);
    Screen('Flip', win);
    KbName('UnifyKeyNames');
    spaceKey = KbName('SPACE');
    while true
        [keydown, ~, keyCode] = KbCheck;
        if keydown && keyCode(spaceKey)
            break;
        end
    end
    sca;
end
