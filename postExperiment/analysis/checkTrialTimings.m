%-------------------------------------------------------
% Author: Brady M. Chisholm
% Date: 7.12.2025
%
% Description: Loads and analyzes per-trial durations for p1 and p2 of the
% Human Tetris experiment. Calculates summary stats and plots histograms.
%-------------------------------------------------------

clear; clc;

% File paths 
p1File = 'Z:\13-humanTetris\data\peepTimingAndLockIn\misc\p1_timingInfo.mat';
p2File = 'Z:\13-humanTetris\data\peepTimingAndLockIn\misc\p2_timingInfo.mat';

% Load
load(p1File, 'trialDur');  % loads 'trialDur' variable
trialDurP1 = trialDur;

load(p2File, 'trialDur');  % loads 'trialDur' again
trialDurP2 = trialDur;

% Summary stats helper
analyze = @(dur) struct( ...
    'nTrials',        numel(dur), ...
    'meanDur',        mean(dur), ...
    'minDur',         min(dur), ...
    'maxDur',         max(dur), ...
    'stdDur',         std(dur), ...
    'totalTimeSec',   sum(dur), ...
    'totalTimeMin',   sum(dur) / 60 ...
);

% Analyze
summaryP1 = analyze(trialDurP1);
summaryP2 = analyze(trialDurP2);

% Display
fprintf('\n=== P1 Timing Summary ===\n');
disp(summaryP1);

fprintf('\n=== P2 Timing Summary ===\n');
disp(summaryP2);

% Plot
figure;
subplot(2,1,1);
histogram(trialDurP1, 40);
title('P1 Trial Durations'); xlabel('Time (s)'); ylabel('Count');

subplot(2,1,2);
histogram(trialDurP2, 40);
title('P2 Trial Durations'); xlabel('Time (s)'); ylabel('Count');

