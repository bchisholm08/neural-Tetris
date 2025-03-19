function [leftPressed, rightPressed, downPressed, rotatePressed, quitPressed, pausePressed] = getInput()
    leftPressed = false;
    rightPressed = false;
    downPressed = false;
    rotatePressed = false;
    quitPressed = false;
    pausePressed = false;

    [keyIsDown, ~, keyCode] = KbCheck;

    if keyIsDown
        if keyCode(KbName('LeftArrow'))
            leftPressed = true;
        elseif keyCode(KbName('RightArrow'))
            rightPressed = true;
        elseif keyCode(KbName('DownArrow'))
            downPressed = true;
        elseif keyCode(KbName('UpArrow'))
            rotatePressed = true;
        elseif keyCode(KbName('p')) || keyCode(KbName('P'))
            pausePressed = true;
        elseif keyCode(KbName('Escape'))
            quitPressed = true;
        end
    end
end
