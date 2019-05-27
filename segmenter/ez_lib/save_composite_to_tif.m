%save composite matrix to tif in results folder
function save_composite_to_tif(pipeline_data, point_name, composite_array)

    % get point folder
    [~, point_folder] = fileparts(point_name);

    % break apart path name to get general folder, use to get to results folder
    compositePath = [pipeline_data.run_path, filesep, 'composites', filesep, point_folder];
    
    % save to composite folder
    imwrite(composite_array, strcat(compositePath, filesep, pipeline_data.name_of_composite_channel, '.tif'));