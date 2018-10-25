clear all; clc;
global shufflegui;

shufflegui.handles.figure1 = figure();
shufflegui.handles.shuffle_box = uicontrol('style', 'edit', 'units', 'normalized', 'position', [.6, .925, .2, .05], 'fontsize', 12, 'callback', @shuffle_box_callback, 'fontname', 'fixedwidth', 'fontweight', 'bold');
shufflegui.handles.shuffle_lab = uicontrol('style', 'text', 'units', 'normalized', 'position', [.5, .925, .1, .05], 'fontsize', 12, 'fontname', 'fixedwidth', 'fontweight', 'bold', 'string', 'Shuffle');
shufflegui.handles.old_dir_box = uicontrol('style', 'listbox', 'units', 'normalized', 'position', [0, 0, .5, .8], 'fontname', 'fixedwidth', 'foregroundcolor', [0,.5,1], 'fontweight', 'bold', 'fontsize', 12);
shufflegui.handles.new_dir_box = uicontrol('style', 'listbox', 'units', 'normalized', 'position', [.5, 0, .5, .8], 'fontname', 'fixedwidth', 'foregroundcolor', [1,.5,0],  'fontweight', 'bold', 'fontsize', 12);
shufflegui.handles.choose_dir_button = uicontrol('style', 'pushbutton', 'units', 'normalized', 'position', [0, .9, .4, .05], 'fontsize', 12, 'fontname', 'fixedwidth', 'callback', @choose_dir_button_callback, 'string', 'Choose data folder');
shufflegui.handles.shuffle_dir_button = uicontrol('style', 'pushbutton', 'units', 'normalized', 'position', [0, .825, .4, .05], 'fontsize', 12, 'fontname', 'fixedwidth', 'callback', @shuffle_dir_button_callback, 'string', 'Shuffle data folder');

shufflegui.handles.shuffle_dir_lab = uicontrol('style', 'text', 'units', 'normalized', 'position', [.45, .825, .55, .1], 'fontsize', 12, 'fontname', 'fixedwidth', 'string', 'no directory selected', 'fontweight', 'bold', 'foregroundcolor', [0,.5,0]);

function tree_string = dir_tree_string(tree)
    tree_string = '';
    for i=1:numel(tree)
        space = repmat('  ',1,i-1);
        for j=1:numel(tree{i})
            if i==numel(tree) %% file
                tree_string = [tree_string, space, char(9642), ' ', tree{i}{j}, newline];
            else
                if j==numel(tree{i}) %% down arrow
                    tree_string = [tree_string, space, char(9660), ' ', tree{i}{j}, newline];
                else %% closed arrow
                    tree_string = [tree_string, space, char(9658), ' ', tree{i}{j}, newline];
                end
            end
        end
    end
end

function choose_dir_button_callback(hObject,eventdata,handles)
    global shufflegui;
    data_dir = uigetdir();
    if data_dir~=0
        shufflegui.data_dir = data_dir;
        set(shufflegui.handles.shuffle_dir_lab, 'string', shufflegui.data_dir);
    end
end

function shuffle_dir_button_callback(hObject,eventdata,handles)
    try
        global shufflegui;
        % Creates all of the directories
        stack_new = shufflegui.stack_new;
        files = shufflegui.files;
        mvfiles = shufflegui.mvfiles;
        waitfig = waitbar(0, 'Creating folders...');
        for i=1:numel(stack_new)
            waitbar(i/numel(stack_new), waitfig, 'Creating folders...');
            rmkdir(stack_new{i});
        end

        % Moves all of the files
        for i=1:numel(files)
            waitbar(i/numel(files), waitfig, 'Moving files...');
            movefile(files{i}, mvfiles{i});
        end
        close(waitfig);

        % Remove the old folders
        % dataPath = strsplit(shufflegui.data_dir, filesep);
        % deleteIndex = numel(dataPath);
        % disp(deleteIndex);
        % for i=1:numel(shufflegui.tree_old{deleteIndex})
        %     rmdir([shufflegui.data_dir, filesep, shufflegui.tree_old{deleteIndex}{i}], 's');
        % end
    catch
        
    end
end

function shuffle_box_callback(hObject,eventdata,handles)
    global shufflegui;
    string = get(hObject, 'String');
    string = replace(string, {'[',']','(',')','{','}',' '}, '');
    string = strsplit(string, ',');
    try
        shuffle = str2double(string);
        data_dir = shufflegui.data_dir;
        dirPath = strsplit(data_dir, filesep); dirPath(1) = [];
        dirLoc = numel(dirPath);
        dirinfo = [dir([data_dir, filesep, '**', filesep, '*.tiff']);...
                   dir([data_dir, filesep, '**', filesep, '*.tif'])];
        folders = {dirinfo.folder};
        names = {dirinfo.name};
        files = cell(size(names));
        mvfiles = cell(size(files));

        files{1} = [folders{1}, filesep, names{1}];
        [path, file, ext] = fileparts(files{1});
        location = strsplit([path, filesep, file], filesep);
        order = 1:(numel(location));
        shuffle = shuffle - numel(shuffle) + numel(location);
        order((end-numel(shuffle)+1):end) = shuffle;
        dirStruct_new = cell(numel(names), numel(location));
        dirStruct_old = cell(numel(names), numel(location));
        
        newDataFolder = [dirPath{end}, '_shuffled']; % there should only be one node at this level
        % newDataFolder = dirPath{end};
        shufflegui.newDataFolder = newDataFolder;
        for i=1:numel(names)
            files{i} = [folders{i}, filesep, names{i}];
            [path, file, ext] = fileparts(files{i});
            location = strsplit([path, filesep, file], filesep);
            dirStruct_old(i, :) = location;
            location{dirLoc+1} = newDataFolder;
            dirStruct_new(i, :) = location(order);
            mvfiles{i} = [strjoin(location(order), filesep), ext];
        end
        dirStruct_new(:,1)=[];
        tree_new = {};
        for i=1:size(dirStruct_new,2)
            tree_new{i} = unique({dirStruct_new{:,i}});
        end
        
        dirStruct_old(:,1)=[];
        tree_old = {};
        for i=1:size(dirStruct_old,2)
            tree_old{i} = unique({dirStruct_old{:,i}});
        end
        
        stack_new = tree_new{end-1};
        for k=(numel(tree_new)-2):-1:1
            new_stack = {};
            cur_root = tree_new{k};
            for i=1:numel(cur_root)
                for j=1:numel(stack_new)
                    new_stack{end+1} = [cur_root{i}, filesep, stack_new{j}];
                end
            end
            stack_new = new_stack;
        end
        stack_old = tree_old{end-1};
        for k=(numel(tree_old)-2):-1:1
            new_stack = {};
            cur_root = tree_old{k};
            for i=1:numel(cur_root)
                for j=1:numel(stack_old)
                    new_stack{end+1} = [cur_root{i}, filesep, stack_old{j}];
                end
            end
            stack_old = new_stack;
        end
        
        shufflegui.tree_old = tree_old;
        shufflegui.tree_new = tree_new;
        shufflegui.stack_new = stack_new;
        shufflegui.stack_old = stack_old;
        shufflegui.files = files;
        shufflegui.mvfiles = mvfiles;
        
        tree_string_old = dir_tree_string(tree_old);
        set(shufflegui.handles.old_dir_box, 'String', tree_string_old);
        set(shufflegui.handles.old_dir_box, 'Value', 1);
        tree_string_new = dir_tree_string(tree_new);
        set(shufflegui.handles.new_dir_box, 'String', tree_string_new);
        set(shufflegui.handles.new_dir_box, 'Value', 1);
    catch
        warning('Invalid shuffle');
        set(shufflegui.handles.old_dir_box, 'String', '');
        set(shufflegui.handles.old_dir_box, 'Value', 1);
        set(shufflegui.handles.new_dir_box, 'String', '');
        set(shufflegui.handles.new_dir_box, 'Value', 1);
    end
end