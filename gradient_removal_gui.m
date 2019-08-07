function varargout = gradient_removal_gui(varargin)
% GRADIENT_REMOVAL_GUI MATLAB code for gradient_removal_gui.fig
%      GRADIENT_REMOVAL_GUI, by itself, creates a new GRADIENT_REMOVAL_GUI or raises the existing
%      singleton*.
%
%      H = GRADIENT_REMOVAL_GUI returns the handle to a new GRADIENT_REMOVAL_GUI or the handle to
%      the existing singleton*.
%
%      GRADIENT_REMOVAL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRADIENT_REMOVAL_GUI.M with the given input arguments.
%
%      GRADIENT_REMOVAL_GUI('Property','Value',...) creates a new GRADIENT_REMOVAL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gradient_removal_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gradient_removal_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gradient_removal_gui

% Last Modified by GUIDE v2.5 10-Jul-2019 10:44:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gradient_removal_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gradient_removal_gui_OutputFcn, ...
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


% --- Executes just before gradient_removal_gui is made visible.
function gradient_removal_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gradient_removal_gui (see VARARGIN)

% Choose default command line output for gradient_removal_gui
handles.output = hObject;
global grad_data;
grad_data = struct();
grad_data.points = {};
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gradient_removal_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gradient_removal_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in add_point_button.
function add_point_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_point_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global grad_data;
    files = uigetdiles('/');
    if numel(files)~=0
        for i=1:numel(files)
            point = struct();
            point.path = files{i};
            disp(['Loading ', point.path]);
            [point.counts, point.labels, point.tags] = loadTIFF_folder([point.path, filesep, 'TIFs']);
            grad_data.points{end+1} = point;
        end
    end
    
    for i=1:numel(grad_data.points)
        name = strsplit(grad_data.points{i}.path, filesep);
        name = name{end};
        grad_data.points{i}.name = name;
        grad_data.points{i}.status = 'true';
    end
    
    names = {};
    for i=1:numel(grad_data.points)
        names{end+1} = tabJoin({grad_data.points{i}.name, grad_data.points{i}.status}, 20);
    end
    
    set(handles.point_listbox, 'string', names);
    

% --- Executes on button press in remove_point_button.
function remove_point_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_point_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in point_listbox.
function point_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to point_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns point_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from point_listbox
    

% --- Executes during object creation, after setting all properties.
function point_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to point_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function disp_cap_edit_Callback(hObject, eventdata, handles)
% hObject    handle to disp_cap_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of disp_cap_edit as text
%        str2double(get(hObject,'String')) returns contents of disp_cap_edit as a double


% --- Executes during object creation, after setting all properties.
function disp_cap_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to disp_cap_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
