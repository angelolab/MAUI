[counts, labels, tags] = loadTIFF_folder('/Users/bryjc/Box/Brain_Team_Project/MIBI_Scanned_Images/Processed_Data_BJC/180905_Validation_AD_ROI1Final2/no_fftnoise/Point2/TIFs');
disp('data loaded');

label = 'Iba1';
label_index = strcmp(labels, label);
%%
global dataobj;
dataobj = struct();

dataobj.data = counts(:,:,label_index);

dataobj.blur = .5;
dataobj.scale = 1;
dataobj.threshold = 0;
dataobj.pxl_threshold = 5;

dataobj.mask = imbinarize(imgaussfilt(scale*data, blur), threshold);
dataobj.stats = regionprops(mask, 'Area', 'PixelIdxList');

[tmp, idxs] = sort(cell2mat({stats.Area}), 'descend');
stats = stats(idxs);
dataobj.histfig = figure();
dataobj.fig = figure;

dataobj.axes = imagesc(dataobj.data);
% set(dataobj.axes, 'ButtonDownFcn', @click_callback);

hold on;
visboundaries(dataobj.mask, 'linewidth', .5, 'EnhanceVisibility', false);

blur_slider = uicontrol(dataobj.fig, 'style', 'slider', 'units', 'normalized', 'position', [0,0.7,.9,.3], 'callback', @blur_callback, 'min', 0, 'max', 10);
t_slider = uicontrol(dataobj.fig, 'style', 'slider', 'units', 'normalized', 'position', [0,0.66,.9,.3], 'callback', @threshold_callback, 'min', 0, 'max', 10);

function segment(varargin)
    global dataobj;
    blur = dataobj.blur;
    scale = dataobj.scale;
    threshold = dataobj.threshold;
    data = dataobj.data;
    
    temp_data = data*scale;
    
    if blur~=0
        temp_data = imgaussfilt(temp_data, blur);
    end
    
    dataobj.mask = imbinarize(temp_data, threshold);
    dataobj.stats = regionprops(dataobj.mask, 'Area', 'PixelIdxList');
    
    % [tmp, idxs] = sort(cell2mat({dataobj.stats.Area}), 'descend');
    % stats = stats(idxs);
    
    figure(dataobj.fig);
    dataobj.axes = imagesc(dataobj.data);
    set(dataobj.axes, 'ButtonDownFcn', @click_callback);
    hold on;
    visboundaries(dataobj.mask, 'linewidth', .5, 'EnhanceVisibility', false);
    sfigure(dataobj.histfig);
    histogram([dataobj.stats.Area]);
end

function click_callback(varargin)
    global dataobj;
    axesHandle = get(varargin{1}, 'Parent');
    coordinates = get(axesHandle, 'CurrentPoint');
    coordinates = ceil(coordinates(1,1:2));
    index = sub2ind(size(dataobj.data), coordinates(2), coordinates(1));
    dataobj.data(index) = 1;
    stats = dataobj.stats;
    
    disp(index);
end

function blur_callback(varargin)
    global dataobj;
    dataobj.blur = get(varargin{1}, 'value');
    segment();
end

function threshold_callback(varargin)
    global dataobj;
    dataobj.threshold = get(varargin{1}, 'value');
    segment();
end