%{
chat gpt function to view a tableau individually, outside of experiment
code. Fun to see how it does
%}
function tableauViewer(tableaus)
    try
        % Bypass sync tests for Windows 11 compatibility
        Screen('Preference', 'SkipSyncTests', 1);
        Screen('Preference', 'ConserveVRAM', 8192); % Enable workarounds
        
        % Basic Psychtoolbox setup
        PsychDefaultSetup(2);
        AssertOpenGL;
        
        % Get screen parameters
        screens = Screen('Screens');
        if isempty(screens)
            error('No screens found! Check display connections.');
        end
        screenNumber = max(screens);
        
        % Open window with optimizations
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask', 'General', 'UseVirtualFramebuffer');
        [window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0.5 0.5 0.5]);
        
        % Prioritize for better timing
        Priority(MaxPriority(window));
        
        % Visualization settings
        blockSize = 40;
        colors.piece = [0 1 0];
        colors.floor = [0.3 0.3 0.3];
        colors.background = [0.5 0.5 0.5];
        
        % Display loop
        current = 1;
        while current <= length(tableaus)
            [tex, texRect] = createTex(window, tableaus(current), colors, blockSize);
            destRect = CenterRect(texRect, windowRect);
            
            Screen('FillRect', window, colors.background);
            Screen('DrawTexture', window, tex, [], destRect);
            
            info = sprintf('%s - %s\n\nLeft/Right: Navigate | ESC: Quit',...
                tableaus(current).piece,...
                strrep(tableaus(current).condition, '_', ' '));
            DrawFormattedText(window, info, 'center', 30, [1 1 1]);
            Screen('Flip', window);
            
            % Robust key handling
            [~, keyCode] = KbWait(-1);
            KbReleaseWait(-1); % Wait for key release
            key = KbName(find(keyCode, 1));
            
            if contains(lower(key), 'left') && current > 1
                current = current - 1;
            elseif contains(lower(key), 'right') && current < length(tableaus)
                current = current + 1;
            elseif strcmpi(key, 'ESCAPE')
                break;
            end
            
            Screen('Close', tex);
        end
    end
end
        
      function [tex, texRect] = createTex(window, tableau, colors, blockSize)
        [h, w] = size(tableau.board);
        img = zeros(h*blockSize, w*blockSize, 3, 'uint8');
        
        % Fill background
        img(:,:,1) = colors.background(1) * 255;
        img(:,:,2) = colors.background(2) * 255;
        img(:,:,3) = colors.background(3) * 255;
        
        % Draw blocks
        border = round(blockSize*0.1); % 10% border
        for row = 1:h
            for col = 1:w
                if tableau.board(row, col) == 1
                    % Choose color
                    if row >= 14
                        color = colors.floor * 255;
                    else
                        color = colors.piece * 255;
                    end
                    
                    % Block coordinates
                    xRange = (1:blockSize) + (col-1)*blockSize;
                    yRange = (1:blockSize) + (row-1)*blockSize;
                    
                    % Apply color to inner region
                    img(yRange(1+border:end-border), xRange(1+border:end-border), :) = ...
                        repmat(reshape(color,1,1,3), ...
                        length(yRange(1+border:end-border)), ...
                        length(xRange(1+border:end-border)), 1);
                end
            end
        end
        
        tex = Screen('MakeTexture', window, img);
        texRect = [0 0 w*blockSize h*blockSize];
      end
