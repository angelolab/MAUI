function [countsNoNoise] = gui_FFTfilter(counts, gauss_blur_radius, spectral_radius, scaling_factor)
    % Scale the image 
    im = counts * scaling_factor;
    
    % Mean of all values
    mean_value = mean(im(:));
    
    % Center the distribution
    im = im - mean_value;
    
    % Add custom blur
    if gauss_blur_radius > 0
        im = imgaussfilt(im, gauss_blur_radius);
    end
    
    % 2D FFT and shift low frequency components to the center
    F = fftshift(fft2(im));
    
    % Create a 2D gaussian filter
    h = fspecial('gaussian',size(F),spectral_radius);
    
    % Rescale to [0 1]
    h = h./max(h(:));
    
    % Apply the filter to the FFT data. Central components remain largely
    % unaffected, outer edge data gets multiplied by low values
    H = F.*h;
    
    % Reverse FFT
    pic = real(ifft2(fftshift(H)));
    
    % Check how negative these get
    pic(pic < 0) = 0;
    
    % Add mean intensity back to data
    pic = floor(pic + mean_value);
    
    countsNoNoise = sqrt((pic/scaling_factor) .* counts);
end

