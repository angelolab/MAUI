smart = 1;

run_folder = uigetdir('/');
if run_folder~=0
    contents = dir([run_folder, filesep, '**', filesep, '*.tiff']);
    old_point_paths = {};
    old_point_names = {};
    for i=1:numel(contents)
        if ~strcmp(contents(i).name(1), '.')
            old_point_paths{end+1} = contents(i).folder;
            old_point_names{end+1} = contents(i).name;
        end
    end
    if smart
        parts = strsplit(old_point_names{end}, '_');
        run_name = parts{1};
        new_point_names = cell(size(old_point_names));
        for i=1:numel(old_point_names)
            parts = strsplit(old_point_names{i}, '_');
            new_point_names{i} = [parts{2}, '.tiff'];
        end
    else
        new_point_names = old_point_names;
    end
    mkdir([run_folder, filesep, 'ionpath']);
    for i=1:numel(old_point_paths)
        old_path = [old_point_paths{i}, filesep, old_point_names{i}];
        new_path = [run_folder, filesep, 'ionpath', filesep, new_point_names{i}];
        movefile(old_path, new_path);
        rmdir(old_point_paths{i});
    end
    mkdir([run_folder, filesep, 'info']);
    if smart
        new_run_folder = strsplit(run_folder, filesep);
        new_run_folder{end} = run_name;
        new_run_folder = strjoin(new_run_folder, filesep);
        movefile(run_folder, new_run_folder);
    end
end