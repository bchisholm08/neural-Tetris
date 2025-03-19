function p2()
    % Load subject data
    subjID = input('Enter subject ID: ', 's');
    [window, ~, params] = experiment_init(subjID);
    [eegHandle, tobiiHandle] = hardware_init();
    
    % Validate calibration
    calibrate_tobii(window, params);
    
    % Section 3: Eye Saccades
    disp('Starting Section 3: Eye Saccades');
    data = struct('trial', [], 'condition', [], 'saccade_latency', [], 'eeg_trigger', []);
    
    tetio_startTracking();
    for trial = 1:450 % 5 pieces × 3 conditions × 30 reps
        % First fixation
        draw_fixation(window, 'center', params);
        [~, startTime] = Screen('Flip', window);
        
        % Bottom fixation
        draw_fixation(window, 'bottom', params);
        Screen('Flip', window, startTime + 0.5);
        
        % Context presentation
        context = randi(3); % 1=none, 2=match, 3=non-match
        show_context(window, context, params);
        
        % Top piece presentation
        draw_fixation(window, 'top', params);
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