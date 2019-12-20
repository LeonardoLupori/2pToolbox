defPath = 'D:\PizzorussoLAB\proj_pupilNN\h-dataset';

% Fetch the pupil DB file
titl = 'Choose a pupil DataBase file';
[FileName,PathName,FilterIndex] = uigetfile([defPath '*.mat'], titl);
if FilterIndex == 0
    disp('Process aborted by user.')
    return
end
% Load the database of images
load([PathName FileName])
t = userData.T;


% Figure out a folder one level above the frames folder
ind = strfind(userData.selPath,filesep);
maskPath = [userData.selPath(1:ind(end)), 'png'];
% resizedpath = [userData.selPath(1:ind(end)), 'resized'];

f = figure;
ax = axes;
% Big for loop that exports all the images
for i=1:size(t,1)
    %     if t.blink(i)
    %         continue
    %     elseif t.rejectedImg(i)
    %         continue
    %     end
    
    if t.rejectedImg(i)
        continue
    end
    
    %     im  = imread([userData.selPath filesep t.imageName{i}]);
    %     im = imresize(im, 0.5);
    %     if i==1
    %         imHandle = imshow(im,'Parent',ax);
    %         h = drawrectangle(gca,'Position',[0,0,128,128],'InteractionsAllowed','translate');
    %     end
    %     imHandle.CData = im;
    %     pause
    
    % Name of the mask Image
    maskImgName = [t.imageName{i}(1:end-3), 'png'];
    
    %     resized = imresize(logical(t.pupilMask{i}), 0.5);
    %     resized = uint8(resized*255);
    %     blankChannel = zeros(size(resized),'uint8');
    %     maskImg = cat(3,resized,blankChannel, blankChannel);
    blankChannel = zeros(size(t.pupilMask{i}),'uint8');
    maskImg = cat(3,t.pupilMask{i},blankChannel, blankChannel);
    if t.blink(i)
        maskImg = cat(3,blankChannel,blankChannel, blankChannel);
    end
    
    
    crop = ceil(h.Position);
%     croppedMask = maskImg(crop(2):crop(2)+crop(4)-1,crop(1):crop(1)+crop(3)-1,:);
    croppedIm = im(crop(2):crop(2)+crop(4)-1,crop(1):crop(1)+crop(3)-1,:);
    
    
    imwrite(croppedMask,[maskPath filesep maskImgName], 'png')
    imwrite(croppedIm,[resizedpath filesep t.imageName{i}], 'jpg')
    fprintf(['File: ' t.imageName{i} ' saved.\n'])
end






