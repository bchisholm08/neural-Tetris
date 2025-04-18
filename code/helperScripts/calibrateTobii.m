function calibrationData = calibrateTobii(window, windowRect, eyetracker, params)
% Inputs:
%   window     : Psychtoolbox onscreen window pointer.
%   windowRect : [left top right bottom] rect from Screen.
%   eyetracker : Eyetracker object from Tobii (EyeTrackingOperations).
%
% Output:
%   calibrationData : struct containing final calibration result if saved.
%                     Returns empty if the user aborts or never saves.

%% ---------------- Setup Colors, Keys, and PTB Info ----------------
HideCursor(window);
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, 24);

% Colors (PTB 0-1 range)
white = [1, 1, 1];
bgColor = [0, 0, 0];
redColor = [1, 0, 0];
blueColor = [0, 0, 1];

% Keys
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
spaceKey  = KbName('Space');
sKey      = KbName('S');
rKey      = KbName('R');

% Basic sizes for calibration dots
dotSizePix   = 30;
innerDotSize = dotSizePix * 0.5;

% We’ll store calibration data only if user saves
calibrationData = struct();
calibrationSaved = false;

%% ----------------- Do loop recal -----------------
calibrateAgain = true;
try
    while calibrateAgain
        
        %-------------------------------------------------
        % 1) WELCOME SCREEN
        %-------------------------------------------------
        Screen('FillRect', window, bgColor);
        welcomeMsg = [
            'Welcome to Tobii Calibration!\n\n',...
            'Wait for experimenter instructions to begin.\n\n',...
            'Experimenter Controls:\n',...
            '- Press SPACE to start calibration\n',...
            '- Press ESC to quit (no calibration)\n'
        ];
        DrawFormattedText(window, welcomeMsg, 'center', 'center', white);
        Screen('Flip', window);
        
        % Wait until user presses SPACE or ESC
        waiting = true;
        while waiting
            [~, ~, keyCode] = KbCheck;
            if keyCode(escapeKey)
                % User chose to abort
                ShowCursor(window);
                disp('Calibration aborted by experimenter.');
                return;  % Return empty calibrationData
            elseif keyCode(spaceKey)
                waiting = false;
            end
        end

%-------------------------------------------------
% 2) TOBII CALIBRATION
%-------------------------------------------------
% Setup calibration object
calib = ScreenBasedCalibration(eyetracker);        
% We'll define your points for calibration here, same as Gabor code:
lb = 0.1;  % left bound
xc = 0.5;  % horizontal center
rb = 0.9;  % right bound
ub = 0.1;  % upper bound
yc = 0.5;  % vertical center
bb = 0.9;  % bottom bound

points_to_calibrate = [
    lb, ub;
    rb, ub;
    xc, yc;
    lb, bb;
    rb, bb
];

% Enter calibration mode
calib.enter_calibration_mode();

% For each calibration point, show dot & collect data
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
for i = 1:size(points_to_calibrate,1)
    pt = points_to_calibrate(i,:);
    
    % Draw large dot (red) + smaller dot (white center)
    Screen('FillRect', window, bgColor);
    Screen('DrawDots', window, pt.*[screenXpixels, screenYpixels], dotSizePix, redColor, [], 2);
    Screen('DrawDots', window, pt.*[screenXpixels, screenYpixels], innerDotSize, white, [], 2);
    Screen('Flip', window);
    
    pause(1);  % wait for user to fixate; pile data 
    
    % Collect data for that point
    status = calib.collect_data(pt);
    if status ~= CalibrationStatus.Success
        % Attempt again if not successful
        calib.collect_data(pt);
    end
end

DrawFormattedText(window, 'Calculating calibration result....', 'center', 'center', white);
Screen('Flip', window);

% apply calibration
calibration_result = calib.compute_and_apply();

% Exit calibration mode
calib.leave_calibration_mode();

% If the calibration fails
if calibration_result.Status ~= CalibrationStatus.Success
    disp('Calibration compute_and_apply() did not succeed. Aborting.');
    ShowCursor(window);
    return;
end

%-------------------------------------------------
% 3) DISPLAY CALIBRATION RESULTS
%-------------------------------------------------
% Next, show all points from the calibration result similarly to your Gabor code.
% We’ll draw them in the correct color for each eye (left=red, right=blue).

points = calibration_result.CalibrationPoints;

Screen('FillRect', window, bgColor);

for i = 1:length(points)
    % Draw the calibration target as a small white dot
    Screen('DrawDots', window, ...
        points(i).PositionOnDisplayArea .* [screenXpixels, screenYpixels], ...
        dotSizePix*0.5, white, [], 2);
    
    % Each CalibrationPoint can have multiple data samples: LeftEye(j), RightEye(j)
    for j = 1:length(points(i).LeftEye)
        
        % If left eye is valid
        if points(i).LeftEye(j).Validity == CalibrationEyeValidity.ValidAndUsed
            leftPt = points(i).LeftEye(j).PositionOnDisplayArea .* [screenXpixels, screenYpixels];
            Screen('DrawDots', window, leftPt, dotSizePix*0.3, redColor, [], 2);
            % Draw a line from the eye point to the target
            coords = [leftPt; points(i).PositionOnDisplayArea .* [screenXpixels, screenYpixels]];
            Screen('DrawLines', window, coords', 2, redColor);
        end
        
        % If right eye is valid
        if points(i).RightEye(j).Validity == CalibrationEyeValidity.ValidAndUsed
            rightPt = points(i).RightEye(j).PositionOnDisplayArea .* [screenXpixels, screenYpixels];
            Screen('DrawDots', window, rightPt, dotSizePix*0.3, blueColor, [], 2);
            coords = [rightPt; points(i).PositionOnDisplayArea .* [screenXpixels, screenYpixels]];
            Screen('DrawLines', window, coords', 2, blueColor);
        end
    end
end

% Prompt to save or recalibrate
% [S] Save, [R] Recalibrate, [ESC] Abort
msg = [
    'Calibration complete!\n\n',...
    'Press "S" to SAVE calibration and finish.\n',...
    'Press "R" to Recalibrate.\n',...
    'Press "ESC" to Abort without saving.\n'
];
DrawFormattedText(window, msg, 'center', screenYpixels*0.93, white);
Screen('Flip', window);

userDecided = false;
while ~userDecided
    [~, ~, keyCode] = KbCheck;
    if keyCode(escapeKey)
        % Abandon calibration entirely
        ShowCursor(window);
        disp('Calibration aborted without saving.');
        return;
    elseif keyCode(sKey)
        % Save calibration
eyeDataDir = fullfile(params.baseDataDir, 'subjData', params.subjID, 'eyeData');
if ~exist(eyeDataDir, 'dir')
    mkdir(eyeDataDir);
end
calibFileName = sprintf('calibration_%s.mat', params.timestamp);
save(fullfile(eyeDataDir, calibFileName), 'calibration_result');
calibrationSaved = true;
calibrationData = calibration_result;

        disp('Calibration saved (returned as output).');
        calibrateAgain = false;
        userDecided = true;
    elseif keyCode(rKey)
        % Recalibrate (loop again)
        disp('Recalibration selected...');
        calibrateAgain = true;
        userDecided = true;
            end
        end
    end
catch ME
    % If something goes wrong, restore cursor & rethrow
    ShowCursor(window);
    rethrow(ME);
end

% If user reached here and saved
ShowCursor(window);
if calibrationSaved
    disp('Calibration finished and saved to "calibrationData".');
else
    disp('No calibration data saved.');
end

end
