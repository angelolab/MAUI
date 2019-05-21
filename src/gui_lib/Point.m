classdef Point < handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        point_path
        path_ext
        counts
        labels
        tags
        runinfo
        % for denoising
        int_norm_d
        k_values
        count_hist
        status
        loaded
        number
        % for titration
        t_figure
        figure_state = [-1, 0, -1]; % [channel_index, presence of histogram, cap_value]
    end
    
    methods
        function obj = Point(point_path, len)
            % note: it is assumed that the order of counts will correspond
            % to the labels.
            obj.t_figure = NaN;
            obj.point_path = point_path;
            [obj.counts, obj.labels, obj.tags, obj.path_ext, obj.runinfo] = loadTIFF_data(point_path);
            
            sizes = [numel(obj.labels), numel(obj.tags), numel(obj.runinfo.masses), size(obj.counts,3)];
            try
                assert(all(sizes==sizes(1)));
            catch
                disp(['obj.labels: ', num2str(numel(obj.labels))]);
                disp(['obj.tags: ', num2str(numel(obj.tags))]);
                disp(['obj.masses: ', num2str(numel(obj.runinfo.masses))]);
                disp(['obj.counts: ', num2str(size(obj.counts,3))]);
            end
            [path, name, ~] = fileparts(point_path);
            name = [path, filesep, name];
            name = strsplit(name, filesep);
            try
                name = name((end-len+1):end);
            catch
                % do nothing
            end
            obj.name = strjoin(name, filesep);
            obj.checkAllLabelsUnique();
            
            obj.int_norm_d = containers.Map;
            obj.count_hist = containers.Map;
            obj.k_values = [];
            for i=1:numel(obj.labels)
                obj.k_values(i) = -1;
            end
            obj.status = 0;
            obj.loaded = 0;
        end
        
        function plotTiter(obj, label_index, cap)
            name_parts = strsplit(obj.name, filesep);
            titer_name = name_parts{end};
            try
                if isvalid(obj.t_figure)
                    sfigure(obj.t_figure);
                else
                    obj.t_figure = sfigure();
                    set(obj.t_figure, 'NumberTitle', 'off');
                    set(obj.t_figure, 'name', titer_name);
                end
            catch
                obj.t_figure = sfigure();
                set(obj.t_figure, 'NumberTitle', 'off');
                set(obj.t_figure, 'name', titer_name');
            end
            subplot(2,1,1);
            if label_index~=obj.figure_state(1) || cap~=obj.figure_state(3)
                cappedImage = obj.counts(:,:,label_index);
                cappedImage(cappedImage>cap) = cap;
                imagesc(cappedImage); plotbrowser on;
                obj.figure_state(1) = label_index;
            end
            title(obj.name);
            label = obj.labels{label_index};
            subplot(2,1,2);
            if ~isempty(obj.count_hist) && any(strcmp(obj.count_hist.keys(), label)) && obj.loaded~=0
                hedges = 0:0.25:30;
                hedges = hedges(1:end-1);
                bar(hedges, obj.count_hist(label), 'histc');
                title([strrep(titer_name, '_', '\_'), ' : ', label, ' - histogram']);
            else
                cla;
                title('No histogram');
            end
        end
        
        function check = checkAllLabelsUnique(obj)
            if numel(unique(obj.labels))==numel(obj.labels)
                check = true;
            else
                check = false;
                warning('NOT ALL LABELS ARE UNIQUE')
            end
        end
        
        function obj = knn(obj, label, k_value)
            if ischar(label)
                label_index = find(strcmp(obj.labels, label));
            else
                label_index = label;
            end
            label = obj.labels{label_index};
            if isempty(label_index)
                error([label, ' not found in labels']);
            else
                if k_value~=obj.k_values(label_index)
                    obj.int_norm_d(label) = MIBI_get_int_norm_dist(obj.counts(:,:,label_index), k_value);
                    hedges = 0:0.25:30;
                    obj.count_hist(label) = histcounts(obj.int_norm_d(label), hedges, 'Normalization', 'probability');
                    obj.k_values(label_index) = k_value;
                end
            end
        end
        
        function [int_norm_d, k_val] = get_IntNormD(obj, label)
            try
                int_norm_d = obj.int_norm_d(label);
            catch
                int_norm_d = [];
            end
            label_index = find(strcmp(label, obj.labels));
            k_val = obj.k_values(label_index);
        end
        
        function count_hist = get_countHist(obj, label)
            try
                count_hist = obj.count_hist(label);
            catch
                count_hist = [];
            end
        end
        
        function loadstatus = get_label_loadstatus(obj)
            loadstatus = zeros(size(obj.labels));
            for i=1:numel(obj.labels)
                if ~isequaln(obj.int_norm_d(obj.labels(i)), [])
                    loadstatus(i) = 1;
                end
            end
        end
        
        function obj = flush_all_data(obj)
            for i=1:numel(obj.labels)
                obj.k_values(i) = -1;
                obj.int_norm_d(obj.labels{i}) = [];
                obj.count_hist(obj.labels{i}) = [];
            end
        end
        
        function obj = flush_labels(obj, label_indices)
            for i=label_indices
                obj.k_values(i) = -1;
                obj.int_norm_d(obj.labels{i}) = [];
                obj.count_hist(obj.labels{i}) = [];
            end
        end
        
        function save_no_background(obj)
            global pipeline_data;
            bgChannel = pipeline_data.bgChannel;
            gausRad = pipeline_data.gausRad;
            t = pipeline_data.t;
            % removeVals = pipeline_data.removeVals;
            removeVals = pipeline_data.points.getRemoveVals();
            capBgChannel = pipeline_data.capBgChannel;
            capEvalChannel = pipeline_data.capEvalChannel;
            [~,bgChannelInd] = ismember(bgChannel,obj.labels);
            mask = MIBI_get_mask(obj.counts(:,:,bgChannelInd),capBgChannel,t,gausRad,0,'');
            countsNoBg = gui_MibiRemoveBackgroundByMaskAllChannels(obj.counts,mask,removeVals);
            
            [dir, pointname, ~] = fileparts(obj.point_path);
            point_path = [dir, filesep, pointname];
            path_parts = strsplit(point_path, filesep);
            path_parts{end-1} = 'no_background';
            new_path = strjoin(path_parts, filesep);
            if ~isempty(obj.path_ext)
                disp(['Saving to ', new_path, filesep, obj.path_ext])
                saveTIFF_folder(countsNoBg, obj.labels, obj.tags, [new_path, filesep, obj.path_ext]);
                save([new_path, filesep, 'dataNoBg.mat'],'countsNoBg');
            else
                disp(['Saving to ', new_path])
                saveTIFF_folder(countsNoBg, obj.labels, obj.tags, new_path);
                save([new_path, filesep, 'dataNoBg.mat'],'countsNoBg');
            end
        end
        
        function save_no_noise(obj)
            global pipeline_data;
            IntNormDData = cell(size(obj.labels));
            noiseT = zeros(size(obj.labels));
            for i=1:numel(obj.labels)
                try
                    IntNormDData{i} = obj.int_norm_d(obj.labels{i});
                catch
                    IntNormDData{i} = [];
                end
                noiseT(i) = pipeline_data.points.getDenoiseParam(i).threshold;
            end
            countsNoNoise = gui_MibiFilterAllByNN(obj.counts,IntNormDData,noiseT);
            
            [dir, pointname, ~] = fileparts(obj.point_path);
            point_path = [dir, filesep, pointname];
            path_parts = strsplit(point_path, filesep);
            path_parts{end-1} = 'no_noise';
            new_path = strjoin(path_parts, filesep);
            
            if ~isempty(obj.path_ext)
                disp(['Saving to ', new_path, filesep, obj.path_ext])
                saveTIFF_folder(countsNoNoise, obj.labels, obj.tags, [new_path, filesep, obj.path_ext]);
                save([new_path, filesep, 'dataNoNoise.mat'],'countsNoNoise');
            else
                disp(['Saving to ', new_path])
                saveTIFF_folder(countsNoNoise, obj.labels, obj.tags, new_path);
                save([new_path, filesep, 'dataNoNoise.mat'],'countsNoNoise');
            end
        end
        
        function save_no_aggregates(obj)
            global pipeline_data;
            countsNoAgg = zeros(size(obj.counts));
            for i=1:numel(obj.labels)
                params = pipeline_data.points.getAggRmParam(i);
                threshold = params.threshold;
                radius = params.radius;
                if radius==0
                    gausFlag = 0;
                else
                    gausFlag = 1;
                end
                countsNoAgg(:,:,i) = gui_MibiFilterAggregates(obj.counts(:,:,i),radius,threshold,gausFlag);
            end
            
            [dir, pointname, ~] = fileparts(obj.point_path);
            point_path = [dir, filesep, pointname];
            path_parts = strsplit(point_path, filesep);
            path_parts{end-1} = 'no_aggregates';
            new_path = strjoin(path_parts, filesep);
            
            if ~isempty(obj.path_ext)
                disp(['Saving to ', new_path, filesep, obj.path_ext])
                saveTIFF_folder(countsNoAgg, obj.labels, obj.tags, [new_path, filesep, obj.path_ext]);
                save([new_path, filesep, 'dataNoAgg.mat'],'countsNoAgg');
            else
                disp(['Saving to ', new_path])
                saveTIFF_folder(countsNoAgg, obj.labels, obj.tags, new_path);
                save([new_path, filesep, 'dataNoAgg.mat'],'countsNoAgg');
            end
        end
        
        function save_no_fftnoise(obj)
            global pipeline_data;
            countsNoNoise = zeros(size(obj.counts));
            for i=1:numel(obj.labels)
                params = pipeline_data.points.getFFTRmParam(i);
                gauss_blur_radius = params.blur;
                spectral_radius = params.radius;
                scaling_factor = params.scale;
                countsNoNoise(:,:,i) = gui_FFTfilter(obj.counts(:,:,i), gauss_blur_radius, spectral_radius, scaling_factor);
            end
            
            [dir, pointname, ~] = fileparts(obj.point_path);
            point_path = [dir, filesep, pointname];
            path_parts = strsplit(point_path, filesep);
            path_parts{end-1} = 'no_fftnoise';
            new_path = strjoin(path_parts, filesep);
            
            if ~isempty(obj.path_ext)
                disp(['Saving to ', new_path, filesep, obj.path_ext])
                saveTIFF_folder(countsNoNoise, obj.labels, obj.tags, [new_path, filesep, obj.path_ext]);
                save([new_path, filesep, 'dataNoFFTNoise.mat'],'countsNoNoise');
            else
                disp(['Saving to ', new_path])
                saveTIFF_folder(countsNoNoise, obj.labels, obj.tags, new_path);
                save([new_path, filesep, 'dataNoFFTNoise.mat'],'countsNoNoise');
            end
        end
        
        function new_path = save_ionpath(obj, run_object, varargin)
            [dir, pointname, ~] = fileparts(obj.point_path);
            path_parts = strsplit([dir, filesep, pointname], filesep);
            path_parts{end-1} = 'ionpath_multitiff';
            if numel(varargin)==1
                path_parts{end-1} = varargin{1};
            end
            new_path = strjoin(path_parts, filesep);
            disp(['Saving to ', new_path]);
            [path_to_multitiff, ~, ~] = fileparts(new_path);
            rmkdir(path_to_multitiff);
            obj.fixTags(run_object);
            saveTIFF_multi(obj.counts, obj.labels, obj.tags, new_path);
        end
        
        function add_composites(obj, new_name, new_counts, new_label_index, new_tags)
            %add name of new channel to labels, counts to counts, and tags
            obj.labels(new_label_index) = cellstr(new_name);
            obj.counts(:,:,new_label_index) = new_counts;
            obj.tags(new_label_index) = new_tags(1);
        end
        
        % There are a couple of steps we should follow in as ordered a
        % manner as possible
        % 1) we need to find the correct runobject from the tracker
        % 2) we need to create an ImageDescription tag if it doesn't
        % already exist
        % 3) we need to fill the ImageDescription object with the correct
        % point-specific information
        % we need to fill the ImageDescription object with the correct
        % channel-specific information
        % we need to modify the tags objects with the correct information

        function imgdsc = get_ImageDescription(obj, index, run_object, pointObj)
            % first check if there is already an ImageDescription
            if isfield(obj.tags{index}, 'ImageDescription')
                % if there is, we simply return it
                imgdsc = ImageDescription(obj.tags{index}.ImageDescription);
            else
                % otherwise we create a new ImageDescription
                imgdsc = ImageDescription();
                imgdsc.dict('mibi.run') = obj.runinfo.runxml.xmlname;
                imgdsc.dict('mibi.dwell') = pointObj.Depth_Profile.Attributes.AcquisitionTime;
                imgdsc.dict('mibi.description') = pointObj.Attributes.PointName;
                imgdsc.dict('mibi.folder') = ['Point', num2str(obj.number), '/RowNumber0/Depth_Profile0'];
                imgdsc.dict('mibi.panel') = obj.runinfo.panelname;
                imgdsc.dict('mibi.mass_offset') = pointObj.Depth_Profile.Attributes.MassOffset;
                imgdsc.dict('mibi.mass_gain') = pointObj.Depth_Profile.Attributes.MassGain;
                imgdsc.dict('mibi.time_resolution') = pointObj.Depth_Profile.Attributes.TimeResolution;
                imgdsc.dict('mibi.filename') = obj.runinfo.runxml.xmlname;
                imgdsc.dict('image.type') = 'SIMS';
                imgdsc.dict('mibi.version') = 'Alpha';
                imgdsc.dict('mibi.instrument') = run_object.instrument.name;
                imgdsc.dict('mibi.miscalibrated') = 'false';
                imgdsc.dict('mibi.check_reg') = 'false';
                imgdsc.dict('channel.mass') = num2str(obj.runinfo.masses(index));
                imgdsc.dict('channel.target') = ['"', obj.labels{index}, '"'];
                imgdsc.dict('shape') = ['[', num2str(size(obj.counts(:,:,index),1)), ', ', num2str(size(obj.counts(:,:,index),2)), ']'];
                imgdsc.encode();
            end
        end
        
        function fixTags(obj, run_object)
            nameNumber = getNumber(obj.name, 'Point');
            obj.number = nameNumber;
            fileNumber = getNumber(obj.point_path, 'Point');
            point_xml = obj.runinfo.runxml.DocRoot.Root.Point{nameNumber};
            xmlNumber = getNumber(point_xml.Depth_Profile.Attributes.FileName, 'Point');
            if nameNumber~=fileNumber || fileNumber~=xmlNumber
                disp([nameNumber, fileNumber, xmlNumber]);
                error('Point numbers are inconsistent');
            end
            for i=1:numel(obj.tags)
                % first we're going to create the ImageDescription object
                imgdsc = obj.get_ImageDescription(i, run_object, point_xml);
                obj.tags{i}.ImageDescription = imgdsc.descstr;
                
                obj.tags{i}.PageName = obj.labels{i};
                obj.tags{i}.Compression = Tiff.Compression.Deflate;
                obj.tags{i}.Software = 'IonpathMIBIv0.1';
                % I think this is causing problems
                % str2double(point_xml.RowNumber0.Attributes.XAttrib)
                % str2double(point_xml.RowNumber0.Attributes.YAttrib)
                obj.tags{i}.XPosition = abs(str2double(point_xml.RowNumber0.Attributes.XAttrib));
                obj.tags{i}.YPosition = abs(str2double(point_xml.RowNumber0.Attributes.YAttrib));
                obj.tags{i}.DateTime = obj.runinfo.runxml.DocRoot.Root.Attributes.RunTime;
                
                fov = run_object.magnification;
                pixels = size(obj.counts(:,:,i),1);
                resolution = pixels/fov*10000; % converts to centimeters
                obj.tags{i}.ResolutionUnit = 3; % resolution is in pixels/cm
                obj.tags{i}.XResolution = resolution;
                obj.tags{i}.YResolution = resolution;
            end
        end
        
        % image description manipulation functions
        function run_name = check_run(obj)
            runs = {};
            for i=1:numel(obj.tags)
                imgdsc = ImageDescription(obj.tags{i}.ImageDescription);
                imgdsc.decode();
                runs{i} = imgdsc.dict('mibi.run');
            end
            if all(cellfun(@(x) strcmp(x, runs{1}), runs))
                run_name = runs{1};
            else
                run_name = runs;
            end
        end
        
        function isthere = check_image_desc(obj)
            isthere = zeros(size(obj.labels));
            for i=1:numel(obj.labels)
                isthere(i) = isfield(obj.tags{i}, 'ImageDescription');
                if ~isthere(i)
                    imgdsc = ImageDescription();
                    imgdsc.encode();
                    obj.tags{i}.ImageDescription = imgdsc.descstr;
                end
            end
        end
        
        function run_name = getRunName(obj)
            run_name = obj.runinfo.runxml.xmlname;
        end
    end
end

