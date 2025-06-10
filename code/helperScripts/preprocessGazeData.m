%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
%
% Description: 
%                            
%-------------------------------------------------------
function trialData = preprocessGazeData(trialData, expParams)

% if ~expParams.demoMode flag = 0 (ignore some points  

if ~isfield(trialData, 'gazeData') || isempty(trialData.gazeData)
    warning('No gazeData found in trialData.');
    trialData.proc = struct(); % Ensure proc struct exists even if empty
    return;
end

gaze = trialData.gazeData;
n = length(gaze);

% Initialize vectors
timestamps = nan(n,1);
leftPupil = nan(n,1);
rightPupil = nan(n,1);
leftGazePoint = nan(n,2);
rightGazePoint = nan(n,2);
leftValidity = nan(n,1);  
rightValidity = nan(n,1); 

for i = 1:n
    g = gaze(i);
    timestamps(i) = g.DeviceTimeStamp;  % In microseconds

    % Check left eye validity
    if isfield(g, 'Left') && isfield(g.Left, 'Validity')
        leftValidity(i) = g.Left.Validity; % <-- NEW: Save validity (0 or 1)
        if g.Left.Validity == 1
            if isfield(g.Left, 'Pupil') && isfield(g.Left.Pupil, 'PupilDiameter')
                leftPupil(i) = g.Left.Pupil.PupilDiameter;
            end
            if isfield(g.Left, 'GazePoint') && isfield(g.Left.GazePoint, 'Position')
                leftGazePoint(i,:) = g.Left.GazePoint.Position;
            end
        end
    end

    % Check right eye validity
    if isfield(g, 'Right') && isfield(g.Right, 'Validity')
        rightValidity(i) = g.Right.Validity; % <-- NEW: Save validity (0 or 1)
        if g.Right.Validity == 1
            if isfield(g.Right, 'Pupil') && isfield(g.Right.Pupil, 'PupilDiameter')
                rightPupil(i) = g.Right.Pupil.PupilDiameter;
            end
            if isfield(g.Right, 'GazePoint') && isfield(g.Right.GazePoint, 'Position')
                rightGazePoint(i,:) = g.Right.GazePoint.Position;
            end
        end
    end
end

% Merge pupil data (average across valid eyes)
merged = nanmean([leftPupil, rightPupil], 2);

% Smooth using a 5-sample window (~16 ms at 300Hz)
smoothed = movmean(merged, 5, 'omitnan');

% relative time in seconds
if all(isnan(timestamps))
    relTime = nan(n,1);
else
    relTime = (timestamps - timestamps(1)) / 1e6;  % μs to seconds
end

% Package data to trialData.proc
trialData.proc = struct();
trialData.proc.time = relTime;
trialData.proc.leftPupil = leftPupil;
trialData.proc.rightPupil = rightPupil;
trialData.proc.mergedPupil = merged;
trialData.proc.smoothedPupil = smoothed;
trialData.proc.leftGazePoint = leftGazePoint;
trialData.proc.rightGazePoint = rightGazePoint;
trialData.proc.leftValidity = leftValidity;   % <-- NEW
trialData.proc.rightValidity = rightValidity; % <-- NEW
end