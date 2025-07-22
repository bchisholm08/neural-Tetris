%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: 
%                            
%-------------------------------------------------------
function allTrials = loadPupilData(subjID, baseDataDir, doPlot)
%   allTrials = loadAllPupilData('P01');                    % No plotting
%   allTrials = loadAllPupilData('P01', '/path/to/data');   % No plotting
%   allTrials = loadAllPupilData('P01', [], true);          % With plotting
% INPUTS:
%   subjID       : string (e.g., 'P01')
%   baseDataDir  : optional string (defaults to pwd/data)
%   doPlot       : optional boolean, if true plots trial pupil traces
%
% OUTPUT:
%   allTrials    : [struct array] one entry per trial

if nargin < 2 || isempty(baseDataDir)
    baseDataDir = fullfile(pwd, 'data');
end
if nargin < 3
    doPlot = false;
end

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

allTrials = {};  % cell array

for i = 1:nFiles
    s = load(fullfile(eyeDir, files(i).name));  % assumes variable name 'trialData'
    if isfield(s, 'trialData')
        allTrials{end+1,1} = s.trialData;  % append to cell array
    else
        warning('Skipping file %s (missing trialData)', files(i).name);
    end
end

fprintf('All Trials Loaded for %s | Trials = %d', subjID, nFiles);

% -------------------------
% Optional Plotting
% -------------------------
if doPlot
    figure('Name', sprintf('Pupil Traces: %s', subjID), 'Color', 'w'); hold on;

    nPlotted = 0;
    for i = 1:length(allTrials)
        trial = allTrials{i};
        if isfield(trial, 'proc') && isfield(trial.proc, 'time') && isfield(trial.proc, 'smoothed')
            t = trial.proc.time;
            y = trial.proc.smoothed;
            if ~all(isnan(y)) && length(t) == length(y)
                plot(t, y, 'Color', [0.5 0.5 1 0.2]);  % light transparent blue
                nPlotted = nPlotted + 1;
            end
        end
    end

    xlabel('Time (s)');
    ylabel('Smoothed Pupil Diameter');
    title(sprintf('Pupil Traces Across %d Trials [%s]', nPlotted, subjID));
    grid on;
    box on;

    if nPlotted == 0
        disp('No valid pupil traces were found to plot.');
    end
end

end
