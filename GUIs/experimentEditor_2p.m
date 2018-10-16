function varargout = experimentEditor_2p(varargin)
% EXPERIMENTEDITOR_2P MATLAB code for experimentEditor_2p.fig
%      EXPERIMENTEDITOR_2P, by itself, creates a new EXPERIMENTEDITOR_2P or raises the existing
%      singleton*.
%
%      H = EXPERIMENTEDITOR_2P returns the handle to a new EXPERIMENTEDITOR_2P or the handle to
%      the existing singleton*.
%
%      EXPERIMENTEDITOR_2P('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPERIMENTEDITOR_2P.M with the given input arguments.
%
%      EXPERIMENTEDITOR_2P('Property','Value',...) creates a new EXPERIMENTEDITOR_2P or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before experimentEditor_2p_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to experimentEditor_2p_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help experimentEditor_2p

% Last Modified by GUIDE v2.5 04-May-2018 13:16:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @experimentEditor_2p_OpeningFcn, ...
                   'gui_OutputFcn',  @experimentEditor_2p_OutputFcn, ...
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

% --- Executes just before experimentEditor_2p is made visible.
function experimentEditor_2p_OpeningFcn(hObject, eventdata, handles, varargin)
[folderPath,~,~] = fileparts(mfilename('fullpath'));
handles.preferences = matfile([folderPath filesep 'experimentEditor_2p_preferences.mat'],'Writable',true);
defaultValues = handles.preferences.defaultValues;
templates = handles.preferences.experimentTemplates;

templateNames = fieldnames(templates);
handles.currTemplateName = templateNames{1};
set(handles.popExperiment,'string',templateNames,'value',1);
set(handles.edtFramerate,'string',defaultValues.frameRate);
set(handles.edtIterations,'string',defaultValues.iterations);

set(handles.tabTrialPreview,'data',{})
set(handles.tabTrialList,'data',{})

% Choose default command line output for experimentEditor_2p
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = experimentEditor_2p_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% TOP PART OF THE GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in popExperiment.
function popExperiment_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
templates = get(hObject,'string');
handles.currTemplateName = templates{get(hObject,'value')};

set(handles.tabTrialList,'data',{},'ColumnName',{})
set(handles.tabTrialPreview,'data',{},'ColumnName',{})
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popExperiment_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edtFramerate_Callback(hObject, eventdata, handles)
handles = guidata(hOject);
if get(handles.radioRemember,'value') == true
    qstring = 'Do you want to save this framerate as the default?';
    button = questdlg(qstring,'Save as default','No');
    if strcmpi(button,'Yes')
        defVal = handles.preferences.defaultValues;
        defVal.frameRate = str2double(get(handles.edtFramerate,'string'));
        handles.preferences.defaultValues = defVal;
    end
end
    
% --- Executes during object creation, after setting all properties.
function edtFramerate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in btnNewTrial.
function btnNewTrial_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
templates = handles.preferences.experimentTemplates;
names = fieldnames(templates.(handles.currTemplateName));
defAns = cell(numel(names),1);
for i=1:size(defAns,1)
    defAns{i,1} = num2str(templates.(handles.currTemplateName).(names{i}));
end
answer = inputdlg(names,'New trial',[1 40],defAns,'off');
if ~isempty(answer)
    for i=1:size(answer,1)
        answer{i} = str2num(answer{i});
    end
    set(handles.tabTrialPreview,'data',answer','ColumnName',names,...
        'ColumnEditable',true)
    if get(handles.radioRemember,'value') == true
        tempNames = get(handles.popExperiment,'string');
        tempName = tempNames{get(handles.popExperiment,'value')};
        expTemp = handles.preferences.experimentTemplates;
        for i=1:length(names)
            newdefault.(names{i}) = answer{i};
        end
        expTemp.(tempName) = newdefault;
        qstring = 'Do you want to save this exmperiment template as the default?';
        button = questdlg(qstring,'Save as default','No');
        if strcmpi(button,'Yes')
            handles.preferences.experimentTemplates = expTemp;
        end
    end
end

% --- Executes on button press in btnRmvTrial.
function btnRmvTrial_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
data = get(handles.tabTrialList,'data');
if size(data,1) < 2
    disp('No trials removed. Please use "Reset"')
    return
else
    data(end,:) = [];
    set(handles.tabTrialList,'data',data);
end

% --- Executes on button press in btnResetList.
function btnResetList_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
templates = handles.preferences.experimentTemplates;
names = fieldnames(templates.(handles.currTemplateName));
set(handles.tabTrialList,'data',{},'ColumnName',{})

% --- Executes on button press in btnLoad.
function btnLoad_Callback(hObject, eventdata, handles)
disp('The "Load" function is still in development.')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% TOOLS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function edtFrames_Callback(hObject, eventdata, handles)
handles = guidata(hObject);

frames = round(str2double(get(hObject,'string')));
if isempty(frames) || isnan(frames)
    set(hObject,'string','frames')
    set(handles.edtMs,'string','ms')
    return
end
framerate = str2double(get(handles.edtFramerate,'string')) / 1000; % conversion in frames/ms
milliseconds = (1/framerate) * frames;
set(hObject,'string',num2str(frames))
set(handles.edtMs,'string',num2str(milliseconds))

% --- Executes during object creation, after setting all properties.
function edtFrames_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edtMs_Callback(hObject, eventdata, handles)
handles = guidata(hObject);

milliseconds = str2double(get(hObject,'string'));
if isempty(milliseconds) || isnan(milliseconds)
    set(hObject,'string','ms')
    set(handles.edtFrames,'string','frames')
    return
end
framerate = str2double(get(handles.edtFramerate,'string')) / 1000; % conversion in frames/ms
frames = milliseconds/(1/framerate);
set(handles.edtFrames,'string',num2str(frames))

% --- Executes during object creation, after setting all properties.
function edtMs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% BOTTOM PART OF THE GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in btnAdd.
function btnAdd_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if isempty(get(handles.tabTrialPreview,'data'))
    disp('Empty trial. Confirmation ignored')
    return
else
    data = get(handles.tabTrialList,'data');
    if isempty(data)
        set(handles.tabTrialList,'ColumnName',get(handles.tabTrialPreview,'ColumnName'))
    end
    data(end+1,:) = get(handles.tabTrialPreview,'data');
    set(handles.tabTrialList,'data',data)
end
guidata(hObject,handles)

% --- Executes on button press in btnReset.
function btnReset_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
templates = handles.preferences.experimentTemplates;
names = fieldnames(templates.(handles.currTemplateName));
set(handles.tabTrialPreview,'data',{},'ColumnName',{})

function edtIterations_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
iterations = round(str2double(get(hObject,'string')));
if isempty(iterations) || isnan(iterations)
    dV = handles.preferences.defaultValues;
    set(handles.edtIterations,'string',num2str(dV.iterations));
    disp('Invalid number of iterations. Parameter reset to default value.')
    return
end

set(hObject,'string',num2str(iterations));
if get(handles.radioRemember,'value') == true
    qstring = 'Do you want to save this number of iterations as the default?';
    button = questdlg(qstring,'Save as default','No');
    if strcmpi(button,'Yes')
        defVal = handles.preferences.defaultValues;
        defVal.iterations = str2double(get(handles.edtIterations,'string'));
        handles.preferences.defaultValues = defVal;
    end
end

% --- Executes during object creation, after setting all properties.
function edtIterations_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
handles = guidata(hObject);

% prepare the struct to be saved
iterations = str2double(get(handles.edtIterations,'string'));
stim = get(handles.tabTrialList,'data');
names = get(handles.tabTrialList,'ColumnName');
if isempty(stim)
    disp('Empty trial list. Saving aborted.')
    return
end
if isempty(iterations) || isnan(iterations)
    disp('Invalid number of iterations. Saving aborted.')
    return
end
stimulusStruct = cell2struct(stim,names,2);
path = 'C:\Users\2FOTNEW\Desktop\experiments';
defaultName = ['MyExperiment' datestr(now,'yyyymmdd_HHMM') '.mat'];
uisave({'stimulusStruct','iterations'},[path filesep defaultName])
