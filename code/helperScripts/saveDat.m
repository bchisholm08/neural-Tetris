function saveDat(section, subjID, data, params, demoMode)
    if demoMode, return; end
    
    % Generate filename
    dateStr = datestr(now, 'mmddyy');
    filename = sprintf('%s_%sDat%s.mat', subjID, section, dateStr);
    savePath = fullfile('Participants', subjID, section, filename);
    
    % Save data
    version = '-v7.3';
    save(savePath, 'data', 'params', version);
    
    % Save hardware settings
    hwSettings = struct('ioAddress', params.ioAddress, 'tobiiSettings', params.eyetracker);
    miscPath = fullfile('Participants', subjID, 'misc', 'hardware_settings.mat');
    save(miscPath, 'hwSettings');
end