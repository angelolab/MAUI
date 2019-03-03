classdef hstruct < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        str
    end
    
    methods
        function obj = hstruct(varargin)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            if numel(varargin)==0
                obj.str = struct();
            else
                obj.str = varargin{1};
            end
        end
        
        function data = get(obj, param)
            data = getfield(obj.str, param);
        end
        
        function obj = set(obj, param, val)
            obj = setfield(obj.str, param, val);
        end
    end
end

