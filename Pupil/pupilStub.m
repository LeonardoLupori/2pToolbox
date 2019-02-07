%% General
clearvars, clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% USER PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resizeFactor = .5;           % image downsampling
crop = 1;                   % Crop or not the movie
croppedResolution = 512;    % size of the square crop
generateVideoVariable = 1;  % creates a variable of the processed video
exportVideo = 0;            % export the video in an avi file
startPath = 'D:\PizzorussoLAB\proj_Fasting\exp_acuity-2P\2P_data\';



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
    h = imrect(gca,[0 0 croppedResolution croppedResolution]);
    setResizable(h,false)
    wait(h);
    pos = round(h.getPosition);
    close(gcf)
end

%% Upload and crop video
nFrames = v.Duration*v.FrameRate;
fprintf('A total Number of %i frames has been detected.\n',nFrames)

if generateVideoVariable
    video = zeros(croppedResolution,croppedResolution,nFrames,'uint8');
end
if exportVideo
    vw = VideoWriter('prova');
    vw.open();
end

% Goes through each frame
v.CurrentTime = 0;      % Reset the movie at the beginning
currentFrame = 1;       % counter
while hasFrame(v)
    temp = v.readFrame('native');
    temp = rgb2gray(temp);
    temp = imresize(temp, resizeFactor);
    if crop
        temp = temp(pos(2):pos(2)+pos(4)-1, pos(1):pos(1)+pos(3)-1);
    end
    if generateVideoVariable
        video(:,:,currentFrame) = temp;
    end
    if exportVideo
        vw.writeVideo(temp);
    end
    % Print a status updater
    if mod(currentFrame,100)==0
        fprintf('Analyzed frame number: %i/%i\n',currentFrame,nFrames);
    end
    currentFrame = currentFrame + 1;
end

if exportVideo
    vw.close();
end
% clearvars -except v video


