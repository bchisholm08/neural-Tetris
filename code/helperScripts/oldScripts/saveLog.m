function saveLog(logFilename, eventLog)
    % eventLog is a cell array:
    %    eventLog{row,1} = Timestamp
    %    eventLog{row,2} = EventType
    %    eventLog{row,3} = Details

    fid = fopen(logFilename, 'w');
    if fid == -1
        warning('Could not open log file: %s', logFilename);
        return;
    end

    for i = 1:size(eventLog,1)
        % Each row is: Timestamp, EventType, Details
        fprintf(fid, '%f,%s,%s\n', eventLog{i,1}, eventLog{i,2}, eventLog{i,3});
    end

    fclose(fid);
end
