% Adds a composite channel to a csv file, ensuring repeat access of composite in ez_segment GUI 
function composite_to_csv(pipeline_data, composite_channel_name)

    %get path names to points
    point_paths = keys(pipeline_data.points.pathsToPoints);
    pt_path = point_paths{1};

    %obtain csv file (csv_filepath) by using fileparts and fullfile functions
    panelPath = [pipeline_data.run_path, filesep, 'info'];
    csvList = dir(fullfile(panelPath, '*.csv'));
    csvList(find(cellfun(@isHiddenName, {csvList.name}))) = [];
    csv_filepath = [csvList.folder, filesep, csvList.name];
    
    %pull up panel from csv
    panel = dataset('File', csv_filepath, 'Delimiter', ',');
    %make sure mass name is accounted for:
    if ~isempty(strmatch('Mass', get(panel, 'VarNames')))
        masses = panel.Mass;
    elseif ~isempty(strmatch('Isotope', get(panel, 'VarNames')))
        masses = panel.Isotope;
    end
    
    %create and append composite line to csv. Example below
    %new_line = 197,Au197,196.7,197.2,196.5,196.6,0,25,0
    new_line = {masses(end)+1, composite_channel_name, 0, 0, 0, 0, 0, 0, 0};
    
    %looping over opened csv to input mixed type array
    fid = fopen(csv_filepath, 'a+' );
    fprintf(fid, '\n%d,%s,%d,%d,%d,%d,%d,%d,%d', ...
        new_line{1},['Composite-',new_line{2}],new_line{3},new_line{4},new_line{5},new_line{6},new_line{7},new_line{8},new_line{9});
    fclose(fid);

end

