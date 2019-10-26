% calculate the mask and stats (i.e. objects) in the image based upon set
% blur, threshold, and minimum values.
function [mask, stats] = calc_mask(point, pipeline_data)
    
    counts = point.counts;
    
    mask_channel_index = find(strcmp(pipeline_data.mask_channel, pipeline_data.points.labels()));
    mask_src = counts(:,:,mask_channel_index);
    
    % can use in this script later on to determine scaling factors for data representation
    scale = 1;
    mask_src = mask_src*scale;
    mask_values = pipeline_data.points.getEZ_SegmentParams();
    
    % gaussian blur around pixels
    if mask_values.blur~=0
        mask_src = imgaussfilt(mask_src, mask_values.blur);
    end
    
    % binarize the image values based upon the threshold chosen by the user (or automated approach - future implementation)
    % mask values are returned
    mask = imbinarize(mask_src, mask_values.threshold); hold on;
    % determine objects by binding them together with regionprops - KEY
    % STEP - uses the bw(binary) mask as input and returns matrix with
    % area, pixelIds, other attributes if desired
    stats = regionprops(mask, 'Area', 'PixelIdxList');
    [tmp, idxs] = sort(cell2mat({stats.Area}), 'descend');
    % stats objects are returned
    stats = stats(idxs);
    
    % remove objects with a pixel count less than the input minimum value
    % or greater than input maximum value
    rm_obj_idxs = find([stats.Area] < mask_values.minimum | [stats.Area] > mask_values.maximum);
    rm_pxl_idxs = [];
    % concatenate all objects to be removed and set their pixels in mask =
    % 0. Return objects (i.e. stats) and masks
    for index = rm_obj_idxs
        rm_pxl_idxs = cat(1, rm_pxl_idxs, stats(index).PixelIdxList);
    end
    mask(rm_pxl_idxs) = 0;
    stats(rm_obj_idxs) = [];