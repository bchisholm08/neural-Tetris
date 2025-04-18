function trialData = preprocessGazeData(trialData)
% preprocessGazeData preprocesses Tobii gaze data for a single trial.
%
% Adds fields to trialData.proc:
%   - time:     relative time (s) from trial onset
%   - left:     left eye pupil diameter (NaN if invalid)
%   - right:    right eye pupil diameter (NaN if invalid)
%   - merged:   mean of valid eyes (NaN if both invalid)
%   - smoothed: moving average of merged signal (optional)
%
% Usage: trialData = preprocessGazeData(trialData)
%
% Dependencies: None. Safe to run standalone on trialData.mat

% Ensure required fields exist
if ~isfield(trialData, 'gazeData') || isempty(trialData.gazeData)
    warning('No gazeData found in trialData.');
    return;
end

gaze = trialData.gazeData;
n = length(gaze);

% Initialize vectors
timestamps = nan(n,1);
leftPupil = nan(n,1);
rightPupil = nan(n,1);

for i = 1:n
    g = gaze(i);
    timestamps(i) = g.DeviceTimeStamp;  % In microseconds

    % Check left eye validity
    if isfield(g, 'Left') && isfield(g.Left, 'Validity') && g.Left.Validity == 1
        if isfield(g.Left, 'Pupil') && isfield(g.Left.Pupil, 'PupilDiameter')
            leftPupil(i) = g.Left.Pupil.PupilDiameter;
        end
    end

    % Check right eye validity
    if isfield(g, 'Right') && isfield(g.Right, 'Validity') && g.Right.Validity == 1
        if isfield(g.Right, 'Pupil') && isfield(g.Right.Pupil, 'PupilDiameter')
            rightPupil(i) = g.Right.Pupil.PupilDiameter;
        end
    end
end

% Merge valid pupil data
merged = nanmean([leftPupil, rightPupil], 2);  % average across valid eyes

% Smooth using a 5-sample window (~16 ms at 300Hz)
smoothed = movmean(merged, 5, 'omitnan');

% Compute relative time in seconds
if all(isnan(timestamps))
    relTime = nan(n,1);
else
    relTime = (timestamps - timestamps(1)) / 1e6;  % μs to seconds
end

% Package into trialData.proc
trialData.proc = struct();
trialData.proc.time     = relTime;
trialData.proc.left     = leftPupil;
trialData.proc.right    = rightPupil;
trialData.proc.merged   = merged;
trialData.proc.smoothed = smoothed;

end
