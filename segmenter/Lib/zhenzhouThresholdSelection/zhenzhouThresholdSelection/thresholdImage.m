function J=thresholdImage(I,NThresholds)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS : I is the input image
%          NThresholds is the number of thresholds required. NThresholds
%          lies between the 1 and (the difference between the maximum and
%          minimum graylevel present in the image)
% OUTPUT:  J is the thresholded image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by : Sujoy Paul, Jadavpur University, Kolkata %
%              Email : paul.sujoy.ju@gmail.com          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(size(I))>2
    I=rgb2gray(I);
end

H = imhist(I);
h = H / numel(I);
NumberOfIter = 1;
FuzzyParameters = differentialEvolution(h,NThresholds,NumberOfIter);
Thresholds=mean([FuzzyParameters(1:2:end);FuzzyParameters(2:2:end)]);

if length(Thresholds)==1
    J=255*im2bw(I,Thresholds/255);
else
    X=grayslice(I,Thresholds);
    J=uint8(255*mat2gray(X));
end

J=uint8(round(J));