function drawFixation(window, windowRect, color)
    [xCenter, yCenter] = RectCenter(windowRect);
    % Horizontal line (length: 20px, thickness: 4px)
    fixRect = [xCenter-10, yCenter-2, xCenter+10, yCenter+2];
    Screen('FillRect', window, color, fixRect);
    % Vertical line (length: 20px, thickness: 4px)
    fixRect = [xCenter-2, yCenter-10, xCenter+2, yCenter+10];
    Screen('FillRect', window, color, fixRect);
end