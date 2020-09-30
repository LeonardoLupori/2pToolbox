function tiffStack = loadTiffStack(filename)

% tiffStack = loadTiffStack(filename)

% loadTiffStack loads a tiff stack into a matlab variable
% Leonardo Lupori 2019

% Get stack infos for preallocating the variable
InfoImage = imfinfo(filename);
mImage = InfoImage(1).Width;
nImage = InfoImage(1).Height;
NumberImages = length(InfoImage);
tiffStack = zeros(nImage,mImage,NumberImages,'uint16');

% Create a Tiff object
TifLink = Tiff(filename, 'r');
% Load every frame (fast)
for i=1:NumberImages
   TifLink.setDirectory(i);
   tiffStack(:,:,i)=TifLink.read();
end
TifLink.close();