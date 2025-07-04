%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Instructions for 4-AFC portion of human tetris experiment 
%
%-------------------------------------------------------

% paste arrows below for directions...
% ↑ ↓ ← →

function p4instruct(window, expParams)
    
    % get parameters for displaying an example tableau 
%    exampleTbl = tableaus(strcmp({tableaus.piece},'T') & strcmp({tableaus.condition},'fit_complete'));
%   examplePce = pieces(strcmp({pieces.name},'T'));
    % shorthand screen center
    cx = expParams.screen.center(1);
    cy = expParams.screen.center(2);
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

    % '       1) Perfect fit and match (maximum points)\n\n\n' ...
    % '       2) Partial fit (no points awarded)\n\n\n' ...
    % '       3) No fit (no points awarded)\n\n\n' ...
    % '       4) Garbage (points awarded for correct rejection)\n\n\n' ...
% screen three
txt3 = sprintf(['The SIDE that the four tableaus are \n on directly correspond to the four keyboard options:\n\n' ...
    '↑ (top tableau), ↓ (bottom tableau), ← (left tableau),  → (right tableau)\n' ...
    'If a piece does not fit into an available tableau, the optimal option is TRASH.\n' ...
    'This may seem illogical, however if a match doesn''t exist, then any other option EXCEPT \n the GARBAGE would be like putting a square through a round hole.\n' ...
    'Points will be awarded when you correctly identify a MATCH and GARBAGE tableau. \n A GARBAGE tableau is an EMPTY tableau frame \n\n' ...
    'Press SPACE to continue...']);
DrawFormattedText(window, txt3, 'center', 'center', [1 1 1]);
Screen('Flip', window);
waitForSpace();

% hypothetical 'example tableau' screen we could show participants 

%{
%–– screen four: live example ––
% clear to background
Screen('FillRect', window, expParams.colors.background );
% draw the example tableau centered a little lower
Screen('DrawTexture', window, exampleTbl.tex, [], ...
       CenterRectOnPoint(exampleTbl.rect, cx, cy+100) );
% draw the example piece on top
Screen('DrawTexture', window, examplePce.tex, [], ...
       CenterRectOnPoint(examplePce.rect, cx, cy-100) );
% label arrows to tableau
DrawFormattedText(window, 'Press ↑ to choose this one','center', cy+200, expParams.colors.white);
% flip it up
Screen('Flip', window);
waitForSpace();s
%}

% screen four
txt4 = sprintf(['Ready to proceed to the first trial?\n\n' ...
    'Press SPACE to begin\n\n\n' ...
    'Otherwise, flip the buzzer to speak with the experimenter']);
DrawFormattedText(window, txt4, 'center', 'center', [1 1 1]);
Screen('Flip', window);
waitForSpace();

end % function end 






