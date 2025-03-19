function [eegHandle] = handleEEG(action, eegHandle)
% StartStopEEG - Combined Start/Stop function for EEG.
%
% Usage:
%   eegHandle = StartStopEEG('start');                  % to start EEG
%   StartStopEEG('stop', eegHandle);                    % to stop EEG
%
% Inputs:
%   action     - 'start' or 'stop' (not case-sensitive)
%   eegHandle  - (only required when stopping) the handle/struct returned 
%                after starting EEG
%
% Output:
%   eegHandle  - (only provided/valid when starting EEG)

    % Convert action to lower case for comparison
    action = lower(action);

    
    if nargin < 1 || isempty(action) || ~ischar(action)
        error('handleEEG: Invalid action input. Expected "start" or "stop".');
    end

   

    switch action
        case 'start'
            % ======= START EEG LOGIC =======
            fprintf('*** EEG START Requested ***\n');
            
            % Placeholder / dummy EEG start:
            % (In a real experiment, you might open a connection, 
            %  initialize hardware, open a file, etc.)
            
            % RETURN
            eegHandle = struct('isDummy', true, ...
                               'description', 'Dummy EEG handle for testing');
            fprintf('EEG acquisition started (dummy).\n');

        case 'stop'
            % ======= STOP EEG LOGIC =======
            fprintf('*** EEG STOP Requested ***\n');
            
            if nargin < 2 || isempty(eegHandle)
                warning('No EEG handle provided to stop. Nothing to do.');
                return;
            end

            % Placeholder / dummy EEG stop:
            % (In a real experiment, you might close the connection,
            %  stop recording, finalize the file, etc.)
            fprintf('EEG acquisition stopped (dummy).\n');

        otherwise
            error('Unrecognized action "%s". Use "start" or "stop".', action);
    end

end
