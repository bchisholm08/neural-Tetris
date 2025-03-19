function [pupilHandle] = handlePupils(action, pupilHandle)
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

    % Convert action to lower case for consistent comparison
    action = lower(action);

    switch action
        case 'start'
            % ======= start pupil LOGIC =======
            fprintf('*** Tobii Tracking Requested ***\n');
            
            % Placeholder / dummy EEG start:
            % (In a real experiment, you might open a connection, 
            %  initialize hardware, open a file, etc.)
            pupilHandle = struct('isDummy', true, ...
                               'description', 'Dummy Pupil handle for testing');
            fprintf('Tobii Data acquisition started (dummy).\n');

        case 'stop'
            % ======= STOP EEG LOGIC =======
            fprintf('*** Tobii STOP Requested ***\n');
            
            if nargin < 2 || isempty(pupilHandle)
                warning('No Pupil handle provided to stop. Nothing to do.');
                return;
            end

            % Placeholder / dummy EEG stop:
            % (In a real experiment, you might close the connection,
            %  stop recording, finalize the file, etc.)
            fprintf('Tobii data acquisition stopped (dummy).\n');

        otherwise
            error('Unrecognized action "%s". Use "start" or "stop".', action);
    end

end
