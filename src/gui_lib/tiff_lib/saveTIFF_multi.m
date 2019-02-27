function saveTIFF_multi(counts, labels, tags, path, varargin)
    path = strsplit(path, '.'); path = path{1}; % normalizing name
    tiff = Tiff([path, '.tiff'], 'a');
    if numel(varargin)==1
        bits = varargin{1};
    else
        bits = 16;
    end
    for index=1:numel(labels)
        tags{index}.BitsPerSample = bits;
        setTag(tiff, tags{index});
        % setTag(tiff, 'PageName', labels{index});
        % setTag(tiff, 'Compression', Tiff.Compression.Deflate);
        % setTag(tiff, 'Software', 'IonpathMIBIv0.1');
       %  setTag(tiff, 'ResolutionUnit', 3);
        % we need to programmatically set these
        % how do we set this programmatically?
        % setTag(tiff, 'XResolution', 25600);
        % setTag(tiff, 'YResolution', 25600);
        % lets try to set this programmatically as well
        % we can set this programmaticaly, it is RunTime
        % setTag(tiff, 'DateTime', '2018:12:07 00:00:00');
        % we need to programmatically set these
        % we can set these programmatically, the are XAttrib and YAttrib
        % setTag(tiff, 'XPosition', 0);
        % setTag(tiff, 'YPosition', 0);
        if ~exist('tags{index}.ImageDescription')
            imgdesc = ImageDescription();
            % imgdesc.dict()
        end
        if tags{index}.BitsPerSample==16
            write(tiff, uint16(counts(:,:,index)));
        elseif tags{index}.BitsPerSample==8
            write(tiff, uint8(counts(:,:,index)));
        else
            warning('The bits are all messed up');
        end
        if index~=length(labels)
            writeDirectory(tiff);
        end
    end
    rewriteDirectory(tiff);
    close(tiff);
end

