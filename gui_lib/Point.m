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
    end
    
    methods
        function obj = Point(point_path, len)
            % note: it is assumed that the order of counts will correspond
            % to the labels.
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
        
        function save_ionpath(obj, varargin)
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
            saveTIFF_multi(obj.counts, obj.labels, obj.tags, new_path);
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
        
        function set_intrachannel_info(obj)
            any(~obj.check_image_desc());
            for i=1:numel(obj.labels)
                imgdsc = ImageDescription(obj.tags{i}.ImageDescription);
                imgdsc.decode();
                if isempty(imgdsc.dict('channel.mass'))
                    imgdsc.dict('channel.mass') = num2str(obj.runinfo.masses(i));
                end
                if isempty(imgdsc.dict('channel.target'))
                    imgdsc.dict('channel.target') = ['"', obj.labels{i}, '"'];
                end
                if isempty(imgdsc.dict('shape'))
                    imgdsc.dict('shape') = ['[', num2str(size(obj.counts(:,:,i),1)), ', ', num2str(size(obj.counts(:,:,i),2)), ']'];
                end
                
                imgdsc.encode();
                obj.tags{i}.ImageDescription = imgdsc.descstr;
            end
        end
        
        function set_interchannel_info(obj, field, val, varargin)
            any(~obj.check_image_desc());
            for i=1:numel(obj.tags)
                imgdsc = ImageDescription(obj.tags{i}.ImageDescription);
                imgdsc.decode();
                if strcmp(class(val),('char'))
                    if ~(val(1)=='"' || val(end)=='"')
                        val = ['"',val,'"'];
                    end
                end
                if numel(varargin)==1 && strcmp(varargin{1}, 'override')
                    imgdsc.dict(field) = val;
                elseif isempty(imgdsc.dict(field))
                    imgdsc.dict(field) = val;
                end
                
                imgdsc.encode();
                obj.tags{i}.ImageDescription = imgdsc.descstr;
            end
        end
        
        function set_intrapoint_info(obj, varargin)
            any(~obj.check_image_desc());
            % we first check that the point number of Point checks out with
            % its runxml struct
            nameNumber = getNumber(obj.name, 'Point');
            fileNumber = getNumber(obj.point_path, 'Point');
            if nameNumber==fileNumber % this should never fail
                pointObj = obj.runinfo.runxml.DocRoot.Root.Point{nameNumber};
                xmlNumber = getNumber(pointObj.Depth_Profile.Attributes.FileName, 'Point');
                if nameNumber==xmlNumber
                    % now we can (relatively) safely set some fields
                    obj.set_interchannel_info('mibi.run', obj.runinfo.runxml.xmlname, varargin{:});
                    obj.set_interchannel_info('mibi.dwell', pointObj.Depth_Profile.Attributes.AcquisitionTime, varargin{:});
                    obj.set_interchannel_info('mibi.description', pointObj.Attributes.PointName, varargin{:});
                    obj.set_interchannel_info('mibi.folder', ['Point', num2str(nameNumber), '/RowNumber0/Depth_Profile0'], varargin{:}); % this is valid (wierdly)
                    obj.set_interchannel_info('mibi.panel', obj.runinfo.panelname, varargin{:});
                    obj.set_interchannel_info('mibi.mass_offset', pointObj.Depth_Profile.Attributes.MassOffset, varargin{:});
                    obj.set_interchannel_info('mibi.mass_gain', pointObj.Depth_Profile.Attributes.MassGain, varargin{:});
                    obj.set_interchannel_info('mibi.time_resolution', pointObj.Depth_Profile.Attributes.TimeResolution, varargin{:});
                    obj.set_interchannel_info('mibi.filename', obj.runinfo.runxml.xmlname, varargin{:});
                    obj.set_interchannel_info('image.type', 'SIMS', varargin{:});
                    
                    obj.set_interchannel_info('mibi.version', 'Alpha', varargin{:});
                    obj.set_interchannel_info('mibi.instrument', 'Apollo', varargin{:});
                    obj.set_interchannel_info('mibi.miscalibrated', 'false', varargin{:});
                    obj.set_interchannel_info('mibi.check_reg', 'false', varargin{:});
                else
                    error('Run xml number and point number do not match');
                end
            else
                error('You should never be allowed to organize any directory ever');
            end
            % obj.set_interchannel_info('mibi.dwell') = pointinfo.Depth_Profile.Attributes.AcquisitionTime;
%             obj.set_interchannel_info('mibi.description'
%             obj.set_interchannel_info(
        end
        
        function set_default_info(obj, varargin)
            obj.set_intrachannel_info();
            obj.set_intrapoint_info(varargin{:});
        end
        
        function run_name = getRunName(obj)
            run_name = obj.runinfo.runxml.xmlname;
        end
    end
end

