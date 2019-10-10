%needs to create a .txt log file with any composite info, masks and data
%info, ez_seg_poaram info, and object_class info
function write_log(pipeline_data)
    
    point_paths = keys(pipeline_data.points.pathsToPoints);
    pt_path = point_paths{1};
    
    % save log file with object name, open for editing
    % save([pipeline_data.run_path, filesep, pipeline_data.named_objects, '_log.txt']);
    fid = fopen([pipeline_data.run_path, filesep, pipeline_data.named_objects, '_log.txt'], 'wt');
    
    % write timestamp to log
    timestring = strrep(datestr(datetime('now')), ':', char(720));
    fprintf(fid, ['time: ', timestring, newline]);
    % write point names to log
    fprintf(fid, ['points: ']);
    for pt = string(pipeline_data.points.getNames())
        fprintf(fid, [char(pt), ', ']);
    end
    fprintf(fid, [newline]);
    % write composites named to log
    fprintf(fid, ['composites: ']);
    for comp = keys(pipeline_data.composite_w_individ_channels)
        try
            fprintf(fid, [char(comp), ': ']);
            individ_channels = values(pipeline_data.composite_w_individ_channels, comp);
            for i = 1:numel(individ_channels{1})
                fprintf(fid, [char(individ_channels{1}{i}), ', ']);
            end
            fprintf(fid, '/ ');
        catch
            %issue with array initalization. currently just ignoring
        end
    end
    fprintf(fid, [newline]);
    % write mask, data channels to log
    fprintf(fid, ['view_data: ', char(pipeline_data.data_channel), newline]);
    fprintf(fid, ['view_mask: ', char(pipeline_data.mask_channel), newline]);
    % write mask from values to log with object name
    fprintf(fid, ['named_objects: ', pipeline_data.named_objects, newline]);
    mask_values = pipeline_data.points.getEZ_SegmentParams();
    fprintf(fid, ['blur: ', num2str(mask_values.blur), newline]);
    fprintf(fid, ['threshold: ', num2str(mask_values.threshold), newline]);
    fprintf(fid, ['minimum: ', num2str(mask_values.minimum), newline]);
    fprintf(fid, ['maximum: ', num2str(mask_values.maximum), newline]);
    fprintf(fid, ['image_cap: ', num2str(mask_values.image_cap), newline]);
    %fprintf(fid, ['refine_threshold: ', num2str(mask_values.refine_threshold), newline]);

    fclose(fid);