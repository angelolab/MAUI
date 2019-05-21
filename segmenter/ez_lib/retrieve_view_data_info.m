% get point, channel information for initial figure display
function [display_point, channel_index, channel_name, channel_counts] = retrieve_view_data_info(handles, pipeline_data)
    
    point_index = get(handles.point_list, 'value');
    point_list = get(handles.point_list, 'string');
    point_name = point_list{point_index};
    display_point = pipeline_data.points.get('name', point_name);

    full_counts = display_point.counts;
    channel_index = handles.view_data.Value;
    channel_name = handles.view_data.String{channel_index};
    channel_counts = full_counts(:,:,channel_index);
end