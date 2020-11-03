clearvars, clc
startPath = 'C:\Users\Leonardo\Documents\MATLAB\2pToolbox\Pupil\';

% -------------------------------------------------------------------------
% DO NOT EDIT PAST THIS POINT
% -------------------------------------------------------------------------

% LOAD a Database .mat file containing images and labels up to date
[file,path,indx] = uigetfile([startPath '*.mat'],'Load a Pupil DB file');
if indx == 0
    disp('Aborted by user.')
    return
else
    load([path filesep file])
end

% Check wether the selected DB is an old version (without glint)
isDbOld = isfield(userData,'currEllipse') && ~any(ismember(userData.T.Properties.VariableNames,'glintMask'));

if ~isDbOld
    warning('The selected DB file does not seem to be an old version (without glint). Aborted.')
    return
end

% Add a variable to store the second ellipse object (for the glint)
% and rename the existing one
userData.currPupilEllipse = userData.currEllipse;
userData.currGlintEllipse = [];
userData = rmfield(userData,'currEllipse');

% Add the glintMask field to the table T
glintMask = cell(length(userData.T.pupilMask),1);
userData.T.glintMask = glintMask;

% Save the output in a new DB file
[file,path,indx] = uiputfile('.mat','Save Pupil labeling file.',['pupilDB_' datestr(now,'YYYYmmDD_hhMM')]);
if indx ~= 0
    save([path filesep file],'userData')
    disp(['Data saved in : ' path file])
end
