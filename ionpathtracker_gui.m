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

% Last Modified by GUIDE v2.5 01-Mar-2019 17:30:58

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

global pipeline_data;
[path, name, ext] = fileparts(mfilename('fullpath'));
options = json.read([path, filesep, 'src', filesep, 'options.json']);
fontsize = options.fontsize;
pipeline_data.url = options.url;
% pipeline_data.url = 'https://backend-dot-mibitracker-angelolab.appspot.com';
pipeline_data.points = PointManager();
[rootpath, name, ext] = fileparts(mfilename('fullpath'));
pipeline_data.defaultPath = rootpath;
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
    

% --- Executes on button press in login_button.
function login_button_Callback(hObject, eventdata, handles)
% hObject    handle to login_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global pipeline_data;
    usr = {'', ''};
    try
        [rootpath, ~, ~] = fileparts(mfilename('fullpath'));
        load([rootpath, filesep, 'usr.mat']);
    end
    barln = '---------------------------';
    usr = inputdlg({'Email:', 'Password:'}, 'Login', 1, usr);
    if ~isempty(usr)
        pipeline_data.usr = usr;
        waiting = gui_msgbox([barln, newline, 'logging in...', newline, barln]);
        try
            pipeline_data.auth_token = getAuthToken(pipeline_data.url, pipeline_data.usr);
            set(handles.remember_me_button, 'enable', 'on');
            set(handles.add_point_button, 'enable', 'on');
        catch err
            close(waiting)
            disp(err)
            gui_warning('Failed to login');
        end
        close(waiting);
    end


% --- Executes on button press in remember_me_button.
function remember_me_button_Callback(hObject, eventdata, handles)
% hObject    handle to remember_me_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global pipeline_data;
    usr = pipeline_data.usr;
    [rootpath, name, ext] = fileparts(mfilename('fullpath'));
    save([rootpath, filesep, 'usr.mat'], 'usr');

% --- Executes on button press in use_run_button.
function use_run_button_Callback(hObject, eventdata, handles)
% hObject    handle to use_run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        global pipeline_data;
        run_index = get(handles.runs_listbox, 'value');
        pipeline_data.points.run_object = pipeline_data.runs_data.results(run_index);
        set(handles.save_multitiffs_button, 'enable', 'on');
%         pipeline_data.pointdata = pipeline_data.runs_data(run_index).imageset.images;
%         pointIDs = cell2mat({pipeline_data.pointdata.id}');
%         % disp(pointIDs)
%         pipeline_data.pointinfo = {};
%         waitfig = waitbar(0);
%         for i=1:numel(pointIDs)
%             cmdout = GET(pipeline_data.url, pipeline_data.auth_token, ['/images/', num2str(pointIDs(i)), '/conjugates/']);
%             disp(cmdout)
%             waitfig = waitbar(i/numel(pointIDs));
%             pipeline_data.pointinfo{i} = json.load(cmdout);
%         end
%         close(waitfig);
    catch
        % do nothing
    end
    
% --- Executes on button press in add_point_button.
function add_point_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_point_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global pipeline_data;
    pointdiles = uigetdiles(pipeline_data.defaultPath);
    if ~isempty(pointdiles)
        [pipeline_data.defaultPath, ~, ~] = fileparts(pointdiles{1});
        pipeline_data.points.add(pointdiles, 'no_load');
        point_names = pipeline_data.points.getNames();
        set(handles.points_listbox, 'string', pipeline_data.points.getPointText(0))
        set(handles.points_listbox, 'max', numel(point_names));
        set(handles.remove_point_button, 'enable', 'on');
        set(handles.find_run_button, 'enable', 'on');
    end
    

% --- Executes on button press in remove_point_button.
function remove_point_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_point_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global pipeline_data;
    pointIndex = get(handles.points_listbox, 'value');
    pointList = pipeline_data.points.getNames();
    % pointList = get(handles.points_listbox, 'string');
    try
        for index = pointIndex
            removedPoint = pointList{index};
            if ~isempty(removedPoint)
                pipeline_data.points.remove('name', removedPoint);
                set(handles.points_listbox, 'string', pipeline_data.points.getNames());
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
    remaining = get(handles.points_listbox, 'string');
    if isempty(remaining)
        set(hObject, 'enable', 'off');
    end

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
    global pipeline_data;
    suggested_run = pipeline_data.points.check_run_names();
    disp(suggested_run)
    % waiting = gui_msgbox([barln, newline, 'fetching run...', newline, barln]);
    old_point_names = pipeline_data.points.getNames();
    new_point_paths = pipeline_data.points.save_ionpath_multitiff();
    for i=1:numel(old_point_names)
        new_point_paths{i} = [new_point_paths{i}, '.tiff'];
        pipeline_data.points.remove('name', old_point_names{i});    
    end
    pipeline_data.points.add(new_point_paths, 'no_load');
    set(handles.points_listbox, 'string', pipeline_data.points.getNames());
    
%     loaded_runs = get(handles.runs_listbox, 'string');
%     run_index = find(strcmp(loaded_runs, suggested_run));
%     pipeline_data.runobject = pipeline_data.runs_data(run_index);
%     if ~isempty(run_index)
%         set(handles.runs_listbox, 'value', run_index);
%         pipeline_data.points.save_ionpath_multitiff();
%     else
%         disp('failed to save')
%         pipeline_data.points.save_ionpath_multitiff();
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


% --- Executes on button press in find_run_button.
function find_run_button_Callback(hObject, eventdata, handles)
% hObject    handle to find_run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global pipeline_data;
    try
        suggested_run = pipeline_data.points.check_run_names();
        default = {suggested_run};
    catch
        default = {''};
    end
    run_name = inputdlg({'Run Name:'}, 'Find run', 1, default);
    if ~isempty(run_name)
        cmdout = httpGET(pipeline_data.auth_token, [pipeline_data.url, '/runs/?name=',run_name{1}]);
        disp(cmdout)
        try
            % disp(cmdout.Body.Data)
            pipeline_data.runs_data = cmdout.Body.Data;
            % set(handles.runs_listbox, 'string')
            if numel(pipeline_data.runs_data.results)==1
                % we've found THE run, unless we want to make a copy
                pipeline_data.points.run_object = pipeline_data.runs_data.results;
                set(handles.save_multitiffs_button, 'enable', 'on');
                disp('One run found');
            elseif isempty(pipeline_data.runs_data.results)
                % we've found no runs
                disp('No runs found');
            else
                % there are multiple runs
                set(handles.use_run_button, 'enable', 'on')
            end
            run_name_list = {pipeline_data.runs_data.results.label};
%             for i=1:numel(pipeline_data.runs_data.results)
%                 % this is bad, we need to handle the case we get multiple
%                 % runs back
%                 run_name_list{i} = ;
%             end
            set(handles.runs_listbox, 'string', run_name_list)
            set(handles.runs_listbox, 'value', 1);
        catch err
            disp(err);
            gui_warning('Failed to find run, please check the IonPath tracker');
        end
    end
