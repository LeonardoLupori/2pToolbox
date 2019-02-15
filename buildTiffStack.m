function buildTiffStack(pathToFiles, substring, fileName, cropLimits)

% buildTiffStack(pathToFiles, substring, fileName)
% buildTiffStack(pathToFiles, substring, fileName, cropLimits)
% 
% buildTiffStack reads a collection of tiff images, sorts them
% alphabetically and generate a single multiplane tiff file for further
% image processing. While loading the images, buildTiffStack can crop in 3D
% the entire stack based on the argument cropLimits. By default it saves
% the entire 3D stack
% 
% ARGUMENTS
% pathToFiles: the path to the folder containing the tiff images
% substring: substring to search for in order to identify images in the
% folder. can be .tif or .ome.tiff or whatever is distinctive of only the
% image files
% fileName: filename to give to the output file
% cropLimits(optional): default([0 0;0 0;0 0]). A 3-by-2 matrix specifying
% the limits of the tiffStack that you want to save. Rows define the
% crop limits for rows, columns and frames, while columns define the
% beginning (1-indexed) and the end of the crop. 0 means maintaining the
% normal dimension (e.g., from 1 to the size of that dimension).
% 
% Leonardo Lupori 11-Feb-2019

if nargin < 4
    cropLimits = zeros(3,2);
end

[logicalList, names] = findFile(pathToFiles, substring);
names = sort(names); % make sure files are in ascending order

if sum(logicalList) == 0
    error(['No file with substring: "' substring '" detected in the folder'])
end

% parse crop limits 
im = imread([pathToFiles filesep names{1}]);
maxDim = [size(im,1), size(im,2), size(names,1)];
for row = 1:3
    % start at 1 if user doesn't specify limits
    if cropLimits(row,1) == 0
        cropLimits(row,1) = 1;
    end
    % ends at the last index if user doesn't specify limits
    if cropLimits(row,2) == 0
        cropLimits(row,2) = maxDim(row);
    end
end

% Save every frame
for i = cropLimits(3,1): cropLimits(3,2)
    im = imread([pathToFiles filesep names{i}]);
    % 2D (x and y) crop of the Tiff stack eventually specified by the user
    im = im(cropLimits(1,1): cropLimits(1,2), cropLimits(2,1): cropLimits(2,2));
    % wtire image
    imwrite(im,fileName,'tif',...
        'WriteMode','append',...
        'Compression','lzw');
end
