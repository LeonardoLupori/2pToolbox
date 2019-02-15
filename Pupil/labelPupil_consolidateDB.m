clearvars, clc
startPath = 'D:\PizzorussoLAB\proj_Fasting\exp_acuity-2P\trainingPupil';
addpath(genpath('C:\Users\Leonardo\Documents\MATLAB\2pToolbox'))
% Get images folder
selPath = uigetdir(startPath,'Select images folder.');
if selPath == 0
    disp('Aborted by user')
    return
end

[file,path,indx] = uigetfile('D:\PizzorussoLAB\*.mat','Load a Pupil DB file');
if indx == 0
    disp('Aborted by user.')
    return
else
    load([path filesep file])
end

% Collect the images and assemble the table T
[logicalList, names] = findFile(selPath,'.jpg');
imageName = names;
rejectedImg = zeros(length(names),1);
blink = zeros(length(names),1);
pupilMask = cell(length(names),1);
Tnew = table(imageName,pupilMask,blink,rejectedImg,'VariableNames',{'imageName','pupilMask','blink','rejectedImg'});
% only add files that were not already there
[~, newIndex] = setdiff(Tnew(:,'imageName'),userData.T(:,'imageName'));
T = [userData.T; Tnew(newIndex,:)];

% update variable to save
userData.T = T;
% Save variable
[file,path,indx] = uiputfile('.mat','Save Pupil labeling file.',['pupilDB_' datestr(now,'YYYYMMDD_hhmm')]);
if indx ~= 0
    save([path filesep file],'userData')
    disp(['Data saved in : ' path filesep file])
end
