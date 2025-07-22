%-------------------------------------------------------
% Author: Brady M. Chisholm
% University of Minnesota Twin Cities, Dpt. of Neuroscience
% Date: 6.9.2025
% 
%
% Description: Helper function for getting paths returned to initExperiment
% standardized paths for the experiment.
% Also finds the root project folder regardless of where MATLAB's "current folder" is.
% ID MAP: 0=root, 1=code, 2=data, 3=tools
%-------------------------------------------------------
function p = pathsAndPlaces(id)
    try
        % The most reliable method to find a file's location is `which`.
        % We use it to find this function's own full path.
        thisFilePath = which(mfilename('fullpath'));
        
        if isempty(thisFilePath)
            error('Could not find the path to getProjectPath.m. Is it saved and on the MATLAB path?');
        end
        
        % Navigate up the directory tree to find the root project folder
        % structure of: .../project_root/code/helperScripts/getProjectPath.m
        helperScriptsFolder = fileparts(thisFilePath);
        codeFolder = fileparts(helperScriptsFolder);
        root_project_folder = fileparts(codeFolder);
        
        % sanity check 
        if isempty(root_project_folder) || ~exist(fullfile(root_project_folder, 'code'), 'dir')
             error('Derived project root folder "%s" seems incorrect. Please check the folder structure.', root_project_folder);
        end
    catch ME
        % if we fail throw an error 
        rethrow(ME);
    end
    
    % Return the requested path based on the input ID
    switch id
        case 0
            p = root_project_folder; % The main project folder (e.g., 'Z:\13-humanTetris')
        case 1
            p = fullfile(root_project_folder, 'code');
        case 2
            p = fullfile(root_project_folder, 'data');
        case 3
            p = fullfile(root_project_folder, 'tools');
        otherwise
            error('Unknown path ID provided to getProjectPath().');
    end
end