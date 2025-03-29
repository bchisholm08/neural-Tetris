function p1()


%{ 
Goal of p1() is to......

1) Gather subject ID and create folder / directory for them 

2) Connect to, calibrate, and utilize eye tracking data 

3) Connect to and trigger BioSemi EEG system (Using TDT)

4) P1() EXPERIMENT
    Display 7 tetris pieces in a block / trial loop, using a mean ITI 1sec 
    
    During experiment:
        send TDT triggers for EEG 
        record eye tracking data 
        
    Implement a demoMode that lets us test the behavioral section of the
    experiment. This should bypass tobii and EEG, but 

%} 
clear all;
sca;

%{
===============
S1 & S2 OPTIONS
===============
%} 
    s1nBlocks = 2; 
    s1presentationsPerBlock = 3;

    s2nBlocks = 2;
    s2PresentationsPerBlock = 3;
%============================================================

% In CATSS, some functions that can interfere 
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

%{
=================================
    %% S1 %%
=================================
%}

% Get the path of the current script
currentScriptPath = mfilename('fullpath');

% Get the folder containing the current script
codeFolder = fileparts(currentScriptPath); 

% Go up one level from /code/
mainFolder = fileparts(codeFolder); 

% Define paths to the helperScripts and dataCollection folders
helperScriptsPath = fullfile(mainFolder, 'code', 'helperScripts');
baseDataDir = fullfile(mainFolder, 'data');

% Add both folders to the MATLAB path
addpath(helperScriptsPath, baseDataDir);

% Display confirmation
disp(['Added to path: ', helperScriptsPath]);
disp(['Added to path: ', baseDataDir]);

% run the tableau script to pre-load into environment 
tableau;

try % ends 144, main trial loop? 
    % Subject input
    subjID = input('Enter subject ID (e.g., P01): ', 's');
    demoMode = input('Enable demo mode? (1 = yes, 0 = no): ');

%{ 
%% IN P1(); CALIBRATE EYETRACKER AND HANDLE DEMO MODE AND EEG 

Take demoMode input (1/0) and deal with Tobii, TDT, and Biosemi/EEG 

When demoMode = 0;
- Use 


When demoMode = 1; 

%} 

%% Set up some eyetracker stuff
trackingMode = 'human'; % For Tobii Pro Spectrum ['human', 'monkey', 'great_ape']; changes the illumination model of Tobii.
whichTracker = 'Tobii Pro Spectrum'; 
eyetrackerSamplerate = 300; % familiar with 300hz, but 

%{
=================================
Here I think I should do an overall calibration before 
anything else. Establishing and setting up Tobii / Tita here 
may be most convienent 
 
=================================
%}

%{
JM set up example 


if demoMode
    keepGoing = getUserInput('You are using demo mode, want to continue anyway? (0 = no, 1= yes): ',[],[0 1]);
    
    if keepGoing ~=1
        error('Experiment terminated. Regular mode desired, but demo mode is active');
    end
end
z
if ~useEEG
    %     addpath('M:\Experiments\Juraj\TDT_Emulator');
    addpath('M:\Experiments\Juraj\TDT_Emulator_PPA');
else
    rmpath('M:\Experiments\Juraj\TDT_Emulator_PPA'); % just in case the emulator is in the path, remove it.
    %     addpath([pwd filesep 'AudioControllerEdit']); % this is where the edited m file for audiocontroller lives. It needs its own folder so that it doesn't overshadow the emulator

    if ~exist('AudioController', 'file')
        addpath('C:\expFun')
    end
    
end
%} 


% unsure if there is any methodological reason for 300Hz sampling. Would really like to know (from  kines. or something) the time scale 
% that pupil dialation occurs at. Could email a UMN expert 
%} 




    % Initialize experiment
    [window, windowRect, params] = initExperiment(subjID, demoMode);

    % Initialize hardware
    if ~demoMode
        [ioObj, address, eyetracker] = initDataTools();
    else
        ioObj = []; address = []; eyetracker = [];
        warning("Tobii and Biosemi not found for data collection. Is demo mode on (do you want it to be?)?");
        dbstop if error % pause on errors when we're in demo mode 
        % dbstop if warning % akin for warnings 
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
% s1 trial / block options used to be here, moved up to top of script

    data = struct('block', [], 'trial', [], 'piece', [], 'onset', []);
    for block = 1:s1nBlocks
        %% Randomize piece order within block
        pieceOrder = repmat(1:nPieces, 1, s1presentationsPerBlock);
        pieceOrder = pieceOrder(randperm(length(pieceOrder)));

        for t = 1:s1presentationsPerBlock
            %% Fixation
            Screen('FillRect', window, params.colors.background);
            fixationOnset = Screen('Flip', window);
            drawFixation('FillRect', window, params.colors.background);

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
    % s2 trial / block options used to be here, moved up to top of script
    
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

    %this is a neat trick that can make matlab jump to a the line where the
    %crash occurred:
    hEditor = matlab.desktop.editor.getActive;
    hEditor.goToLine(whathappened.stack(end).line)
    commandwindow;
    % Courtesy of JM :) 
%=========================================================================
end % try end
end % funcEnd