function [countsNoNoise] = gui_FFTfilter(counts, gauss_blur_radius, spectral_radius, scaling_factor)
    im = counts*scaling_factor;
    mean_value = mean(im(:));
    im = im-mean_value;
    if gauss_blur_radius>0
        im = imgaussfilt(im, gauss_blur_radius);
    end
    F = fftshift(fft2(im));
    h = fspecial('gaussian',size(F),spectral_radius);
    h = h./max(h(:));
    H = F.*h;
    pic = real(ifft2(fftshift(H)));
    pic(pic<0)=0;
    pic = floor(pic + mean_value);
    pic = sqrt(pic.*counts);
    countsNoNoise = pic/scaling_factor;
end

