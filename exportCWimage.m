function exportCWimage()

defPath = 'D:\PizzorussoLAB\';
% LOAD THE REQUIRED FILES
% Load t file
[FileName,PathName,FilterIndex] = uigetfile('*.mat','Select a widefield file', defPath);
if ~FilterIndex
    disp('Aborted.')
    return
end

% Check wether the file has an anatomy variable
m = matfile([PathName FileName]);
if ~misField(m,'anatomy')
    error('The selected file doesn''t have any anatomy file')
end
% If more than one image are present select the first
img = m.anatomy;
if size(img,3)>1
    img = img(:,:,1);
end
img = im2uint8(cat(3,img,img,img));
% assemble the filename of the image
filename = [PathName 'cranialWindowImage.png'];
imwrite(img, filename)








