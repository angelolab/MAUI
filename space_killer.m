folders = uigetdiles('/');
for i=1:numel(folders)
    temp = dir([folders{i}, '/TIFs']);
    for j=1:numel(temp)
        name = temp(j).name;
        name = strrep(name, ' ', '');
        old_filename = [temp(j).folder, filesep, temp(j).name];
        new_filename = [temp(j).folder, filesep, name];
        movefile(old_filename, new_filename);
    end
end