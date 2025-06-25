%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Thanks participant for their time amd brain waves 
%                            
%-------------------------------------------------------
function showEndScreen(window, expParams)
    % use existing PTB window and expParams for colors.

    % text settings 
    Screen('TextSize', window, 32);
    Screen('TextFont', window, 'Arial'); 

    endText = ('Experiment complete! \n\n Thank you for your time and participation! \n\n Press SPACE to exit....');

    Screen('FillRect', window, expParams.colors.background); 
    DrawFormattedText(window, endText, 'center', 'center', expParams.colors.white);
    Screen('Flip', window);

    KbName('UnifyKeyNames');
    spaceKey = KbName('SPACE');
    KbWait(-1, 2); % Wait for key release before proceeding
    while true % Wait space
        [keydown, ~, keyCode] = KbCheck;
        if keydown && keyCode(spaceKey)
            break;
        end
        WaitSecs(0.01);
    end
    % rm PTB screen 
    sca;
end