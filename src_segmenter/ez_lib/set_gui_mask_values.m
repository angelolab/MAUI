function set_gui_mask_values(src, slider_handle, text_handle, min, value, max)

    if strcmp(src, 'range')
        if value > max; value = max; end
        if value < min; value = min; end
    elseif strcmp(src, 'slide')
        %pass
    elseif strcmp(src, 'text')
        if value > max; max = value; end
        if value < min; min = value; end
    end
    
    set(slider_handle, 'min', min)
    set(slider_handle, 'max', max)
    set(slider_handle, 'value', value)
    set(text_handle, 'string', value)
end