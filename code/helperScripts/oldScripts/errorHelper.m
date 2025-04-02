function errorHelper(subjID, data)
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    errorFile = fullfile('Participants', subjID, 'misc', ['error_' timestamp '.mat']);
    save(errorFile, 'data');
    sca;
    Priority(0);
    ShowCursor;
    rethrow(lasterror);
end