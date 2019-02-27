function [] = MIBIevaluateBackgroundParameters(points)
    global pipeline_data;
    
    for i=1:numel(points)
        point = pipeline_data.points.get('name', points{i});
        countsAllSFiltCRSum = point.counts;
        labels = point.labels;
        
        bgChannel = pipeline_data.bgChannel;
        evalChannelInd = pipeline_data.evalChannelInd;
        params = pipeline_data.points.getBgRmParam(evalChannelInd);
        evalChannel = params.label;
        % removeVal = params.rm_value;
        capEvalChannel = pipeline_data.capEvalChannel;
        capBgChannel = pipeline_data.capBgChannel;
        t = pipeline_data.t;
        gausRad = pipeline_data.gausRad;
        
        removeVals = pipeline_data.points.getRemoveVals();
        [~,bgChannelInd] = ismember(bgChannel, labels);
        mask = MIBI_get_mask(countsAllSFiltCRSum(:,:,bgChannelInd),capBgChannel,t,gausRad,0);
        countsNoBg = gui_MibiRemoveBackgroundByMaskAllChannels(countsAllSFiltCRSum,mask,removeVals);
        
        point_name = points{i};
        point_name = strrep(point_name, '_', '\_');
        
        img1 = gui_MibiPlotDataAndCap(countsAllSFiltCRSum(:,:,evalChannelInd),capEvalChannel,[point_name, newline, evalChannel , ' - before'], 'Before'); plotbrowser on;
        img2 = gui_MibiPlotDataAndCap(countsNoBg(:,:,evalChannelInd),capEvalChannel,[point_name, newline, evalChannel , ' - Params ', pipeline_data.all_param_TITLEstring, ' - after'], 'After'); plotbrowser on;
        linkaxes([img1, img2]);
    end
end

