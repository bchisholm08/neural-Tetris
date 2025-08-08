clear;

% =============================
% Pupillometry + Event Overlay
% =============================

% --- INPUT FILES (P03, game 7) ---
eyeData   = "Z:\13-humanTetris\data\P03\eyeData\P03_game007_gaze.mat";
eventsMat = "Z:\13-humanTetris\data\P03\boardSnapshots\P03_p5_boardSnapshot_g07.mat";

% load eye data 
eyeData = load(eyeData);

% vectors (Nx1)
currLeftDia  = [eyeData.blockGazeData.PupilDiaL]';
currRightDia = [eyeData.blockGazeData.PupilDiaR]';
gazeSystemTimestamps = [eyeData.blockGazeData.SystemTimeStamp]';   % Windows clock
% tobiiTimestamps     = [E.blockGazeData.DeviceTimeStamp]';  % (not used here)

% get event data 
S = load(eventsMat);
eventTypeList          = {S.eventLog.eventType}';          
event_systemTimestamps = [S.eventLog.systemTS]';           
% event_timestamps     = [S.eventLog.timestamp]';          

% ---------- Collapse runs of identical events (bookend) ----------
isNewRun   = [true; ~strcmp(eventTypeList(1:end-1), eventTypeList(2:end))];
isEndOfRun = [~strcmp(eventTypeList(1:end-1), eventTypeList(2:end)); true];

startIdx = find(isNewRun);
endIdx   = find(isEndOfRun);

bookTypes = eventTypeList(startIdx);  % names

% normalize time and detect units 
gazeRaw = double(gazeSystemTimestamps);
dg = median(diff(gazeRaw));
if dg > 1000
    gazeScale = 1e-6;  % microseconds -> seconds
elseif dg > 1
    gazeScale = 1e-3;  % milliseconds -> seconds
else
    gazeScale = 1;     % already seconds
end
t0_gaze  = gazeRaw(1);
timeSec  = (gazeRaw - t0_gaze) * gazeScale;  % pupil x-axis; 0 for first sample)

% get units 
evRaw = double(event_systemTimestamps);
de = median(diff(evRaw(~isnan(evRaw) & isfinite(evRaw))));
if isempty(de), de = dg; end  
if de > 1000
    evScale = 1e-6;
elseif de > 1
    evScale = 1e-3;
else
    evScale = 1;
end
evSec_abs = evRaw * evScale;
t0_gaze_s = t0_gaze * gazeScale;
evSec_rel = evSec_abs - t0_gaze_s;    % event times relative to pupil time zero

% bookend w/ relative seconds 
bookStartTimes = evSec_rel(startIdx);
bookEndTimes   = evSec_rel(endIdx);

bookendedTbl = table(bookTypes, bookStartTimes, bookEndTimes, ...
    'VariableNames', {'Type','StartTime','EndTime'});

% plot 
leftPup  = currLeftDia;
rightPup = currRightDia;

figure('Color','w'); hold on;
p1 = plot(timeSec, leftPup,  'DisplayName','Left pupil');
p2 = plot(timeSec, rightPup, 'DisplayName','Right pupil');

xlabel('Time (s since start)');
ylabel('Pupil diameter');
legend([p1 p2], 'Location','best');
grid on;

% get events in range 
xMin = 0;
xMax = max(timeSec);

% interested events 
eventsToMark = {'game_start','piece_spawn','piece_lock','line_clear_1','line_clear_2','game_over'};

% color maps 
colors = lines(numel(eventsToMark));
proxy  = gobjects(0);   % list each event type once

for k = 1:numel(eventsToMark)
    evName = eventsToMark{k};
    c      = colors(k,:);
    isEv   = strcmp(bookendedTbl.Type, evName);

    tEv = bookendedTbl.StartTime(isEv);
    tEv = tEv(tEv >= xMin & tEv <= xMax);  % keep in-range only

    % draw the actual vertical lines (hidden from legend)
    for t = tEv(:).'
        h = xline(t, '--', 'Color', c, 'HandleVisibility','off');
    
        h.Label = evName;
        h.LabelOrientation = 'aligned';           % vertical for xline
        h.LabelHorizontalAlignment = 'center';
        h.LabelVerticalAlignment   = 'bottom';
        h.Interpreter = 'none';
    end

    
    proxy(end+1) = plot(nan, nan, '--', 'Color', c, 'DisplayName', evName); %#ok<SAGROW>
end

% Add event proxies to legend (pupil traces first, then event types)
lgd = legend([p1 p2 proxy], 'Location','bestoutside');
lgd.AutoUpdate = 'off';

% Lock limits after adding lines so axis doesn't blow up
xlim([xMin, xMax]);

% xtickangle(45);

box on; hold off;

fprintf('Gaze dt ~ %.4f s | Total span ~ %.1f s | Events plotted: %d types, %d lines\n', dg*gazeScale, xMax, numel(eventsToMark), sum(ismember(bookendedTbl.Type, eventsToMark)));
