%save composite array to tif in results folder
function save_array_to_tif(pipeline_data, point_name, new_array, img_type)

    % get point folder
    [~, point_folder] = fileparts(point_name);

    if strcmp(img_type, 'composites')
        % break apart path name to get general folder, use to get to results folder
        compositePath = [pipeline_data.run_path, filesep, 'composites', filesep, point_folder];

        % save to composite folder
        imwrite(new_array, strcat(compositePath, filesep, pipeline_data.name_of_composite_channel, '.tif'));
    end
    
    if strcmp(img_type, 'masks')
        % break apart path name to get general folder, use to get to results folder
        compositePath = [pipeline_data.run_path, filesep, 'masks', filesep, point_folder];

        % save to mask folder
        imwrite(new_array, strcat(compositePath, filesep, pipeline_data.named_objects, '.tif'));
    end