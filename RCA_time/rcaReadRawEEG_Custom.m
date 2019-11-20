function [subj_names, DataOut] = rcaReadRawEEG_Custom(varargin)
% Alexandra Yakovleva, Stanford University 2012-2020

% loads project's EEG data with the option of loading from default export directory 'Exp_MATL_HCN_128_Avg'
% possible to load directories with specific flag 

    rca_path = varargin{1};
    
    loadedDir = rca_path.loadedEEG;
    eegSrc = rca_path.srcEEG;
    listDir = eegSrc;

    if (nargin >1)
        listDir = fullfile(eegSrc, varargin{2});
    end
    
    subdir = '';
    
    if (nargin > 2)
        subdir = 'Exp_MATL_HCN_128_Avg';
    end
    % data processing args
    how.nScenes = 1;
    removeEyes = 0;
    nanArtifacts = 1;
    censorEvents = [];
    
    readArgs = { how, removeEyes, nanArtifacts, censorEvents};
       
    list_subj = list_folder(listDir);        
    nsubj = numel(list_subj);
    subj_names = {list_subj(:).name};
    % check if there is a matfile
    rcaData = {};
    display(['Eye Artifacts Status = ' num2str(removeEyes)]);
    for nge = 1:nsubj
        if (list_subj(nge).isdir)
            subjDir = fullfile(eegSrc, list_subj(nge).name, subdir);
            subjDataFile = fullfile(loadedDir, [list_subj(nge).name '.mat']);
            try                
                if (exist(subjDataFile, 'file'))
                    display(['Loading   ' subjDataFile]);
                    load(subjDataFile);
                else
                    display(['Loading   ' subjDir]);                   
                    %subjEEG = readRawData(subjDir, removeEyes);
                    subjEEG = exportToRcaReady(subjDir, readArgs{:});                    
                    save(subjDataFile, 'subjEEG');
                end
                rcaData(nge, :) = subjEEG(:)';
            catch err
                display(['Warning, could not load   ' list_subj(nge).name]);
                subj_names(nge) = [];
                %do nothing
            end 
        else
            % if mat file
            subjDataFile = fullfile(loadedDir, list_subj(nge).name);
            try                               
                display(['Loading   ' subjDataFile]);
                load(subjDataFile);
                rcaData(nge, :) = subjEEG(:)';
            catch
            end
        end
    end
    DataOut = reshape(rcaData(~cellfun('isempty', rcaData)), size(rcaData));
end
