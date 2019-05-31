function entropy=fuzzyEntropy(x,h)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS : 'x' is the fuzzy parameter vector
%          'h' is the histrogram of the image
% OUTPUT:  'entropy' is the Fuzzy Entropy of the image after fuzzy partition
%          of the histogram 'h' by the fuzzy parameter vector 'x'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by : Sujoy Paul, Jadavpur University, Kolkata %
%              Email : paul.sujoy.ju@gmail.com          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

entropy=0;
x=[1 1 (x+1) 256 256];

for i=1:2:length(x)-3
    U=trapmf(1:256,x(i:i+3));
    P=U.*h;
    P=P./sum(P);
    P=P.*log(P);
    P(isnan(P))=0;
    entropy=entropy+sum(P);
end

entropy=-entropy;