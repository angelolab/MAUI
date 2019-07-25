function [x] = imtranslatetrail(x, offset)
    x = imtt(x, [offset(1),0]);
    x = imtt(x, [0,offset(2)]);
end


function [y] = imtt(x, offset)
    y = imtranslate(x, offset, 'FillValue', NaN);
    
    if offset(1)>0
        y(:,1:offset(1)) = repmat(x(:,1),1,abs(offset(1)));
    elseif offset(1)<0
        y(:,(end+offset(1)+1):end) = repmat(x(:,end),1,abs(offset(1)));
    else
        % do nothing
    end

    if offset(2)>0
        y(1:offset(2),:) = repmat(x(1,:),abs(offset(2)),1);
    elseif offset(2)<0
        y((end+offset(2)+1):end,:) = repmat(x(end,:),abs(offset(2)),1);
    else
        % do nothing
    end
end