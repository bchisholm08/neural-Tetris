function p2()
    
    %  clean slate
    clear;
    close all;
    sca;
    helperScriptsPath = fullfile(fileparts(mfilename('fullpath')), 'helperScripts');
    addpath(helperScriptsPath);
try
    % subj input
    subjID = input('Enter subject ID (e.g., P01): ', 's');
    demoMode = input('Enable demo mode? (1 = yes, 0 = no): ');
    [window, windowRect, params] = initExperiment(subjID, demoMode);
    [eegHandle, tobiiHandle] = initDataTools();
    
    % initialize hardware 
  if ~demoMode
        [ioObj, address, eyetracker] = initDataTools();
    else
        ioObj = []; address = []; eyetracker = [];
        warning("Tobii and Biosemi not connected for data collection.\nIs demo mode on?");
  end

    baseDataDir = 'C:\Users\chish071\Desktop\tetris\data';
    rootDir = fullfile(baseDataDir, 'subjData', subjID);
    if ~exist(rootDir, 'dir')
        mkdir(rootDir);
        arrayfun(@(x) mkdir(fullfile(rootDir, sprintf('p%d', x))), 1:4);
        mkdir(fullfile(rootDir, 'misc'));
    end

    % check for dir creation
    if ~exist(rootDir, 'dir')
        error('Failed to create directory: %s', rootDir);
    end

    %% Add in instruction screen(s), and practice blocks...
    p3instruct(window,params);
    % Section 3: Eye Saccades
    disp('Starting Section 3: Eye Saccades');
    data = struct('trial', [], 'condition', [], 'saccade_latency', [], 'eeg_trigger', []);
    
    tetio_startTracking();
    for trial = 1:450 % 5 pieces × 3 conditions × 30 reps
        % First fixation
        drawFixation(window, 'center', params);
        % suggested code...Screen('Flip', window);
        [~, startTime] = Screen('Flip', window);
        
        % Bottom fixation
        %draw_fixation(window, 'bottom', params);
        drawFixation(window,'bottom',params);
        [~, startTime]= Screen('Flip', window, startTime + 0.5);
        
        % Context presentation
        context = randi(3); % 1=none, 2=match, 3=non-match
        show_context(window, context, params);
        
        % Top piece presentation
        drawFixation(window, 'top', params);
        [~, pieceOnset] = Screen('Flip', window);
        
        % Log data
        data(end+1) = struct(...
            'trial', trial,...
            'condition', context,...
            'saccade_latency', NaN,...
            'eeg_trigger', 100 + context);
        
        % ITI
        WaitSecs(1.5); % Saccade time
        Screen('Flip', window);
        WaitSecs(2 + rand); % 2-3s ITI
    end
    save(fullfile('Participants', subjID, 'p3', 'section3.mat'), 'data');
    tetio_stopTracking();
    tetio_saveData(fullfile('Participants', subjID, 'p3', 'section3_eyetrack.tsv'));
    
    % Cleanup
    tetio_disconnectTracker();
    sca;
end