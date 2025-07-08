%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: First section of the human tetris experiment. This section
% is focused on obtaining evoked responses to each of the tetris pieces.
% Each piece is presented
%
%-------------------------------------------------------
function p1(subjID, demoMode, window, windowRect, expParams, ioObj, address, eyetracker)

try %% main exp. try/C
    %% instruction screen call
    p1instruct(window, expParams);
    
   
% begin eye tings

gazeFile = fullfile(expParams.subjPaths.eyeDir, ...
            sprintf('%s_p1_gaze.mat', subjID));

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


    pieces = getTetrino(expParams);
    nPieces = length(pieces);

    presentationPieceOrder = randi(nPieces, 1, expParams.p1.options.totalP1Trials);
    % returns random list of numbers from 1 to 7, for the number of totalP1Trials input

    if length(presentationPieceOrder) ~= expParams.p1.options.totalP1Trials
        % fatal experiment error, cgit aannot continue
        error('ERROR: pieceOrder (%d) DNE expected trial count (%d)', length(presentationPieceOrder), expParams.p1.options.totalP1Trials);
    end

    %% block loop       should really have a break at AT LEAST halfway thru 490 trials...let subjects rest their eyes etc.
    for block = 1:expParams.p1.options.blocks
        %% trial loop
        for t = 1:expParams.p1.options.trialsPerBlock

            % --- Get Trial Information ---
            trialIndex = (block - 1) * expParams.p1.options.trialsPerBlock + t;
            pieceID = presentationPieceOrder(trialIndex);
            pieceName = pieces(pieceID).name; % More direct way to get piece name
            eegTrigger = getTrig(pieceName, 'alone');

            % pull ITI into script
            iti = expParams.p1.options.itiFcn();
            itiDuration = iti;

            % --- 1. Fixation Period ---

            % Prepare the fixation cross frame in the back buffer
            drawFixation(window, windowRect, expParams); %
            % Flip to show the fixation cross and get its onset time
            fixationOnset = Screen('Flip', window);

            % Wait for the duration of the fixation period
            WaitSecs(expParams.p1.options.fixationDuration);

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

            % --- 2. Stimulus Presentation ---
            % Prepare the piece frame in the back buffer
            Screen('DrawTexture', window, pieces(pieceID).tex);
            % Flip at the exact moment the fixation period ends. This swaps the fixation
            % for the piece instantly. Record the timestamp of this event.
            stimOnset = Screen('Flip', window);

            % Send EEG trigger precisely at stimulus onset
            if ~demoMode && ~isempty(ioObj)
                io64(ioObj, address, eegTrigger);
            end

            % fixme (rm piece letter? I would like all the user output formatted the same
            fprintf('B#%d/T#%d | pID = %d (%s) | eegTrig = %d\n', block, t, pieceID, pieceName, eegTrigger);

            % piece is on screen. pause for length of presentation duration.
            WaitSecs(expParams.p1.options.stimulusDuration);


            % --- 3. Inter-Trial Interval (ITI) ---
            % Prepare the ITI frame (which is just the fixation cross again)
            drawFixation(window, windowRect, expParams); %
            % Flip at the exact moment the stimulus duration ends. This swaps the
            % piece for the fixation cross instantly.
            itiOnset = Screen('Flip', window);

            % Log behavioral data for this trial.
            % ordering is directly reflected in .csv file
            data(trialIndex).block = block;
            data(trialIndex).trial = t;
            data(trialIndex).pieceID = pieceID;
            data(trialIndex).pieceName = pieceName;
            data(trialIndex).fixationOnset = fixationOnset;
            data(trialIndex).stimOnset = stimOnset;
            data(trialIndex).itiOnset = itiOnset;
            data(trialIndex).eegTrigger = eegTrigger;
            data(trialIndex).trialDuration = stimOnset - fixationOnset;


            % during this time check for pause
            handlePause(window, expParams.keys);

            % The fixation cross is now on screen. Wait for the rest of the ITI.
            WaitSecs(itiDuration);



        end % --- End of trial loop ---
        % no breaks in p1
    end % p1 block end



    % not sure if this will be useful or not--too simple to NOT include
    expParams.p1.options.sectionDoneFlag = 1;
    
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
    % save data
    saveDat('p1', subjID, data, expParams, demoMode);

catch ME % get MException object
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
    fprintf(2, 'ERROR IN SCRIPT: %s\n', ME.stack(1).file); % where error occurred
    fprintf(2, 'Function: %s, Line: %d\n', ME.stack(1).name, ME.stack(1).line); % function name with line
    fprintf(2, 'Error Message: %s\n', ME.message);
    fprintf(2, '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');

    rethrow(ME); % rethrow error for wrapper
end % try exp end
end % p1 end