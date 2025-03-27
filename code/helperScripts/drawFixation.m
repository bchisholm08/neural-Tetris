function drawFixation(window, position, params)
    % Draws a fixation cross or dot at the specified position on the screen.
    %
    % Inputs:
    %   window: The Psychtoolbox window pointer.
    %   position: The position to draw the fixation (e.g., 'center' or [x, y] coordinates).
    %   params: A structure containing parameters for the fixation (e.g., size, color).
    %
    % Example usage:
    %   draw_fixation(window, 'center', params);

    % Get the window's center if position is 'center'
    if strcmpi(position, 'center')
        [winWidth, winHeight] = Screen('WindowSize', window);
        xCenter = winWidth / 2;
        yCenter = winHeight / 2;
        position = [xCenter, yCenter];
    end

    % Extract fixation parameters from params
    fixationSize = params.fixation.size; % Size of the fixation cross or dot
    fixationColor = params.fixation.color; % Color of the fixation (e.g., [255 255 255] for white)
    fixationType = params.fixation.type; % 'cross' or 'dot'

    % Draw the fixation
    switch lower(fixationType)
        case 'cross'
            % Draw a fixation cross
            crossArmLength = fixationSize / 2;
            Screen('DrawLines', window, ...
                   [-crossArmLength, crossArmLength, 0, 0; 0, 0, -crossArmLength, crossArmLength], ...
                   2, fixationColor, position);
        case 'dot'
            % Draw a fixation dot
            dotRadius = fixationSize / 2;
            Screen('DrawDots', window, position, dotRadius * 2, fixationColor, [], 2);
        otherwise
            error('Invalid fixation type. Use "cross" or "dot".');
    end
end