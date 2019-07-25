function saveTIFF_folder(counts, labels, tags, path, varargin)
    rmkdir(path);
    for index=1:numel(labels)
        tiff = Tiff([path, filesep, labels{index}, '.tif'], 'w');
        setTag(tiff, tags{index});
        setTag(tiff, 'Compression', Tiff.Compression.Deflate);
        if numel(varargin)>0
            bitspersample = varargin{1};
            setTag(tiff, 'BitsPerSample', bitspersample);
            tags{index}.BitsPerSample = bitspersample;
        end
        if tags{index}.BitsPerSample==16
            write(tiff, uint16(counts(:,:,index)));
        elseif tags{index}.BitsPerSample==8
            write(tiff, uint8(counts(:,:,index)));
        else
            warning('The bits are all messed up');
        end
        rewriteDirectory(tiff);
        close(tiff);
    end
end

