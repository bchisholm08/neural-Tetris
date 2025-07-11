% Path to gaze .mat files
dataDir = "Z:\13-humanTetris\data\catssTestEyeData\eyeData\";
datFiles = dir(fullfile(dataDir, "*.mat"));

summaryTable = table();  % to store output stats

for i = 1:numel(datFiles)
    fileName = datFiles(i).name;
    filePath = fullfile(datFiles(i).folder, fileName);
    
    % Load the gaze data
    data = load(filePath);

    % Adjust based on how the pupil data is stored inside
    if isfield(data, 'blockGazeData')
        gaze = data.blockGazeData;
    elseif isfield(data, 'GazeData')
        gaze = data.GazeData;
    else
        warning('No known gaze variable in %s', fileName);
        continue;
    end

    % Extract pupil data vectors
    pupilL = [gaze.PupilDiaL];
    pupilR = [gaze.PupilDiaR];
    timeVec = [gaze.DeviceTimeStamp];

    % Convert time to seconds (if needed)
    timeVec = (timeVec - timeVec(1)) / 1000;  % assuming microseconds or ms

    % Plot pupil diameter over time
    figure;
    plot(timeVec, pupilL, 'b-', 'DisplayName', 'Left');
    hold on;
    plot(timeVec, pupilR, 'r-', 'DisplayName', 'Right');
    xlabel('Time (s)');
    ylabel('Pupil Diameter (px or mm)');
    title(sprintf('Pupil Trace: %s', fileName), 'Interpreter', 'none');
    legend;
    grid on;

    % Calculate stats
    meanL = mean(pupilL, 'omitnan');
    meanR = mean(pupilR, 'omitnan');
    stdL  = std(pupilL, 'omitnan');
    stdR  = std(pupilR, 'omitnan');
    nMissingL = sum(isnan(pupilL));
    nMissingR = sum(isnan(pupilR));
    totalSamples = length(pupilL);

    % Append to summary table
    summaryTable = [summaryTable; table( ...
        string(fileName), meanL, stdL, nMissingL/totalSamples, ...
                         meanR, stdR, nMissingR/totalSamples, ...
        'VariableNames', {'File', 'MeanL', 'StdL', 'PctMissingL', ...
                                   'MeanR', 'StdR', 'PctMissingR'})];
end

% Display final summary
disp(summaryTable);

% Optional: write to file
writetable(summaryTable, fullfile(dataDir, 'pupil_summary_stats.csv'));
