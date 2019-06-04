classdef variable_ui < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        var_name
        var_value
        var_range
        
        var_label
        var_slider
        var_valEdit
        var_rangeEdit
    end
    
    methods
        function obj = variable_ui(control_panel, position, name, varRange, onChangeFunction)
            obj.var_name = name;
            obj.var_range = varRange;
            obj.var_value = varRange(1);
            str = ['[', char(strjoin(string(varRange), ', ')), ']'];
            
            obj.var_label = uicontrol(control_panel, 'style', 'text', 'units', 'normalized', 'position', [0, 1-position/10, .1, .1], 'string', name);
            obj.var_slider = uicontrol(control_panel, 'style', 'slider', 'units', 'normalized', 'position', [.1, 1-position/10, .7, .1], 'callback', {@obj.slider_callback, onChangeFunction}, 'min', varRange(1), 'max', varRange(2), 'value', obj.var_value);
            obj.var_rangeEdit = uicontrol(control_panel, 'style', 'edit', 'units', 'normalized', 'position', [0.9, 1-position/10+0.05, .1, .05], 'string', str, 'callback', {@obj.rangeEdit_callback, onChangeFunction});
            obj.var_valEdit = uicontrol(control_panel, 'style', 'edit', 'units', 'normalized', 'position', [0.8, 1-position/10+0.05, .1, .05], 'string', obj.var_value, 'callback', {@obj.valueEdit_callback, onChangeFunction});
        end
        
        function slider_callback(obj, src, evt, func)
            obj.var_value = get(src, 'value');
            
            set(obj.var_valEdit, 'string', obj.var_value);
            func{1}(func{2});
        end
        
        function rangeEdit_callback(obj, src, evt, func)
            str = get(src, 'string');
            str = strsplit(str(2:(end-1)), ', ');
            obj.var_range = str2double(str);
            
            if obj.var_value < obj.var_range(1)
                obj.var_value = obj.var_range(1);
            end
            if obj.var_value > obj.var_range(2)
                obj.var_value = obj.var_range(2);
            end
            
            set(obj.var_slider, 'value', obj.var_value);
            set(obj.var_slider, 'min', obj.var_range(1));
            set(obj.var_slider, 'max', obj.var_range(2));
            
            set(obj.var_valEdit, 'string', obj.var_value);
            
            func{1}(func{2});
        end
        
        function valueEdit_callback(obj, src, evt, func)
            str = get(src, 'string');
            obj.var_value = str2double(str);
            
            if obj.var_value < obj.var_range(1)
                obj.var_range(1) = obj.var_value;
            end
            if obj.var_value > obj.var_range(2)
                obj.var_range(2) = obj.var_value;
            end
            
            set(obj.var_slider, 'value', obj.var_value);
            set(obj.var_slider, 'min', obj.var_range(1));
            set(obj.var_slider, 'max', obj.var_range(2));
            
            str = ['[', char(strjoin(string(obj.var_range), ', ')), ']'];
            set(obj.var_rangeEdit, 'string', str);
            
            func{1}(func{2});
        end
    end
end