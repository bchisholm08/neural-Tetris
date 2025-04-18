function saveDat(section, subjID, data, params, demoMode)
    % Ensure base directory from params, or use fallback
    if isfield(params, 'baseDataDir')
        baseDir = params.baseDataDir;
    else
        baseDir = fullfile(pwd, 'data');  % fallback
    end

    % Root directory for subject
    rootDir = fullfile(baseDir, 'subjData', subjID);

    % Add timestamp if missing
    if ~isfield(params, 'timestamp')
        params.timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    end

    % ========== DEMO MODE LOGGING ========== 
    if demoMode
        % We'll write a small text log to note that "DemoMode = ON"
        logFile = fullfile(rootDir, 'misc', sprintf('demoLog_%s.txt', params.timestamp));

        % Make sure the folder exists
        miscDir = fileparts(logFile);
        if ~exist(miscDir, 'dir'), mkdir(miscDir); end

        % Open the log file safely, checking for errors
        fid = fopen(logFile, 'w');
        if fid == -1
            error('Could not open demo log file for writing: %s', logFile);
        end

        fprintf(fid, 'DemoMode = ON\nSubject = %s\nTrials = %d\nDate = %s\n', ...
            subjID, length(data), datestr(now, 'yyyy-mm-dd HH:MM:SS'));
        fclose(fid);

    % ========== ACTUAL DATA SAVE (non-demo) ========== 
    else
        % Construct a date string for filename, e.g. mmddyy or yyyymmdd
        dateStr = datestr(now, 'mmddyy');
        % For a more verbose style, you could do something like:
        % dateStr = datestr(now, 'yyyymmdd_HHMMSS');

        % Make a subject-specific directory for this "section" of data
        sectionDir = fullfile(rootDir, section);
        if ~exist(sectionDir, 'dir')
            mkdir(sectionDir);
        end

        % Create the final .mat filename (e.g., P01_p1Dat040123.mat)
        filename = sprintf('%s_%sDat%s.mat', subjID, section, dateStr);
        savePath = fullfile(sectionDir, filename);

        % Save the main data and the params
        % -v7.3 is good for large structs/arrays
        save(savePath, 'data', 'params', '-v7.3');

        % Optionally, save minimal hardware snapshot if present
        hwSettings = struct();
        if isfield(params, 'ioAddress'),  hwSettings.ioAddress  = params.ioAddress;  end
        if isfield(params, 'eyetracker'), hwSettings.eyetracker = params.eyetracker; end

        % Save hardware settings into the misc folder
        miscPath = fullfile(rootDir, 'misc');
        if ~exist(miscPath, 'dir'), mkdir(miscPath); end
        save(fullfile(miscPath, 'hardware_settings.mat'), 'hwSettings');
    end
end
