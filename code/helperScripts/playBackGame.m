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

% update .mat variable structure
% struct('timestamp',GetSecs,'board',S.boardMatrix, 'eegTrigs', lastEEGTrig)

snapshots = data.boardSnapshot;  % or change field name accordingly

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

try % begin try for eye 
        
if ~demoMode   

blockGazeData = struct( ...
    'DeviceTimeStamp', {}, ...
    'GazeX',           {}, ...
    'GazeY',           {}, ...
    'PupilDiaL',       {}, ...
    'PupilDiaR',       {} );

        % add in struct to save  
        WaitSecs(1);

tGameStart = GetSecs;
    eyetracker.start_recording();

    % flush any leftover buffer so samples align with replay start
    eyetracker.get_gaze_data();
end 

for k = 1:length(snapshots) % for length of snapshots...(not frames--as a matter of fact MORE precise than frame. This is not an issue until it is (i.e. taking 120 seconds to save a .mat snapshot file) 
    if ~demoMode
        newSamples = eyetracker.get_gaze_data();   % grab ALL unread samples
        if ~isempty(newSamples)
            blockGazeData(end+1:end+numel(newSamples)) = newSamples;
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
    % final flush
    tailSamples = eyetracker.get_gaze_data();
    if ~isempty(tailSamples)
        blockGazeData(end+1:end+numel(tailSamples)) = tailSamples;
    end

    eyetracker.stop_recording();
    tGameEnd = GetSecs;

    lossL = mean([blockGazeData.PupilDiaL] == 0);
    lossR = mean([blockGazeData.PupilDiaR] == 0);

    gazeFile = fullfile(expParams.subjPaths.eyeDir, ...
        sprintf('%s_gamePlayback%03d_gaze.mat', subjID, gameIdx));
    save(gazeFile, 'blockGazeData', 'tGameStart', 'tGameEnd', 'lossL', 'lossR');
end


catch ME
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    fprintf(2, 'ERROR IN SCRIPT: %s\n', ME.stack(1).file); % where error occurred
    fprintf(2, 'Function: %s, Line: %d\n', ME.stack(1).name, ME.stack(1).line); % function name with line
    fprintf(2, 'Error Message: %s\n', ME.message);
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    
    rethrow(ME); % rethrow error for wrapper 
end % try end  
end % function end 
