function [counts, labels, tags, runinfo] = sortByMass(counts, labels, tags, path)
    % we have two basic conditions. EITHER we have data from Leeat's
    % scripts, OR we have data from the IonPath extractor.
    % we have data from the IonPath extractor
    if exist('tags{1}.PageName')
        try
            masses = double(size(tags));
            for i=1:numel(tags)
                % we could also here try to pull the mass from the
                % ImageDescription json string, but for now we're going to
                % use the PageName tag becuase it's a little easier.
                pagename = strsplit(tags{i}.PageName, ' (');
                mass = pagename{end};
                masses(i) = str2double(strrep(mass, ')', ''));
            end
            
            [~, idx] = sort(masses);
            masses = masses(idx);
        catch e
            error(e)
        end
    else % we have data from Leeat's extractor, so assume path is usefull
        [folder, ~, ~] = fileparts(path); % remember that path should be to a POINT folder
        [folder, ~, ~] = fileparts(folder);
        panelPath = [folder, filesep, 'info'];
        csvList = dir(fullfile(panelPath, '*.csv'));
        csvList(find(cellfun(@isHiddenName, {csvList.name}))) = [];
        if numel(csvList)==1
            filepath = [csvList.folder, filesep, csvList.name];
            panel = dataset('File', filepath, 'Delimiter', ',');
        elseif isempty(csvList)
            error(['No CSV file was found inside of ', panelPath]);
        else
            error(['Too many CSV files were found inside of ', panelPath]);
        end
        idx = zeros(size(tags));
        % disp(labels)
        if ~isempty(strmatch('Label', get(panel, 'VarNames')))
            panelLabel = panel.Label;
        elseif ~isempty(strmatch('Target', get(panel, 'VarNames')))
            panelLabel = panel.Target;
        else
            error('no label or target info in this panel');
        end
        for i=1:numel(labels)
            id = find(strcmp(labels, panelLabel{i}));
            % disp(['{',num2str(id),'} ', labels{i}])
            if numel(id)~=1
                disp('A label couldn''t be found')
                disp(panelLabel{id})
                disp(panelLabel{i})
                disp(labels')
            end
            idx(i) = id;
        end
%         disp(idx);
%         disp(panelLabel);
%         disp(labels(idx));
%         counts = counts(:,:,idx);
%         labels = labels(idx);
%         tags = tags(idx);
        if ~isempty(strmatch('Mass', get(panel, 'VarNames')))
            masses = panel.Mass;
        elseif ~isempty(strmatch('Isotope', get(panel, 'VarNames')))
            masses = panel.Isotope;
        else
            error('No mass or isotope info in this panel')
        end
    end
    
    try
        counts = counts(:,:,idx);
    catch
        % do nothing
    end
    labels = labels(idx);
    tags = tags(idx);
    
    runinfo = struct();
    runinfo.masses = masses;
    [~, runinfo.panelname, ~] = fileparts(csvList.name);
end

