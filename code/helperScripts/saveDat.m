function saveDat(section, subjID, data, params, demoMode)
    if demoMode, return; end
    
    % Generate filename
    dateStr = datestr(now, 'mmddyy');
    filename = sprintf('%s_%sDat%s.mat', subjID, section, dateStr);
    savePath = fullfile('Participants', subjID, section, filename);
    
    % Save data
    save(savePath, 'data', 'params', '-v7.3'); % -v7.3 for large gazeData  
    
    % Save hardware settings
    hwSettings = struct('ioAddress', params.ioAddress, 'tobiiSettings', params.eyetracker);
    miscPath = fullfile('Participants', subjID, 'misc', 'hardware_settings.mat');
    save(miscPath, 'hwSettings');
end