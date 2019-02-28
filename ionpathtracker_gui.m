function varargout = ionpathtracker_gui(varargin)
% IONPATHTRACKER_GUI MATLAB code for ionpathtracker_gui.fig
%      IONPATHTRACKER_GUI, by itself, creates a new IONPATHTRACKER_GUI or raises the existing
%      singleton*.
%
%      H = IONPATHTRACKER_GUI returns the handle to a new IONPATHTRACKER_GUI or the handle to
%      the existing singleton*.
%
%      IONPATHTRACKER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IONPATHTRACKER_GUI.M with the given input arguments.
%
%      IONPATHTRACKER_GUI('Property','Value',...) creates a new IONPATHTRACKER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ionpathtracker_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ionpathtracker_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ionpathtracker_gui

% Last Modified by GUIDE v2.5 27-Feb-2019 14:43:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ionpathtracker_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @ionpathtracker_gui_OutputFcn, ...
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


% --- Executes just before ionpathtracker_gui is made visible.
function ionpathtracker_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ionpathtracker_gui (see VARARGIN)

% Choose default command line output for ionpathtracker_gui
handles.output = hObject;

setenv('PATH', '/anaconda3/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin');

global usrinfo;
usrinfo.url = 'https://backend-dot-mibitracker-angelolab.appspot.com';
usrinfo.points = PointManager();
[rootpath, name, ext] = fileparts(mfilename('fullpath'));
usrinfo.defaultPath = rootpath;
guidata(hObject, handles);

% UIWAIT makes ionpathtracker_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ionpathtracker_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in runs_listbox.
function runs_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to runs_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns runs_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from runs_listbox


% --- Executes during object creation, after setting all properties.
function runs_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to runs_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in points_listbox.
function points_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to points_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns points_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from points_listbox


% --- Executes during object creation, after setting all properties.
function points_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to points_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function auth_token = getToken(url, usr, varargin)
    email = usr{1}; password = usr{2};
    if numel(varargin)==1 % a token was provided, check the token
        auth_token = varargin{1};
        [status, cmdout] = system(['python3 ', script(), ' -auth ', url, ' ', auth_token]);
        if ~isempty(cmdout)
            auth_token = getAuthToken(url, email, password);
        end
    else
        auth_token = getAuthToken(url, email, password);
    end


function [status, cmdout] = GET(url, token, route)
    disp(url);
    disp(token);
    disp(route);
    [status, cmdout] = system(['python3 ', script(), ' -auth ', url, ' ', token, ' -get ', route]);

function [status, cmdout] = UPLOAD(url, token, tiffpath)
    [status, cmdout] = system(['python3 ', script(), ' -auth ', url, ' ', token, ' -upload ', '"', tiffpath, '"']);

function val = script()
    val = '/Users/raymondbaranski/GitHub/MIBI_GUI/src/gui_lib/ionpath/mibitracker-client-master/mibitracker/ionpath_test.py';


% --- Executes on button press in login_button.
function login_button_Callback(hObject, eventdata, handles)
% hObject    handle to login_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global usrinfo;
    usr = {'', ''};
    try
        [rootpath, ~, ~] = fileparts(mfilename('fullpath'));
        load([rootpath, filesep, 'usr.mat']);
    end
    barln = '---------------------------';
    usr = inputdlg({'Email:', 'Password:'}, 'Login', 1, usr);
    if ~isempty(usr)
        usrinfo.usr = usr;
        waiting = gui_msgbox([barln, newline, 'logging in...', newline, barln]);
        usrinfo.auth_token = getToken(usrinfo.url, usrinfo.usr);
        close(waiting);
        
%         waiting = gui_msgbox([barln, newline, 'fetching runs...', newline, barln]);
%         [status, cmdout] = GET(usrinfo.url, usrinfo.auth_token, '/runs/');
%         usrinfo.runs_data = json.load(cmdout);
%         close(waiting);
%         
%         set(handles.runs_listbox, 'string', {usrinfo.runs_data.name}');
        

% % Update handles structure
    end


% --- Executes on button press in remember_me_button.
function remember_me_button_Callback(hObject, eventdata, handles)
% hObject    handle to remember_me_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global usrinfo;
    usr = usrinfo.usr;
    [rootpath, name, ext] = fileparts(mfilename('fullpath'));
    save([rootpath, filesep, 'usr.mat'], 'usr');

% --- Executes on button press in use_run_button.
function use_run_button_Callback(hObject, eventdata, handles)
% hObject    handle to use_run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        global usrinfo;
        run_index = get(handles.runs_listbox, 'value');
        usrinfo.pointdata = usrinfo.runs_data(run_index).imageset.images;
        pointIDs = cell2mat({usrinfo.pointdata.id}');
        % disp(pointIDs)
        usrinfo.pointinfo = {};
        waitfig = waitbar(0);
        for i=1:numel(pointIDs)
            [status, cmdout] = GET(usrinfo.url, usrinfo.auth_token, ['/images/', num2str(pointIDs(i)), '/conjugates/']);
            disp(cmdout)
            disp(status)
            waitfig = waitbar(i/numel(pointIDs));
            usrinfo.pointinfo{i} = json.load(cmdout);
        end
        close(waitfig);
    catch
        % do nothing
    end
    

% --- Executes on button press in upload_button.
function upload_button_Callback(hObject, eventdata, handles)
% hObject    handle to upload_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global usrinfo;
    pointPaths = usrinfo.points.pathsToPoints.keys();
    for i=1:numel(pointPaths)
        [status, cmdout] = UPLOAD(usrinfo.url, usrinfo.auth_token, pointPaths{i});
        disp('<=========v');
        disp(status)
        disp(cmdout)
    end
    
% --- Executes on button press in add_point_button.
function add_point_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_point_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global usrinfo;
    pointdiles = uigetdiles(usrinfo.defaultPath);
    if ~isempty(pointdiles)
        [usrinfo.defaultPath, ~, ~] = fileparts(pointdiles{1});
        usrinfo.points.add(pointdiles);
        point_names = usrinfo.points.getNames();
        set(handles.points_listbox, 'string', usrinfo.points.getPointText(0))
        set(handles.points_listbox, 'max', numel(point_names));
    end
    

% --- Executes on button press in remove_point_button.
function remove_point_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_point_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global usrinfo;
    pointIndex = get(handles.points_listbox, 'value');
    disp('>')
    disp(usrinfo)
    disp('<')
    pointList = usrinfo.points.getNames();
    % pointList = get(handles.points_listbox, 'string');
    try
        for index = pointIndex
            removedPoint = pointList{index};
            if ~isempty(removedPoint)
                usrinfo.points.remove('name', removedPoint);
                set(handles.points_listbox, 'string', usrinfo.points.getNames());
            end
        end
    catch err
        % disp(err)
    end
    val = get(handles.points_listbox, 'value');
    val = min(val)-1;
    if val==0
        val = 1;
    end
    set(handles.points_listbox, 'value', val)

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in change_save_path_button.
function change_save_path_button_Callback(hObject, eventdata, handles)
% hObject    handle to change_save_path_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    


% --- Executes on button press in save_multitiffs_button.
function save_multitiffs_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_multitiffs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global usrinfo;
    suggested_run = usrinfo.points.check_run_names();
    disp(suggested_run)
    % waiting = gui_msgbox([barln, newline, 'fetching run...', newline, barln]);
    
    usrinfo.points.save_ionpath_multitiff();
%     loaded_runs = get(handles.runs_listbox, 'string');
%     run_index = find(strcmp(loaded_runs, suggested_run));
%     usrinfo.runobject = usrinfo.runs_data(run_index);
%     if ~isempty(run_index)
%         set(handles.runs_listbox, 'value', run_index);
%         usrinfo.points.save_ionpath_multitiff();
%     else
%         disp('failed to save')
%         usrinfo.points.save_ionpath_multitiff();
%     end
    % 


function savepath_edit_Callback(hObject, eventdata, handles)
% hObject    handle to savepath_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of savepath_edit as text
%        str2double(get(hObject,'String')) returns contents of savepath_edit as a double


% --- Executes during object creation, after setting all properties.
function savepath_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savepath_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in copy_run_button.
function copy_run_button_Callback(hObject, eventdata, handles)
% hObject    handle to copy_run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global usrinfo;
    % when this button is pushed, we look for a selected run
    selected_run_index = get(handles.runs_listbox, 'value');
    selected_run = usrinfo.runs_data{selected_run_index};
    original_run_label = selected_run.label;
    new_run_label = inputdlg({'New Label:'}, 'Copy run', 1, {original_run_label});
    if strcmp(original_run_label, new_run_label)
        gui_warning('You need to pick a different label');
    else
        
    end
    % run_index = get(handles.runs_listbox, 'value');
    % usrinfo.runs_data(run_index);
    % if we find one, we present its label as a starting for a new label
    % if the user doesn't change the name, we say that we can't copy
    % once we've made the actual copy, fetch it from ionpath
    % then present it as a new option


% --- Executes on button press in find_run_button.
function find_run_button_Callback(hObject, eventdata, handles)
% hObject    handle to find_run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global usrinfo;
    try
        suggested_run = usrinfo.points.check_run_names();
        default = {suggested_run};
    catch
        default = {''};
    end
    run_name = inputdlg({'Run Name:'}, 'Find run', 1, default);
    [status, cmdout] = GET(usrinfo.url, usrinfo.auth_token, ['/runs/?label=',run_name{1}]);
    disp(cmdout)
    usrinfo.runs_data = json.load(cmdout);
    % set(handles.runs_listbox, 'string')
    if numel(usrinfo.runs_data)==1
        % we've found THE run, unless we want to make a copy
        usrinfo.points.run_object = usrinfo.runs_data{1};
        
    elseif isempty(usrinfo.runs_data)
        % we've found no runs
        
    else
        % there are multiple runs
        
    end
    run_name_list = {};
    for i=1:numel(usrinfo.runs_data)
        run_name_list{i} = usrinfo.runs_data{i}.name;
    end
    set(handles.runs_listbox, 'string', run_name_list)
    set(handles.runs_listbox, 'value', 1);