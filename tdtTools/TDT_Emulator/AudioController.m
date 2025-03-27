
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
global playbackStamp TrialStimuli SampleRate % GetSecs

playbackStamp = TDT.playbackStamp;
assignin('base','playbackStamp',playbackStamp)

soundout = audioplayer(TrialStimuli,SampleRate);

start_time = toc;
disp(' ');
disp(sprintf('   >>>   #%d   %0.1f s   <<<',playbackStamp,start_time));
disp(' ');

play(soundout); % This doesn't workd b/c the audio object gets
% auto-deleted when the function returns
% playblocking(soundout)

% GetSecs = toc; % uncomment this if you don't have PTB
% assignin('base','GetSecs',GetSecs) % uncomment this if you don't have PTB
assignin('base', 'soundout',soundout)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = init(TDT)

tic;
% GetSecs = toc;
% assignin('base','GetSecs',GetSecs);

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
TrialStimuli = wave_data;

assignin('base','SampleRate',TDT.fs);
assignin('base','TrialStimuli',wave_data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stopReset(TDT)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
