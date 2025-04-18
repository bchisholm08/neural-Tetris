function allTrials = pupilPreprocLoadSubj(subjID, doPlot, baseDataDir, saveUpdates)
% pupilPreprocLoadSubj loads, preprocesses, and optionally plots pupil data
%
% USAGE:
%   allTrials = pupilPreprocLoadSubj('P01');                    % just loads
%   allTrials = pupilPreprocLoadSubj('P01', true);              % loads + plots
%   allTrials = pupilPreprocLoadSubj('P01', true, '/my/data');  % custom path
%   allTrials = pupilPreprocLoadSubj('P01', true, [], true);    % save updates
%
% INPUTS:
%   subjID       : subject ID (e.g., 'P01')
%   doPlot       : (optional) true/false, default = false
%   baseDataDir  : (optional) base dir to 'subjData', default = ./data/
%   saveUpdates  : (optional) true to overwrite .mat with updated trialData
%
% OUTPUT:
%   allTrials    : {cell array} of preprocessed trialData structs

if nargin < 2 || isempty(doPlot),      doPlot = false;           end
if nargin < 3 || isempty(baseDataDir), baseDataDir = fullfile(pwd, 'data'); end
if nargin < 4 || isempty(saveUpdates), saveUpdates = false;      end

eyeDir = fullfile(baseDataDir, subjID, 'eyeData');
if ~exist(eyeDir, 'dir')
    error('Could not find eyeData directory: %s', eyeDir);
end

files = dir(fullfile(eyeDir, sprintf('%s_trial*.mat', subjID)));
nFiles = length(files);

if nFiles == 0
    error('No trialData files found for subject %s.', subjID);
end

fprintf('Found %d trialData files for %s\n', nFiles, subjID);

allTrials = {};
nUpdated = 0;

for i = 1:nFiles
    fpath = fullfile(eyeDir, files(i).name);
    s = load(fpath);
    if isfield(s, 'trialData')
        trial = s.trialData;

        needsPreproc = ~isfield(trial, 'proc') || ~isfield(trial.proc, 'smoothed');

        if needsPreproc
            trial = preprocessGazeData(trial);
            nUpdated = nUpdated + 1;

            if saveUpdates
                save(fpath, 'trial', '-v7');
            end
        end

        allTrials{end+1,1} = trial;

    else
        warning('Skipping %s (no trialData found)', files(i).name);
    end
end

fprintf('All Trials Loaded for %s | Trials = %d | Newly Preprocessed = %d\n', ...
    subjID, length(allTrials), nUpdated);

% Optional plotting
if doPlot
    figure('Name', sprintf('Pupil Traces: %s', subjID), 'Color', 'w'); hold on;
    nPlotted = 0;
    for i = 1:length(allTrials)
        trial = allTrials{i};
        if isfield(trial, 'proc') && isfield(trial.proc, 'time') && isfield(trial.proc, 'smoothed')
            t = trial.proc.time;
            y = trial.proc.smoothed;
            if ~all(isnan(y)) && length(t) == length(y)
                plot(t, y, 'Color', [0.5 0.5 1 0.25]);  % semi-transparent blue
                nPlotted = nPlotted + 1;
            end
        end
    end
    xlabel('Time (s)'); ylabel('Smoothed Pupil Diameter');
    title(sprintf('All Pupil Traces [%s] (%d Trials)', subjID, nPlotted));
    box on; grid on;
    if nPlotted == 0
        disp('No valid pupil traces found to plot.');
    end
end

end
