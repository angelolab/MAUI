function printFields(level, obj)
    fields = fieldnames(obj);
    for i=1:numel(fields)
        field = getfield(obj, fields{i});
        try
            if isstruct(field)
                disp([repmat(' ',1,level*3), fields{i}, ': {'])
                printFields(level+1, field)
                disp([repmat(' ',1,level*3), '}']);
            elseif iscell(field)
                disp([repmat(' ',1,level*3), fields{i}, ': ['])
                for j=1:numel(field)
                    printFields(level+1, field{i})
                end
                disp([repmat(' ',1,level*3), ']']);
            else
                if islogical(field)
                    disp([repmat(' ',1,level*3), fields{i}, ': ', char(string(field))])
                else
                    disp([repmat(' ',1,level*3), fields{i}, ': ', field])
                end
            end
        catch
            disp([repmat(' ',1,level*3), fields{i}, ': failed to print'])
        end
    end
end