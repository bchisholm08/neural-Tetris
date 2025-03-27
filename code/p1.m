function p1()

clear all;
sca;

% In CATSS, there are some functions in this folder that
% interfere with this experiment (e.g., apclab's hann function)
if isfolder('C:\CATSS_Booth2')
    rmpath('C:\CATSS_Booth2');
end

if isfolder('R:\cla_psyc_oxenham_labscripts\scripts\')
    rmpath('R:\cla_psyc_oxenham_labscripts\scripts\')
end

if isfolder('P:\scripts') || isfolder('P:\afc\scripts')
    rmpath(genpath('P:\scripts'));
    rmpath('P:\afc\scripts');
end

%% Set up some eyetracker stuff (JM)
trackingMode = 'human'; % For Tobii Pro Spectrum ['human', 'monkey', 'great_ape']; changes the illumination model of Tobii.
whichTracker = 'Tobii Pro Spectrum'; 
eyetrackerSamplerate = 300; % familiar with 300hz, but 
% not sure if there is any methodological reason for it. Would really like to know (from a kines. or something) the time scale that pupil dialation occurs at. Could email an expert 
 
%{
=================================
    %% S1
=================================
%}
helperScriptsPath = fullfile(fileparts(mfilename('fullpath')), 'helperScripts');
addpath(helperScriptsPath);

% run the tableau script to pre-load them into environment 
tableau;

try % ends 144, main trial loop? 
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
        warning("Tobii and Biosemi not found for data collection.\nIs demo mode on (do you want it to be?)?");
    end

    % Create directory structure
    % original path baseDataDir = 'C:\Users\chish071\Desktop\tetris\data';
    % try to use relative not absolute paths so this program doesn't crash 
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
    %FIXME add practice blocks and practice instructions? 
    pieces = getTetrino(params);
    nPieces = 7; % standard # of tetrino 
    s1nBlocks = 2; 
    s1presentationsPerBlock = 5;

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
    end % S1 block end 
    %% Save Section 1 data
    saveDat('p1', subjID, data, params, demoMode);

% ============================
% ============================
% ============================
% ============================

    helperScriptsPath = fullfile(fileparts(mfilename('fullpath')), 'helperScripts');
    addpath(helperScriptsPath);
%{
==========================
%% S2  
==========================
%}
   
    p2instruct(window, params);

    %% Section 2: Tableaus and contexts 
    fprintf('\n=== Running Section 2 ===\n');
    tableaus = getTableaus(); 
    s2nBlocks = 2;
    s2PresentationsPerBlock = 5;

    s2TotalTrials = s2nBlocks * s2PresentationsPerBlock;
    for block = 1:s2nBlocks
        currentTableau = tableaus(block);
        blockData = struct('block', block, 'trials', []);

        for t = 1:s2PresentationsPerBlock  
            %% Present tableau
            getTableaus();
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
         %% Break between blocks
        if block < s2nBlocks
            take5Brubeck(window, params); 
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
    sca;          % Close PTB, screan clear 
    Priority(0);  % Reset priority of matlab
    ShowCursor;   % Restore cursor
    rethrow(ME);  % Show error details
end % try end
end % funcEnd