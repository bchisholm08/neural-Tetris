%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.15.2025
%
% Description: In P4 of the experiment we have uniquely complicated
% stimuli, and want to have explicit control over how the stimuli are
% created. This function takes in the pieces list, some options, and
% conditions from the P4 experiment. 
%                            
%-------------------------------------------------------
% getMyP4Stimuli.m
%
% Returns a struct array 'stimulusSequence' with fields:
%   blockNum, trialNumWithinBlock,
%   targetPieceName, stimulusPieceName,
%   isMatch, eegTrigger,
%   tableauPositions, correctResponseKey
%
function stimulusSequence = getMyP4Stimuli(pieces, p4opts, conditions)

    % unpack options
    numBlocks      = p4opts.blocks;
    trialsPerBlock = p4opts.trialsPerBlock;
    nPieces        = numel(pieces);
    
    % sanity check
    if mod(trialsPerBlock,2)~=0
        error('getMyP4Stimuli: trialsPerBlock must be even.');
    end
    
    % names & counts
    totalTrials = numBlocks * trialsPerBlock;
    pieceNames  = {pieces.name};
    
    % pre-alloc
    stimulusSequence = repmat(struct(...
        'blockNum',[],...
        'trialNumWithinBlock',[],...
        'targetPieceName','', ...
        'stimulusPieceName','', ...
        'isMatch',[], ...
        'eegTrigger',[], ...
        'tableauPositions',[], ...
        'correctResponseKey','' ), totalTrials, 1);
    
    % prepare block order
    blockOrder = randperm(nPieces);
    overallIdx = 0;
    
    for b = 1:numBlocks
        targetName = pieceNames{ blockOrder(b) };
        
        % build 50/50 match / non-match list
        matchList    = repmat({targetName}, trialsPerBlock/2, 1);
        nonMatchPool = pieceNames(~strcmp(pieceNames,targetName));
        nmList       = repmat(nonMatchPool, 1, ceil((trialsPerBlock/2)/numel(nonMatchPool)));
        nmList       = nmList(1:trialsPerBlock/2)';
        
        thisBlockList = [matchList; nmList];
        thisBlockList = thisBlockList(randperm(trialsPerBlock));
        
        for t = 1:trialsPerBlock
            overallIdx = overallIdx + 1;
            stimName   = thisBlockList{t};
            isMatch    = strcmp(stimName, targetName);
            
            % choose eventType
            if isMatch
                eventType = 'afc_match_trial';
                correctCond = 'fit_complete';
            else
                eventType = 'afc_nonmatch_trial';
                correctCond = 'garbage';
            end
            
            % get trigger code
            trig = getTrig(stimName, eventType);
            
            % randomize tableau positions
            posKeys = {'up','down','left','right'};
            shuffledConds = conditions(randperm(numel(conditions)));
            tblPos = cell2struct(shuffledConds, posKeys, 2);
            
            % correct response key
            respKey = posKeys{ strcmp(shuffledConds, correctCond) };
            
            % fill struct
            S = stimulusSequence(overallIdx);
            S.blockNum            = b;
            S.trialNumWithinBlock = t;
            S.targetPieceName     = targetName;
            S.stimulusPieceName   = stimName;
            S.isMatch             = isMatch;
            S.eegTrigger          = trig;
            S.tableauPositions    = tblPos;
            S.correctResponseKey  = respKey;
            
            stimulusSequence(overallIdx) = S;
        end
    end
    
    fprintf('getMyP4Stimuli: Created %d trials (%d blocks × %d trials).\n', ...
            totalTrials, numBlocks, trialsPerBlock);
end
