%create objects from masks and export to fcs for ez_segmenter
function create_objects(point_index, pipeline_data)
    % get point from provided index    
    point_names = pipeline_data.points.getNames();
    point_name = point_names{point_index};
    point = pipeline_data.points.get('name', point_name);
    
    % do final calculation of mask and create objects (i.e. stats)
    [mask, stats] = calc_mask(point, pipeline_data);
    if isempty(stats)
        disp([point_names{point_index}, ' did not have objects within mask'])
        return
    end
    
    % save masks as tifs in results folder
    save_array_to_tif(pipeline_data, point_name, mask, 'masks');  
    
    % make a data matrix the size of the number of labels x the number of markers
    counts_size = size(point.counts);
    countsReshape = reshape(point.counts, counts_size(1)*counts_size(2), counts_size(3));
    
    objNum = numel(stats);
    channelNum = counts_size(3);
    
    data = zeros(objNum,channelNum);
    dataScaleSize = zeros(objNum,channelNum);
    cellSizes = zeros(objNum,1);
    
    % for each label extract information
    for i=1:objNum
        currData = countsReshape(stats(i).PixelIdxList,:);
        data(i,:) = sum(currData,1);
        dataScaleSize(i,:) = sum(currData,1) / stats(i).Area;
        cellSizes(i) = stats(i).Area;
    end
    
    % get cell sizes only for cells
    cellSizesVec = cellSizes;
    dataCells = data;
    dataScaleSizeCells = dataScaleSize;
    objIdentityNew2 = 1:objNum;
    objVec = objIdentityNew2';
    
    % asinh transform
    dataScaleSizeCellsTrans = asinh(dataScaleSizeCells);
    dataCellsTrans = asinh(dataCells);
    
    % standardize
    dataTransL = [objVec, cellSizesVec,dataCellsTrans];
    dataScaleSizeTransL = [objVec, cellSizesVec, dataScaleSizeCellsTrans];
    dataL = [objVec, cellSizesVec, dataCells];
    dataScaleSizeL = [objVec, cellSizesVec, dataScaleSizeCells];
    
    % save objects to queue - potential later today
    
    %% FCS stuff
    % names for FCS
    channelLabelsForFCS = ['cellLabelInImage';'cellSize';pipeline_data.points.labels'];
    TEXT.PnS = channelLabelsForFCS;
    TEXT.PnN = channelLabelsForFCS;
    
    % set up paths
    disp(point_index);
    [folder_path, point_folder] = fileparts(pipeline_data.points.getPath(point.name));
    [folder_path, ~] = fileparts(folder_path);
    pathSegment = [pipeline_data.run_path, filesep, 'fcs_points'];
    resultsDir = [pipeline_data.run_path, filesep, 'fcs_all'];
%     rmkdir([pathSegment, filesep, point_folder]);
%     rmkdir(resultsDir);
    
    % save and write FCS
    save([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_cellData.mat'],'objIdentityNew2','objVec','cellSizesVec','dataCells','dataScaleSizeCells','dataScaleSizeCellsTrans','dataCellsTrans','channelLabelsForFCS');
    writeFCS([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_dataFCS.fcs'],dataL,TEXT);
    writeFCS([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_dataScaleSizeFCS.fcs'],dataScaleSizeL,TEXT);
    writeFCS([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_dataTransFCS.fcs'],dataTransL,TEXT);
    writeFCS([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_dataScaleSizeTransFCS.fcs'],dataScaleSizeTransL,TEXT);
    
    writeFCS([resultsDir,'/',pipeline_data.named_objects,'_dataFCS_',point_folder,'.fcs'],dataL,TEXT);
    writeFCS([resultsDir,'/',pipeline_data.named_objects,'_dataScaleSizeFCS_',point_folder,'.fcs'],dataScaleSizeL,TEXT);
    writeFCS([resultsDir,'/',pipeline_data.named_objects,'_dataTransFCS_',point_folder,'.fcs'],dataTransL,TEXT);
    writeFCS([resultsDir,'/',pipeline_data.named_objects,'_dataScaleSizeTransFCS_',point_folder,'.fcs'],dataScaleSizeTransL,TEXT);
    
end