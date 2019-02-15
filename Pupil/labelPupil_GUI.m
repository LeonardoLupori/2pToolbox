startPath = 'C:\Users\Leonardo\Documents\MATLAB\2pToolbox\Pupil\';
[file,path,indx] = uigetfile([startPath '*.mat'],'Load a Pupil DB file');
if indx == 0
    disp('Aborted by user.')
    return
else
    load([path filesep file])
end
if exist('handles','var') && isfield(handles,'f') && ishandle(handles.f)
    close(handles.f);
end
handles.f = figure('Position',[338 89 1180 887],'Name','Pupil Labeler');
handles.ax = axes('Parent',handles.f,'DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual');

% Load parameters from the DB file
handles.f.UserData.imageInd = userData.imageInd;
handles.f.UserData.T = userData.T;
handles.f.UserData.selPath = userData.selPath;

% Initialize plots and show the first image
ind = handles.f.UserData.imageInd;
imData = imread([handles.f.UserData.selPath filesep handles.f.UserData.T.imageName{ind}]);
handles.img = imshow(imData,'Parent',handles.ax,'InitialMagnification',150,'Border','loose');
hold on
if ~isempty(handles.f.UserData.T.pupilMask{ind})
    handles.msk = imshow(handles.f.UserData.T.pupilMask{ind},'Parent',handles.ax);
    handles.msk.AlphaData = 0.1;
else
    handles.msk = imshow(zeros(size(imData),'uint8'),'Parent',handles.ax);
    handles.msk.AlphaData = 0;
end
hold off
title(handles.ax,['File: ' handles.f.UserData.T.imageName{ind}],'Interpreter','none')
handles.f.KeyPressFcn = {@keyParser,handles};

% SUBFUNCTIONS

function keyParser(src,event,handles)
key = event.Key;
switch key
    case 'd'
        handles.f.UserData.imageInd = indexManager(handles,'+');
        updateImages(handles)
    case 'a'
        handles.f.UserData.imageInd = indexManager(handles,'-');
        updateImages(handles)
    case 'p'
        handles.msk.AlphaData = 0;
        handles.f.UserData.currEllipse = drawellipse('FaceAlpha',0.05,...
            'Color','r',...
            'Parent',handles.ax);
    case 'return'
        if ~isempty(handles.f.UserData.currEllipse)
            mask = createMask(handles.f.UserData.currEllipse,handles.img);
            mask = uint8(mask*255);
            handles.f.UserData.T.pupilMask{handles.f.UserData.imageInd} = mask;
            updateImages(handles)
        end
    case 'backspace'
        updateImages(handles)
    case 'f12'
        [file,path,indx] = uiputfile('.mat','Save Pupil labeling file.',['pupilDB_' datestr(now,'YYYYmmDD_hhMM')]);
        if indx ~= 0
            userData = handles.f.UserData;
            save([path filesep file],'userData')
            disp(['Data saved in : ' path filesep file])
        end
    case 'b'
        handles.f.UserData.T.blink(handles.f.UserData.imageInd) = ~handles.f.UserData.T.blink(handles.f.UserData.imageInd);
        updateImages(handles)
    case 'r'
        handles.f.UserData.T.rejectedImg(handles.f.UserData.imageInd) = ~handles.f.UserData.T.rejectedImg(handles.f.UserData.imageInd);
        updateImages(handles)   
end
end

function updateImages(handles)
ind = handles.f.UserData.imageInd;
T = handles.f.UserData.T;
if isfield(handles.f.UserData,'currEllipse') && ishandle(handles.f.UserData.currEllipse)
    delete(handles.f.UserData.currEllipse)
end
imData = imread([handles.f.UserData.selPath filesep T.imageName{ind}]);
handles.img.CData = imData;
handles.ax.Title.String = [sprintf('File(%i/%i): ',ind,size(T,1)) T.imageName{ind}];
if ~isempty(T.pupilMask{ind})
    hold on
    handles.msk.CData = cat(3,zeros([size(T.pupilMask{ind}),2],'uint8'),T.pupilMask{ind});
    handles.msk.AlphaData = 0.1;
    hold off
else
    handles.msk.CData = zeros(size(imData),'uint8');
    handles.msk.AlphaData = 0;
end
blinkTextHandle = handles.ax.Children.findobj('String','Blink');
if T.blink(ind)
    handles.txB = text(0.01,0.05,'Blink','Color','g','FontSize',30,'Units','normalized');
elseif ~isempty(blinkTextHandle)
    delete(blinkTextHandle)
end
rejTextHandle = handles.ax.Children.findobj('String','Rejected');
if T.rejectedImg(ind)
    handles.txR = text(0.43,0.5,'Rejected','Color','r','FontSize',35,'Units','normalized');
elseif ~isempty(rejTextHandle)
    delete(rejTextHandle)
end
end

function index = indexManager(handles,direction)
ind = handles.f.UserData.imageInd;
T = handles.f.UserData.T;
if strcmp(direction,'+')
    index = ind+1;
elseif strcmp(direction,'-')
    index = ind-1;
else
    return
end

if index<1
    index = size(T,1);
elseif index>size(T,1)
    index=1;
end
end
