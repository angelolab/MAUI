clear all; close all; clc;

global dataobj
dataobj = hstruct();
dataobj.str.histfig = figure();
dataobj.str.dispfig = figure();
dataobj.str.uifig = figure();

point_paths = uigetdiles('/');
dataobj.str.points = {};

if ~isempty(point_paths)
    for i=1:numel(point_paths)
        [counts, labels, tags] = loadTIFF_data([point_paths{i}, filesep, 'TIFs']);
        point = struct();
        point.counts = counts;
        point.labels = labels;
        point.tags = tags;
        
        temp = strsplit(point_paths{i}, filesep);
        point.name = temp{end};
        dataobj.str.points{end+1} = point;
    end
    dataobj.str.points = cell2mat(dataobj.str.points);
    dataobj.str.labels = labels;
    temp = temp(1:(end-1));
    dataobj.str.dir = strjoin(temp, filesep);
end

dataobj.str.blur = variable_ui(dataobj.str.uifig, 1, 'blur', [0, 2], {@display_mask, dataobj});
dataobj.str.threshold = variable_ui(dataobj.str.uifig, 2, 'threshold', [0, 2], {@display_mask, dataobj});
dataobj.str.minimum = variable_ui(dataobj.str.uifig, 3, 'minimum', [0, 50], {@display_mask, dataobj});

%create menus
dataobj.str.point_menu = uicontrol(dataobj.str.uifig, 'style', 'popupmenu', 'string', {dataobj.str.points.name}, 'units', 'normalized', 'position', [.1, 1-.4, .9, .1], 'value', 1, 'callback', @point_menu_callback);
dataobj.str.composite_menu = uicontrol(dataobj.str.uifig, 'style', 'popupmenu', 'string', dataobj.str.labels, 'units', 'normalized', 'position', [.1, 1-.5, .9, .1], 'value', 1, 'callback', @composite_menu_callback);
dataobj.str.composite_box = uicontrol(dataobj.str.uifig, 'style', 'listbox', 'string', dataobj.str.labels, 'units', 'normalized', 'position', [.1, 1-.6, .9, .1], 'value', 1, 'callback', @composite_box_callback);
dataobj.str.data_menu = uicontrol(dataobj.str.uifig, 'style', 'popupmenu', 'string', dataobj.str.labels, 'units', 'normalized', 'position', [.1, 1-.6, .9, .1], 'value', 1, 'callback', @data_menu_callback);
dataobj.str.view_menu = uicontrol(dataobj.str.uifig, 'style', 'popupmenu', 'string', dataobj.str.labels, 'units', 'normalized', 'position', [.1, 1-.7, .9, .1], 'value', 1, 'callback', @view_menu_callback);

%create menu labels
dataobj.str.point_text = uicontrol(dataobj.str.uifig, 'style', 'text', 'string', 'Point', 'units', 'normalized', 'position', [0, 1-.4, .1, .1]);
dataobj.str.composite_menu = uicontrol(dataobj.str.uifig, 'style', 'text', 'string', 'Composite channel', 'units', 'normalized', 'position', [0, 1-.5, .1, .1]);
dataobj.str.data_text = uicontrol(dataobj.str.uifig, 'style', 'text', 'string', 'Data', 'units', 'normalized', 'position', [0, 1-.6, .1, .1]);
dataobj.str.view_text = uicontrol(dataobj.str.uifig, 'style', 'text', 'string', 'View', 'units', 'normalized', 'position', [0, 1-.7, .1, .1]);

dataobj.str.save_button = uicontrol(dataobj.str.uifig, 'style', 'pushbutton', 'string', 'Save', 'units', 'normalized', 'position', [0, .2, .3, .1], 'callback', @save_callback);

dataobj.str.point_index = 1;
dataobj.str.data_index = 1;
dataobj.str.view_index = 1;

display_mask();

function composite_menu_callback(varagin)
    global dataobj;
    composite_index = get(varargin{1}, 'value');
    dataobj.str.composite_index = composite_index;
    display_mask();
end

function point_menu_callback(varargin)
    global dataobj;
    dataobj.str.point_index = get(varargin{1}, 'value');
    display_mask();
end

function data_menu_callback(varargin)
    global dataobj;
    data_index = get(varargin{1}, 'value');
    dataobj.str.data_index = data_index;
    display_mask();
end

function view_menu_callback(varargin)
    global dataobj;
    view_index = get(varargin{1}, 'value');
    dataobj.str.view_index = view_index;
    display_mask();
end

function [mask, stats] = calc_mask(point_index)
    global dataobj;
    blur = dataobj.str.blur.var_value;
    scale = 1;
    threshold = dataobj.str.threshold.var_value;
    minimum = dataobj.str.minimum.var_value;
    
    point = dataobj.str.points(point_index);
    counts = point.counts;
    
    data_index = dataobj.str.data_index;
    mask_src = counts(:,:,data_index);
    
    mask_src = mask_src*scale;
    if blur~=0
        mask_src = imgaussfilt(mask_src, blur);
    end
    
    mask = imbinarize(mask_src, threshold);
    stats = regionprops(mask, 'Area', 'PixelIdxList');
    [tmp, idxs] = sort(cell2mat({stats.Area}), 'descend');
    stats = stats(idxs);
    
    rm_obj_idxs = find([stats.Area]<minimum);
    rm_pxl_idxs = [];
    for index=rm_obj_idxs
        rm_pxl_idxs = cat(1, rm_pxl_idxs, stats(index).PixelIdxList);
    end
    mask(rm_pxl_idxs)=0;
    stats(rm_obj_idxs) = [];
end

function display_mask(varargin)
    global dataobj;
    
    point_index = dataobj.str.point_index;
    point = dataobj.str.points(point_index);
    counts = point.counts;
    view_data = counts(:,:,dataobj.str.view_index);
    
    [dataobj.str.mask, dataobj.str.stats] = calc_mask(point_index);
    
    sfigure(dataobj.str.dispfig);
    dataobj.str.axes = imagesc(view_data); hold on;
    set(dataobj.str.axes, 'ButtonDownFcn', @click_callback);
    visboundaries(dataobj.str.mask, 'linewidth', .5, 'EnhanceVisibility', false);
    
    dataobj.str.segment_uptodate = false;
    
    sfigure(dataobj.str.histfig);
    histogram([dataobj.str.stats.Area], 'normalization', 'pdf');
end

function save_callback(varargin)
    global dataobj
    msg = waitbar(0, ['"That is what forgiveness sounds like. Screaming and then silence."', newline, ' - Carl, Llamas with Hats']);
    for point_index=1:numel(dataobj.str.points)
        waitbar(point_index/numel(dataobj.str.points), msg, ['"That is what forgiveness sounds like. Screaming and then silence."', newline, ' - Carl, Llamas with Hats']);
        save_point(point_index);
    end
    
    try
        h = load('handel.mat');
        sound(h.y, h.Fs);
        catch
            
    end
    close(msg);
end

function save_point(point_index)
    global dataobj;
    point = dataobj.str.points(point_index);
    [mask, stats] = calc_mask(point_index);
    
    counts_size = size(point.counts);
    countsReshape = reshape(point.counts, counts_size(1)*counts_size(2), counts_size(3));
    
    labelNum = numel(stats); % number of objects, bad variable name
    channelNum = counts_size(3);
    
    data = zeros(labelNum,channelNum);
    dataScaleSize = zeros(labelNum,channelNum);
    cellSizes = zeros(labelNum,1);
    
    for i=1:labelNum
        currData = countsReshape(stats(i).PixelIdxList,:);
        data(i,:) = sum(currData,1);
        dataScaleSize(i,:) = sum(currData,1) / stats(i).Area;
        cellSizes(i) = stats(i).Area;
    end
    
    % at this point you might want to insert from the old script...
        % get the final information only for the labels with 
        % 1.positive nuclear identity (cells)
        % 2. That have enough information in the clustering channels to be
        % clustered
        
    cellSizesVec = cellSizes;
    dataCells = data;
    dataScaleSizeCells = dataScaleSize;
    labelIdentityNew2 = 1:labelNum;
    labelVec = labelIdentityNew2';
    
    dataScaleSizeCellsTrans = asinh(dataScaleSizeCells);
    dataCellsTrans = asinh(dataCells);
    
    dataTransL = [labelVec,cellSizesVec,dataCellsTrans];
    dataScaleSizeTransL = [labelVec,cellSizesVec, dataScaleSizeCellsTrans];
    dataL = [labelVec,cellSizesVec, dataCells];
    dataScaleSizeL = [labelVec,cellSizesVec, dataScaleSizeCells];
    
    channelLabelsForFCS = ['cellLabelInImage';'cellSize';dataobj.str.labels'];
    TEXT.PnS = channelLabelsForFCS;
    TEXT.PnN = channelLabelsForFCS;
    
    point_name = point.name;
    pointNumber = get_point_number(point_name);
    disp(pointNumber);
    pathSegment = [dataobj.str.dir, filesep, 'segmentation'];
    resultsDir = [dataobj.str.dir, filesep, 'results'];
    rmkdir([pathSegment, filesep, point_name]);
    rmkdir(resultsDir);
    
    
    save([pathSegment,'/Point',num2str(pointNumber),'/cellData.mat'],'labelIdentityNew2','labelVec','cellSizesVec','dataCells','dataScaleSizeCells','dataScaleSizeCellsTrans','dataCellsTrans','channelLabelsForFCS');
    writeFCS([pathSegment,'/Point',num2str(pointNumber),'/dataFCS.fcs'],dataL,TEXT);
    writeFCS([pathSegment,'/Point',num2str(pointNumber),'/dataScaleSizeFCS.fcs'],dataScaleSizeL,TEXT);
    writeFCS([pathSegment,'/Point',num2str(pointNumber),'/dataTransFCS.fcs'],dataTransL,TEXT);
    writeFCS([pathSegment,'/Point',num2str(pointNumber),'/dataScaleSizeTransFCS.fcs'],dataScaleSizeTransL,TEXT);
    
    writeFCS([resultsDir,'/dataFCS_p',num2str(pointNumber),'.fcs'],dataL,TEXT);
    writeFCS([resultsDir,'/dataScaleSizeFCS_p',num2str(pointNumber),'.fcs'],dataScaleSizeL,TEXT);
    writeFCS([resultsDir,'/dataTransFCS_p',num2str(pointNumber),'.fcs'],dataTransL,TEXT);
    writeFCS([resultsDir,'/dataScaleSizeTransFCS_p',num2str(pointNumber),'.fcs'],dataScaleSizeTransL,TEXT);
end
    
function num = get_point_number(point_name)
    num_idxs = regexp(point_name,'[^a-zA-Z]');
    num_str = point_name(num_idxs);
    num = str2double(num_str);
end

function click_callback(varargin)
    global dataobj;
    axesHandle = get(varargin{1}, 'Parent');
    coordinates = get(axesHandle, 'CurrentPoint');
    coordinates = ceil(coordinates(1,1:2));
    pxl_index = sub2ind(size(dataobj.str.mask), coordinates(2), coordinates(1));
    
    obj_index = get_stat_index(pxl_index);
    if obj_index~=-1
        object = dataobj.str.stats(obj_index);
        pxl_idxs = object.PixelIdxList;
        single_mask = zeros(size(dataobj.str.mask));
        single_mask(pxl_idxs) = 1;
        display_mask();
        sfigure(dataobj.str.dispfig);
        hold on;
        visboundaries(single_mask, 'linewidth', 2, 'EnhanceVisibility', false, 'color', [0,1,0]);
        
        point = dataobj.str.points(dataobj.str.point_index);
        counts = point.counts;
        
        if false
            for label=1:numel(dataobj.str.labels)
                channel = counts(:,:,label);
                expression = channel(pxl_idxs);
                expression = sum(expression(:));
                disp(tabJoin({dataobj.str.labels{label}, num2str(expression)}, 20));
            end
            disp(newline);
        end
    end
end

function obj_index = get_stat_index(pxl_index)
    global dataobj;
    stats = dataobj.str.stats;
    obj_index = -1;
    for i=1:numel(stats)
        if any(stats(i).PixelIdxList==pxl_index)
            obj_index = i;
            break;
        end
    end
end
