function humanTetrisWrapper(subjID)
% this function will ultimately use the subj id (and maybe demoMode and/or params) as an
% input to call p1(), p2(), etc... 
% may included other 'helper' type things, but pretty simple overall

% use interExp(subjID) to simply displays a screen and begins an
% internal timer to record how long of a break we take between p1(), p2() etc... 

p1(subjID);
% interExp(subjID)

p2(subjID);
% interExp(subjID)

p3(subjID);
% interExp(subjID)

p4(subjID);
% interExp(subjID)

p5(subjID);
% interExp(subjID)

% end screen? () 
end 