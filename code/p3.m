function p3()
    % Load subject data
    subjID = input('Enter subject ID: ', 's');
    [window, ~, params] = experiment_init(subjID);
    [eegHandle, tobiiHandle] = hardware_init();
    
    % Section 4: 4-AFC Task
    disp('Starting Section 4: 4-AFC Task');
    data = struct('block', [], 'trial', [], 'response', [], 'rt', [], 'correct', []);
    keyMap = containers.Map({'1','2','3','4'}, {'fit_reward','fit','no_fit','garbage'});
    
    tetio_startTracking();
    for block = 1:20
        for t = 1:150
            % Present 4-AFC
            [correctKey, options] = generate_afc_trial();
            [response, rt] = collect_response(window, options);
            
            % Log data
            data(end+1) = struct(...
                'block', block,...
                'trial', t,...
                'response', keyMap(response),...
                'rt', rt,...
                'correct', strcmp(response, correctKey));
            
            % ITI
            WaitSecs(0.5);
            Screen('Flip', window);
            WaitSecs(0.8 + rand*0.4);
        end
    end
    save(fullfile('Participants', subjID, 'p4', 'section4.mat'), 'data');
    tetio_stopTracking();
    tetio_saveData(fullfile('Participants', subjID, 'p4', 'section4_eyetrack.tsv'));
    
    % Cleanup
    tetio_disconnectTracker();
    sca;
end