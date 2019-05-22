% Displays MIBI images, calculates and overlays visual mask
function display_segment(handles, pipeline_data, varargin)

    %get info for creating base display
    [display_point, channel_index, channel_name, channel_counts] = retrieve_view_data_info(handles, pipeline_data);
    sfigure(pipeline_data.display)
    
    [mask, stats] = calc_mask(display_point, pipeline_data);
    
    imagesc(channel_counts); hold on;
    %pipeline_data.display.axes = imagesc(channel_counts); hold on;
    %set(pipeline_data.display.axes, 'ButtonDownFcn', {@click_callback, pipeline_data});
    
    % needed to handle initial axes issue upon adding points the first time
    if ~isempty(varargin)
        xlim([0, inf]); ylim([0, inf]);
    end
    visboundaries(mask, 'linewidth', .5, 'EnhanceVisibility', false);

    %dataobj.str.segment_uptodate = false;
    %add axes labeling information LATER
    
    %add histo viz LATER
    %sfigure(dataobj.str.histfig);
    %histogram([dataobj.str.stats.Area], 'normalization', 'pdf');
end

% used in selecting objects from the image
% function click_callback(varargin)
%     global dataobj;
%     axesHandle = get(varargin{1}, 'Parent');
%     coordinates = get(axesHandle, 'CurrentPoint');
%     coordinates = ceil(coordinates(1,1:2));
%     pxl_index = sub2ind(size(dataobj.str.mask), coordinates(2), coordinates(1));
%     
%     obj_index = get_stat_index(pxl_index);
%     if obj_index~=-1
%         object = dataobj.str.stats(obj_index);
%         pxl_idxs = object.PixelIdxList;
%         single_mask = zeros(size(dataobj.str.mask));
%         single_mask(pxl_idxs) = 1;
%         display_mask();
%         sfigure(dataobj.str.dispfig);
%         hold on;
%         visboundaries(single_mask, 'linewidth', 2, 'EnhanceVisibility', false, 'color', [0,1,0]);
%         
%         point = dataobj.str.points(dataobj.str.point_index);
%         counts = point.counts;
%         
%         if false
%             for label=1:numel(dataobj.str.labels)
%                 channel = counts(:,:,label);
%                 expression = channel(pxl_idxs);
%                 expression = sum(expression(:));
%                 disp(tabJoin({dataobj.str.labels{label}, num2str(expression)}, 20));
%             end
%             disp(newline);
%         end
%     end
% end