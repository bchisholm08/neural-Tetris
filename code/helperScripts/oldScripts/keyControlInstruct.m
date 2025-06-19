%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: 
%                            
%-------------------------------------------------------
function keyControlInstruct(window, expParams)

% use arrows below for directions... 
% ↑ ↓ ← → 

keyboardReminder = sprintf(['As a reminder, you will respond with the arrow keys during this section ' ...
'of the experiment.\nThe arrow keys directly correspond to the side of the screen an option is on\n\n' ...
'For instance, to match a piece with the tableau on the TOP of the screen, press ↑ on the keyboard\n\n' ...
'If you wanted to select the tableau to the RIGHT on the screen, press → on the keyboard\n\n' ...
'Buzz the experimenter NOW if you have any questions\n\n' ...
'Otherwise, press SPACE to continue.']);
% NOTE TO SELF: I do not think it is unreasonable to add example
% tableaus--this is a very novel task. Need to ask JP. Keep as is for now 
    
    Screen('TextSize', window, 30);
    Screen('TextFont', window, 'Arial');
    DrawFormattedText(window, keyboardReminder, 'center', 'center', [1 1 1]);
    Screen('Flip', window);
    
    % Wait for key press
    KbStrokeWait;
end

%{

function keyControlInstruct(window, expParams)

    % Define multiple instruction screens
    instructionScreens = {
        sprintf(['Welcome to this section of the experiment.\n\n' ...
        'You will be asked to match Tetris pieces to one of the possible\n' ...
        'tableaus (Tetris boards) shown on the screen.']), 
        
        sprintf(['You will respond using the arrow keys on the keyboard:\n' ...
        '↑ = Top\n↓ = Bottom\n← = Left\n→ = Right\n\n' ...
        'Each option will be on one of those sides of the screen.']),

        sprintf(['To select the tableau at the TOP, press ↑\n' ...
        'To select the tableau on the RIGHT, press →\n\n' ...
        'Buzz the experimenter NOW if you have any questions.']),

        sprintf(['Otherwise, press SPACE to begin the task.\n\n' ...
        'Get ready!'])
    };

    Screen('TextSize', window, 30);
    Screen('TextFont', window, 'Arial');

    for i = 1:length(instructionScreens)
        DrawFormattedText(window, instructionScreens{i}, 'center', 'center', [1 1 1]);
        Screen('Flip', window);
        
        % Wait for space bar only
        while true
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown && keyCode(KbName('space'))
                break;
            end
        end
        WaitSecs(0.2); % small debounce delay
    end
end









%}