
%%
clear all; close all; clc
commandwindow;

addpath('R:\cla_psyc_oxenham_labscripts\scripts');

%% Exp parameters
samplerate = 24414;     %% Sampling rate based on MSP TDT
% noiseLevel = 50;        %% No noise
stimulus_Amplitude = 70;
ERmax = 106;            %% +3dB because we are using stimuli with rms=1 (not peak=1)%%%%%NEED TO CHECK WITH ANDY
lMax = ERmax;           %JM: Is this the same as peak level for the headphones?

attenDB = -20; 
attenLin = 10^(attenDB/20); 

nTrials = 1;
freq = 1000;
dur = 20000;

ear = 1; % 1 = left, 2 =right

currTone =  attenLin.*tone(freq,dur,0,samplerate);

% Now that stimuli and experiment parameters are loaded, let's get going
TDT.use_keyboard = true;
TDT.onsetdel = 0;
TDT.Type = 'RP2';
TDT.fs = 24414;
TDT.circuit_dir = '.\'; % this is where the custom circuit that allows rapid triggers resides

% TempNoise = audioread('M:\Lab_Files\Experiments\Kelly\MusNMus\EEG\NoiseClip_Resampled.wav');
% NoiseScaler = 10^((noiseLevel-ERmax)/20);  % Scaler relative to calibrated level.
% [~, ~, TDT] = initializeStructures('tempExp');
TDT.noiseAmp = 0;%/rms(TempNoise); %getStimScaler(TDT,noiseAmp);
% to get noise: throw in extra noise arm in circuit

%%%%% Calibration for MSP ER1 earphones %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TDT (Tucker-Davis-Technology) - drivers that allow finely timed auditory
% delivery + triggers for EEG (for details see catss.umn.edu/msp/MSPEquipment.html )

% Initialize sound and display
TDT = AudioController('init', TDT); % populate TDT structure

nextPlayTime = GetSecs + 1;

for trialNum = 1:nTrials
    
    fprintf(1,'Trial Number %d/%d \n',trialNum,nTrials);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Load sound stimuli into TDT  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    AudioController('clearBuffer', TDT); % Ensure any previous stimuli are cleared before loading new one
   
    if ear == 1
        tempTone = [currTone; 0.*currTone];
    elseif ear == 2
        tempTone = [0.*currTone; currTone];
    elseif ear == 3
        tempTone = [currTone; currTone];
    end
    
        AudioController('loadBuffer', TDT, tempTone);
        TDT.playbackStamp = 1;
  
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Cue Frame and audio playback start  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %WaitSecs('UntilTime', presTimesSched(1,trialNum));
    WaitSecs('UntilTime', nextPlayTime);
    
    presTimesActual(trialNum) = AudioController('start', TDT);
    
    WaitSecs(dur/1000 +.01); % Wait while the sound plays
    nextPlayTime = GetSecs + 1;
    
    AudioController('stopReset', TDT); % Stop the sound and reset the cursor
    

    %quitCheck;          % looks to see if esc or ctrl is pressed and quits
end
cleanupError(TDT);

%% Noise Parameters:
% Uncorrelated noise between ears
% 20 db lower than stimulus
% continuous gnoise from 100 to 10kHz
