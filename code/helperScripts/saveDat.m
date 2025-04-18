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
        % note demo mode 
        logFile = fullfile(rootDir, 'misc', sprintf('demoLog_%s.txt', params.timestamp));

        % check folder ex 
        miscDir = fileparts(logFile);
        if ~exist(miscDir, 'dir'), mkdir(miscDir); end

        % open log 
        fid = fopen(logFile, 'w');
        if fid == -1
            error('Could not open demo log file for writing: %s', logFile);
        end

        fprintf(fid, 'DemoMode = ON\nSubject = %s\nTrials = %d\nDate = %s\n', ...
            subjID, length(data), datestr(now, 'yyyy-mm-dd HH:MM:SS'));
        fclose(fid);

    % ========== ACTUAL DATA SAVE (non-demo) ========== 
    else
        % Construct date str 
        dateStr = datestr(now, 'mmddyy');
       
        sectionDir = fullfile(rootDir, section);
        if ~exist(sectionDir, 'dir')
            mkdir(sectionDir);
        end

        % Create .mat (e.g., P01_p1Dat040123.mat)
        filename = sprintf('%s_%sDat%s.mat', subjID, section, dateStr);
        savePath = fullfile(sectionDir, filename);
        % save data and params 
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
    % notify save 
if isfield(params, 'currentBlock') && isfield(params, 'totalBlocks')
    blocksRemaining = params.totalBlocks - params.currentBlock;
    fprintf('\n==================================\n');
    fprintf('PUPILLOMETRY DATA SAVED FOR BLOCK #%d\n', params.currentBlock);
    fprintf('==================================\n');
    fprintf('%d BLOCKS TO GO\n', blocksRemaining);
    fprintf('==================================\n\n');
else
    fprintf('\n==================================\n');
    fprintf('PUPILLOMETRY DATA SAVED\n');
    fprintf('==================================\n\n');

end
