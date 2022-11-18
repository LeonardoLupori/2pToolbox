function outImage = cellsOverlay(meanImage, stat, iscell, options)
% outImage = cellsOverlay(meanImage, stat, iscell)
% outImage = cellsOverlay(meanImage, stat, iscell, options)
% 
% cellsOverlay Creates an RGB image that overlays colored cells ROI on the
% average Image of a 2P recording. The transparency of the colored ROIs is
% determined by the "alpha" option.
% 
% OPTIONS
% alpha(float [0:1]): transparency of the cells
% robust(bool): Wether the average image is displayed scaled to
% min-max(false) of if the top and bottom 1 precentile will be
% clipped(true)
% onlyValidCells(bool): Display only valid cells or all cells
% 
% EXAMPLE
% outImage = cellsOverlay(ops.meanImg, stat, iscell, 'alpha', 0.2);

arguments
    meanImage
    stat
    iscell
    options.alpha = 0.4;
    options.robust = true;
    options.onlyValidCells = true
end

if options.robust
    lims = [quantile(meanImage(:),0.01), quantile(meanImage(:),0.99)];
else
    lims = [min(meanImage(:)), max(meanImage(:))];
end

if options.onlyValidCells
    nCells = sum(iscell(:,1));
    cellsStatToPlot = stat(logical(iscell(:,1)));
else
    nCells = size(iscell,1);
    cellsStatToPlot = stat;
end

% Create uint8 RGB background image
intMean = uint8(mat2gray(meanImage, lims) * 255);
intMean = cat(3, intMean,intMean,intMean);

% Custom colormap with unique colors for each cell
myCmap = uint8(hsv(nCells) * 255);

% RGB image with cells colored
roiImg = zeros([size(meanImage), 3],'uint8');
roiImg = reshape(roiImg,[],3);

for i=1:nCells
    ind = sub2ind(size(meanImage),cellsStatToPlot{i}.ypix+1, cellsStatToPlot{i}.xpix+1);
    roiImg(ind,1) = myCmap(i,1);
    roiImg(ind,2) = myCmap(i,2);
    roiImg(ind,3) = myCmap(i,3);
end

roiImg = reshape(roiImg,size(meanImage,1), size(meanImage,2), 3);

outImage = options.alpha * roiImg + (1 - options.alpha) * intMean;

