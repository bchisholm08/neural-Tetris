%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Instructions for 4-AFC portion of human tetris experiment 
%
%-------------------------------------------------------

% use arrows below for directions...
% ↑ ↓ ← →

function p4instruct(window, expParams)

% screen one
txt1 = sprintf(['Part Three of the Human Tetris Experiment\n\n' ...
    'During this section of the experiment, your job will be to score as many points as possible \n by correctly matching Tetris pieces to their matching tableau.\n' ...
    'A tableau is what you saw in the previous section, and is essentially a Tetris game frozen in time. \nThis is meant to emulate a chess puzzle, in a way, where you are allowed one move to finish a game\n' ...
    'Each of the 7 Tetris pieces have three unique tableaus, and all pieces share a common GARBAGE tableau, totalling 4 tableaus per piece.\n\n' ...
    'Press SPACE to continue...']);
% special options for first set of directions... 
Screen('TextSize', window, 30);
Screen('TextFont', window, 'Arial');
% copy below for more 
DrawFormattedText(window, txt1, 'center', 'center', [1 1 1]);
Screen('Flip', window);
waitForSpace();

% screen two
txt2 = sprintf(['Your task is to match pieces to their respective tableau to score as many points as possible\n\n' ...
    'To give your response, or ''match'' a piece to a particular tableau, you will use the arrow keys.\n\n' ...
    'In a particular trial, you would press ↑ on the keyboard to match the piece with the tableau at the TOP of the screen\n\n' ...
    'Or, you could press ← on the keyboard to match the piece with the tableau on the LEFT side of the screen\n\n' ...
    'In one trial, FOUR tableaus are presented at once, and your task is to select the best available match\n\n' ...
    'Press SPACE to continue\n\n\n']);
DrawFormattedText(window, txt2, 'center', 'center', [1 1 1]);
Screen('Flip', window);
waitForSpace();

% screen three
txt3 = sprintf(['The four tableaus correspond to the four keyboard options (↑ ↓ ← →) :\n\n' ...
    '       1) Perfect fit and match (maximum points)\n\n\n' ...
    '       2) Partial fit (no points awarded)\n\n\n' ...
    '       3) No fit (no points awarded)\n\n\n' ...
    '       4) Garbage (points awarded for correct rejection)\n\n\n' ...
    'If a piece does not fit into an available tableau, the optimal option is to trash the piece.\n' ...
    'This may seem illogical, however if a match doesn''t exist, then any other option EXCEPT \n the GARBAGE would be like putting a square through a round hole.\n' ...
    'Points will be awarded when you correctly identify a MATCH and GARBAGE tableau. \n Your score will be displayed during the fixation period.\n' ...
    'Press SPACE to continue...']);
DrawFormattedText(window, txt3, 'center', 'center', [1 1 1]);
Screen('Flip', window);
waitForSpace();

% screen four
txt4 = sprintf(['Ready to proceed to the first trial?\n\n\n\n' ...
    'Press SPACE to continue to trials\n\n\n\n' ...
    'Otherwise, flip the buzzer to speak with the experimenter']);
DrawFormattedText(window, txt4, 'center', 'center', [1 1 1]);
Screen('Flip', window);
waitForSpace();

end % function end 

% one local helper function...    :(
function waitForSpace()
WaitSecs(0.3); % somehow we skip our first instruction screen, I suspect it's reading the same keyboard input 
while true
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('space'))
        break;
    end
end
WaitSecs(0.2);  % avoid accidental skips
end





