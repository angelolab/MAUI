function varargout = fft_removal_gui(varargin)
% FFT_REMOVAL_GUI MATLAB code for fft_removal_gui.fig
%      FFT_REMOVAL_GUI, by itself, creates a new FFT_REMOVAL_GUI or raises the existing
%      singleton*.
%
%      H = FFT_REMOVAL_GUI returns the handle to a new FFT_REMOVAL_GUI or the handle to
%      the existing singleton*.
%
%      FFT_REMOVAL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FFT_REMOVAL_GUI.M with the given input arguments.
%
%      FFT_REMOVAL_GUI('Property','value',...) creates a new FFT_REMOVAL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fft_removal_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fft_removal_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fft_removal_gui

% Last Modified by GUIDE v2.5 07-Dec-2018 16:16:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fft_removal_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @fft_removal_gui_OutputFcn, ...
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


% --- Executes just before fft_removal_gui is made visible.
function fft_removal_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fft_removal_gui (see VARARGIN)

global pipeline_data;
json.startup;
pipeline_data = struct();
pipeline_data.points = PointManager();
pipeline_data.tiffFigure = NaN;
pipeline_data.corePath = {};
pipeline_data.dataNoNoise = containers.Map;
[path, name, ext] = fileparts(mfilename('fullpath'));
warning('off', 'MATLAB:hg:uicontrol:StringMustBeNonEmpty');
warning('off', 'MATLAB:imagesci:tifftagsread:expectedTagDataFormat');
path = strsplit(path, filesep);
path(end) = [];
path = strjoin(path, filesep);
pipeline_data.defaultPath = path;
% Choose default command line output for fft_removal_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fft_removal_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fft_removal_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function point = getPointName(handles)
    contents = cellstr(get(handles.points_listbox,'string'));
    point = contents{get(handles.points_listbox,'value')};

   
function channel_params = getChannelParams(handles)
    global pipeline_data;
    channel_index = get(handles.channel_listbox, 'value');
    channel_params = pipeline_data.points.getFFTRmParam(channel_index);
    
function generateFFTRmText(handles)
    global pipeline_data;
    set(handles.channel_listbox, 'string', pipeline_data.points.getFFTRmText());
    
function setBlurParam(handles)
    global pipeline_data;
    channel_index = get(handles.channel_listbox, 'value');
    blur = str2double(get(handles.blur_display_text, 'string'));
    pipeline_data.points.setFFTRmParam(channel_index, 'blur', blur);
    generateFFTRmText(handles);
    
function setRadiusParam(handles)
    global pipeline_data;
    channel_index = get(handles.channel_listbox, 'value');
    radius = str2double(get(handles.radius_display_text, 'string'));
    pipeline_data.points.setFFTRmParam(channel_index, 'radius', radius);
    generateFFTRmText(handles);
    
function setScaleParam(handles)
    global pipeline_data;
    channel_index = get(handles.channel_listbox, 'value');
    scale = str2double(get(handles.scale_display_text, 'string'));
    pipeline_data.points.setFFTRmParam(channel_index, 'scale', scale);
    generateFFTRmText(handles);
    
function setImagecapParam(handles)
    global pipeline_data;
    channel_index = get(handles.channel_listbox, 'value');
    imagecap = str2double(get(handles.cap_display_text, 'string'));
    pipeline_data.points.setFFTRmParam(channel_index, 'imagecap', imagecap);
    generateFFTRmText(handles);
    
function setBlurSlider(val, handles)
    try
        if val<get(handles.blur_slider, 'min')
            set(handles.blur_slider, 'min', val);
        elseif val>get(handles.blur_slider, 'max')
            set(handles.blur_slider, 'max', val);
        else
        end
        set(handles.blur_slider, 'value', val);
        setBlurParam(handles);
    catch
        
    end
    
function setRadiusSlider(val, handles)
    try
        if val<get(handles.radius_slider, 'min')
            set(handles.radius_slider, 'min', val);
        elseif val>get(handles.radius_slider, 'max')
            set(handles.radius_slider, 'max', val);
        else
        end
        set(handles.radius_slider, 'value', val);
        setRadiusParam(handles);
    catch
        
    end
    
function setScaleSlider(val, handles)
    try
        if val<get(handles.scale_slider, 'min')
            set(handles.scale_slider, 'min', val);
        elseif val>get(handles.scale_slider, 'max')
            set(handles.scale_slider, 'max', val);
        else
        end
        set(handles.scale_slider, 'value', val);
        setScaleParam(handles);
    catch
        
    end
    
function setImagecapSlider(val, handles)
    try
        if val<get(handles.cap_slider, 'min')
            set(handles.cap_slider, 'min', val);
        elseif val>get(handles.cap_slider, 'max')
            set(handles.cap_slider, 'max', val);
        else
        end
        set(handles.cap_slider, 'value', val);
        setImagecapParam(handles);
    catch
        
    end
    
function plotFFTRmParams(handles)
    global pipeline_data;
    label_index = get(handles.channel_listbox, 'value');
    params = pipeline_data.points.getFFTRmParam(label_index);
    label = params.label;
    blur = params.blur;
    radius = params.radius;
    scale = params.scale;
    imagecap = params.imagecap;
    point = pipeline_data.points.get('name', getPointName(handles));
    counts = point.counts;
    plotChannelInd = find(strcmp(pipeline_data.points.labels(), label));
    xlimits = NaN;
    ylimits = NaN;
    try
        sfigure(pipeline_data.tiffFigure);
        xlimits = xlim;
        ylimits = ylim;
    catch error1
        pipeline_data.tiffFigure = sfigure();
        disp(pipeline_data.tiffFigure);
        handles.reset_button = uicontrol('Parent',pipeline_data.tiffFigure,'Style','pushbutton','string','Reset','Units','normalized','Position',[0.015 .94 0.1 0.05],'Visible','on', 'Callback', @reset_plot_Callback);
    end
    
    try
        rawdata = counts(:,:,plotChannelInd);
        countsNoNoise = gui_FFTfilter(rawdata, blur, radius, scale);
        currdata = countsNoNoise;
        
        rawdata(rawdata>imagecap) = imagecap;
        currdata(currdata>imagecap) = imagecap;
        
        imagemin = min(min(rawdata(:)), min(currdata(:)));
        imagemax = max(max(rawdata(:)), max(currdata(:)));
        
        % currdata(currdata>capImage) = capImage;
        pipeline_data.currdata = currdata;
        sfigure(pipeline_data.tiffFigure);
        
        subplot(1,2,1);
        imagesc(rawdata);
        caxis([imagemin, imagemax]);
        title([label, ' - before']);
        ax1 = gca();
        subplot(1,2,2);
        imagesc(currdata);
        caxis([imagemin, imagemax]);
        if ~isnan(xlimits)
            xlim(xlimits);
            ylim(ylimits);
        end
        ax2 = gca();
        title([label, ' - after']);
        linkaxes([ax1, ax2]);
    catch error2
        disp('error2')
        disp(error2)
    end   
    
    
function reset_plot_Callback(hObject, eventdata, hadles)
    % handles = guidata(hObject);
    global pipeline_data;
    sfigure(pipeline_data.tiffFigure);
    imagesc(pipeline_data.currdata);
    
% --- Executes on button press in add_point_button.
function add_point_button_Callback(hObject, eventdata, handles)
    global pipeline_data;
    pointdiles = uigetdiles(pipeline_data.defaultPath);
    if ~isempty(pointdiles)
        [pipeline_data.defaultPath, ~, ~] = fileparts(pointdiles{1});
        pipeline_data.points.add(pointdiles);
        point_names = pipeline_data.points.getNames();
        set(handles.points_listbox, 'string', point_names)
        set(handles.points_listbox, 'value', 1);
        set(handles.channel_listbox, 'value', 1);
        generateFFTRmText(handles)
        plotFFTRmParams(handles);
    end
    
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
    fix_handle(handles.channel_listbox);

% --- Executes on button press in remove_point_button.
function remove_point_button_Callback(hObject, eventdata, handles)
    global pipeline_data;
    pointIndex = get(handles.points_listbox, 'value');
    pointList = pipeline_data.points.getNames();
    try
        removedPoint = pointList{pointIndex};
        if ~isempty(removedPoint)
            pipeline_data.points.remove('name', removedPoint);
            set(handles.points_listbox, 'string', pipeline_data.points.getNames());
            set(handles.channel_listbox, 'string', pipeline_data.points.getFFTRmText());
        end
        fix_menus_and_lists(handles);
    catch
    end

% --- Executes on button press in select_point_button.
function select_point_button_Callback(hObject, eventdata, handles)
    try
        global pipeline_data;
        point = getPointName(handles);
        set(handles.selected_point_text, 'string', point);
        pipeline_data.labels = pipeline_data.dataNoNoise(point).labels;
        plotFFTRmParams(handles);
    catch
        % do nothing
    end

% --- Executes on slider movement.
function blur_slider_Callback(hObject, eventdata, handles)
    try
        val = get(hObject,'value');
        set(handles.blur_display_text, 'string', num2str(val));
        setBlurParam(handles);
        plotFFTRmParams(handles);
    catch

    end

% --- Executes during object creation, after setting all properties.
function blur_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function blur_display_text_Callback(hObject, eventdata, handles)
    try
        val = str2double(get(hObject,'string'));
        setBlurSlider(val, handles);
        plotFFTRmParams(handles);
    catch
        
    end

% --- Executes during object creation, after setting all properties.
function blur_display_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in channel_listbox.
function channel_listbox_Callback(hObject, eventdata, handles)
    % try
        global pipeline_data;
        channel_params = pipeline_data.points.getFFTRmParam(get(handles.channel_listbox, 'value'));
        blur = channel_params.blur;
        radius = channel_params.radius;
        scale = channel_params.scale;
        imagecap = channel_params.imagecap;
        set(handles.blur_display_text, 'string', blur);
        set(handles.radius_display_text, 'string', radius);
        set(handles.scale_display_text, 'string', scale);
        set(handles.cap_display_text, 'string', imagecap);
        setBlurSlider(blur, handles);
        setRadiusSlider(radius, handles);
        setScaleSlider(scale, handles);
        setImagecapSlider(imagecap, handles);
        plotFFTRmParams(handles)
    % catch
        
    % end

% --- Executes during object creation, after setting all properties.
function channel_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in blur_button.
function blur_button_Callback(hObject, eventdata, handles)
defaults = {num2str(get(handles.blur_slider, 'min')), num2str(get(handles.blur_slider, 'max'))};
vals = inputdlg({'Threshold minimum', 'Threshold maximum'}, 'Threshold range', 1, defaults);
    try
        vals = str2double(vals);
        if vals(2)>vals(1)
            value = get(handles.blur_slider, 'value');
            if value<vals(1) % value less than minimum
                value = vals(1);
            elseif value>vals(2) % value greater than maximum
                value = vals(2);
            else
                % value is fine
            end
            set(handles.blur_slider, 'min', vals(1));
            set(handles.blur_slider, 'max', vals(2));
            set(handles.blur_slider, 'value', value);
            set(handles.blur_display_text, 'string', value);
            setBlurParam(handles);
        else
            gui_warning('Threshold maximum must be greater than threshold minimum');
        end
    catch
        % gui_warning('You did not enter valid numbers');
    end

% --- Executes on button press in remove_noise_button.
function remove_noise_button_Callback(hObject, eventdata, handles)
    global pipeline_data;
    set(handles.figure1, 'pointer', 'watch');
    pipeline_data.points.save_no_fft_noise();
    set(handles.figure1, 'pointer', 'arrow');
    
    msg = {'+----------------------------------------------+',...
           '|                                              |',...
           '|           Done removing noise                |',...
           '|                                              |',...
           '+----------------------------------------------+'};
    m = gui_msgbox(msg);
    


% --- Executes on button press in save_run_button.
function save_run_button_Callback(hObject, eventdata, handles)
    [file,path] = uiputfile('*.mat');
    global pipeline_data;
    try
        pipeline_data.tiffFigure = NaN;
        save([path, filesep, file], 'pipeline_data')
    catch
        
    end

% --- Executes on button press in load_run_button.
function load_run_button_Callback(hObject, eventdata, handles)
    [file,path] = uigetfile('*.mat');
    set(handles.figure1, 'pointer', 'watch');
    drawnow
    global pipeline_data;
    try
        pipeline_data = load([path, filesep, file]);
        try
            pipeline_data = pipeline_data.pipeline_data;
            set(handles.points_listbox, 'string', pipeline_data.corePath);
            generateFFTRmText(handles);
        catch
            gui_warning('Invalid file');
        end
    catch
        % do nothing
    end
    set(handles.figure1, 'pointer', 'arrow');

% --- Executes on slider movement.
function scale_slider_Callback(hObject, eventdata, handles)
    try
        val = get(hObject,'value');
        set(handles.scale_display_text, 'string', num2str(val));
        setScaleParam(handles);
        plotFFTRmParams(handles);
    catch

    end

% --- Executes during object creation, after setting all properties.
function scale_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function scale_display_text_Callback(hObject, eventdata, handles)
    try
        val = str2double(get(hObject,'string'));
        setScaleSlider(val, handles);
        plotFFTRmParams(handles);
    catch
        
    end

% --- Executes during object creation, after setting all properties.
function scale_display_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in scale_button.
function scale_button_Callback(hObject, eventdata, handles)
defaults = {num2str(get(handles.scale_slider, 'min')), num2str(get(handles.scale_slider, 'max'))};
vals = inputdlg({'Image cap minimum', 'Image cap maximum'}, 'Image cap range', 1, defaults);
    try
        vals = str2double(vals);
        if vals(2)>vals(1)
            value = get(handles.scale_slider, 'value');
            if value<vals(1) % value less than minimum
                value = vals(1);
            elseif value>vals(2) % value greater than maximum
                value = vals(2);
            else
                % value is fine
            end
            set(handles.scale_slider, 'min', vals(1));
            set(handles.scale_slider, 'max', vals(2));
            set(handles.scale_slider, 'value', value);
            set(handles.scale_display_text, 'string', value);
            setScaleParam(handles);
            plotFFTRmParams(handles);
        else
            gui_warning('Image cap maximum must be greater than image cap minimum');
        end
    catch
        % gui_warning('You did not enter valid numbers');
    end

% --- Executes on slider movement.
function radius_slider_Callback(hObject, eventdata, handles)
    try
        val = get(hObject,'value');
        set(handles.radius_display_text, 'string', num2str(val));
        setRadiusParam(handles);
        plotFFTRmParams(handles);
    catch

    end

% --- Executes during object creation, after setting all properties.
function radius_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function radius_display_text_Callback(hObject, eventdata, handles)
    try
        val = str2double(get(hObject,'string'));
        setRadiusSlider(val, handles);
        plotFFTRmParams(handles);
    catch
        
    end

% --- Executes during object creation, after setting all properties.
function radius_display_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in spectral_radius_button.
function spectral_radius_button_Callback(hObject, eventdata, handles)
defaults = {num2str(get(handles.radius_slider, 'min')), num2str(get(handles.radius_slider, 'max'))};
vals = inputdlg({'Gaussian Radius minimum', 'Gaussian Radius maximum'}, 'Gaussian Radius range', 1, defaults);
    try
        vals = str2double(vals);
        if vals(2)>vals(1)
            value = get(handles.radius_slider, 'value');
            if value<vals(1) % value less than minimum
                value = vals(1);
            elseif value>vals(2) % value greater than maximum
                value = vals(2);
            else
                % value is fine
            end
            set(handles.radius_slider, 'min', vals(1));
            set(handles.radius_slider, 'max', vals(2));
            set(handles.radius_slider, 'value', value);
            set(handles.radius_display_text, 'string', value);
            setRadiusParam(handles);
            plotFFTRmParams(handles);
        else
            gui_warning('Radius maximum must be greater than radius minimum');
        end
    catch
        % gui_warning('You did not enter valid numbers');
    end

% --- Executes on selection change in points_listbox.
function points_listbox_Callback(hObject, eventdata, handles)
    generateFFTRmText(handles);
    plotFFTRmParams(handles);

% --- Executes during object creation, after setting all properties.
function points_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function cap_slider_Callback(hObject, eventdata, handles)
    try
        val = get(hObject,'value');
        set(handles.cap_display_text, 'string', num2str(val));
        setImagecapParam(handles);
        plotFFTRmParams(handles);
    catch

    end


% --- Executes during object creation, after setting all properties.
function cap_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cap_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function cap_display_text_Callback(hObject, eventdata, handles)
    try
        val = str2double(get(hObject,'string'));
        setImagecapSlider(val, handles);
        plotFFTRmParams(handles);
    catch
        
    end


% --- Executes during object creation, after setting all properties.
function cap_display_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cap_display_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cap_button.
function cap_button_Callback(hObject, eventdata, handles)
defaults = {num2str(get(handles.cap_slider, 'min')), num2str(get(handles.cap_slider, 'max'))};
vals = inputdlg({'Image cap minimum', 'Image cap maximum'}, 'Image cap range', 1, defaults);
    try
        vals = str2double(vals);
        if vals(2)>vals(1)
            value = get(handles.cap_slider, 'value');
            if value<vals(1) % value less than minimum
                value = vals(1);
            elseif value>vals(2) % value greater than maximum
                value = vals(2);
            else
                % value is fine
            end
            set(handles.cap_slider, 'min', vals(1));
            set(handles.cap_slider, 'max', vals(2));
            set(handles.cap_slider, 'value', value);
            set(handles.cap_display_text, 'string', value);
            setImagecapParam(handles);
            plotFFTRmParams(handles);
        else
            gui_warning('Radius maximum must be greater than radius minimum');
        end
    catch
        % gui_warning('You did not enter valid numbers');
    end
