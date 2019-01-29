function write_tiff_folder(counts, labels, path)
    path = strsplit(path, '.'); path = path{1}; % normalizing name
    tiff = Tiff([path, '.tiff'], 'a');
    for index=1:numel(labels)
        setTag(tiff, 'PageName', labels{index});
        setTag(tiff, 'SubFileType', 0);
        setTag(tiff, 'Photometric', 1);
        setTag(tiff, 'ImageLength', size(counts,1));
        setTag(tiff, 'ImageWidth', size(counts,2));
        setTag(tiff, 'BitsPerSample', 8);
        setTag(tiff, 'Compression', Tiff.Compression.Deflate);
        setTag(tiff, 'PlanarConfiguration', 1);
        setTag(tiff, 'SampleFormat', 1);
        setTag(tiff, 'SamplesPerPixel', 1);
        setTag(tiff, 'Orientation', 1);
        if ~exist('tags{index}.ImageDescription')
            imgdesc = ImageDescription();
            % imgdesc.dict()
        end
        write(tiff, uint8(counts(:,:,index)));
        if index~=length(labels)
            writeDirectory(tiff);
        end
    end
    rewriteDirectory(tiff);
    close(tiff);
end

