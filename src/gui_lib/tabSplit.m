% this function is going to interpret single spaces as regular spaces, and
% anything larger (2 or more) consecutive spaces as 'tab'
function [clean_string] = tabSplit(string_to_split)
    % then we'll remove any trailing spaces
    trailing_space_idx = regexp(string_to_split, '[ \t]+$');
    if ~isempty(trailing_space_idx)
        string_to_split(trailing_space_idx:end) = [];
    end
    
    % now we find the starting and ending indexes of 'tabs'
    start_idxs = regexp(string_to_split, '[^ ][ ]{2,}');
    end_idxs = regexp(string_to_split, '[ ]{2}[^ ]')+2;
    leading_idx = regexp(string_to_split, '^[ ]{1,}[^ ]', 'once');
    if ~isempty(leading_idx)
        leading_idx = 1:(end_idxs(1)-1);
        end_idxs(1) = [];
    end
    
    for i=numel(start_idxs):-1:1
        string_to_split = insert(string_to_split,start_idxs(i),end_idxs(i),char(8197));
    end
    
    % check if there is leading white space and remove it
    if ~isempty(leading_idx)
        string_to_split(leading_idx) = [];
    end
    
    clean_string = strsplit(string_to_split,char(8197));
end