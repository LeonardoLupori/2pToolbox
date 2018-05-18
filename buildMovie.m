function [redMovie, greenMovie] = buildMovie(frameFolder, sequenceStruct)
% [redMovie, greenMovie] = buildMovie(frameFolder, sequenceStruct)
% 
% buildMovie create 3D MATLAB arrays of images of a sequence specified as a
% sequenceStruct in the arguments. The function automatically detects which
% channel was active and collects the TIFF files for each active channel in
% a 3D matlab array. For inactive channels, buildMovie returns an empty
% array.
% The MATLAB arrays have the same datatype of the TIFF images (usually
% uint16)
% 
% ARGUMENTS
% frameFolder - The experiment folder in which all the TIFF and XML files
% of the experiment are stored.
% sequenceStruct - A struct of a sequence to analyze (can be generated from
% an XML file with the function loadExperimentXML). IMPORTANT: A single
% sequence at a time can be built in this function. In case of
% multisequence experiments, loadExperimentXML returns a mutidimensional
% struct of sequences. Analyze one at a time.
% 
% OUTPUTS
% redMovie - a MATLAB array containing the data of the red channel imported
% from the TIFF files. If the red channel was not recorded, redMovie is an
% empty array.
% greenMovie - a MATLAB array containing the data of the green channel imported
% from the TIFF files. If the green channel was not recorded, greenMovie is an
% empty array.
% 
% Created by: Leonardo Lupori 09/04/2018
% 
% see also loadExperimentXML

% Get movie size for array initialization
numOfFrames = size(sequenceStruct.frame,2); % get the 3rd dimension
[redActive, greenActive] = channelsActive(sequenceStruct);
if redActive % load the firts image available to get 1st and 2nd dimensions
    fileName = sequenceStruct.frame(1).redChannelFrame;
elseif greenActive
    fileName = sequenceStruct.frame(1).greenChannelFrame;
else
    error('Neither red nor green channel data are available in the specified sequenceStruct')
end
img = imread([frameFolder fileName]);

redMovie = [];
greenMovie = [];

if redActive
    % Preallocation
    redMovie = zeros(size(img,1), size(img,2), numOfFrames, class(img));
    % Fill the array with image Data
    for f = 1:numOfFrames
        redMovie(:,:,f) = imread([frameFolder sequenceStruct.frame(f).redChannelFrame]);
    end
end

if greenActive && (~(nargout == 1))
    % Preallocation
    greenMovie = zeros(size(img,1), size(img,2), numOfFrames, class(img));
    % Fill the array with image Data
    for f = 1:numOfFrames
        greenMovie(:,:,f) = imread([frameFolder sequenceStruct.frame(f).greenChannelFrame]);
    end
end

