%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: Saves subject data in .csv format 
%
%-------------------------------------------------------
function saveDat(section, subjID, data, params, demoMode)
% saveDat: A centralized function to handle data saving for the experiment.
% For real data, saves behavioral data to .csv and parameters to .mat.
% For demo mode, saves a detailed .csv log.

% --- Get the correct subject directory paths from the params struct ---
if ~isfield(params, 'subjPaths') || ~isfield(params.subjPaths, 'behavDir') || ~isfield(params.subjPaths, 'miscDir')
    error('saveDat:PathError', 'Required subject path fields (.behavDir, .miscDir) not found in params.subjPaths. Check initExperiment.m');
end
behavDir = params.subjPaths.behavDir;
miscDir = params.subjPaths.miscDir;

% --- DEMO MODE: Write a detailed .csv log ---
if demoMode
    fileSaveTimeStamp = datestr(now, 'yyyymmdd_HHMMSS');
    logFile = fullfile(miscDir, sprintf('demoLog_%s_%s.csv', section, fileSaveTimeStamp));

    try
        % Convert the struct array to a table for easy writing
        dataTable = struct2table(data);
        % Write the table directly to a .csv file
        writetable(dataTable, logFile);
        fprintf('Demo log saved as CSV to: %s\n', logFile);
    catch ME
        warning('Could not save demo log as .csv, possibly due to inconsistent struct fields. Error: %s', ME.message);
    end

    % --- REAL EXPERIMENT MODE: Save behavioral .csv and params .mat ---
else
    dateStr = datestr(now, 'ddmmmyyyy'); % e.g., 16Jun2025

    % 1. Save Behavioral Data to CSV
    % Construct filename, e.g., P01_p4_behavioral_16Jun2025.csv
    behavioralFilename = sprintf('%s_%s_behavioral_%s.csv', subjID, section, dateStr);
    behavioralSavePath = fullfile(behavDir, behavioralFilename);

    try
        if isstruct(data)
            % If data is a struct array (from p1, p2, p4), use struct2table
            dataTable = struct2table(data, 'AsArray', true);
            % if expParams.p4.options.sectionDoneFlag
            % % special data processing for p4? Seems to always result in
            % % crashes 
            % end 
        elseif iscell(data)
            % If data is a cell array (from p5), use cell2table
            header = {'Timestamp', 'EventType', 'Value1', 'Value2'};
            dataTable = cell2table(data, 'VariableNames', header);
        else
            error('Unsupported data type for logging.');
        end

        % Write the resulting table to the .csv file
        writetable(dataTable, logFile);
        fprintf('Demo log saved as CSV to: %s\n', logFile);
    catch ME
        warning('Could not save demo log as .csv. Error: %s', ME.message);
    end

    % 2. Save Parameters and Full Stimulus Sequence to .MAT
    % Construct filename, e.g., P01_p4_params_16Jun2025.mat
    paramsFilename = sprintf('%s_%s_params_%s.mat', subjID, section, dateStr);
    paramsSavePath = fullfile(miscDir, paramsFilename);

    try
        % Save the entire params struct, which includes stimulus sequences and all settings
        save(paramsSavePath, 'params', '-v7.3');
        fprintf('Experiment parameters for section "%s" saved to: %s\n', section, paramsSavePath);
    catch ME
        error('saveDat:MatFileError', 'Could not save parameters .mat file. Error: %s', ME.message);
    end
end

% --- Final Notification ---
fprintf('\n==================================\n');
fprintf('SAVE COMPLETE FOR SECTION: %s\n', upper(section));
fprintf('==================================\n\n');
end