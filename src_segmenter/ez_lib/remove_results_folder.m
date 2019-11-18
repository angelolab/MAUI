% remove previously made point folders in composite, fcs_points folders
function remove_results_folder(pipeline_data, point_name)
    
    % create point folders for composite tifs
    [~, point_folder] = fileparts(point_name);
    rm_folder = [pipeline_data.run_path, filesep, 'composites', filesep, point_folder];
    if ~exist(rm_folder, 'dir')
        disp('no points removed');
    else
        rmvd = rmdir(rm_folder, 's');
        disp(rmvd);
    end
    
    % create point folders for fcs files
    [~, point_folder] = fileparts(point_name);
    rm_folder = [pipeline_data.run_path, filesep, 'objects_points', filesep, point_folder];
    if ~exist(rm_folder, 'dir')
        disp('no points removed');
    else
        rmvd = rmdir(rm_folder, 's');
        disp(rmvd)
    end