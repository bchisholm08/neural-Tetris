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


    gazeFile = fullfile(expParams.subjPaths.eyeDir, sprintf('%s_p1_gaze.mat', subjID));

    % init gaze
    blockGazeData = struct( ...
        'SystemTimeStamp',{}, ...  % Tobii SDK clock
        'DeviceTimeStamp',{}, ...  % Tobii device clock
        'GazeX',           {}, ...
        'GazeY',           {}, ...
        'PupilDiaL',       {}, ...
        'PupilDiaR',       {} );
    tDataCollectionBegin = NaN;
    tDataCollectionEnd   = NaN;

    if ~demoMode
        % open eyes and clear
        subResult = eyetracker.get_gaze_data();
        if isa(subResult,'StreamError')
            warning('Tobii subscription error: %s', subResult.Message);
        end
        pause(0.2);                   % start stream
        eyetracker.get_gaze_data();   % clear junk

        % start data stream and get time
        % tRecordingStart = eyetracker.get_system_time_stamp();
        tGameStart      = GetSecs;
        tDataCollectionBegin = tGameStart;
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
    nTotalTrials = expParams.p1.options.totalP1Trials;
    trialDur = zeros(1, nTotalTrials);  % preallocate timing vector

    if length(presentationPieceOrder) ~= expParams.p1.options.totalP1Trials
        % fatal experiment error, cannot continue
        error('ERROR: pieceOrder (%d) DNE expected trial count (%d)', length(presentationPieceOrder), expParams.p1.options.totalP1Trials);
    end

    trig = getTrig("section_start");
    fprintf(['section_start trigger sent: %d\n'],trig);
    if ~demoMode && ~isempty(ioObj)
        io64(ioObj, address, trig);
    end
    WaitSecs(2);

ifi     = expParams.screen.ifi;                     % single‐frame duration
fixDur  = expParams.p1.options.fixationDuration;    % 0.5 s
stimDur = expParams.p1.options.stimulusDuration;    % 0.1 s

    %% block loop should really have a break at AT LEAST halfway thru 490 trials...let subjects rest their eyes etc.
    for block = 1:expParams.p1.options.blocks
        %% trial loop
        for t = 1:expParams.p1.options.trialsPerBlock

            % trial params
            trialIndex = (block - 1) * expParams.p1.options.trialsPerBlock + t;
            pieceID = presentationPieceOrder(trialIndex);
            pieceName = pieces(pieceID).name; % More direct way to get piece name
            eegTrigger = getTrig(pieceName, 'alone');



            stimDur = expParams.p1.options.stimulusDuration;
            % handle fixation

            % Prepare the fixation cross frame in the back buffer
            tStart = tic;  % start timing this trial
            drawFixation(window, windowRect, expParams);
            % Flip to show the fixation cross and get its onset time
            fixationOnset = Screen('Flip', window);

            % Wait for the duration of the fixation period
            % THIS IS IMPROPER TIMING WaitSecs(expParams.p1.options.fixationDuration);

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

            % % Stimulus

            % % get piece for flip
            dstRect = CenterRectOnPoint(pieces(pieceID).rect, expParams.screen.center(1), expParams.screen.center(2));
            Screen('DrawTexture', window, pieces(pieceID).tex, [], dstRect);

            % % Flip at exact moment fixation ends. swaps fixation
            % % instantly. Record the timestamp of this event
            ifi = expParams.screen.ifi;
            stimOnset = Screen('Flip', window, fixationOnset + fixDur - ifi/2);

            % send trig at flip
            if ~demoMode && ~isempty(ioObj)
                io64(ioObj, address, eegTrigger);
            end

            % fixme (rm piece letter? I would like all the user output formatted the same
            fprintf('B#%d/T#%d | pID = %d (%s) | eegTrig = %d\n', block, t, pieceID, pieceName, eegTrigger);

            % piece is on screen. pause for length of presentation duration.
            % IMPROPER TIMING WaitSecs(expParams.p1.options.stimulusDuration);

            % iti
            drawFixation(window, windowRect, expParams); %

            itiOnset = Screen('Flip', window, stimOnset + stimDur - ifi/2);

            % Log behavioral data
            % ordering is 1:1 to .csv file cols
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

            % wait for duration of ITI
            %  WaitSecs(itiDuration);


            trialDur(trialIndex) = toc(tStart);

            % pull ITI into script
            iti = expParams.p1.options.itiFcn();
            itiDuration = iti;

            WaitSecs(iti);

        end % end trial loop

    end % p1 block end

    trig = getTrig('section_end');
    fprintf(['section_end trigger sent: %d\n'],trig);
    if ~demoMode && ~isempty(ioObj)
        io64(ioObj, address, trig);
    end
    WaitSecs(1);

    expParams.timing.p1 = trialDur;
    save(fullfile(expParams.subjPaths.miscDir,'p1_timingInfo.mat'),'trialDur');

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
        tDataCollectionEnd = GetSecs;
    else
        WaitSecs(1);
        tDataCollectionEnd = GetSecs;
    end


    % QC #s
    lossL = mean([blockGazeData.PupilDiaL] == 0);
    lossR = mean([blockGazeData.PupilDiaR] == 0);


    % save gaze file
    save(gazeFile, ... % named @ top of script
        'blockGazeData', ...
        'tDataCollectionBegin', ...
        'tDataCollectionEnd', ...
        'lossL', 'lossR', ...
        'demoMode', ...
        '-v7.3'); % v7.3 more effecient saving

    % not sure if this will be useful or not--too simple to NOT include
    expParams.p1.options.sectionDoneFlag = 1;

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