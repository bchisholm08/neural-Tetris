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

% Load snapshot struct from .mat
data = load(snapshotFile);

snapshots = data.boardSnapshot;  % or change field name accordingly

% begin eye tings

gazeFile = fullfile(expParams.subjPaths.eyeDir, ...
            sprintf('%s_gameReplay%03d_gaze.mat', subjID, gameIdx));

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

    % — c) mark "recording" start with timestamp only —
    % tRecordingStart = eyetracker.get_system_time_stamp();
    tGameStart      = GetSecs;
end


if ~demoMode
    % flush stray samples & catch errors
    raw0 = eyetracker.get_gaze_data();
    if isa(raw0,'StreamError')
        warning('Pre-loop gaze flush error: %s', raw0.Message);
    end
end	


% Extract timing
times = [snapshots.timestamp];
delays = [0, diff(times)];

% Set up screen (FIXME: PULL FROM expParams) 
blockSize   = expParams.visual.blockSize;
boardWidth  = expParams.visual.boardW;
boardHeight = expParams.visual.boardH;
boardX      = (windowRect(3) - boardWidth * blockSize) / 2;
boardY      = (windowRect(4) - boardHeight * blockSize) / 2;
boardRect   = [boardX, boardY, boardX + boardWidth*blockSize, boardY + boardHeight*blockSize];

try % begin try for eye 

if ~demoMode
    raw = eyetracker.get_gaze_data();
    if isa(raw,'StreamError')
        warning('Mid-loop gaze error: %s', raw.Message);
        raw = [];
    end
    for i = 1:numel(raw)
        s = raw(i);

        blockGazeData(end+1) = struct( ...
    'SystemTimeStamp', s.SystemTimeStamp, ...
    'DeviceTimeStamp', s.DeviceTimeStamp, ...
    'GazeX',           s.LeftEye.GazePoint.OnDisplayArea(1), ...
    'GazeY',           s.LeftEye.GazePoint.OnDisplayArea(2), ...
    'PupilDiaL',       s.LeftEye.Pupil.Diameter, ...
    'PupilDiaR',       s.RightEye.Pupil.Diameter ...
);

    end
end	

for k = 1:length(snapshots) % for length of snapshots...(not frames--as a matter of fact MORE precise than frame. This is not an issue until it is (i.e. taking 120 seconds to save a .mat snapshot file) 
        % eye data 
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
        rawF = eyetracker.get_gaze_data();
        if isa(rawF,'StreamError')
            warning('Final gaze error: %s', rawF.Message);
            rawF = [];
        end

        for i = 1:numel(rawF)
            s = rawF(i);

            % handle possible missing eye data
            if isfield(s, 'LeftEye') && ~isempty(s.LeftEye) && isfield(s.LeftEye, 'GazePoint') && isfield(s.LeftEye.GazePoint, 'OnDisplayArea')
                gazeX = s.LeftEye.GazePoint.OnDisplayArea(1);
                gazeY = s.LeftEye.GazePoint.OnDisplayArea(2);
                pupL  = s.LeftEye.Pupil.Diameter;
            else
                gazeX = NaN;
                gazeY = NaN;
                pupL  = NaN;
            end

            if isfield(s, 'RightEye') && ~isempty(s.RightEye) && isfield(s.RightEye, 'Pupil')
                pupR = s.RightEye.Pupil.Diameter;
            else
                pupR = NaN;
            end

            blockGazeData(end+1) = struct( ...
                'SystemTimeStamp', s.SystemTimeStamp, ...
                'DeviceTimeStamp', s.DeviceTimeStamp, ...
                'GazeX',           gazeX, ...
                'GazeY',           gazeY, ...
                'PupilDiaL',       pupL, ...
                'PupilDiaR',       pupR ...
                );
        end


        % — stop recording & stamp Tobii clock at end —
        % eyetracker.stop_recording();
        % tRecordingEnd = eyetracker.get_system_time_stamp();
        tRecordingEnd = GetSecs;
    else
        WaitSecs(1);  % demo stub
        tRecordingEnd = GetSecs;
    end
	
	
    % — compute QC loss metrics —
    lossL = mean([blockGazeData.PupilDiaL] == 0);
    lossR = mean([blockGazeData.PupilDiaR] == 0);
	
	
	% save gaze file 
    save(gazeFile, ... % named @ top of script 
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
