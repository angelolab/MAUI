function countsNoBg = gui_MibiRemoveBackgroundByMaskAllChannels_3(countsAllSFiltCRSum,mask, removeVals)
% function MibiRemoveBackgroundByMaskAllChannels
% function receives a matrix of counts and a logical 2d-mask, and reduces
% values where mask is positive. The amount of reduction is set by
% removeVal. If it is not provided, the function will zero these regions

mask3d = mask;
disp(size(mask));
countsNoBg = countsAllSFiltCRSum;
if ~exist('removeVals')
    countsNoBg(mask3d) = 0;
else
    for layer=1:size(countsNoBg,3)
        countsNoBgLayer = countsNoBg(:,:,layer);
        countsNoBgLayer(logical(mask(:,:,layer))) = countsNoBgLayer(logical(mask(:,:,layer))) - removeVals(layer);
        countsNoBg(:,:,layer) = countsNoBgLayer;
    end
    % countsNoBg(mask3d) = countsNoBg(mask3d)-removeVal;
    countsNoBg(countsNoBg<0) = 0;
end