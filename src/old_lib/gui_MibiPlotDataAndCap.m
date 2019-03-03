function img = gui_MibiPlotDataAndCap(data,cap,titlestr,figureTitle,varargin)
global pipeline_data
currdata = data;
currdata(currdata>cap) = cap;
disp('varargin >')
disp(varargin)
disp('<')
if any(strcmp('background', varargin))
    if numel(varargin)==2
        sfigure(varargin{1});
    else
        pipeline_data.backgroundChannelFigure = sfigure(figure('Name', figureTitle));
    end
else
    figure('Name', figureTitle);
end
imagesc(currdata);
title(titlestr);
img = imgca(gcf);