%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 7.8.2025
%
% Description: Facilitates playback of one Tetris game with no player control.
% This also includes long with eye tracking data and EEG triggers when not in demo mode. 
%
%-------------------------------------------------------
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

snapshots = data.boardSnapshot; 
fprintf('First EEG Trigger: %d | Last EEG Trigger: %d\n', snapshots(1).eegTrigs, snapshots(end).eegTrigs);


if isempty(snapshots(1).eegTrigs) || snapshots(1).eegTrigs ~= 101
    fakeStart = snapshots(1);
    fakeStart.eegTrigs = 101;
    fakeStart.timestamp = snapshots(1).timestamp - 0.001;  % 1 ms before first frame
    snapshots = [fakeStart, snapshots];
end

% Check and insert missing final EEG trigger (124)
if isempty(snapshots(end).eegTrigs) || snapshots(end).eegTrigs ~= 124
    fakeEnd = snapshots(end);
    fakeEnd.eegTrigs = 124;
    fakeEnd.timestamp = snapshots(end).timestamp + 0.001;  % 1 ms after last frame
    snapshots = [snapshots, fakeEnd];
end

% begin eye tings

gazeFile = fullfile(expParams.subjPaths.eyeDir, ...
            sprintf('%s_gameReplay%03d_gaze.mat', subjID, gameIdx));

% init gaze struct
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
    % open & flush any errors
    subResult = eyetracker.get_gaze_data();
    if isa(subResult,'StreamError')
        warning('Tobii subscription error: %s', subResult.Message);
    end
    pause(0.2);                   % let data stack
    eyetracker.get_gaze_data();   % clear junk

    %  start with timestamp 
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

% get timing
times = [snapshots.timestamp];
delays = [0, diff(times)];

% set up screen (FIXME: PULL FROM expParams) 
blockSize   = expParams.visual.blockSize;
boardWidth  = expParams.visual.boardW;
boardHeight = expParams.visual.boardH;
boardX      = (windowRect(3) - boardWidth * blockSize) / 2;
boardY      = (windowRect(4) - boardHeight * blockSize) / 2;
boardRect   = [boardX, boardY, boardX + boardWidth*blockSize, boardY + boardHeight*blockSize];

try % begin try for eye data

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
        
    % handle pause
    pauseDur = handlePause(window, expParams.keys);
    if isempty(pauseDur)
        pauseDur = 0;
    end

    if pauseDur > 0
        lastDropTime = lastDropTime + pauseDur;
    end
    
    % eye data 
    board = snapshots(k).board;

    % Draw board
    Screen('FillRect', window, [0 0 0]);  % Clear

    % 
    Screen('FrameRect', window, expParams.colors.gray, boardRect, 5);
       for r = 1:boardHeight
            for c = 1:boardWidth
                pieceID = board(r,c); % r,c
                if pieceID > 0
                    x = boardX + (c-1)*blockSize;
                    y = boardY + (boardHeight - r)*blockSize;
                    blockRect = [x, y, x+blockSize, y+blockSize];

                    blockColor = expParams.colors.white; % uint 128                   

                    Screen('FillRect', window, blockColor, blockRect);
                    Screen('FrameRect', window, [0 0 0], blockRect, 1); % black border
                end
            end
       end


    % find our trigger
    replayTrig = snapshots(k).eegTrigs;

            
    Screen('Flip', window);
    % send trigger at replay flip 
    if ~isempty(replayTrig) && ~isnan(replayTrig)
        if ~demoMode && ~isempty(ioObj)
        
        io64(ioObj, address, replayTrig + 100);
        end 
        
        fprintf('[REPLAY] Trigger → %3d @ %.4f\n', replayTrig + 100, GetSecs); 
        
    end

    % Wait for frame delay (hint as to sampling rate and FPS we actually capture) 

    % FIX ME THIS TIMING IS BAD!!!!!!!!!!!!!!!!!!!!!!! JITTER B/C OF LARGE
    % FILE OR BAD CODING?!?!?!?! 
    WaitSecs(delays(k));

end % snapshots replay loop end

  if ~demoMode
        % final data and light error
        rawF = eyetracker.get_gaze_data();
        if isa(rawF,'StreamError')
            warning('Final gaze error: %s', rawF.Message);
            rawF = [];
        end

        for i = 1:numel(rawF)
            s = rawF(i);

            % handle missing eye dat
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


        % stop & timestmp 
        % tRecordingEnd = eyetracker.get_system_time_stamp();
        tRecordingEnd = GetSecs;
    else
        WaitSecs(1);  % demo stub
        tRecordingEnd = GetSecs;
    end
	
	
    % qc
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
