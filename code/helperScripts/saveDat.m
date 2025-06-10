%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: 
%                            
%-------------------------------------------------------
function saveDat(section, subjID, data, expParams, demoMode)
    
    % Ensure base directory from params, or use fallback
    assert(isfield(expParams.subjPaths, 'subjRootDir'));

    % Root directory for curr subj
    subjRootDataDir = expParams.subjPaths.subjRootDir;

    % if missing, add timestamp 
    if ~isfield(expParams, 'timestamp')
        expParams.timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    end

    %% demoMode data save 
    if demoMode
        % note demo mode 
        % error out here on root dir 
        logFile = fullfile(subjRootDataDir, 'misc', sprintf('demoLog_%s.txt', expParams.timestamp));

        % check folder ex 
        miscDir = fileparts(logFile);
        if ~exist(miscDir, 'dir'), mkdir(miscDir); end

        % open log 
        fid = fopen(logFile, 'w');
        if fid == -1
            error('Could not open demo log file for writing: %s', logFile);
        end

        fprintf(fid, 'DemoMode = ON\n\nSubject = %s\nTrials = %d\nDate = %s\n', subjID, length(data), datestr(now, 'yyyy-mm-dd HH:MM:SS'));
        fclose(fid);

    %% non demo mode data save 
    else
        % Construct date str 
        dateStr = datestr(now, 'mmddyy');
       
        sectionDir = fullfile(subjRootDataDir, section);
        if ~exist(sectionDir, 'dir')
            mkdir(sectionDir);
        end

        % Create .mat (e.g., P01_p1Dat040123.mat)
        filename = sprintf('%s_%sDat%s.mat', subjID, section, dateStr);
        savePath = fullfile(sectionDir, filename);
        % save data and params 
        save(savePath, 'data', 'expParams', '-v7.3');

        % Optionally, save minimal hardware snapshot if present
        hwSettings = struct();
        if isfield(expParams, 'ioAddress'),  hwSettings.ioAddress  = expParams.ioAddress;  end
        if isfield(expParams, 'eyetracker'), hwSettings.eyetracker = expParams.eyetracker; end

        % Save hardware settings into the misc folder
        miscPath = fullfile(subjRootDataDir, 'misc');
        if ~exist(miscPath, 'dir'), mkdir(miscPath); end
        save(fullfile(miscPath, 'hardware_settings.mat'), 'hwSettings');
    end
    % notify save 
if isfield(expParams, 'currentBlock') && isfield(expParams, 'totalBlocks')
    blocksRemaining = expParams.totalBlocks - expParams.currentBlock;
    fprintf('\n==================================\n');
    fprintf('PUPILLOMETRY DATA SAVED FOR BLOCK #%d\n', expParams.currentBlock);
    fprintf('==================================\n');
    fprintf('%d BLOCKS TO GO\n', blocksRemaining);
    fprintf('==================================\n\n');
else
    fprintf('\n==================================\n');
    fprintf('PUPILLOMETRY DATA SAVED\n');
    fprintf('==================================\n\n');

end
