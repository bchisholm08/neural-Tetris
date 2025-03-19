function [window, windowRect, params] = initExperiment(subjID, demoMode)

% Set sync test tolerance based on demoMode
if demoMode
    Screen('Preference', 'SkipSyncTests', 2); % Lenient checks
else
    Screen('Preference', 'SkipSyncTests', 0); % Strict checks
end

sca;

% Init PTB
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);

% open PTB window for config 
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0]);

% def experiment params 
params = struct();
params.window = window; % MUST pass window handle %FIXME 3.19.25
params.colors.background = [0 0 0];
params.colors.piece = [0.5 0.5 0.5];
[params.screen.width, params.screen.height] = Screen('WindowSize', window);
params.subjID = subjID;
params.demoMode = demoMode;

% Hide cursor and set text
HideCursor;
Screen('TextSize', window, 24);
end
