%create objects from masks and export to fcs for ez_segmenter
function create_objects(point_index, pipeline_data)

%% Pre-processing steps to mask data, convert into fcs / csv usable format, and create attributes to be saved later

    % get point from provided index    
    point_names = pipeline_data.points.getNames();
    point_name = point_names{point_index};
    point = pipeline_data.points.get('name', point_name);
    
    % do final calculation of mask and create objects (i.e. stats)
    [masks, stats] = calc_mask(point, pipeline_data);
    if isempty(stats)
        disp([point_names{point_index}, ' did not have objects within mask'])
        return
    end
    
    % save objects with unique identifiers, masks as tifs in results folder
    [mapped_obj_ids, total_objects] = bwlabel(masks);
    save_array_to_tif(pipeline_data, point_name, masks, 'masks');  
    
    % make a data matrix the size of the number of labels x the number of markers using reshape
    counts_size = size(point.counts);
    countsReshape = reshape(point.counts, counts_size(1)*counts_size(2), counts_size(3));
    
    % set up parameters & matricies for data loading
    objNum = total_objects;
    channelNum = counts_size(3);
    
    dataScaleSize = zeros(objNum,channelNum);
    objSizes = zeros(objNum,1);
    
    % for each object extract information and load into matrices
    for i=1:objNum
        currData = countsReshape(stats(i).PixelIdxList,:);
        dataScaleSize(i,:) = sum(currData,1) / stats(i).Area;
        objSizes(i) = stats(i).Area;
    end
    
    % get object identities only for objects
    objSizesVec = objSizes;
    dataScaleSizeObjs = dataScaleSize;
    objIdentity = 1:objNum;
    objVec = objIdentity';
    
    % extract point number to include as point_id variable for each object
    [~, point_number] = fileparts(point_name);
    point_id = regexp(point_number, '[0-9]*', 'match');
    point_id = str2num(point_id{1});
    pointVector = repmat(point_id, objNum, 1);
    
    % name of objects - future version where csv uses a struct2csv writer
    %nameVector = repmat(pipeline_data.named_objects, objNum, 1);
    
    % !!! collect data for ouput !!!
    dataScaleSize_out = [pointVector, objVec, objSizesVec, dataScaleSizeObjs];
    
%% object file attributes and formation
    % data for objects --> ouput headers
    channelLabelsForObjs = ['point_id'; 'obj_id'; 'obj_size'; pipeline_data.points.labels'];

    % set up paths
    disp(point_index);
    [folder_path, point_folder] = fileparts(pipeline_data.points.getPath(point.name));
    [folder_path, ~] = fileparts(folder_path);
    pathSegment = [pipeline_data.run_path, filesep, 'objects_points'];
    resultsDir = [pipeline_data.run_path, filesep, 'objects_all'];

    % save attributes and locations (mask) of the objects extracted from ez_segmenter in point folders :)
    save([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_cellData.mat'],'channelLabelsForObjs','pointVector','objIdentity','objVec','objSizesVec','mapped_obj_ids','dataScaleSizeObjs');

    % write csv with objects to objects_points folder using MIBI_GUI func csvwrite_with_headers
    csvwrite_with_headers([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_dataScaleSize.csv'], dataScaleSize_out, channelLabelsForObjs);
    csvwrite_with_headers([resultsDir,'/',pipeline_data.named_objects,'_dataScaleSize_',point_folder,'.csv'], dataScaleSize_out, channelLabelsForObjs);

    
end