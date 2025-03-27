function [expInfo, eventLog] = getExpInfo(eventLog)
    % GETEXPINFO  Collect participant/session info, update eventLog
    %
    %   [expInfo, eventLog] = getExpInfo(eventLog)
    %
    %   Prompts user for participant info in MATLAB command window,
    %   returns a struct containing the parameters and appends an
    %   entry to the provided eventLog.
    %
    %   eventLog is a cell array with columns:
    %       {Timestamp, EventType, Details}
    %
    %   Example:
    %       eventLog = {};
    %       [expInfo, eventLog] = getExpInfo(eventLog);
    %       % Now expInfo contains the subject/session info and
    %       % eventLog has an "EXPERIMENT_INFO" entry.

    if nargin < 1 || isempty(eventLog)
        eventLog = {};
    end

    fprintf('\n--- Collecting Experiment Info ---\n');
    
    % Prompt user for participant/experiment details
    expInfo.subjectID     = input('Enter Participant/Subject ID: ', 's');
    expInfo.sessionNumber = input('Enter Session Number (numeric): ');
    expInfo.condition     = input('Enter Condition Label: ', 's');
    
    % Store a timestamp for when the experiment was set up
    expInfo.startTime     = datestr(now, 'yyyy-mm-dd_HH-MM-SS');

    % Append an entry to the eventLog
    timeNow = GetSecs();  % Psychtoolbox timing function
    detailsString = sprintf('SubjectID:%s, Session:%d, Condition:%s, StartTime:%s', ...
        expInfo.subjectID, expInfo.sessionNumber, expInfo.condition, expInfo.startTime);
    
    eventLog(end+1, :) = {timeNow, 'EXPERIMENT_INFO', detailsString};

    fprintf('Experiment info collected and logged.\n\n');
end
