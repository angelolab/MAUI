function [pointnumber, dirindex] = getNumber(point_path, point)
    dirs = strsplit(point_path, {'\', '/'});
    hasPoint = ~cellfun('isempty', strfind(dirs, point));
    dirindex = find(hasPoint);
    if numel(dirindex)==1
        pointname = dirs{dirindex};
        pointnumstr = strrep(pointname, point, '');
        try
            pointnumber = str2double(pointnumstr);
        catch
            error(['Invalid point number "', pointnumstr, '"']);
        end
        if isnan(pointnumber) || isinf(pointnumber) || pointnumber<1
            error(['Invalid point number "', pointnumstr, '"']);
        end
    elseif numel(dirindex)==0
        error(['"', point, '" not found in given path']);
    else %numel(dirindex)>1
        error(['Path name is ambiguous, more than one level contains the string "', point, '"']);
    end
end

