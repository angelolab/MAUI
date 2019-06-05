function varargout = titration_gui(varargin)
    % TITRATION_GUI MATLAB code for titration_gui.fig
    %      TITRATION_GUI, by itself, creates a new TITRATION_GUI or raises the existing
    %      singleton*.
    %
    %      H = TITRATION_GUI returns the handle to a new TITRATION_GUI or the handle to
    %      the existing singleton*.
    %
    %      TITRATION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in TITRATION_GUI.M with the given input arguments.
    %
    %      TITRATION_GUI('Property','value',...) creates a new TITRATION_GUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before titration_gui_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to titration_gui_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help titration_gui

    % Last Modified by GUIDE v2.5 04-Jun-2019 10:09:15

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @titration_gui_OpeningFcn, ...
                       'gui_OutputFcn',  @titration_gui_OutputFcn, ...
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


% --- Executes just before titration_gui is made visible.
function titration_gui_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to titration_gui (see VARARGIN)
    global pipeline_data;
    json.startup;
    pipeline_data = struct();
    pipeline_data.points = PointManager();
    pipeline_data.titers = struct();
    pipeline_data.labels = {};
    pipeline_data.figures = {};
    % Choose default command line output for titration_gui
    handles.output = hObject;
    [rootpath, name, ext] = fileparts(mfilename('fullpath'));
    options = json.read([rootpath, filesep, 'src', filesep, 'options.json']);
    fontsize = options.fontsize;
    pipeline_data.woahdude = imread([rootpath, filesep, 'src', filesep, 'gui_lib', filesep, 'resources', filesep, 'awaitinganalysis.png']);
    warning('off', 'MATLAB:hg:uicontrol:StringMustBeNonEmpty');
    warning('off', 'MATLAB:imagesci:tifftagsread:expectedTagDataFormat');
    rootpath = strsplit(rootpath, filesep);
    rootpath(end) = [];
    rootpath = strjoin(rootpath, filesep);
    pipeline_data.defaultPath = rootpath;
    % Update handles structure
    guidata(hObject, handles);
    
    set(handles.points_listbox, 'KeyPressFcn', {@points_listbox_keypressfcn, {eventdata, handles}});
    set(handles.channels_listbox, 'KeyPressFcn', {@channels_listbox_keypressfcn, {eventdata, handles}});
    setUIFontSize(handles, fontsize)
    
    f = figure; plotbrowser on;
    close(f);

% UIWAIT makes titration_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = titration_gui_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;


function fix_handle(handle)
    try
        if get(handle, 'value') > numel(get(handle, 'string'))
            set(handle, 'value', numel(get(handle, 'string')));
        end
        if isempty(get(handle, 'string'))
            set(handle, 'string', '');
            set(handle, 'value', 1)
        end
        if ~isnumeric(get(handle, 'value'))
            set(handle, 'value', 1)
        end
    catch
        
    end

function fix_menus_and_lists(handles)
    fix_handle(handles.points_listbox);
    fix_handle(handles.channels_listbox);

function point_names = getPointNames(handles)
    contents = cellstr(get(handles.points_listbox,'string'));
    point_idx = get(handles.points_listbox,'value');
    if isempty(contents)
        point_names = [];
    else
        point_names = contents(point_idx);
    end
    for i=1:numel(point_names)
        point_names{i} = tabSplit(point_names{i});
        point_names{i} = point_names{i}{1};
    end

function channel_params = getChannelParams(handles)
    global pipeline_data;
    label_index = get(handles.channels_listbox,'value');
    channel_params = pipeline_data.points.getDenoiseParam(label_index);

function setDispcapParam(handles)
    global pipeline_data;
    label_index = get(handles.channels_listbox,'value');
    dispcap = str2double(get(handles.dispcap_edit, 'string'));
    pipeline_data.points.setDenoiseParam(label_index, 'dispcap', dispcap);
    
function set_gui_state(handles, state)
    handle_names = fieldnames(handles);
    for i=1:numel(handle_names)
        try
            set(handles.(handle_names{i}), 'enable', state);
        catch
        end
    end
    drawnow
% --- Executes on button press in add_point.

function run_knn(handles)
    global pipeline_data;
    point_names = pipeline_data.points.getSelectedPointNames();
    label_indices = pipeline_data.points.getSelectedLabelIndices();
    set(handles.figure1, 'pointer', 'watch')
    wait = waitbar(0, 'Calculating nearest neighbors');
    startTime = tic;
    set_gui_state(handles, 'off');
    labels = pipeline_data.points.labels();
    for i=1:numel(point_names)
        for j=1:numel(label_indices)
            fraction = ((i-1)*numel(label_indices)+j)/(numel(point_names)*numel(label_indices));
            timeLeft = (toc(startTime)/fraction)*(1-fraction);

            min = floor(timeLeft/60);
            sec = round(timeLeft-60*min);
            waitbar(fraction, wait, ['Calculating KNN for ' strrep(point_names{i}, '_', '\_'), ':', labels{label_indices(j)}, '.' newline, 'Time remaining: ', num2str(min), ' minutes and ', num2str(sec), ' seconds']);
            figure(wait);
            k_value = pipeline_data.points.getDenoiseParam(label_indices(j)).k_value;
            pipeline_data.points.knn(point_names{i}, label_indices(j), k_value);
        end
    end
    for i=1:numel(point_names)
        for j=1:numel(label_indices)
            pipeline_data.points.setDenoiseParam(label_indices(j), 'loaded', 1);
        end
    end
    set(handles.figure1, 'pointer', 'arrow')
    close(wait);
    set_gui_state(handles, 'on');
    pipeline_data.points.flush_data();
    label_index = get(handles.channels_listbox, 'value');
    pipeline_data.points.plotTiters(label_index);
    set(handles.points_listbox, 'string', pipeline_data.points.getPointText());
    set(handles.channels_listbox, 'string', pipeline_data.points.getTitrationText());

function points_listbox_keypressfcn(hObject, eventdata, handles)
    global pipeline_data;
    if strcmp(eventdata.Key, 'return')
        point_names = getPointNames(handles{2});
        if numel(point_names)>1 || true
            for i=1:numel(point_names)
                pipeline_data.points.togglePointStatus(point_names{i});
            end
            set(handles{2}.points_listbox, 'string', pipeline_data.points.getPointText());
        end
    end
    
function channels_listbox_keypressfcn(hObject, eventdata, handles)
    global pipeline_data;
    if strcmp(eventdata.Key, 'return')
        channel_indices = get(handles{2}.channels_listbox,'value');
        if numel(channel_indices)>1 || true
            for i=1:numel(channel_indices)
                pipeline_data.points.setDenoiseParam(channel_indices(i), 'status');
            end
        end
        set(handles{2}.channels_listbox, 'string', pipeline_data.points.getTitrationText());
    end

function add_point_Callback(hObject, eventdata, handles)
    global pipeline_data;
    pointdiles = uigetdiles(pipeline_data.defaultPath);
    if ~isempty(pointdiles)
        [pipeline_data.defaultPath, ~, ~] = fileparts(pointdiles{1});
        pipeline_data.points.add(pointdiles);
        point_names = pipeline_data.points.getNames();
        set(handles.points_listbox, 'string', pipeline_data.points.getPointText())
        set(handles.points_listbox, 'max', numel(point_names));
        denoise_text = pipeline_data.points.getTitrationText();
        set(handles.channels_listbox, 'string', denoise_text);
        set(handles.channels_listbox, 'max', numel(denoise_text));
        % pipeline_data.labels = pipeline_data.points.labels();
    end

% --- Executes on button press in remove_point.
function remove_point_Callback(hObject, eventdata, handles)
    global pipeline_data;
    pointIndex = get(handles.points_listbox, 'value');
    pointList = pipeline_data.points.getNames();
    % pointList = get(handles.points_listbox, 'string');
    try
        removedPoint = pointList{pointIndex};
        if ~isempty(removedPoint)
            pipeline_data.points.remove('name', removedPoint);
            set(handles.points_listbox, 'string', pipeline_data.points.getNames());
            set(handles.channels_listbox, 'string', pipeline_data.points.getTitrationText());
        end
        fix_menus_and_lists(handles);
    catch
    end

% --- Executes on button press in run_knn.
function run_knn_Callback(hObject, eventdata, handles)
    run_knn(handles);

% --- Executes on selection change in points_listbox.
function points_listbox_Callback(hObject, eventdata, handles)
    try
        global pipeline_data;
        label_index = get(handles.channels_listbox,'value');
        point_indxs = get(handles.points_listbox, 'value');
        contents = get(handles.points_listbox, 'string');
        
        if ~isempty(point_indxs) && ~isempty(label_index)
            % we need to loop through the points that are selected
            for point_index = point_indxs
                point_name = contents{point_index};
                point = pipeline_data.points.get('name', point_name);
                pipeline_data.points.plotTiters(label_index)
                point.plotTiter(label_index, pipeline_data.points.denoiseParams{label_index}.dispcap)
            end
        end
    catch err
        disp('Error in titration_gui.m from points_listbox_Callback');
        % error(err)
    end

% --- Executes on selection change in channels_listbox.
function channels_listbox_Callback(hObject, eventdata, handles)
    try
        global pipeline_data;
        label_index = get(handles.channels_listbox,'value');
        if ~isempty(label_index)
            channel_params = pipeline_data.points.getDenoiseParam(label_index);
            % channel_params = getChannelParams(handles);
            dispcap = channel_params.dispcap;

            if strcmp(get(gcf,'selectiontype'),'open')
                pipeline_data.points.setDenoiseParam(label_index, 'status');
                set(handles.channels_listbox, 'string', pipeline_data.points.getTitrationText());
            end
            set(handles.dispcap_edit, 'string', dispcap);
            
            if dispcap<get(handles.dispcap_slider, 'min')
                set(handles.dispcap_slider, 'min', dispcap)
            elseif dispcap>get(handles.dispcap_slider, 'max')
                set(handles.dispcap_slider, 'max', dispcap)
            else
            end
            set(handles.dispcap_slider, 'value', dispcap);
            fix_menus_and_lists(handles);
        else
            
        end
    catch
    end
    try
        label_index = get(handles.channels_listbox,'value');
        point_indxs = get(handles.points_listbox, 'value');
        contents = get(handles.points_listbox, 'string');
        
        if ~isempty(point_indxs) && numel(label_index)==1 
            % we need to loop through the points that are selected
            for point_index = point_indxs
                point_name = contents{point_index};
                point = pipeline_data.points.get('name', point_name);
                pipeline_data.points.plotTiters(label_index)
                point.plotTiter(label_index, pipeline_data.points.denoiseParams{label_index}.dispcap)
            end
        end
    catch err
        disp('Error in titration_gui.m from channels_listbox_Callback');
        disp(err);
    end
    
% --- Executes on button press in load_run_button.
function load_run_button_Callback(hObject, eventdata, handles)
    [file,path] = uigetfile('*.log');
    global pipeline_data;
    logstring = fileread([path, filesep, file]);
    logstring = strsplit(logstring, filesep);
    logstring = logstring{1};
    label_params = strsplit(logstring, [' }', newline]);
    label_params(end) = [];
    % we should go through this and process them.
    for i=1:numel(label_params)
        if ~strcmp('not denoised', label_params{i}(end-11:end))
            % disp(label_params{i});
            label_param = label_params{i};
            label_param = strsplit(label_param, [': {', newline]);
            label = label_param{1}; % concerned there may be trailing space sometimes, could mess up stuff, check
            % we need to get the label_index to set the denoise_params
            % through PointManager
            label_index = pipeline_data.points.get_label_index(label);
            
            params = strsplit(label_param{2}, newline);
            
            k_val = params{1};
            k_val = strrep(k_val, ' ', '');
            k_val = strsplit(k_val, ':');
            k_val = str2double(k_val{2});
            
            threshold = params{2};
            threshold = strrep(threshold, ' ', '');
            threshold = strsplit(threshold, ':');
            threshold = str2double(threshold{2});
            
            pipeline_data.points.setDenoiseParam(label_index, 'k_value', k_val);
            pipeline_data.points.setDenoiseParam(label_index, 'threshold', threshold);
        else
            % this means this channel wasn't denoised
            label_param = strsplit(label_params{i}, ':');
            label = label_param{1};
            label_index = pipeline_data.points.get_label_index(label);
            pipeline_data.points.setDenoiseParam(label_index, 'status', -1);
        end
        set(handles.channels_listbox, 'string', pipeline_data.points.getTitrationText());
    end
    
% we need a function that takes in the string from a .log file and outputs
% a listbox string
function listbox_string = parse_log_file(logstring)


% --- Executes during object creation, after setting all properties.
function points_listbox_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function channels_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function dispcap_slider_Callback(hObject, eventdata, handles)
    global pipeline_data;
    try
        val = get(hObject,'value');
        set(handles.dispcap_edit, 'string', num2str(val));
        setDispcapParam(handles);
        label_index = get(handles.channels_listbox, 'value');
        pipeline_data.points.plotTiters(label_index);
        set(handles.channels_listbox, 'string', pipeline_data.points.getTitrationText());
        % point.plotTiter(label_index, pipeline_data.points.denoiseParams{label_index}.dispcap)
        pipeline_data.plotTiters(label_index);
    catch

    end

% --- Executes during object creation, after setting all properties.
function dispcap_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispcap_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function dispcap_edit_Callback(hObject, eventdata, handles)
    global pipeline_data;
    try
        val = str2double(get(hObject,'string'));
        if val<get(handles.dispcap_slider, 'min')
            set(handles.dispcap_slider, 'min', val);
        elseif val>get(handles.dispcap_slider, 'max')
            set(handles.dispcap_slider, 'max', val);
        else
            
        end
        set(handles.dispcap_slider, 'value', val);
        setDispcapParam(handles);
        label_index = get(handles.channels_listbox, 'value');
        pipeline_data.points.plotTiters(label_index);
        set(handles.channels_listbox, 'string', pipeline_data.points.getTitrationText());
    catch
        
    end

% --- Executes during object creation, after setting all properties.
function dispcap_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispcap_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dispcap_minmax_button.
function dispcap_minmax_button_Callback(hObject, eventdata, handles)
    global pipeline_data;
    defaults = {num2str(get(handles.dispcap_slider, 'min')), num2str(get(handles.dispcap_slider, 'max'))};
    vals = inputdlg({'Dispcap minimum', 'Dispcap maximum'}, 'Dispcap range', 1, defaults);
    try
        vals = str2double(vals);
        if vals(1)<0
            vals(1) = 0;
        end
        if vals(2)<0
            vals(2) = 0;
        end
        if vals(2)>vals(1)
            value = get(handles.dispcap_slider, 'value');
            if value<vals(1) % value less than minimum
                value = vals(1);
            elseif value>vals(2) % value greater than maximum
                value = vals(2);
            else
                % value is fine
            end
            set(handles.dispcap_slider, 'min', vals(1));
            set(handles.dispcap_slider, 'max', vals(2));
            set(handles.dispcap_slider, 'value', value);
            set(handles.dispcap_edit, 'string', value);
            setDispcapParam(handles);
            label_index = get(handles.channels_listbox, 'value');
            pipeline_data.points.plotTiters(label_index);
            set(handles.channels_listbox, 'string', pipeline_data.points.getTitrationText());
        else
            gui_warning('Threshold maximum must be greater than threshold minimum');
        end
    catch
        % do nothing
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


% --- Executes on selection change in titers_listbox.
function titers_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to titers_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns titers_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from titers_listbox


% --- Executes during object creation, after setting all properties.
function titers_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to titers_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_titer_button.
function add_titer_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_titer_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    input = inputdlg({'Titer name'}, 'New Titer', 1, {'new titer'});
    if ~strcmp(input, '')
        curr_titers = get(handles.titer_listbox, 'string');
        if any(strcmp(input, curr_titers))
            guiwarning('Titer already exists, pick a different name');
        else
            curr_titers = [curr_titers, input];
        end
    end


% --- Executes on button press in remove_titer_button.
function remove_titer_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_titer_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rename_titer_button.
function rename_titer_button_Callback(hObject, eventdata, handles)
% hObject    handle to rename_titer_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
