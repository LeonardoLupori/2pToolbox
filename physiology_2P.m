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

% Last Modified by GUIDE v2.5 22-May-2018 18:05:40

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
set(handles.tglStart,'Enable','off')
% Load default values from the preferences file
[folderPath,~,~] = fileparts(mfilename('fullpath'));
mPreferences = matfile([folderPath filesep 'physiology_2p_preferences.mat'],'Writable',true);
handles.defValues = mPreferences.defaultValues;
% Initialize some useful variables
handles.currentExperiment = [];
handles.currentEnvironment = [];
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
%%%% MAIN BODY AND BUTTON CALLBACKS
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
        guidata(hObject,handles)
        % Decide whether to enable the start button
        updateStartButton(hObject)
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
        fclose(handles.tcpConnObject); guidata(hObject,handles)
        updateStartButton(hObject)
        set(hObject,'value',0,'backgroundColor',[.94 .94 .94]);
        fprintf('TCP/IP connection closed.\n')
    catch
        warning('There was an error during connection closure. The GUI may be an inconsistent state.\n')
        set(hObject,'value',1);
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
        % Decide whether to enable the start button
        updateStartButton(hObject)
        set(handles.tglLive,'Enable','on');
        set(handles.btnLoadEnv,'Enable','on');
        set(handles.btnLoadVolt,'Enable','on');
        set(handles.btnBrowseFolder,'Enable','on');
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
        updateStartButton(hObject)
        fprintf('Disconnected from Prairie View.\n')
        set(hObject,'value',0,'backgroundColor',[.94 .94 .94]);
        set(handles.tglLive,'Enable','off');
        set(handles.btnLoadEnv,'Enable','off');
        set(handles.btnLoadVolt,'Enable','off');
        set(handles.btnBrowseFolder,'Enable','off');
    catch ME
        fprintf('The following ERROR occurred during the disonnection:\n')
        fprintf([ME.message '\n'])
        set(hObject,'value',1)
    end
end

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
updateStartButton(hObject)
% Display that the stimulus is successfully loaded
set(handles.txtCurrentExp,'string',FileName)
fprintf(['Experiment file: ' FileName ' successfully loaded.\n'])
guidata(hObject,handles)

% --- Executes on button press in btnLoadEnv.
function btnLoadEnv_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
% Get default path
if isfield(handles.defValues,'environmentFolder')
    startingFolder = handles.defValues.environmentFolder;
else
    startingFolder = '';
end
% Fetch the file
FilterSpec = [startingFolder '*.env'];
DialogTitle = 'Select an environment file';
[FileName,PathName,FilterIndex] = uigetfile(FilterSpec,DialogTitle);
if FilterIndex==0
    return
end
try
    % Load the new environment on Prairie view
    handles.prairieLink.SendScriptCommands(['-LoadEnvironment ' PathName FileName])
    % Update the default path for experiment files for the session
    handles.defValues.environmentFolder = PathName;
    handles.currentEnvironment = FileName;
    updateStartButton(hObject)
    % Display that the stimulus is successfully loaded
    set(handles.txtCurrentEnv,'string',FileName)
    fprintf(['Environment file: ' FileName ' successfully loaded.\n'])
    guidata(hObject,handles)
catch ME
    fprintf('ENVIRONMENT NOT LOADED. The following ERROR occurred:\n')
    fprintf(ME.message)
end

% --- Executes on button press in tglLive.
function tglLive_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
pressed = get(hObject,'Value');
if pressed
    try
        handles.prairieLink.SendScriptCommands('-livescan on');
        set(hObject,'backgroundColor',[1 1 .7]);
    catch ME
        handles.prairieLink.SendScriptCommands('-livescan off');
        rethrow(ME)
    end
elseif ~pressed
    handles.prairieLink.SendScriptCommands('-livescan off');
    set(hObject,'backgroundColor',[.94 .94 .94]);
end

% --- Executes on button press in tglStart.
function tglStart_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
pressed = get(hObject,'Value');

if pressed
    
    % safety check of iterations and image length
    
    trialSequence = generateTrialsSequence(handles.currentExperiment,...
        handles.currentExperimentIterations,'pseudoradom');
    stimulationProtocol(hObject,trialSequence);
    
    
    timestamp = datestr(now,'yyyymmdd_HHMMSS');
    foldername = ['physiology-TSeries_' timestamp];
    
    
    
    
elseif ~pressed
%     handles.prairieLink.SendScriptCommands('-Abort')
    fprintf('Stimulattion stopped by the user.')
end

% --- Executes on button press in btnBrowseFolder.
function btnBrowseFolder_Callback(hObject, eventdata, handles)
% hObject    handle to btnBrowseFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in btnLoadVolt.
function btnLoadVolt_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoadVolt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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

function createPreferences()
% Define the numerical values to set as a default
defaultValues.experimentFolder = 'E:\';
defaultValues.environmentFolder = 'E:\';
defaultValues.tcp_stimulationPcIP = '192.168.0.3';
defaultValues.tcp_port = 45000;
defaultValues.tcp_bufferSize = 2^14;
defaultValues.savePath = 'E:\';

% Create a new matfile containing the values
[folderPath,~,~] = fileparts(mfilename('fullpath'));
m = matfile([folderPath filesep 'physiology_2p_preferences.mat'], 'writable', true);
m.defaultValues = defaultValues;

function bool = isReady(hObject,itemsToCheck)
handles = guidata(hObject);

if nargin<2
    itemsToCheck = {'tcp','prairieLink','environment','experiment'};
end

if ~iscell(itemsToCheck) % if the  input is a single string
    conditions = false; % initialize a logical vector
    switch itemsToCheck
        case 'tcp'
            conditions = isfield(handles,'tcpConnObject') && strcmpi(handles.tcpConnObject.Status,'Open');
        case 'prairieLink'
            conditions = isfield(handles,'prairieLink') && handles.prairieLink.Connected;
        case 'environment'
            conditions = isfield(handles,'currentEnvironment') && ~isempty(handles.currentEnvironment);
        case 'experiment'
            conditions = isfield(handles,'currentExperiment') && ~isempty(handles.currentExperiment);
    end
else % if the  input is a cell of strings
    conditions = false(length(itemsToCheck),1); % initialize a logical vector
    for i=1:length(itemsToCheck)
        switch itemsToCheck{i}
            case 'tcp'
                conditions(i) = isfield(handles,'tcpConnObject') && strcmpi(handles.tcpConnObject.Status,'Open');
            case 'prairieLink'
                conditions(i) = isfield(handles,'prairieLink') && handles.prairieLink.Connected;
            case 'environment'
                conditions(i) = isfield(handles,'currentEnvironment') && ~isempty(handles.currentEnvironment);
            case 'experiment'
                conditions(i) = isfield(handles,'currentExperiment') && ~isempty(handles.currentExperiment);
        end
    end
end
if all(conditions)
    bool = true;
else
    bool = false;
end

function updateStartButton(hObject)
handles = guidata(hObject);
if isReady(hObject)
    set(handles.tglStart,'Enable','on');
else
    set(handles.tglStart,'Enable','off');
end

function trialSequence = generateTrialsSequence(experiment,iterations,method)
%  trialSequence = generateTrialsSequence(experiment, iterations,method)
% 
% method can be 'sequential', 'pseudoradom' (default), 'fullrandom'
if nargin<3
    method = 'pseudoradom';
end
switch method
    case 'sequential'
        trialSequence = repmat(experiment,iterations,1);
    case 'pseudoradom'
        numOfConditions = size(experiment,1);
        order = [];
        for i=1:iterations
            order = [order randperm(numOfConditions)];
        end
        trialSequence = experiment(order,1);
    case 'fullrandom'
        rawSequence = repmat(experiment,iterations,1);
        totalConditions = size(rawSequence,1);
        order = randperm(totalConditions);
        trialSequence = rawSequence(order,1);
end

function bool = readyToSendStimulus(tcpObject)
% bool = readyToSendStimulus(tcpObject)

while tcpObject.BytesAvailable == 0
    continue
end
msg = fscanf(tcpObject,'%c',tcpObject.BytesAvailable);
if strcmp(msg,'ready')
    bool = true;
else
    bool = false;
end
flushinput(tcpObject)

function stimulationProtocol(hObject,trialSequence)
%  Loop through every stimulation
for i=1:size(trialSequence,1)
    handles = guidata(hObject);
    
    if get(handles.tglStart,'value') == 0
        handles.prairieLink.SendScriptCommands('-Abort')
        fprintf('Stimulation stopped by the user.')
    end
    while ~readyToSendStimulus(handles.tcpConnObject)
        continue
    end
    if i==1 % Start the TimeSeries on the first iteration
        handles.prairieLink.SendScriptCommands('-TSeries')
    end
    % Send the info for the current stimulus
    stimulus = trialSequence(i,1);
    encodedStimulus = jsonencode(stimulus);
    fprintf(handles.tcpConnObject,encodedStimulus);
    fprintf(['Stimulation: ' num2str(i) '/' num2str(size(trialSequence,1)) ' sent.\n'])
end
