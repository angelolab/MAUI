function varargout = ez_segment_v4(varargin)
% EZ_SEGMENT_V4 MATLAB code for ez_segment_v4.fig
%      EZ_SEGMENT_V4, by itself, creates a new EZ_SEGMENT_V4 or raises the existing
%      singleton*.
%
%      H = EZ_SEGMENT_V4 returns the handle to a new EZ_SEGMENT_V4 or the handle to
%      the existing singleton*.
%
%      EZ_SEGMENT_V4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EZ_SEGMENT_V4.M with the given input arguments.
%
%      EZ_SEGMENT_V4('Property','Value',...) creates a new EZ_SEGMENT_V4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ez_segment_v4_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ez_segment_v4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ez_segment_v4

% Last Modified by GUIDE v2.5 25-Mar-2019 14:52:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ez_segment_v4_OpeningFcn, ...
                   'gui_OutputFcn',  @ez_segment_v4_OutputFcn, ...
                   'gui_LayoutFcn',  @ez_segment_v4_LayoutFcn, ...
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


% --- Executes just before ez_segment_v4 is made visible.
function ez_segment_v4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ez_segment_v4 (see VARARGIN)
feature('DefaultCharacterSet','UTF-8');
global pipeline_data;
pipeline_data = struct();
pipeline_data.view_channel = '89';
pipeline_data.removingBackground = false;
pipeline_data.points = PointManager();
pipeline_data.view_point = '';
% Choose default command line output for ez_segment_v4
handles.output = hObject;
[path, name, ext] = fileparts(mfilename('fullpath'));
options = json.read([path, filesep, 'src', filesep, 'options.json']);
fontsize = options.fontsize;
warning('off', 'MATLAB:hg:uicontrol:StringMustBeNonEmpty');
warning('off', 'MATLAB:imagesci:tifftagsread:expectedTagDataFormat');
path = strsplit(path, filesep);
path(end) = [];
path = strjoin(path, filesep);
pipeline_data.defaultPath = path;
% Update handles structure
guidata(hObject, handles);
setUIFontSize(handles, fontsize)

% UIWAIT makes ez_segment_v4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ez_segment_v4_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
2

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Creates and returns a handle to the GUI figure. 
function h1 = ez_segment_v4_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end
load ez_segment_v4.mat


appdata = [];
appdata.GUIDEOptions = mat{1};
appdata.lastValidTag = 'figure1';
appdata.GUIDELayoutEditor = [];
appdata.initTags = struct(...
    'handle', [], ...
    'tag', 'figure1');

h1 = figure(...
'PaperUnits',get(0,'defaultfigurePaperUnits'),...
'Units','characters',...
'Position',[181.066666666667 69.9794871794872 66.7142857142857 42.5333333333333],...
'Visible',get(0,'defaultfigureVisible'),...
'Color',get(0,'defaultfigureColor'),...
'CloseRequestFcn',get(0,'defaultfigureCloseRequestFcn'),...
'CurrentAxesMode','manual',...
'CurrentObjectMode','manual',...
'CurrentPointMode','manual',...
'SelectionTypeMode','manual',...
'ResizeFcn',blanks(0),...
'IntegerHandle','off',...
'NextPlot',get(0,'defaultfigureNextPlot'),...
'Alphamap',get(0,'defaultfigureAlphamap'),...
'WindowButtonDownFcn',blanks(0),...
'WindowButtonUpFcn',blanks(0),...
'WindowButtonMotionFcn',blanks(0),...
'WindowScrollWheelFcn',blanks(0),...
'WindowKeyPressFcn',blanks(0),...
'WindowKeyReleaseFcn',blanks(0),...
'MenuBar','none',...
'ToolBar',get(0,'defaultfigureToolBar'),...
'Pointer',get(0,'defaultfigurePointer'),...
'PointerShapeHotSpot',get(0,'defaultfigurePointerShapeHotSpot'),...
'Name','untitled1',...
'NumberTitle','off',...
'ButtonDownFcn',blanks(0),...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag','figure1',...
'UserData',[],...
'WindowStyle',get(0,'defaultfigureWindowStyle'),...
'DockControls',get(0,'defaultfigureDockControls'),...
'Resize','off',...
'PaperPosition',get(0,'defaultfigurePaperPosition'),...
'PaperSize',get(0,'defaultfigurePaperSize'),...
'PaperType',get(0,'defaultfigurePaperType'),...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'PaperOrientation',get(0,'defaultfigurePaperOrientation'),...
'ScreenPixelsPerInchMode','manual',...
'KeyPressFcn',blanks(0),...
'KeyReleaseFcn',blanks(0),...
'HandleVisibility','callback');

appdata = [];
appdata.lastValidTag = 'popupmenu1';

h2 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Pop-up Menu' },...
'Style','popupmenu',...
'Value',1,...
'ValueMode',get(0,'defaultuicontrolValueMode'),...
'Position',[14.1428571428571 37.3333333333333 17.4285714285714 1.8],...
'Callback',@(hObject,eventdata)ez_segment_v4('popupmenu1_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)ez_segment_v4('popupmenu1_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popupmenu1');

appdata = [];
appdata.lastValidTag = 'text2';

h3 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Static Text' },...
'Style','text',...
'Position',[1.42857142857143 37.3333333333333 12.7142857142857 1.73333333333333],...
'Children',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'Tag','text2');

appdata = [];
appdata.lastValidTag = 'text3';

h4 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Static Text' },...
'Style','text',...
'Position',[1.42857142857143 34.7333333333333 12.7142857142857 1.73333333333333],...
'Children',[],...
'ButtonDownFcn',blanks(0),...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag','text3');

appdata = [];
appdata.lastValidTag = 'popupmenu2';

h5 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Pop-up Menu' },...
'Style','popupmenu',...
'Value',1,...
'ValueMode',get(0,'defaultuicontrolValueMode'),...
'Position',[14.1428571428571 32.2 17.4285714285714 1.8],...
'Callback',@(hObject,eventdata)ez_segment_v4('popupmenu2_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)ez_segment_v4('popupmenu2_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popupmenu2');

appdata = [];
appdata.lastValidTag = 'listbox1';

h6 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Listbox' },...
'Style','listbox',...
'Value',1,...
'ValueMode',get(0,'defaultuicontrolValueMode'),...
'Position',[14 25.9333333333333 32.8571428571429 4.93333333333333],...
'Callback',@(hObject,eventdata)ez_segment_v4('listbox1_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)ez_segment_v4('listbox1_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','listbox1');

appdata = [];
appdata.lastValidTag = 'text5';

h7 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Static Text' },...
'Style','text',...
'Position',[1.28571428571429 20.8 12.7142857142857 1.73333333333333],...
'Children',[],...
'ButtonDownFcn',blanks(0),...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag','text5');

appdata = [];
appdata.lastValidTag = 'text6';

h8 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Static Text' },...
'Style','text',...
'Position',[1.28571428571429 17.4666666666667 12.7142857142857 1.73333333333333],...
'Children',[],...
'ButtonDownFcn',blanks(0),...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag','text6');

appdata = [];
appdata.lastValidTag = 'pushbutton1';

h9 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Push Button' },...
'Style',get(0,'defaultuicontrolStyle'),...
'Position',[1.71428571428571 27.5333333333333 12.2857142857143 2.46666666666667],...
'Callback',@(hObject,eventdata)ez_segment_v4('pushbutton1_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tag','pushbutton1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text8';

h10 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Static Text' },...
'Style','text',...
'Position',[1.28571428571429 14.1333333333333 12.7142857142857 1.73333333333333],...
'Children',[],...
'ButtonDownFcn',blanks(0),...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag','text8');

appdata = [];
appdata.lastValidTag = 'slider1';

h11 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Slider' },...
'Style','slider',...
'Position',[14 10.6666666666667 50.1428571428571 1.93333333333333],...
'BackgroundColor',[0.9 0.9 0.9],...
'Callback',@(hObject,eventdata)ez_segment_v4('slider1_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)ez_segment_v4('slider1_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','slider1');

appdata = [];
appdata.lastValidTag = 'slider2';

h12 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Slider' },...
'Style','slider',...
'Position',[13.8571428571429 7.73333333333333 50.1428571428571 1.53333333333333],...
'BackgroundColor',[0.9 0.9 0.9],...
'Callback',@(hObject,eventdata)ez_segment_v4('slider2_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'ButtonDownFcn',blanks(0),...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)ez_segment_v4('slider2_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag','slider2',...
'KeyPressFcn',blanks(0));

appdata = [];
appdata.lastValidTag = 'slider3';

h13 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Slider' },...
'Style','slider',...
'Position',[13.8571428571429 4 50.1428571428571 1.93333333333333],...
'BackgroundColor',[0.9 0.9 0.9],...
'Callback',@(hObject,eventdata)ez_segment_v4('slider3_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'ButtonDownFcn',blanks(0),...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)ez_segment_v4('slider3_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag','slider3',...
'KeyPressFcn',blanks(0));

appdata = [];
appdata.lastValidTag = 'popupmenu3';

h14 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Pop-up Menu' },...
'Style','popupmenu',...
'Value',1,...
'ValueMode',get(0,'defaultuicontrolValueMode'),...
'Position',[14 20.8 17.4285714285714 1.8],...
'Callback',@(hObject,eventdata)ez_segment_v4('popupmenu3_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'ButtonDownFcn',blanks(0),...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)ez_segment_v4('popupmenu3_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag','popupmenu3',...
'KeyPressFcn',blanks(0));

appdata = [];
appdata.lastValidTag = 'popupmenu4';

h15 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Pop-up Menu' },...
'Style','popupmenu',...
'Value',1,...
'ValueMode',get(0,'defaultuicontrolValueMode'),...
'Position',[14 17.4666666666667 17.4285714285714 1.8],...
'Callback',@(hObject,eventdata)ez_segment_v4('popupmenu4_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'ButtonDownFcn',blanks(0),...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)ez_segment_v4('popupmenu4_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag','popupmenu4',...
'KeyPressFcn',blanks(0));

appdata = [];
appdata.lastValidTag = 'text12';

h16 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Static Text' },...
'Style','text',...
'Position',[1.28571428571429 23.4 12.7142857142857 1.73333333333333],...
'Children',[],...
'ButtonDownFcn',blanks(0),...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag','text12');

appdata = [];
appdata.lastValidTag = 'text13';

h17 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Static Text' },...
'Style','text',...
'Position',[1.28571428571429 10.8666666666667 12.7142857142857 1.73333333333333],...
'Children',[],...
'ButtonDownFcn',blanks(0),...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag','text13');

appdata = [];
appdata.lastValidTag = 'text14';

h18 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Static Text' },...
'Style','text',...
'Position',[1.28571428571429 7.53333333333333 12.7142857142857 1.73333333333333],...
'Children',[],...
'ButtonDownFcn',blanks(0),...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag','text14');

appdata = [];
appdata.lastValidTag = 'text15';

h19 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Static Text' },...
'Style','text',...
'Position',[1.28571428571429 4.2 12.7142857142857 1.73333333333333],...
'Children',[],...
'ButtonDownFcn',blanks(0),...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag','text15');

appdata = [];
appdata.lastValidTag = 'text16';

h20 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Static Text' },...
'Style','text',...
'Position',[1.42857142857143 32.2666666666667 12.7142857142857 1.73333333333333],...
'Children',[],...
'ButtonDownFcn',blanks(0),...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag','text16');

appdata = [];
appdata.lastValidTag = 'pushbutton2';

h21 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Push Button' },...
'Style',get(0,'defaultuicontrolStyle'),...
'Position',[3.85714285714286 0.6 24.7142857142857 3.4],...
'Callback',@(hObject,eventdata)ez_segment_v4('pushbutton2_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'Tag','pushbutton2');

appdata = [];
appdata.lastValidTag = 'pushbutton3';

h22 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Push Button' },...
'Style',get(0,'defaultuicontrolStyle'),...
'Position',[30 0.6 24.7142857142857 3.4],...
'Callback',@(hObject,eventdata)ez_segment_v4('pushbutton3_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'ButtonDownFcn',blanks(0),...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag','pushbutton3',...
'KeyPressFcn',blanks(0));

appdata = [];
appdata.lastValidTag = 'text17';

h23 = uicontrol(...
'Parent',h1,...
'FontUnits',get(0,'defaultuicontrolFontUnits'),...
'Units','characters',...
'String',{  'Static Text' },...
'Style','text',...
'Position',[3.85714285714286 40.0666666666667 31.8571428571429 1.66666666666666],...
'Children',[],...
'Tag','text17',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );


hsingleton = h1;


% --- Set application data first then calling the CreateFcn. 
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

if ~isempty(appdata)
   names = fieldnames(appdata);
   for i=1:length(names)
       name = char(names(i));
       setappdata(hObject, name, getfield(appdata,name));
   end
end

if ~isempty(createfcn)
   if isa(createfcn,'function_handle')
       createfcn(hObject, eventdata);
   else
       eval(createfcn);
   end
end


% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)

gui_StateFields =  {'gui_Name'
    'gui_Singleton'
    'gui_OpeningFcn'
    'gui_OutputFcn'
    'gui_LayoutFcn'
    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error(message('MATLAB:guide:StateFieldNotFound', gui_StateFields{ i }, gui_Mfile));
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [gui_State.(gui_StateFields{i}), '.m'];
    end
end

numargin = length(varargin);

if numargin == 0
    % EZ_SEGMENT_V4
    % create the GUI only if we are not in the process of loading it
    % already
    gui_Create = true;
elseif local_isInvokeActiveXCallback(gui_State, varargin{:})
    % EZ_SEGMENT_V4(ACTIVEX,...)
    vin{1} = gui_State.gui_Name;
    vin{2} = [get(varargin{1}.Peer, 'Tag'), '_', varargin{end}];
    vin{3} = varargin{1};
    vin{4} = varargin{end-1};
    vin{5} = guidata(varargin{1}.Peer);
    feval(vin{:});
    return;
elseif local_isInvokeHGCallback(gui_State, varargin{:})
    % EZ_SEGMENT_V4('CALLBACK',hObject,eventData,handles,...)
    gui_Create = false;
else
    % EZ_SEGMENT_V4(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = true;
end

if ~gui_Create
    % In design time, we need to mark all components possibly created in
    % the coming callback evaluation as non-serializable. This way, they
    % will not be brought into GUIDE and not be saved in the figure file
    % when running/saving the GUI from GUIDE.
    designEval = false;
    if (numargin>1 && ishghandle(varargin{2}))
        fig = varargin{2};
        while ~isempty(fig) && ~ishghandle(fig,'figure')
            fig = get(fig,'parent');
        end
        
        designEval = isappdata(0,'CreatingGUIDEFigure') || (isscalar(fig)&&isprop(fig,'GUIDEFigure'));
    end
        
    if designEval
        beforeChildren = findall(fig);
    end
    
    % evaluate the callback now
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else       
        feval(varargin{:});
    end
    
    % Set serializable of objects created in the above callback to off in
    % design time. Need to check whether figure handle is still valid in
    % case the figure is deleted during the callback dispatching.
    if designEval && ishghandle(fig)
        set(setdiff(findall(fig),beforeChildren), 'Serializable','off');
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end

    % Check user passing 'visible' P/V pair first so that its value can be
    % used by oepnfig to prevent flickering
    gui_Visible = 'auto';
    gui_VisibleInput = '';
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        % Recognize 'visible' P/V pair
        len1 = min(length('visible'),length(varargin{index}));
        len2 = min(length('off'),length(varargin{index+1}));
        if ischar(varargin{index+1}) && strncmpi(varargin{index},'visible',len1) && len2 > 1
            if strncmpi(varargin{index+1},'off',len2)
                gui_Visible = 'invisible';
                gui_VisibleInput = 'off';
            elseif strncmpi(varargin{index+1},'on',len2)
                gui_Visible = 'visible';
                gui_VisibleInput = 'on';
            end
        end
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.

    
    % Do feval on layout code in m-file if it exists
    gui_Exported = ~isempty(gui_State.gui_LayoutFcn);
    % this application data is used to indicate the running mode of a GUIDE
    % GUI to distinguish it from the design mode of the GUI in GUIDE. it is
    % only used by actxproxy at this time.   
    setappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]),1);
    if gui_Exported
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);

        % make figure invisible here so that the visibility of figure is
        % consistent in OpeningFcn in the exported GUI case
        if isempty(gui_VisibleInput)
            gui_VisibleInput = get(gui_hFigure,'Visible');
        end
        set(gui_hFigure,'Visible','off')

        % openfig (called by local_openfig below) does this for guis without
        % the LayoutFcn. Be sure to do it here so guis show up on screen.
        movegui(gui_hFigure,'onscreen');
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        end
    end
    if isappdata(0, genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]))
        rmappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]));
    end

    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);

    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    % Singleton setting in the GUI MATLAB code file takes priority if different
    gui_Options.singleton = gui_State.gui_Singleton;

    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig
            set(gui_hFigure,'Color', get(0,'DefaultUicontrolBackgroundColor'));
        end

        % Generate HANDLES structure and store with GUIDATA. If there is
        % user set GUI data already, keep that also.
        data = guidata(gui_hFigure);
        handles = guihandles(gui_hFigure);
        if ~isempty(handles)
            if isempty(data)
                data = handles;
            else
                names = fieldnames(handles);
                for k=1:length(names)
                    data.(char(names(k)))=handles.(char(names(k)));
                end
            end
        end
        guidata(gui_hFigure, data);
    end

    % Apply input P/V pairs other than 'visible'
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        len1 = min(length('visible'),length(varargin{index}));
        if ~strncmpi(varargin{index},'visible',len1)
            try set(gui_hFigure, varargin{index}, varargin{index+1}), catch break, end
        end
    end

    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end

    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});

    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        % Handle the default callbacks of predefined toolbar tools in this
        % GUI, if any
        guidemfile('restoreToolbarToolPredefinedCallback',gui_hFigure); 
        
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);

        % Call openfig again to pick up the saved visibility or apply the
        % one passed in from the P/V pairs
        if ~gui_Exported
            gui_hFigure = local_openfig(gui_State.gui_Name, 'reuse',gui_Visible);
        elseif ~isempty(gui_VisibleInput)
            set(gui_hFigure,'Visible',gui_VisibleInput);
        end
        if strcmpi(get(gui_hFigure, 'Visible'), 'on')
            figure(gui_hFigure);
            
            if gui_Options.singleton
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end

        % Done with GUI initialization
        if isappdata(gui_hFigure,'InGUIInitialization')
            rmappdata(gui_hFigure,'InGUIInitialization');
        end

        % If handle visibility is set to 'callback', turn it on until
        % finished with OutputFcn
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end

    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end

    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end

function gui_hFigure = local_openfig(name, singleton, visible)

% openfig with three arguments was new from R13. Try to call that first, if
% failed, try the old openfig.
if nargin('openfig') == 2
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = matlab.hg.internal.openfigLegacy(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
else
    % Call version of openfig that accepts 'auto' option"
    gui_hFigure = matlab.hg.internal.openfigLegacy(name, singleton, visible);  
%     %workaround for CreateFcn not called to create ActiveX
%         peers=findobj(findall(allchild(gui_hFigure)),'type','uicontrol','style','text');    
%         for i=1:length(peers)
%             if isappdata(peers(i),'Control')
%                 actxproxy(peers(i));
%             end            
%         end
end

function result = local_isInvokeActiveXCallback(gui_State, varargin)

try
    result = ispc && iscom(varargin{1}) ...
             && isequal(varargin{1},gcbo);
catch
    result = false;
end

function result = local_isInvokeHGCallback(gui_State, varargin)

try
    fhandle = functions(gui_State.gui_Callback);
    result = ~isempty(findstr(gui_State.gui_Name,fhandle.file)) || ...
             (ischar(varargin{1}) ...
             && isequal(ishghandle(varargin{2}), 1) ...
             && (~isempty(strfind(varargin{1},[get(varargin{2}, 'Tag'), '_'])) || ...
                ~isempty(strfind(varargin{1}, '_CreateFcn'))) );
catch
    result = false;
end

function setUIFontSize(handles, fontSize)
    fields = fieldnames(handles);
    for i=1:numel(fields)
        ui_element_name = fields{i};
        ui_element = getfield(handles, ui_element_name);
        try
            ui_element.FontSize = fontSize;
        catch
            % probably no FontSize field to modify
        end
    end
