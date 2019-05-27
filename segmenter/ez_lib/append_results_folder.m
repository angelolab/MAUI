function append_results_folder(pipeline_data)
    
    point_names = pipeline_data.points.getNames();
    
    % create point folders for composite tifs
    for index=1:numel(point_names)
        [~, point_folder] = fileparts(point_names{index});
        new_folder = [pipeline_data.run_path, filesep, 'composites', filesep, point_folder];
        if exist(new_folder, 'dir')
            disp('point(s) added previously');
        else
            mkdir(new_folder);
        end
    end
    
    % create point folders for fcs files
    for index=1:numel(point_names)
        [~, point_folder] = fileparts(point_names{index});
        new_folder = [pipeline_data.run_path, filesep, 'fcs_points', filesep, point_folder];
        if exist(new_folder, 'dir')
            disp('point(s) added previously');
        else
            mkdir(new_folder);
        end
    end