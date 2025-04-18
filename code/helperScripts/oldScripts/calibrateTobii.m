function calibrate_tobii(window, params)
    calib = tetio_localCalibration();
    calibPoints = [0.1 0.1; 0.9 0.1; 0.5 0.5; 0.1 0.9; 0.9 0.9];
    
    for p = 1:size(calibPoints,1)
        pos = calibPoints(p,:) .* [params.screen.width, params.screen.height];
        Screen('DrawDots', window, pos, 30, [1 1 1], [], 2);
        Screen('Flip', window);
        tetio_addCalibPoint(pos(1), pos(2));
        WaitSecs(1);
    end
    
    [calibResult, quality] = tetio_computeCalib();
    if quality < 0.8
        error('Calibration quality insufficient (%.2f)', quality);
    end
    disp('Tobii calibration successful');
end