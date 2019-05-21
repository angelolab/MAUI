%%                              label2rgbBackdropLive.m
% Overview:
%
% Code that labels different regions of a bw image in different colors. The
% inputs are the image to be colored, a 2D array the size of the image that
% indexes the regions to be colored and the colormap for the indexed
% regions. Code can also convert a bw image into a solid color of choice
%
%
% Inputs:
%
% labelmat - matrix that specifies the labels of the regions to be colored,
%            if empty whole image will be colored one color.
% colormap - matrix with the rgb coordinates(R -[1,0,0]) of the colors as rows, one correponding to each label index
%            or matlab custom color scheme e.g. 'jet'.
% backgroundcolor - rgb coordinate of background color
%
% image - 2D image to be colored
%
% varagin - can allow colors to be shuffled by putting in 'shuffle' for
%           this input (input optional)
%
% 
% Outputs:
%
% colorimage - Color image
%
% Comments:
%
%

function colorimage = label2rgbBackdropLive(labelmat,colormap,backgroundcolor,image,varagin)

if ~isempty(labelmat) & strcmp(class(labelmat),'double')    % cast labelmatric as uint16 to speed things up
   labelmat=cast(labelmat,'uint16');
end


if nargin == 4 && ~isempty(labelmat)                 % Labelling of indexed regions with chosen colors
R = label2rgb(labelmat, colormap, backgroundcolor);     
elseif ~isempty(labelmat)                            % Labelling of indexed regions with colors shuffled
R = label2rgb(labelmat, colormap, backgroundcolor,varagin);
else                                                 % Labelling of image one color
R = label2rgb(ones(size(image),'uint8'), colormap, backgroundcolor);
end


colorimage = cast(bsxfun(@times,single(R)/255,single(image)),class(image)); % Multiply color template by image