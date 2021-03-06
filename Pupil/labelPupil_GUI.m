clearvars, clc
startPath = 'C:\Users\Leonardo\Documents\MATLAB\2pToolbox\Pupil\';

% -------------------------------------------------------------------------
% DO NOT EDIT PAST THIS POINT
% -------------------------------------------------------------------------
global handles
handles.pupilTransparency = 0.15;
handles.glintTransparency = 0.15;

% LOAD a Database .mat file containing images and labels up to date
[file,path,indx] = uigetfile([startPath '*.mat'],'Load a Pupil DB file');
if indx == 0
    disp('Aborted by user.')
    return
else
    load([path filesep file])
end


% Close the figures if they already exist
% (avoid duplicate figures on repeated calls of this script)
if exist('handles','var') && isfield(handles,'f') && ishandle(handles.f)
    close(handles.f);
end
if exist('handles','var') && isfield(handles,'fInstructions') && ishandle(handles.fInstructions)
    close(handles.fInstructions);
end


% Create the figure and adjust axes and location
screenSize = get(0,'ScreenSize');
relativeSize = 1/10;
pos = [screenSize(3)*relativeSize, screenSize(4)*relativeSize, ...
    screenSize(3)-(2*screenSize(3)*relativeSize),...
    screenSize(4)-(2*screenSize(4)*relativeSize)];

handles.f = figure('Position',pos,'Name','Pupil Labeler');
handles.ax = axes('Parent',handles.f,'DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual');


% Create figure for instructions
% instrWidth = screenSize(3) * 0.15;
% instrHeight = screenSize(4) * 0.3;
instrWidth = 250;
instrHeight = 300;
pos = [screenSize(3)-instrWidth, (screenSize(4)-instrHeight)/2,...
    instrWidth, instrHeight];
handles.fInstructions = figure('Position',pos, 'Name','Labeler Instructions',...
    'NumberTitle','off','ToolBar','none','Color',[.9 1 .9]);
handles.p = uipanel(handles.fInstructions,'Position',[0.05 0.05 0.9 0.9],...
    'Title','Commands','FontSize',12,'FontWeight','bold');
tx = sprintf(['A: previous img\n'...
    'D: next img\n'...
    'P: draw pupil\n'...
    '    --> Enter: confirm\n'...
    '    --> Canc: delete pupil\n'...
    'G: draw glint\n'...
    'B: flag as blink\n'...
    'R: flag as rejected\n'...
    'F12: save DB']);
uicontrol(handles.p, 'Style','text', 'String',tx,'Units','normalized',...
    'Position',[.1 .05 .8 .93],'HorizontalAlignment','left','FontSize',11,...
    'FontWeight','bold')


% Load parameters from the DB file
handles.f.UserData.imageInd = userData.imageInd;
handles.f.UserData.T = userData.T;
handles.f.UserData.selPath = userData.selPath;


% Initialize plots and show the first image
ind = handles.f.UserData.imageInd;
imData = imread([handles.f.UserData.selPath filesep handles.f.UserData.T.imageName{ind}]);
handles.img = imshow(imadjust(imData),...
    'Parent',handles.ax,...
    'InitialMagnification',150,...
    'Border','loose');
hold(handles.ax,'on')

% Pupil
yellowImg = zeros([size(imData),3],'uint8');
yellowImg(:,:,1:2) = 255;
handles.pupilMsk = imshow(yellowImg,'Parent',handles.ax);
if ~isempty(handles.f.UserData.T.pupilMask{ind})
    
    handles.pupilMsk.AlphaData = handles.f.UserData.T.pupilMask{ind} * handles.pupilTransparency;
    %     handles.img.CData = imoverlay(imData,handles.f.UserData.T.pupilMask{ind} > 128 ,'yellow');
else
    %     handles.msk = imshow(zeros(size(imData),'uint8'),'Parent',handles.ax);
    handles.pupilMsk.AlphaData = 0;
end

% Glint
blueImg = zeros([size(imData),3],'uint8');
blueImg(:,:,3) = 255;
handles.glintMsk = imshow(blueImg,'Parent',handles.ax);
if ~isempty(handles.f.UserData.T.glintMask{ind})
    
    handles.glintMsk.AlphaData = handles.f.UserData.T.glintMask{ind} * handles.glintTransparency;
    %     handles.img.CData = imoverlay(imData,handles.f.UserData.T.pupilMask{ind} > 128 ,'yellow');
else
    %     handles.msk = imshow(zeros(size(imData),'uint8'),'Parent',handles.ax);
    handles.glintMsk.AlphaData = 0;
end

hold(handles.ax,'off')

title(handles.ax,['File: ' handles.f.UserData.T.imageName{ind}],'Interpreter','none')
handles.f.KeyPressFcn = @keyParser;
handles.f.CloseRequestFcn = {@deleteAllFigures,handles};
handles.fInstructions.CloseRequestFcn = {@deleteAllFigures,handles};

% Set back focus on pupil figure
figure(handles.f)

% -------------------------------------------------------------------------
% ---- SUBFUNCTIONS
% -------------------------------------------------------------------------
function keyParser(src,event)
global handles
key = event.Key;
switch key
    case 'd'
        handles.f.UserData.imageInd = indexManager(handles,'+');
        updateImages
        
    case 'a'
        handles.f.UserData.imageInd = indexManager(handles,'-');
        updateImages
        
    case 'p'
        handles.f.UserData.currPupilEllipse = drawellipse('FaceAlpha',0.05,...
            'Color','y',...
            'Parent',handles.ax);
        
    case 'delete'
        ind = handles.f.UserData.imageInd;
        if ~isempty(handles.f.UserData.T.pupilMask{ind})
            handles.f.UserData.T.pupilMask{ind} = [];
        end
        if ~isempty(handles.f.UserData.T.glintMask{ind})
            handles.f.UserData.T.glintMask{ind} = [];
        end
        updateImages
        
    case 'return'
        % Save the drawn ellipse for the Pupil
        if isfield(handles.f.UserData,'currPupilEllipse') &&...
                ~isempty(handles.f.UserData.currPupilEllipse) &&...
                ishandle(handles.f.UserData.currPupilEllipse)
            mask = createMask(handles.f.UserData.currPupilEllipse,handles.img);
            mask = uint8(mask*255);
            handles.f.UserData.T.pupilMask{handles.f.UserData.imageInd} = mask;
        end
        % Save the drawn ellipse for the Glint
        if isfield(handles.f.UserData,'currGlintEllipse') &&...
                ~isempty(handles.f.UserData.currGlintEllipse) &&...
                ishandle(handles.f.UserData.currGlintEllipse)
            mask = createMask(handles.f.UserData.currGlintEllipse,handles.img);
            mask = uint8(mask*255);
            handles.f.UserData.T.glintMask{handles.f.UserData.imageInd} = mask;
        end
        updateImages
        
    case 'backspace'
        updateImages
        
    case 'f12'
        [file,path,indx] = uiputfile('.mat','Save Pupil labeling file.',['pupilDB_' datestr(now,'YYYYmmDD_hhMM')]);
        if indx ~= 0
            userData = handles.f.UserData;
            save([path filesep file],'userData')
            disp(['Data saved in : ' path file])
        end
        
    case 'b'
        handles.f.UserData.T.blink(handles.f.UserData.imageInd) = ~handles.f.UserData.T.blink(handles.f.UserData.imageInd);
        updateImages
        
    case 'r'
        handles.f.UserData.T.rejectedImg(handles.f.UserData.imageInd) = ~handles.f.UserData.T.rejectedImg(handles.f.UserData.imageInd);
        updateImages
        
    case 'g'
        handles.f.UserData.currGlintEllipse = drawellipse('FaceAlpha',0.05,...
            'Color','b',...
            'Parent',handles.ax);
        
end
end

function updateImages
global handles
ind = handles.f.UserData.imageInd;
T = handles.f.UserData.T;

% Deletes the interactive ellipses
if isfield(handles.f.UserData,'currPupilEllipse') && ishandle(handles.f.UserData.currPupilEllipse)
    delete(handles.f.UserData.currPupilEllipse)
end
if isfield(handles.f.UserData,'currGlintEllipse') && ishandle(handles.f.UserData.currGlintEllipse)
    delete(handles.f.UserData.currGlintEllipse)
end

imData = imread([handles.f.UserData.selPath filesep T.imageName{ind}]);
if all(size(imData) == size(handles.img.CData))
    sameResolution = true;
else
    sameResolution = false;
end

if sameResolution
    handles.img.CData = imadjust(imData);
else
    handles.img = imshow(imadjust(imData),...
    'Parent',handles.ax,...
    'InitialMagnification',150,...
    'Border','loose');
end
handles.ax.Title.String = [sprintf('File(%i/%i): ',ind,size(T,1)) T.imageName{ind}];
handles.ax.Title.Interpreter = 'none';

% Create new yellow and blue images if the resolution changed
if ~sameResolution
    hold(handles.ax,'on')
    
    yellowImg = zeros([size(imData),3],'uint8');
    yellowImg(:,:,1:2) = 255;
    handles.pupilMsk = imshow(yellowImg,'Parent',handles.ax);
    
    blueImg = zeros([size(imData),3],'uint8');
    blueImg(:,:,3) = 255;
    handles.glintMsk = imshow(blueImg,'Parent',handles.ax);

    hold(handles.ax,'off')
end

% Create image with overlays for visualization
if ~isempty(T.pupilMask{ind})
    handles.pupilMsk.AlphaData = handles.f.UserData.T.pupilMask{ind} * handles.pupilTransparency;
else
    handles.pupilMsk.AlphaData = 0;
end

if ~isempty(T.glintMask{ind})
    handles.glintMsk.AlphaData = handles.f.UserData.T.glintMask{ind} * handles.glintTransparency;
else
    handles.glintMsk.AlphaData = 0;
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

% Deletes both figures at the same time
function deleteAllFigures(~,~,handles)
try
    delete(handles.f)
    delete(handles.fInstructions)
catch ME
end
end



