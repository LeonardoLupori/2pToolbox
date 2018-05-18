function varargout = physiology_2P(varargin)
% PHYSIOLOGY_2P MATLAB code for physiology_2P.fig
%      PHYSIOLOGY_2P, by itself, creates a new PHYSIOLOGY_2P or raises the existing
%      singleton*.
%
%      H = PHYSIOLOGY_2P returns the handle to a new PHYSIOLOGY_2P or the handle to
%      the existing singleton*.
%
%      PHYSIOLOGY_2P('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHYSIOLOGY_2P.M with the given input arguments.
%
%      PHYSIOLOGY_2P('Property','Value',...) creates a new PHYSIOLOGY_2P or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before physiology_2P_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to physiology_2P_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help physiology_2P

% Last Modified by GUIDE v2.5 17-May-2018 19:10:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @physiology_2P_OpeningFcn, ...
                   'gui_OutputFcn',  @physiology_2P_OutputFcn, ...
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

% --- Executes just before physiology_2P is made visible.
function physiology_2P_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to physiology_2P (see VARARGIN)
statusUpdate(hObject);
% Choose default command line output for physiology_2P
handles.output = hObject;
% Recreate the preferences file if it has been deleted by error
if ~exist('physiology_2p_preferences.mat','file')
    createPreferences()
end
% Set some button properties as default
set(handles.btnStart,'Enable','off')
% Load default values from the preferences file
[folderPath,~,~] = fileparts(mfilename('fullpath'));
mPreferences = matfile([folderPath filesep 'physiology_2p_preferences.mat'],'Writable',true);
handles.defValues = mPreferences.defaultValues;
% Initialize some useful variables
handles.currentExperiment = [];
% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = physiology_2P_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% MAIN BODY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in tglTcpConnect.
function tglTcpConnect_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
pressed = get(hObject,'value'); % check if pressed or not
if pressed
    statusUpdate(hObject,'Waiting for the client...',[1 1 .7])
    drawnow % necessary to flush the queue to update statusBar
    defaults = handles.defValues;
    clientIP = defaults.tcp_stimulationPcIP;
    port = defaults.tcp_port;
    buffersize = defaults.tcp_bufferSize;
    handles.tcpConnObject = tcpip(clientIP,port,...
        'NetworkRole','server',...
        'InputBufferSize',buffersize,...
        'OutputBufferSize',buffersize);
    fprintf(['Connecting to ' clientIP '    port: ' num2str(port) '.\nWaiting for client...'])
    try
        fopen(handles.tcpConnObject); % This will not return unless a connection is recieved
        fprintf(' connected!\n')
        statusUpdate(hObject)
        set(hObject,'backgroundColor',[.8 1 .8]);
    catch ME
        set(hObject,'value',0,'backgroundColor',[.94 .94 .94]);
        fprintf(' NOT CONNECTED. The following ERROR occurred:\n')
        fprintf(ME.message)
        statusUpdate(hObject)
    end

elseif ~pressed
    try
        fclose(handles.tcpConnObject);
        set(hObject,'value',0,'backgroundColor',[.94 .94 .94]);
        fprintf('TCP/IP connection closed.\n')
    catch
        fprintf('There was an error during connection closure. The GUI may be an inconsistent state.\n')
        toggleProperyEditor(hObject,handles.tglTcpConnect,'default')
    end
end
guidata(hObject,handles);

% --- Executes on button press in tglPrairieConnect.
function tglPrairieConnect_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
pressed = get(hObject,'value'); % check if pressed or not
if pressed
    try
        pl = actxserver('PrairieLink.Application');
        pl.Connect();
        fprintf('Connected to Prairie View through Prairie Link.\n')
        set(hObject,'backgroundColor',[.8 1 .8]);
        handles.prairieLink = pl;
        guidata(hObject,handles)
    catch ME
        fprintf('The following ERROR occurred during the connection:\n')
        fprintf([ME.message '\n'])
        set(hObject,'value',0)
    end
else
    try
        pl = handles.prairieLink;
        pl.Disconnect()
        fprintf('Disconnected from Prairie View.\n')
        set(hObject,'value',0,'backgroundColor',[.94 .94 .94]);
    catch ME
        fprintf('The following ERROR occurred during the disonnection:\n')
        fprintf([ME.message '\n'])
        set(hObject,'value',1)
    end
end

% --- Executes on button press in btnStart.
function btnStart_Callback(hObject, eventdata, handles)
statusUpdate(hObject,'uno',[1 0 0])

% --- Executes on button press in btnBrowseExperiment.
function btnBrowseExperiment_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
% Get default path
if isfield(handles.defValues,'experimentFolder')
    startingFolder = handles.defValues.experimentFolder;
else
    startingFolder = '';
end
% Fetch the file
FilterSpec = [startingFolder '*.mat'];
DialogTitle = 'Select an experiment file';
[FileName,PathName,FilterIndex] = uigetfile(FilterSpec,DialogTitle);
if FilterIndex==0
    return
end
% Load the file and verify that it's a stimulus file
m = matfile([PathName FileName]);
if ~misField(m,'stimulusStruct')
    fprintf('The provided file is not a valid Experiment file.\n')
    return
end
% Update the default path for experiment files for the session
handles.defValues.experimentFolder = PathName;
% Load the experiment file
handles.currentExperiment = m.stimulusStruct;
handles.currentExperimentIterations = m.iterations;
% Make sure the stimulus is smaller that the TCP/IP buffer size 
encodedStimulus = jsonencode(m.stimulusStruct);
fileDetails = whos('encodedStimulus');
if fileDetails.bytes > handles.defValues.tcp_bufferSize
    warning('Size(Bytes) of the stimulus exceeds TCP/IP buffersize. Increse buffer size in the preferences matfile.')
end
% Display that the stimulus is successfully loaded
set(handles.btnStart,'Enable','on')
set(handles.txtCurrentExp,'string',FileName)
fprintf(['Experiment file: ' FileName ' successfully loaded.\n'])
guidata(hObject,handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% SUBFUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function statusUpdate(hObject,string,color)
handles = guidata(hObject);
if nargin < 2
    string = 'Ready! :)';
    color = [.8 1 .8];
elseif nargin < 3
    color = [.8 1 .8];
end
set(handles.txtStatus,'string',string,'backgroundColor',color)
guidata(hObject,handles)

function toggleProperyEditor(hObject,buttonHandle,state)
handles = guidata(hObject);
switch state
    case 'default'
        set(buttonHandle,'value',0,...
            'backgroundColor',[.94 .94 .94])
    case 'ready'
        set(buttonHandle,'backgroundColor',[.8 .1 .8])
    case 'waiting'
        set(buttonHandle,'backgroundColor',[1 1 .7])
end

function createPreferences()
% Define the numerical values to set as a default
defaultValues.experimentFolder = 'E:\';
defaultValues.tcp_stimulationPcIP = '192.168.0.3';
defaultValues.tcp_port = 45000;
defaultValues.tcp_bufferSize = 2^14;

% Create a new matfile containing the values
[folderPath,~,~] = fileparts(mfilename('fullpath'));
m = matfile([folderPath filesep 'physiology_2p_preferences.mat'], 'writable', true);
m.defaultValues = defaultValues;




















