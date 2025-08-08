function getTetrisSubjs()


    subjList = { ...
        "P01", "P02",'P03','P04',"P05","P06"...  % subjs 1-...
        };

    excludeSubjs = {'P01'}; % P01 must redo session 
    subjList = setdiff(subjList, excludeSubjs, 'stable');
end 