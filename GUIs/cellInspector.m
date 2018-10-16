function varargout = cellInspector(varargin)
% CELLINSPECTOR MATLAB code for cellInspector.fig
%      CELLINSPECTOR, by itself, creates a new CELLINSPECTOR or raises the existing
%      singleton*.
%
%      H = CELLINSPECTOR returns the handle to a new CELLINSPECTOR or the handle to
%      the existing singleton*.
%
%      CELLINSPECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CELLINSPECTOR.M with the given input arguments.
%
%      CELLINSPECTOR('Property','Value',...) creates a new CELLINSPECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cellInspector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cellInspector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cellInspector

% Last Modified by GUIDE v2.5 14-Sep-2018 17:49:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cellInspector_OpeningFcn, ...
                   'gui_OutputFcn',  @cellInspector_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before cellInspector is made visible.
function cellInspector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cellInspector (see VARARGIN)

% Choose default command line output for cellInspector
handles.output = hObject;
% Get argunets of the GUI
handles.data = varargin{1};
handles.cInd = 1;
% Update handles structure
guidata(hObject, handles);


createGraphics(hObject)


% --- Outputs from this function are returned to the command line.
function varargout = cellInspector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btn_Up.
function btn_Up_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btn_R_cell.
function btn_R_cell_Callback(hObject, eventdata, handles)
% hObject    handle to btn_R_cell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
d = handles.data;
if handles.cInd< length(d.validCells)
    handles.cInd = handles.cInd+1;
    guidata(hObject, handles);
    updateGraphics(hObject)
end

% --- Executes on button press in btn_L_cell.
function btn_L_cell_Callback(hObject, eventdata, handles)
% hObject    handle to btn_L_cell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
d = handles.data;
if handles.cInd> 1
    handles.cInd = handles.cInd-1;
    guidata(hObject, handles);
    updateGraphics(hObject)
end

% --- Executes on button press in btn_down.
function btn_down_Callback(hObject, eventdata, handles)
% hObject    handle to btn_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateGraphics(hObject)
handles = guidata(hObject);
d = handles.data;
[currentCellResp, currentCellStims, currentCellSEM] = responsivity(handles);

coloredPlotter(hObject, handles.ax_plot, d.framesTime,...
    d.dFoF(:,d.validCells(handles.cInd)), d.stimulus)

handles.respPlot.YData = currentCellResp;
handles.respPlot.YPositiveDelta = currentCellSEM;
handles.respPlot.YNegativeDelta = currentCellSEM;
title(handles.ax_plot,['Cell #' num2str(d.validCells(handles.cInd))])

function [currentCellResp, currentCellStims, currentCellSEM] = responsivity(handles)
d = handles.data;
stim = unique(d.stimulus(d.stimulus~=0)); % excluding 0
avgResp = zeros(size(stim));
avgSEM = zeros(size(stim));
trace = d.dFoF(:,d.validCells(handles.cInd));
for i=1:length(avgResp) 
    avgResp(i) = mean(trace(d.stimulus==(i)));
    avgSEM(i) = std(trace(d.stimulus==(i))) / sqrt(sum(d.stimulus==(i)));
end
currentCellResp =  avgResp;
currentCellStims = stim;
currentCellSEM = avgSEM;

function createGraphics(hObject)
handles = guidata(hObject);
d = handles.data;

% dR/Rplot
numOfConditions = length(unique(d.stimulus));
set(gcf,'DefaultAxesColorOrder',linspecer(numOfConditions))

coloredPlotter(hObject, handles.ax_plot, d.framesTime,...
    d.dFoF(:,d.validCells(handles.cInd)), d.stimulus)

% numOfConditions = length(unique(d.stimulus));
% for i=0:numOfConditions-1
%     x =  d.framesTime;
%     x(d.stimulus~=i) = NaN;
%     y = d.dFoF(:,d.validCells(handles.cInd));
%     y(d.stimulus~=i) = NaN;
%     handles.plot(i+1) = plot(handles.ax_plot,x,y,'DisplayName',['Cond:' num2str(i)],...
%         'LineWidth',1.1);
%     if i==0
%         hold(handles.ax_plot,'on')
%     end
% end

% handles.plot = plot(handles.ax_plot, d.framesTime,...
%     d.dFoF(:,d.validCells(handles.cInd)),'DisplayName','dF/F trace');
% hold(handles.ax_plot,'on')
% handles.stim = plot(handles.ax_plot, d.framesTime, (d.stimulus*.1)-1,...
%     'color','r','DisplayName','Stimuli','linewidth',1);

guidata(hObject, handles);

% responsivness plot
[currentCellResp, currentCellStims currentCellSEM] = responsivity(handles);
handles = guidata(hObject);
handles.respPlot = errorbar(handles.ax_resp, currentCellStims,...
    currentCellResp,currentCellSEM ,'color','b','marker','s');
line([0 currentCellStims(end)],[0 0],'color','k')
uistack(handles.respPlot,'top')
xlim([1 max(currentCellStims)])
ylabel('AVG \DeltaF/F'), xlabel('Stim Condition')
title('Stim Selectivity')
guidata(hObject, handles);

function coloredPlotter(hObject,axHanlde,time,trace,stimuli)
handles = guidata(hObject);
d = handles.data;
numOfConditions = length(unique(stimuli));
for i=0:numOfConditions-1
    x = time;
    x(stimuli~=i) = NaN;
    y = trace;
    y(stimuli~=i) = NaN;
    handles.plot(i+1) = plot(axHanlde,x,y,'DisplayName',['Cond:' num2str(i)],...
        'LineWidth',1.1);
    if i==0
        hold(axHanlde,'on')
    end
end

hold(handles.ax_plot, 'off')
line(handles.ax_plot,[0 d.framesTime(end)],[0 0],'color','k','linewidth',1.5)
xlim(handles.ax_plot,[0 d.framesTime(end)])
uistack(handles.plot,'top')
legend(handles.ax_plot,handles.plot,'location','best');
title(handles.ax_plot,['Cell #' num2str(d.validCells(handles.cInd))])
xlabel(handles.ax_plot,'Time (s)'), ylabel(handles.ax_plot,'\DeltaF/F')
guidata(hObject, handles);
