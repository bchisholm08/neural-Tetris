function calibrationData = calibrateTobii(window, windowRect, eyetracker, expParams)
%-------------------------------------------------------
% Author: Brady M. Chisholm (merged with Tobii example)
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025 
%
% Description:
%   Unified Tobii calibration routine that:
%     • Shows a PTB welcome screen
%     • Wraps enter_calibration_mode in try/catch to recover error210
%     • Displays each point, collects data, and prints its result code
%     • Computes & applies the calibration
%     • Plots calibration targets and gaze samples in a MATLAB figure
%     • Reports left/right loss %, lets experimenter Save, Re-calibrate, or Abort
%
% Inputs:
%   window, windowRect : Psychtoolbox window
%   eyetracker         : Tobii EyeTracker object
%   expParams          : struct (must contain baseDataDir, subjID, timestamp)
%
% Output:
%   calibrationData    : empty if aborted, or the calibration_result struct

HideCursor(window);
Screen('TextFont', window, 'Arial');
Screen('TextSize', window, 24);

white     = [1 1 1];
bgColor   = [0 0 0];
redColor  = [1 0 0];
blueColor = [0 0 1];

KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
spaceKey  = KbName('SPACE');
sKey      = KbName('S');
rKey      = KbName('R');

dotSizePix   = 30;
innerDotSize = dotSizePix * 0.5;

calibrationData  = [];
calibrationSaved = false;
calibrateAgain   = true;

try
    while calibrateAgain
        %% Welcome & wait for SPACE or ESC
        Screen('FillRect', window, bgColor);
        msg = [
            'Welcome to Tobii Calibration!'             newline newline ...
            'Experimenter Controls:'                    newline ...
            '- SPACE: Start calibration'                newline ...
            '- ESC:   Abort (no calibration)'          newline];
        DrawFormattedText(window, msg, 'center','center', white);
        Screen('Flip', window);

        % wait
        while true
            [~,~,keyCode] = KbCheck;
            if keyCode(escapeKey)
                ShowCursor(window);
                disp('Calibration aborted by experimenter.');
                return
            elseif keyCode(spaceKey)
                break
            end
        end

        %% Enter calibration mode (with manufacturer's retry on error210)
        calib = ScreenBasedCalibration(eyetracker);
        try
            calib.enter_calibration_mode();
        catch ME
            if strcmp(ME.identifier,'EnterCalibrationMode:error210')
                fprintf('Previous calibration not completed; restarting...\n');
                calib.leave_calibration_mode();
                calib.enter_calibration_mode();
            else
                rethrow(ME);
            end
        end

        %% Show & collect each calibration point
        [sx, sy] = Screen('WindowSize', window);
        pts = [0.1 0.1; 0.9 0.1; 0.5 0.5; 0.1 0.9; 0.9 0.9];

        for i = 1:size(pts,1)
            p = pts(i,:);
            Screen('FillRect', window, bgColor);
            Screen('DrawDots', window, p.*[sx sy], dotSizePix,   redColor,  [], 2);
            Screen('DrawDots', window, p.*[sx sy], innerDotSize, white,     [], 2);
            Screen('Flip', window);
            pause(1);

            cr = calib.collect_data(p);
            fprintf('Point [%.2f,%.2f] result: %d\n', p, cr.value);
            if cr.value ~= CalibrationStatus.Success
                cr = calib.collect_data(p);
                fprintf('  Retry → result: %d\n', cr.value);
            end
        end

        %% Compute & apply
        DrawFormattedText(window, 'Computing calibration…', 'center','center', white);
        Screen('Flip', window);
        calibration_result = calib.compute_and_apply();
      %  fprintf('Calibration Status: %d\n', calibration_result.Status.value);
        calib.leave_calibration_mode();

        if calibration_result.Status ~= CalibrationStatus.Success
            disp('Calibration failed to apply; retrying full calibration.');
            continue
        end

        %% Plot calibration targets & gaze samples
        if calibration_result.Status == CalibrationStatus.Success
            figure('Name','Tobii Calibration Plot','NumberTitle','off');
            hold on;
            set(gca,'YDir','reverse');
            axis([-0.2 1.2 -0.2 1.2]);
            CP = calibration_result.CalibrationPoints;
            for i = 1:numel(CP)
                % plot target
                pos = CP(i).PositionOnDisplayArea;
                plot(pos(1), pos(2), 'ok', 'LineWidth', 10);
                % plot each eye sample
                mSize = numel(CP(i).LeftEye);
                for j = 1:mSize
                    if CP(i).LeftEye(j).Validity  == CalibrationEyeValidity.ValidAndUsed
                        lep = CP(i).LeftEye(j).PositionOnDisplayArea;
                        plot(lep(1), lep(2), '-xr', 'LineWidth', 3);
                    end
                    if CP(i).RightEye(j).Validity == CalibrationEyeValidity.ValidAndUsed
                        rep = CP(i).RightEye(j).PositionOnDisplayArea;
                        plot(rep(1), rep(2), 'xb', 'LineWidth', 3);
                    end
                end
            end
            xlabel('Normalized X Position');
            ylabel('Normalized Y Position');
            title('Calibration targets (black) & gaze samples');
            hold off;
        end

        %% Compute left/right loss %
        totalPts = 0; leftValid = 0; rightValid = 0;
        CP = calibration_result.CalibrationPoints;
        for i = 1:numel(CP)
            for j = 1:numel(CP(i).LeftEye)
                totalPts = totalPts + 1;
                if CP(i).LeftEye(j).Validity  == CalibrationEyeValidity.ValidAndUsed,  leftValid  = leftValid+1;  end
                if CP(i).RightEye(j).Validity == CalibrationEyeValidity.ValidAndUsed,  rightValid = rightValid+1; end
            end
        end
        leftLoss  = 100*(1 - leftValid/totalPts);
        rightLoss = 100*(1 - rightValid/totalPts);

        %% Prompt Save vs Re-calibrate vs Abort
        statsMsg = sprintf(...
          'Calibration Stats:\nTotal samples: %d\nLeft loss: %.1f%%\nRight loss: %.1f%%\n\n' + ...
          'Press S=Save, R=Re-calibrate, ESC=Abort\n', totalPts, leftLoss, rightLoss);
        DrawFormattedText(window, statsMsg, 'center','center', white);
        Screen('Flip', window);

        while true
            [~,~,keyCode] = KbCheck;
            if keyCode(escapeKey)
                ShowCursor(window);
                disp('Calibration aborted without saving.');
                return
            elseif keyCode(sKey)
                outDir = expParams.subjPaths.eyeDir;
                if ~exist(outDir,'dir'), mkdir(outDir), end
                fn = sprintf('calibration_%s.mat', expParams.timestamp);
                save(fullfile(outDir,fn), 'calibration_result');
                calibrationSaved = true;
                calibrationData  = calibration_result;
                disp('Calibration saved.');
                break
            elseif keyCode(rKey)
                disp('Re-calibration selected.');
                break
            end
        end

        if calibrationSaved
            calibrateAgain = false;
        end
    end
catch ME
    ShowCursor(window);
    rethrow(ME);
end

ShowCursor(window);
if ~calibrationSaved
    disp('No calibration data saved.');
end
end
