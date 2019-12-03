%% Options
s_width = 14;
s_height = 14;
p_size = 512;
num_markers = 47;
num_points = s_width * s_height;
folder = '/Volumes/ALEX G-DRIVE USB/bangelo_data/Alex_brain_cohort/';

%% Load data
points = {};

for i=1:num_points
    disp(i);
    [counts, labels, tags, path_ext, runinfo] = loadTIFF_data([folder, 'no_background/Point', num2str(i)], 'TIFs');
    point = struct();
    point.counts = counts;
    point.labels = labels;
    point.tags = tags;
    point.path_ext = path_ext;
    point.runinfo = runinfo;
    
    points{end+1} = point;
end

%% Estimate gradients
pointmap = zeros(s_height,s_width);
pointnums = num_points:-1:1;
point_index = 1;
for i=1:s_height
    if mod(i,2)==1
        for j=1:s_width
            pointmap(i,j) = pointnums(point_index);
            point_index = point_index + 1;
        end
    else
        for j=s_width:-1:1
            pointmap(i,j) = pointnums(point_index);
            point_index = point_index + 1;
        end
    end
end

ignore_points = [1,2,28,7,29,56,57,84,85,17,17,140,141,142,168,167,169,170,171,76,75,74,73,72];
more_to_ignore = [162,75,72,71,74,93,76,94,75,48,79];
ignore_points = [ignore_points, more_to_ignore];

masks_channel = cell(size(points{end}.labels));

% odd_mask = zeros(size(points{end}.counts));
% even_mask = zeros(size(points{end}.counts));

for midx = 1:numel(points{end}.labels)
    masks_channel{midx} = struct();
    art_odd = 0; odd_count = 0;
    art_even = 0; even_count = 0;
    for i=1:s_height
        for j=1:s_width
            point_num = pointmap(i,j);
            dat = points{point_num}.counts(:,:,midx);
            % regdat = dat / mean(dat(:));
            if mod(i,2)==1
                if ~any(point_num==ignore_points)
                    art_odd = art_odd + dat;
                    odd_count = odd_count + 1;
                end
            else
                if ~any(point_num==ignore_points)
                    art_even = art_even + dat;
                    even_count = even_count + 1;
                end
            end
        end
    end
    
    art_odd = art_odd / odd_count;
    art_even = art_even / even_count;
    masks_channel{midx}.art_odd = grad_filt(art_odd);
    masks_channel{midx}.art_even = grad_filt(art_even);
    
    disp(['Gradient # ', num2str(midx), ' constructed']);
    % odd_mask(:,:,midx) = masks_channel{midx}.art_odd;
    % even_mask(:,:,midx) = masks_channel{midx}.art_even;
end

%% Correct gradiens
for i=1:s_height
    for j=1:s_width
        point_num = pointmap(i,j);
        new_counts = zeros(size(points{point_num}.counts));
        
        for midx=1:numel(labels)
            dat = points{point_num}.counts(:,:,midx);

            if mod(i,2)==1
                art_data = masks_channel{midx}.art_odd;
            else
                art_data = masks_channel{midx}.art_even;
            end

            dat_mean = mean(dat(:));
            new_dat = dat ./ art_data;
            new_dat(isinf(new_dat)) = 0;
            new_dat(isnan(new_dat)) = 0;
            new_dat = new_dat / mean(new_dat(:)) * dat_mean;
            
            new_counts(:,:,midx) = vimgaussfilt(new_dat,4);
        end
        points{point_num}.new_counts = new_counts;
        
        point = points{point_num};
        
        tiff_folder_path = [folder, 'corrected/Point', num2str(point_num), '/TIFs'];
        saveTIFF_folder(round(256*point.new_counts),point.labels,point.tags,tiff_folder_path,16);
        
        disp(['Point ', num2str(point_num), ' corrected']);
    end
end

disp([newline, 'Finished correcting points. Have a good day!']);