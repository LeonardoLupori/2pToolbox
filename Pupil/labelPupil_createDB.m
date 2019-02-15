clearvars, clc
startPath = 'D:\PizzorussoLAB\proj_Fasting\exp_acuity-2P\trainingPupil';
addpath(genpath('C:\Users\Leonardo\Documents\MATLAB\2pToolbox'))
% Get images folder
selPath = uigetdir(startPath,'Select images folder.');
if selPath == 0
    disp('Aborted by user')
    return
end
% Collect the images and assemble the table T
[logicalList, names] = findFile(selPath,'.jpg');
imageName = names;
rejectedImg = zeros(length(names),1,'logical');
blink = zeros(length(names),1,'logical');
pupilMask = cell(length(names),1);
T = table(imageName,pupilMask,blink,rejectedImg,'VariableNames',{'imageName','pupilMask','blink','rejectedImg'});
% Create variable to save
userData.imageInd = 1;
userData.T = T;
userData.selPath = selPath;
% Save variable
[file,path,indx] = uiputfile('.mat','Save Pupil labeling file.',['pupilDB_' datestr(now,'YYYYmmDD_hhMM')]);
if indx ~= 0
    save([path filesep file],'userData')
    disp(['Data saved in : ' path filesep file])
end

