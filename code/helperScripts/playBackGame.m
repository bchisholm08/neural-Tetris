function playBackGame(snapshotFile, expParams)
window = expParams.screen.window;
windowRect = expParams.screen.windowRect;
demoMode  = expParams.demoMode;
ioObj     = expParams.ioObj;
address   = expParams.address;
eyetracker = expParams.eyeTracker;       
subjID     = expParams.subjID;           
gameIdx    = expParams.p5.gameplayCount; 
% FIXME add in expParam window/screen vars
gazeFile = fullfile(expParams.subjPaths.eyeDir, ...
            sprintf('%s_gameReplay%03d_gaze.mat', subjID, gameIdx));

% Load snapshot struct from .mat
data = load(snapshotFile);

% update .mat variable structure
% struct('timestamp',GetSecs,'board',S.boardMatrix, 'eegTrigs', lastEEGTrig)

snapshots = data.boardSnapshot;  % or change field name accordingly

% initialize gaze buffer (flat struct, both timestamps)
% — a) init gaze buffer with both timestamps —
blockGazeData = struct( ...
'SystemTimeStamp',{}, ...  % Tobii SDK clock
'DeviceTimeStamp',{}, ...  % Tobii device clock
'GazeX',           {}, ...
'GazeY',           {}, ...
'PupilDiaL',       {}, ...
'PupilDiaR',       {} );
    tRecordingStart = NaN;
    tRecordingEnd   = NaN;
if ~demoMode

    % — b) subscribe & flush any errors —
    subResult = eyetracker.get_gaze_data();
    if isa(subResult,'StreamError')
        warning('Tobii subscription error: %s', subResult.Message);
    end
    pause(0.2);                   % let the stream start
    eyetracker.get_gaze_data();   % clear junk

    % — c) start recording & stamp clocks —
    eyetracker.start_recording();
    tRecordingStart = eyetracker.get_system_time_stamp();
    tGameStart      = GetSecs;
    
end



% Extract timing
times = [snapshots.timestamp];
delays = [0, diff(times)];

% Set up screen (FIXME: PULL FROM expParams) 
blockSize   = 30;
boardWidth  = 10;
boardHeight = 20;
boardX      = (windowRect(3) - boardWidth * blockSize) / 2;
boardY      = (windowRect(4) - boardHeight * blockSize) / 2;
boardRect   = [boardX, boardY, boardX + boardWidth*blockSize, boardY + boardHeight*blockSize];

if ~demoMode
    % flush stray samples & catch errors
    raw0 = eyetracker.get_gaze_data();
    if isa(raw0,'StreamError')
        warning('Pre-loop gaze flush error: %s', raw0.Message);
    end
end

try % begin try for eye 
        


% begin eye tings
% GAZE GRAB ───────────────────────────────────────────────
% — pull & append all samples with error‐check —
if ~demoMode
    raw = eyetracker.get_gaze_data('flat');
    if isa(raw,'StreamError')
        warning('Mid-loop gaze error: %s', raw.Message);
        raw = [];
    end
    for i = 1:numel(raw)
        s = raw(i);
        blockGazeData(end+1) = struct( ...
            'SystemTimeStamp', s.SystemTimeStamp, ...
            'DeviceTimeStamp', s.DeviceTimeStamp, ...
            'GazeX',           s.LeftEye_GazePoint_OnDisplayArea(1), ...
            'GazeY',           s.LeftEye_GazePoint_OnDisplayArea(2), ...
            'PupilDiaL',       s.LeftEye_Pupil_Diameter, ...
            'PupilDiaR',       s.RightEye_Pupil_Diameter ...
        );
    end
end


for k = 1:length(snapshots) % for length of snapshots...(not frames--as a matter of fact MORE precise than frame. This is not an issue until it is (i.e. taking 120 seconds to save a .mat snapshot file) 
        % eye data 
    if ~demoMode
            % pull & append all samples in flat mode with error-check
            raw = eyetracker.get_gaze_data('flat');
            if isa(raw,'StreamError')
                warning('Mid-loop gaze error: %s', raw.Message);
                raw = [];
            end
            for i = 1:numel(raw)
                s = raw(i);
                blockGazeData(end+1) = struct( ...
                    'SystemTimeStamp', s.SystemTimeStamp, ...
                    'DeviceTimeStamp', s.DeviceTimeStamp, ...
                    'GazeX',           s.LeftEye_GazePoint_OnDisplayArea(1), ...
                    'GazeY',           s.LeftEye_GazePoint_OnDisplayArea(2), ...
                    'PupilDiaL',       s.LeftEye_Pupil_Diameter, ...
                    'PupilDiaR',       s.RightEye_Pupil_Diameter ...
                );
            end
    end


    board = snapshots(k).board;

    % Draw board
    Screen('FillRect', window, [0 0 0]);  % Clear

    % draw board frame 
    Screen('FrameRect', window, [255 255 255], boardRect, 5);
       for r = 1:boardHeight
            for c = 1:boardWidth
                pieceID = board(r,c); % r,c
                if pieceID > 0
                    x = boardX + (c-1)*blockSize;
                    y = boardY + (boardHeight - r)*blockSize;
                    blockRect = [x, y, x+blockSize, y+blockSize];

                    blockColor = expParams.colors.piece; % should be gray                   

                    Screen('FillRect', window, blockColor, blockRect);
                    Screen('FrameRect', window, [0 0 0], blockRect, 1); % black border
                end
            end
        end

% send triggers during replay 
    replayTrig = snapshots(k).eegTrigs;
    if ~isempty(replayTrig) && ~isnan(replayTrig)
        if ~demoMode && ~isempty(ioObj)
        % send to port
        io64(ioObj, address, replayTrig + 100);
        end 
        % trig debugging 
        fprintf('[REPLAY] Trigger → %3d @ %.4f\n', replayTrig, GetSecs); % triggers have 100 added 
        
    end

    % add EEG triggers @ flip? 
    Screen('Flip', window);

    % Wait for frame delay (hint as to sampling rate and FPS we actually capture) 

    % FIX ME THIS TIMING IS BAD!!!!!!!!!!!!!!!!!!!!!!! JITTER B/C OF LARGE
    % FILE OR BAD CODING?!?!?!?! 
    WaitSecs(delays(k));

end % snapshots replay loop end


if ~demoMode
    % — final pull & error‐check —
    rawF = eyetracker.get_gaze_data('flat');
    if isa(rawF,'StreamError')
        warning('Final gaze error: %s', rawF.Message);
        rawF = [];
    end
    for i = 1:numel(rawF)
        % append into blockGazeData…
    end

    % — stop recording & stamp Tobii clock at end —
    eyetracker.stop_recording();
    tRecordingEnd = eyetracker.get_system_time_stamp();
else
    WaitSecs(1);  % demo stub
    tRecordingEnd = GetSecs; 
end

% — compute QC loss metrics —
lossL = mean([blockGazeData.PupilDiaL] == 0);
lossR = mean([blockGazeData.PupilDiaR] == 0);

% — save gaze file for QC (always) —
gazeFile = fullfile(expParams.subjPaths.eyeDir, ...
    sprintf('%s_gamePlayback%03d_gaze.mat', subjID, gameIdx));
save(gazeFile, ...
     'blockGazeData', ...
     'tRecordingStart', ...
     'tRecordingEnd', ...
     'lossL', 'lossR', ...
     'demoMode', ...
     '-v7.3');

catch ME
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    fprintf(2, 'ERROR IN SCRIPT: %s\n', ME.stack(1).file); % where error occurred
    fprintf(2, 'Function: %s, Line: %d\n', ME.stack(1).name, ME.stack(1).line); % function name with line
    fprintf(2, 'Error Message: %s\n', ME.message);
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    
    rethrow(ME); % rethrow error for wrapper 
end % try end  
end % function end 
