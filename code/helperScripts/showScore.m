function showScore(window, score)
  Screen('TextSize', window, 24);
  DrawFormattedText(window, sprintf('Score: %d', score), 'left', 'top', [255 255 255]);
  Screen('Flip', window);
end
