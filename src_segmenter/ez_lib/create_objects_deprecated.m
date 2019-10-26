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
    
    % save masks as tifs in results folder
    save_array_to_tif(pipeline_data, point_name, masks, 'masks');  
    
    % make a data matrix the size of the number of labels x the number of markers using reshape
    counts_size = size(point.counts);
    countsReshape = reshape(point.counts, counts_size(1)*counts_size(2), counts_size(3));
    
    % NEED TO INCLUDE [object_unique_ids, total_objects] = bwlabel(masks)
    objNum = numel(stats);
    channelNum = counts_size(3);
    
    data = zeros(objNum,channelNum);
    dataScaleSize = zeros(objNum,channelNum);
    objSizes = zeros(objNum,1);
    
    % for each object extract information
    for i=1:objNum
        currData = countsReshape(stats(i).PixelIdxList,:);
        data(i,:) = sum(currData,1);
        dataScaleSize(i,:) = sum(currData,1) / stats(i).Area;
        objSizes(i) = stats(i).Area;
    end
    
    % get cell sizes only for cells
    objSizesVec = objSizes;
    dataObjs = data;
    dataScaleSizeObjs = dataScaleSize;
    objIdentityNew2 = 1:objNum;
    objVec = objIdentityNew2';
    
    % asinh transform - currently excluding
        % dataScaleSizeCellsTrans = asinh(dataScaleSizeCells);
        % dataCellsTrans = asinh(dataCells);
    
    % standardize data (none, size, and size + linear transform) - currently excluding transformed data from this
    % is L == linear?
    dataL = [objVec, objSizesVec, dataObjs];
    dataScaleSizeL = [objVec, objSizesVec, dataScaleSizeObjs];
    dataScaleSizeLMultiply=[objVec,objSizesVec,dataScaleSizeObjs*100];
        % dataTransL = [objVec, cellSizesVec,dataCellsTrans];
        % dataScaleSizeTransL = [objVec, cellSizesVec, dataScaleSizeCellsTrans];

    
    %% FUTUREE VERSION NOTE save objects to queue for later concatenation - potentially later
    
    %% FCS, CSV attributes and formation
        % names for FCS
        channelLabelsForFCS = ['objsLabelInImage';'objSize';pipeline_data.points.labels'];
        TEXT.PnS = channelLabelsForFCS;
        TEXT.PnN = channelLabelsForFCS;
        TEXT.PnR = channelLabelsForFCS;

        % set up paths
        disp(point_index);
        [folder_path, point_folder] = fileparts(pipeline_data.points.getPath(point.name));
        [folder_path, ~] = fileparts(folder_path);
        pathSegment = [pipeline_data.run_path, filesep, 'fcs_points'];
        resultsDir = [pipeline_data.run_path, filesep, 'fcs_all'];
            % rmkdir([pathSegment, filesep, point_folder]);
            % mkdir(resultsDir);
        
        % SAVE attributes and locations (mask) of the objects extracted
        % from ez_segmenter in point folders :)
        % (maybe throw into msks folder as well? also transforms are currently blocked out
        save([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_cellData.mat'],'masks', 'objIdentityNew2','objVec','objSizesVec','dataObjs','dataScaleSizeObjs','channelLabelsForFCS');
            %save([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_cellData.mat'],'masks', 'objIdentityNew2','objVec','objSizesVec','dataObjs','dataScaleSizeObjs','dataScaleSizeObjsTrans','dataObjsTrans','channelLabelsForFCS');

        % save and write csv - currently excluding transformed data
        csvwrite_with_headers([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_data.csv'],dataL,TEXT.PnS)
        csvwrite_with_headers([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_dataScaleSize.csv'],dataScaleSizeL,TEXT.PnS)
           % csvwrite_with_headers([pathSegment,'/Point',num2str(pointNumber),'/dataTransFCS.csv'],dataTransL,TEXT.PnS)
           % csvwrite_with_headers([pathSegment,'/Point',num2str(pointNumber),'/dataScaleSizeTransFCS.csv'],dataScaleSizeTransL,TEXT.PnS)
        csvwrite_with_headers([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_dataScaleSizeMultiply.csv'],dataScaleSizeLMultiply,TEXT.PnS);

        csvwrite_with_headers([resultsDir,'/',pipeline_data.named_objects,'_data_',point_folder,'.csv'],dataL,TEXT.PnS);
        csvwrite_with_headers([resultsDir,'/',pipeline_data.named_objects,'_dataScaleSize_',point_folder,'.csv'],dataScaleSizeL,TEXT.PnS);
            % csvwrite_with_headers([resultsDir,'/',pipeline_data.named_objects,'_dataTrans_',point_folder,'.fcs'],dataTransL,TEXT.PnS);
            % csvwrite_with_headers([resultsDir,'/',pipeline_data.named_objects,'_dataScaleSizeTrans_',point_folder,'.csv'],dataScaleSizeTransL,TEXT.PnS);
        csvwrite_with_headers([resultsDir,'/',pipeline_data.named_objects,'_dataScaleSizeMultiply_',point_folder,'.csv'],dataScaleSizeL,TEXT.PnS);
        
        % save and write FCS - currently excluding transformed data
        writeFCS([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_data.fcs'],dataL,TEXT);
        writeFCS([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_dataScaleSize.fcs'],dataScaleSizeL,TEXT);
            % writeFCS([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_dataTransFCS.fcs'],dataTransL,TEXT);
            % writeFCS([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_dataScaleSizeTransFCS.fcs'],dataScaleSizeTransL,TEXT);
        writeFCS([pathSegment,'/',point_folder,'/',pipeline_data.named_objects,'_dataScaleSizeMultiply.fcs'],dataScaleSizeLMultiply,TEXT);

        writeFCS([resultsDir,'/',pipeline_data.named_objects,'_data_',point_folder,'.fcs'],dataL,TEXT);
        writeFCS([resultsDir,'/',pipeline_data.named_objects,'_dataScaleSize_',point_folder,'.fcs'],dataScaleSizeL,TEXT);        
            % writeFCS([resultsDir,'/',pipeline_data.named_objects,'_dataTrans_',point_folder,'.fcs'],dataTransL,TEXT);
            % writeFCS([resultsDir,'/',pipeline_data.named_objects,'_dataScaleSizeTrans_',point_folder,'.fcs'],dataScaleSizeTransL,TEXT);
        writeFCS([resultsDir,'/',pipeline_data.named_objects,'_dataScaleSizeMultiply_',point_folder,'.fcs'],dataScaleSizeL,TEXT);     
    
end