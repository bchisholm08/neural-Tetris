
function varargout = AudioController(command_str, TDT, varargin)

if strcmp(command_str, 'init')
    evalStr = sprintf('TDT = %s(TDT, varargin{:});', command_str);
elseif strcmp(command_str, 'start')
    evalStr = sprintf('start_time = %s(TDT, varargin{:});', command_str);
else
    evalStr = sprintf('%s(TDT, varargin{:});', command_str);
end
eval(evalStr)

if strcmp(command_str, 'init') && nargout == 1
    varargout{1} = TDT;
elseif strcmp(command_str, 'start') && nargout == 1
    varargout{1} = start_time;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function start_time = start(TDT)
global playbackStamp  % GetSecs

playbackStamp = TDT.playbackStamp;
assignin('base','playbackStamp',playbackStamp)

% soundout = audioplayer(TrialStimuli,SampleRate);

start_time = toc;
disp(' ');
disp(sprintf('   >>>   #%d   %0.1f s   <<<',playbackStamp,start_time));
disp(' ');


% Start then stop the sound playback.
repetitions = 1;
when = 0;
startTime = PsychPortAudio('Start',...  % start the playback and recording process and record the starttime
    TDT.pahandle,...                            % handle of the audio device
    repetitions,...                         % number of repetitions
    when);

% play(soundout); % This doesn't workd b/c the audio object gets
% auto-deleted when the function returns
% playblocking(soundout)

% GetSecs = toc; % uncomment this if you don't have PTB
% assignin('base','GetSecs',GetSecs) % uncomment this if you don't have PTB
% assignin('base', 'soundout',soundout)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = init(TDT)

tic;
% GetSecs = toc;
% assignin('base','GetSecs',GetSecs);
Fs = 24414; 
InitializePsychSound(1)

% Open a connection to the sound card
TDT.pahandle = PsychPortAudio('Open',[],...     % create a handle to the [default soundcard] This should default to the only ASIO card.
    1,...                                 % Sound Playback mode (1 = sound only, 2 = record only, 3 = duplex mode
    0,...                                 % Latency minimization (0 = none, 1 = try for low latency with reliable playback, 2 = full audio device control, 3 full controll with agressive settings, 4 full controll with agressive settings and fail if device won't meet requirements)
    Fs,...                                % Sampling Frequency
    [2],...                               % Number of channels for [Out In]
    []);                                  %  Default buffersize
      



varargout{1} = TDT;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function clearBuffer(TDT, N)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function loadBuffer(TDT, wave_data)
global TrialStimuli SampleRate

if (max(max(abs(wave_data)))) > 1
    disp(sprintf([' *** WARNING: Audio clipping! Maximum amplitude was ' num2str((max(max(abs(wave_data))))) '! ***']));
end

SampleRate = TDT.fs;
TrialStimuli = wave_data';

PsychPortAudio('FillBuffer',...             % Create and fill buffer with stimuli
    TDT.pahandle,...                % handle of the audio device
    [TrialStimuli]);

assignin('base','SampleRate',TDT.fs);
assignin('base','TrialStimuli',wave_data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stopReset(TDT)
PsychPortAudio('Stop',...                       % stop playback/recording
    TDT.pahandle,...                        % audio device handle
    0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function close(TDT)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
