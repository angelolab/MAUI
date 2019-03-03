classdef ImageDescription < handle
    properties
        descstr
        dict;
        keys;
    end
    
    methods
        function obj = ImageDescription(varargin)
            if numel(varargin)==1
                obj.descstr = varargin{1};
            elseif numel(varargin)==0
                obj.keys = {
                    'mibi.run',...
                    'mibi.version',...
                    'mibi.instrument',...
                    'mibi.dwell',...
                    'mibi.description',...
                    'mibi.folder',...
                    'mibi.panel',...
                    'mibi.mass_offset',...
                    'mibi.mass_gain',...
                    'mibi.time_resolution',...
                    'mibi.miscalibrated',...
                    'mibi.check_reg',...
                    'mibi.filename',...
                    'image.type',...
                    'channel.mass',...
                    'channel.target',...
                    'shape'};
                obj.dict = containers.Map;
                for i=1:numel(obj.keys)
                    obj.dict(obj.keys{i}) = '';
                end
            end
        end
        
        
        
        function obj = decode(obj)
            temp = obj.descstr;
            temp = strrep(temp, '{', '');
            temp = strrep(temp, '}', '');
            temp = strrep(temp, ': ', ':');
            temp = strsplit(temp, ', "');
            for i=1:numel(temp)
                temp{i} = strsplit(temp{i}, ':');
                temp{i}{1} = strrep(temp{i}{1}, '"', '');
            end

            data = struct();
            data.dict = containers.Map;
            data.keys = {};
            for i=1:numel(temp)
                data.dict(temp{i}{1}) = temp{i}{2};
                data.keys{i} = temp{i}{1};
            end
            obj.dict = data.dict;
            obj.keys = data.keys';
        end
        
        function obj = encode(obj)
            data = struct;
            data.dict = obj.dict;
            data.keys = obj.keys;
            temp = {};

            for i=1:numel(obj.keys)
                temp{i}{1} = obj.keys{i};
                temp{i}{2} = obj.dict(obj.keys{i});
            end
            for i=1:numel(temp)
                temp{i}{1} = ['"', temp{i}{1}, '"'];
                temp{i} = strjoin(temp{i}, ':');
            end
            temp = strjoin(temp, ', ');
            temp = strrep(temp, ':', ': ');
            temp = ['{', temp, '}'];
            obj.descstr = temp;
        end
        
        function print(obj)
            for i=1:numel(obj.keys)
                disp(tabJoin({obj.keys{i}, obj.dict(obj.keys{i})}, 25))
            end
        end
    end
end

