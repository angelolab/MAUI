function countsNoBg = gui_MibiRemoveBackgroundByMaskAllChannels_graded(countsAllSFiltCRSum,mask,gains)
    channelNum = size(countsAllSFiltCRSum,3);
    mask3d = repmat(mask,1,1,channelNum);
    countsNoBg = countsAllSFiltCRSum;
    if ~exist('gains')
        countsNoBg(mask3d) = 0;
    else
        for layer=1:size(countsNoBg,3)
            countsNoBgLayer = countsNoBg(:,:,layer);
            countsNoBgLayer = countsNoBgLayer - mask * gains(layer);
            countsNoBg(:,:,layer) = countsNoBgLayer;
        end
        countsNoBg(countsNoBg<0) = 0;
    end
    countsNoBg = round(countsNoBg);
end