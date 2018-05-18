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

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes physiology_2P wait for user response (see UIRESUME)
% uiwait(handles.figure1);


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
    clientIP = '192.168.0.3';
    port = 45000;
    buffersize = 2^14;
    handles.tcpConnObject = tcpip(clientIP,port,...
        'NetworkRole','server',...
        'InputBufferSize',buffersize,...
        'OutputBufferSize',buffersize);
    fprintf(['Connecting to ' clientIP '    port: ' num2str(port) '.\nWaiting for client...'])
    try
        fopen(handles.tcpConnObject); % This will not return unless a connection is recieved
        fprintf(' connected!\n')
        set(hObject,'backgroundColor',[.8 1 .8]);
    catch ME
        set(hObject,'value',0,'backgroundColor',[.94 .94 .94]);
        fprintf(' NOT CONNECTED. The following ERROR occurred:\n')
        fprintf(ME.message)
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
        pl = actxserver();
        pl.connect();
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
        pl.disconnect()
        set(hObject,'value',0,'backgroundColor',[.94 .94 .94]);
    catch ME
        fprintf('The following ERROR occurred during the connection:\n')
        fprintf([ME.message '\n'])
        set(hObject,'value',1)
    end
end

% --- Executes on button press in btnStart.
function btnStart_Callback(hObject, eventdata, handles)
statusUpdate(hObject,'uno',[1 0 0])

% --- Executes on button press in btnBrowseExperiment.
function btnBrowseExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to btnBrowseExperiment (see GCBO)
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
