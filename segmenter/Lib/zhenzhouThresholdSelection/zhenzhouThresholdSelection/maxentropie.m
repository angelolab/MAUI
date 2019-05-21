%**************************************************************************
%**************************************************************************
%   
% maxentropie is a function for thresholding using Maximum Entropy
% 
% 
% input = I ==> Image in gray level 
% output =
%           I1 ==> binary image
%           threshold ==> the threshold choosen by maxentropie
%  
% F.Gargouri
%
%
%**************************************************************************
%**************************************************************************


function [threshold I1]=maxentropie(I)

    [n,m]=size(I);
    h=imhist(I);
    %normalize the histogram ==>  hn(k)=h(k)/(n*m) ==> k  in [1 256]
    hn=h/(n*m);
   
    %Cumulative distribution function
	c(1) = hn(1);
    for l=2:256
        c(l)=c(l-1)+hn(l);
    end
    
    
    hl = zeros(1,256);
    hh = zeros(1,256);
    for t=1:256
        %low range entropy
        cl=double(c(t));
        if cl>0
            for i=1:t
                if hn(i)>0
                    hl(t) = hl(t)- (hn(i)/cl)*log(hn(i)/cl);                      
                end
            end
        end
        
        %high range entropy
        ch=double(1.0-cl);  %constraint cl+ch=1
        if ch>0
            for i=t+1:256
                if hn(i)>0
                    hh(t) = hh(t)- (hn(i)/ch)*log(hn(i)/ch);
                end
            end
        end
    end
    
    % choose best threshold
    
	h_max =hl(1)+hh(1)
	threshold = 0;
    entropie(1)=h_max;
    for t=2:256
        entropie(t)=hl(t)+hh(t);
        if entropie(t)>h_max
            h_max=entropie(t);
            threshold=t-1;
        end
    end
    
    % Display    
    I1 = zeros(size(I));
    I1(I<threshold) = 0;
    I1(I>threshold) = 255;
    %imshow(I1)      
end 
    