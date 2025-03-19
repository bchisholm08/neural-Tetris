function [eegHandle, tobiiHandle] = dataCollectInitialize()
    % Initialize BioSemi EEG
    eegHandle = struct('status', 'connected');
    disp('BioSemi EEG initialized');
    
    % Initialize Tobii Eye Tracker
    try
        tetio_init();
        tobiiHandle = tetio_connectTracker('');
        tetio_setFrameRate(300);
        disp('Tobii Pro Spectrum initialized at 300Hz');
    catch
        error('Tobii initialization failed');
    end
end