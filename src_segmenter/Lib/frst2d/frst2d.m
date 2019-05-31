function [ filtered ] = frst2d( image, radii, alpha, stdFactor, mode )
%FRST2D Applies Fast radial symmetry transform to image
%   Check paper Loy, G., & Zelinsky, A. (2002). A fast radial symmetry transform for detecting points of interest. Computer Vision?ECCV 2002.
%   Three different modes are available: 'bright', 'dark', 'both'

% Example:
% I = imread('iris.jpg');
% Id = rgb2gray(I);
% IdSmall = imresize(Id, 0.25);
% 
% f = frst2d(IdSmall, 13, 2, 0.1, 'dark');
% 
% subplot(2,1,1);
% imshow(IdSmall, []);
% subplot(2,1,2);
% imshow(f,[]);

    bright = false;
    dark = false;
    if (strcmp(mode, 'bright'))
        bright = true;
    elseif (strcmp(mode, 'dark'))
        dark = true;
    elseif (strcmp(mode, 'both'))
        bright = true;
        dark = true;
    else
        error('invalid mode');
    end
    
    original = double(image);

    [gy, gx] = gradient(original);
    
    maxRadius = ceil(max(radii(:)));
    offset = [maxRadius maxRadius];
    
    filtered = zeros(size(original) + 2*offset);

    
    S = zeros([numel(radii), size(filtered, 1), size(filtered, 2)]);
    
    radiusIndex = 1;
    for n = radii
        
        O_n = zeros(size(filtered));
        M_n = zeros(size(filtered));
        
        for i = 1:size(original, 1)
            for j=1:size(original, 2)
                p = [i j];
                g = [gx(i,j) gy(i,j)];
                gnorm = sqrt( g * g' ) ;
                if (gnorm > 0)
                    gp = round((g./gnorm) * n);

                    if (bright)
                        ppve = p + gp;
                        ppve = ppve + offset;

                        O_n(ppve(1), ppve(2)) = O_n(ppve(1), ppve(2)) + 1;
                        M_n(ppve(1), ppve(2)) = M_n(ppve(1), ppve(2)) + gnorm;
                    end
                    
                    if (dark)
                        pnve = p - gp;
                        pnve = pnve + offset;

                        O_n(pnve(1), pnve(2)) = O_n(pnve(1), pnve(2)) - 1;
                        M_n(pnve(1), pnve(2)) = M_n(pnve(1), pnve(2)) - gnorm;
                    end
                end
                
            end
        end

        O_n = abs(O_n);
        O_n = O_n ./ max(O_n(:));
        
        M_n = abs(M_n);
        M_n = M_n ./ max(M_n(:));
        
        
        S_n = (O_n.^alpha) .* M_n;
        
        gaussian = fspecial('gaussian', [ceil(n/2) ceil(n/2)], n*stdFactor);
        S(radiusIndex, :, :) = imfilter(S_n, gaussian);
        
        radiusIndex = radiusIndex + 1;
    end
    
    filtered = squeeze(sum(S, 1));
    filtered = filtered(offset(1)+1:end-offset(2), offset(1)+1:end-offset(2));

end

