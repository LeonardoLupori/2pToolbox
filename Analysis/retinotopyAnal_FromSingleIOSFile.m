clearvars, clc
startPath = 'D:\PizzorussoLAB\proj_Fasting\exp_acuity-2P\2P_data';
iosPostPath = 'C:\Users\Leonardo\Documents\MATLAB\IOS\ISOI_postProcessing';
framesPostStimToAverage = 8;

addpath(genpath(iosPostPath))
addpath(genpath('C:\Users\Leonardo\Documents\MATLAB\2pToolbox'))

% Load the tif file
[FileName,PathName,FilterIndex] = uigetfile('*.mat','Select all the mat files', startPath,...
    'MultiSelect','on');
if ~FilterIndex
    disp('Aborted.')
    return
end

ios_preprocessing([PathName filesep FileName]);

%%
m = matfile([PathName filesep FileName]);


anatomy = adapthisteq(m.anatomy);

ios = imgaussfilt(m.avgImage, 2) * -1;

im2plot = ios;
im2plot(im2plot<0) = 0;
im2plot = rescale(im2plot)*255;
im = cat(3, imresize(im2plot, size(anatomy)), anatomy);
sc(im,'prob');

%%

saveas(gcf, [PathName 'retinotopySpots.jpg'])

a = uint8(anatomy/256);
imwrite(imresize(a,2), [PathName 'anatomy.jpg'])


