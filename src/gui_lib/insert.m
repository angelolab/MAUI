function [array3] = insert(array1,index1,index2,array2)
    array3 = [array1(1:index1), array2, array1(index2:end)];
end

