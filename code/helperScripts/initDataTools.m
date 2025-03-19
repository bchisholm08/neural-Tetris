function [ioObj, address, eyetracker] = initDataTools()
    % EEG Trigger Setup
    ioObj = io64;
    status = io64(ioObj);
    address = hex2dec('3FF8');
    
    % Tobii Eye Tracker
    Tobii = EyeTrackingOperations();
    eyetracker_address = 'tet-tcp://169.254.6.40';
    eyetracker = Tobii.get_eyetracker(eyetracker_address);
    
    if isa(eyetracker, 'EyeTracker')
        fprintf('Tobii initialized at %s\n', eyetracker.Address);
    else
        error('Eye tracker not found!');
    end
end