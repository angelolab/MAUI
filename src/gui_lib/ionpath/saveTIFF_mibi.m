function saveTIFF_mibi(opts)
    fields = fieldnames(opts);
    argstring = '';
    for i=1:numel(fields)
        field = fields{i};
        arg = num2str(opts.(field));
        if isnan(str2double(arg))
            if contains(arg, ' ')
                arg = ['"', arg, '"'];
            end
        else
            arg = num2str(arg);
        end
        if isempty(arg)
            arg = 'None';
        end
        argstring = [argstring, ' ', field, ' ', arg];
    end
    [mpath, ~, ~] = fileparts(mfilename('fullpath'));
    mpath = [mpath, filesep, 'mergetiffs', filesep, 'mergetiffs'];
    cmd = [mpath, argstring];
    system(cmd);
%     disp(mpath)
%     mpath = strsplit(mpath, filesep);
%     mpath = strjoin(mpath(1:(end-3)), filesep);
%     spath = [mpath, filesep, 'mibitracker-client', filesep, 'mergetiffs.py'];
    % disp(spath)
%     spath = '/Users/raymondbaranski/GitHub/mibitiff/mibidata/dist/mergetiffs/mergetiffs';
%     cmd = [spath, argstring];
%     system(cmd);
end

