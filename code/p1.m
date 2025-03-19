function p1()
%  clean slate
clear;
close all;
sca;
helperScriptsPath = fullfile(fileparts(mfilename('fullpath')), 'helperScripts');
addpath(helperScriptsPath);

% run the tableau script to load into environment 
tableau;
try
    % Subject input
    subjID = input('Enter subject ID (e.g., P01): ', 's');
    demoMode = input('Enable demo mode? (1 = yes, 0 = no): ');

    % Initialize experiment
    [window, windowRect, params] = initExperiment(subjID, demoMode);

    % Initialize hardware
    if ~demoMode
        [ioObj, address, eyetracker] = initDataTools();
    else
        ioObj = []; address = []; eyetracker = [];
        warning("Tobii and/or Biosemi not found for data collection. \n Is demo mode on? ")
    end

    % Create directory structure
    baseDataDir = 'C:\Users\chish071\Desktop\tetris\data';
    rootDir = fullfile(baseDataDir, 'subjData', subjID);
    if ~exist(rootDir, 'dir')
        mkdir(rootDir);
        arrayfun(@(x) mkdir(fullfile(rootDir, sprintf('p%d', x))), 1:4);
        mkdir(fullfile(rootDir, 'misc'));
    end

    % check for dir creation
    if ~exist(rootDir, 'dir')
        error('Failed to create directory: %s', rootDir);
    end

    %% Add in instruction screen(s), and practice blocks...
    p1instruct(window, params);

    pieces = getTetrino(params);
    nPieces = 7; % standard tetrino 
    s1nBlocks = 2; 
    s1presentationsPerBlock = 20;

    data = struct('block', [], 'trial', [], 'piece', [], 'onset', []);
    for block = 1:s1nBlocks
        %% Randomize piece order within block
        pieceOrder = repmat(1:nPieces, 1, s1presentationsPerBlock);
        pieceOrder = pieceOrder(randperm(length(pieceOrder)));

        for t = 1:s1presentationsPerBlock
            %% Fixation
            Screen('FillRect', window, params.colors.background);
            fixationOnset = Screen('Flip', window);

            %% Present piece
            pieceID = pieceOrder(t);  % Use actual piece ID
            Screen('DrawTexture', window, pieces(pieceID).tex);
            [~, stimOnset] = Screen('Flip', window, fixationOnset + 0.8 + rand*0.4);

            %% Send EEG trigger
            if ~demoMode && ~isempty(ioObj)
                io64(ioObj, address, pieceID);
            end

            %% Log data
            data(end+1).block = block;
            data(end).trial = t;
            data(end).piece = pieceID;
            data(end).onset = stimOnset;

            %% ITI
            WaitSecs(0.1);  % 100ms presentation
            Screen('Flip', window);
            WaitSecs(0.7 + rand*0.4);  % 800-1200ms ITI
        end

        %% Break between blocks
        if block < s1nBlocks
            take5Brubeck(window, params); 
        end
    end

    %% Save Section 1 data
    saveDat('p1', subjID, data, params, demoMode);

    %% Add in instruction screen(s), and practice blocks

    %% Section 2: Tableaus
    fprintf('\n=== Running Section 2 ===\n');
    tableaus = getTableaus(); 
    s2nBlocks = 2;
    s2PresentationsPerBlock = 10;

    s2TotalTrials = s2nBlocks * s2PresentationsPerBlock;
    for block = 1:s2nBlocks
        currentTableau = tableaus(block);
        blockData = struct('block', block, 'trials', []);

        for t = 1:s2PresentationsPerBlock  % 30 trials per block
            %% Present tableau
            draw_tableau(window, currentTableau, params);
            [~, tabOnset] = Screen('Flip', window);

            %% Present piece
            pieceID = randi(nPieces);  % Use all 7 pieces
            Screen('DrawTexture', window, pieces(pieceID).tex);
            [~, pieceOnset] = Screen('Flip', window, tabOnset + 0.8 + rand*0.4);

            %% Log data
            blockData.trials(t).piece = pieceID;
            blockData.trials(t).onset = pieceOnset;

            %% ITI
            WaitSecs(0.1);
            Screen('Flip', window);
            WaitSecs(0.7 + rand*0.4);
        end

        %% Save block data
        saveDat('p2', subjID, blockData, params, demoMode);
    end

    % Cleanup
    if ~demoMode
        tetio_disconnectTracker();
    end
    sca;

catch ME
    sca;          % Close PTB
    Priority(0);  % Reset priority of matlab
    ShowCursor;   % Restore cursor
    rethrow(ME);  % Show error details
end % try end
end % funcEnd