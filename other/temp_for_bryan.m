fig = figure();
some_labels = {'immunology stuff', 'cells are hard', 'what are these names', 'why are there so many molecules'};

global listbox;
listbox = uicontrol(fig, 'style', 'listbox', 'units', 'normalized', 'position', [0, 0, .5, .5], 'string', some_labels, 'max', 3, 'callback', @bryan_callback);

brybutt = uicontrol(fig, 'style', 'pushbutton', 'units', 'normalized', 'position', [0, 0, .1, .1], 'string', 'brybutt', 'max', 3, 'callback', @brybutt_callback);

function bryan_callback(varargin)  
    
end

function brybutt_callback(varargin)
    global listbox;    
    disp(listbox.Value)
    
end

