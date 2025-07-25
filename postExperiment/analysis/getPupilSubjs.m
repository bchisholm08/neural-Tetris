function subjList = getPupilSubjs(experiment)
%GETPUPILSUBJS Return subject IDs for a given experiment.
%   subjList = GETPUPILSUBJS(experiment)
%
%   experiment == 1 : returns the hard-coded list minus excluded subjects
%   otherwise       : throws an error

if experiment == 1
    subjList = { ...
        'gg02', % subjs 1-10
                % subjs 11-20
        };

    excludeSubjs = {'_'};
    subjList = setdiff(subjList, excludeSubjs, 'stable');

else
    error('getPupilSubjs:BadInput', ...
          'Input experiment=%d has no subject list defined.', experiment);
end
end