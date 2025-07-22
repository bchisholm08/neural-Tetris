% ===================================================== %
% PUPIL Preprocessing Pipeline v1.2                   %
% ===================================================== %
% Implements loading, raw plotting, resampling to uniform time,
% preprocessing with PUPILS toolbox, and saving results for
% gameplay and replay conditions in the Human Tetris experiment.
% Configure subject, game, and directories before running.

%% 0) USER SETTINGS
subjID   = 'ggPilot_02';      % e.g. 'AB1234'
gameNum  = 4;              % integer game index (e.g. 4)
isReplay = false;          % false: raw gameplay, true: replay

%% 1) PATHS
baseDir       = 'Z:\13-humanTetris\data';
rawEyeDir     = fullfile(baseDir, subjID, 'eyeData');
if isReplay
    gazeFileName = sprintf('%s_gameReplay%03d_gaze.mat', subjID, gameNum);
    rawFigName   = sprintf('%s_gameReplay%03d_rawPupilTrace.png', subjID, gameNum);
    preprocMat   = sprintf('%s_gameReplay%03d_preprocGazeDat.mat', subjID, gameNum);
else
    gazeFileName = sprintf('%s_game%03d_gaze.mat', subjID, gameNum);
    rawFigName   = sprintf('%s_game%03d_rawPupilTrace.png', subjID, gameNum);
    preprocMat   = sprintf('%s_game%03d_preprocGazeDat.mat', subjID, gameNum);
end
rawGazePath   = fullfile(rawEyeDir, gazeFileName);

postDir        = 'Z:\13-humanTetris\postExperiment\preProcessedData\preprocEyeData';
preprocSubjDir = fullfile(postDir, subjID);
if ~exist(preprocSubjDir, 'dir')
    mkdir(preprocSubjDir);
end

%% 2) LOAD RAW DATA
D   = load(rawGazePath);
bGD = D.blockGazeData;   % struct array [1 x N]

% Extract raw vectors and cast to double
pupilL = double([bGD.PupilDiaL]);
pupilR = double([bGD.PupilDiaR]);
gazeX  = double([bGD.GazeX]);
gazeY  = double([bGD.GazeY]);
Nraw   = numel(pupilL);

%% 3) BUILD IDEAL TIME VECTOR & RESAMPLE (if needed)
fs      = 300;                     % sampling rate (Hz)
timeRaw = (0:Nraw-1)'/fs;         % ideal uniform time (double)

% % % % % % % % % % % % % % % % % % Resample if actual timestamps exist and are irregular
% % % % % % % % % % % % % % % % % % if isfield(bGD, 'DeviceTimeStamp') && any(~cellfun(@isempty,{bGD.DeviceTimeStamp}))
% % % % % % % % % % % % % % % % % %     Collect and cast timestamps
% % % % % % % % % % % % % % % % % %     tsRaw = [bGD.DeviceTimeStamp];           % possibly integer array
% % % % % % % % % % % % % % % % % %     actualTS = double(tsRaw(:));             % ms or ticks
% % % % % % % % % % % % % % % % % %     Convert to seconds relative to start
% % % % % % % % % % % % % % % % % %     t0       = actualTS(1);
% % % % % % % % % % % % % % % % % %     actualTS = (actualTS - t0) / 1000;       % to seconds
% % % % % % % % % % % % % % % % % %     Check spacing
% % % % % % % % % % % % % % % % % %     dt = diff(actualTS);
% % % % % % % % % % % % % % % % % % end
%% 4) PLOT & SAVE RAW TRACES
rawFigPath = fullfile(preprocSubjDir, rawFigName);
fig1 = figure('Visible','off');
plot(timeRaw, pupilL);
hold on;
plot(timeRaw, pupilR);
hold off;
xlabel('Time (s)');
ylabel('Pupil Diameter (a.u.)');
title(sprintf('%s Game%03d Raw Pupil Trace', subjID, gameNum));
grid on;
print(fig1, rawFigPath, '-dpng', '-r300');
close(fig1);

%% 5) SAVE RAW DATA TABLE
Traw = table(timeRaw, gazeX', gazeY', pupilL', pupilR', ...
    'VariableNames', {'time_s','x_px','y_px','pupilL','pupilR'});
rawCSV = strrep(rawFigName, '_rawPupilTrace.png', '_rawPupilData.csv');
writetable(Traw, fullfile(preprocSubjDir, rawCSV));

%% 6) PREPROCESS WITH PUPILS TOOLBOX
% Assemble input matrix: [time_s x_px y_px pupil]
dataMatrix = [Traw.time_s, Traw.x_px, Traw.y_px, Traw.pupilL];

opts = struct();
opts.fs                   = fs;        % Hz
opts.blink_rule           = 'vel';     % 'std' or 'vel'
opts.pre_blink_t          = 100;       % ms before blink for interp
opts.post_blink_t         = 200;       % ms after blink
opts.xy_units             = 'px';
opts.vel_threshold        = 30;        % px/s
opts.min_sacc_duration    = 10;        % ms
opts.interpolate_saccades = false;     % no interpolation of saccades
opts.pre_sacc_t           = 50;        % ms
opts.post_sacc_t          = 100;       % ms
opts.low_pass_fc          = 10;        % Hz

[proc_data, proc_info] = processPupilData(dataMatrix, opts);
save(fullfile(preprocSubjDir, preprocMat), 'proc_data', 'proc_info');

%% 7) PLOT & SAVE PROCESSED TRACE
Nproc = size(proc_data,1);
timeP = (0:Nproc-1)'/fs;
procPNG = strrep(rawFigName, '_rawPupilTrace.png', '_preprocPupilTrace.png');
fig2 = figure('Visible','off');
plot(timeP, proc_data(:,4));
hold on;
yL = ylim;
% Shade blinks
for i = 1:proc_info.number_of_blinks
    x0 = proc_info.blink_starts_s(i);
    w  = proc_info.blink_durations(i);
    rectangle('Position', [x0 yL(1) w diff(yL)], 'FaceColor', [0.85 0.85 0.85], 'EdgeColor', 'none');
end
% Shade saccades
for i = 1:proc_info.number_of_saccades
    x0 = proc_info.saccade_starts_s(i);
    w  = proc_info.saccade_durations(i);
    rectangle('Position', [x0 yL(1) w diff(yL)], 'FaceColor', [0.65 0.65 0.65], 'EdgeColor', 'none');
end
hold off;
xlabel('Time (s)');
ylabel('Pupil Diameter (a.u.)');
title(sprintf('%s Game%03d Processed Pupil Trace', subjID, gameNum));
print(fig2, fullfile(preprocSubjDir, procPNG), '-dpng', '-r300');
close(fig2);

fprintf('Pipeline complete: %s Game%03d (replay=%d)\n', subjID, gameNum, isReplay);

%{ 
for processing pupil data...

1) load and plot raw pupil traces
    In figure, min and max pupil size and sd. (include 0/1 option for
    opening figs) 
    Save figure of raw trace to preproc data directory BEFORE 

    Raw game data exmp: "Z:\13-humanTetris\data\<subjID>\eyeData\<subjID>_game004_gaze.mat"
    Raw game replay data exmp: "Z:\13-humanTetris\data\<subjID>\eyeData\<subjID>_gameReplay004_gaze.mat"

    raw gameplay fig: <subjID>_game004_rawPupilTrace.png
    raw replay fig:   <subjID>_gameReplay004_rawPupilTrace.png

2) Transform data for PUPILS and save to new directory 

    "dataframe should include in that order:
    time stamps
    x-coordinate
    y-coordinate
    pupil size"

3) run data through PUPILS preproc pipeline and save 
    After preprocessing, (CREATE DIRECTORY and) save preprocessed data to:
    Z:\13-humanTetris\postExperiment\preProcessedData\preprocEyeData\<subjID_folder>\
    
    Preproc game data saved as: <subjID>_game004_preprocGazeDat.mat
    Preproc game replay data saved as: <subjID>_gameReplay004_preprocGazeDat.mat
    
    Replot pupil traces, and save figure. Figure inlay, with PUPILS blinks
    from L/R, L/R loss %, min and max pupil size and sd. 

    raw gameplay fig: <subjID>_game004_rawPupilTrace.png
    raw replay fig:   <subjID>_gameReplay004_rawPupilTrace.png
%} 