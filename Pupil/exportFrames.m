clearvars, clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% USER PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resizeFactor = 1;                   % image downsampling
crop = 1;                           % logical. Crop or not the movie
croppedResolution = [600 700];      % size of the square crop (HxW)
framesBracket = [0.1, 0.9];         % first and last frame (normalized to total length to 0:1) where to get random imgs
nImages = 50;                       % number of images to export
startPath = 'D:\PizzorussoLAB\proj_Fasting\exp_acuity-2P\2P_data\prove\g2\';


[file,path,indx] = uigetfile([startPath '*.avi'],'Select a pupil Movie');
if indx==0
    disp('Selection aborted by user.')
    return
end
v = VideoReader([path file]);

% determine the square crop if the user chose to crop
if crop
    im = rgb2gray(imresize(v.readFrame('native'),resizeFactor));
    imshow(im)
    h = imrect(gca,[0 0 croppedResolution(2) croppedResolution(1)]);
    setResizable(h,false)
    wait(h);
    pos = round(h.getPosition);
    close(gcf)
end

%%

selpath = uigetdir(path,'Choose where to save output images');
if selpath==0
    disp('Process aborted by user.')
    return
end
% Choose nImages frames randomly
nFrames = v.Duration*v.FrameRate;
from = ceil(framesBracket(1)*nFrames);
to = ceil(framesBracket(2)*nFrames);
frames = datasample(from:to,nImages,'Replace',false);

% Create a template for the images names
imName = strsplit(v.Name,'-');
imName = [imName{1:end-1}];

for i = 1:size(frames,2)
    v.CurrentTime = (frames(i)-1)/v.FrameRate;
    temp = v.readFrame('native');
    temp = rgb2gray(temp);
    temp = imresize(temp, resizeFactor);
    if crop
        temp = temp(pos(2):pos(2)+pos(4)-1, pos(1):pos(1)+pos(3)-1);
    end
    imwrite(temp,[imName '.jpg'],'jpg')
end














