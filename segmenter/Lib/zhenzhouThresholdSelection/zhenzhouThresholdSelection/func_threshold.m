function thre = func_threshold(I)
% Compute an optimal threshold for seperating the data into two classes [1]. 

% This algorithm can be summarized as follows. The histogram is initially segmented into two
% parts using a a randonly-select starting threshold value (denoted as
% T(1)). Then, the data are classified into two classes (denoted as c1 and
% c2). Then, a new threshold value is computed as the average of the above
% two sample means. This process is repeated untill the threshold value
% does not change any more.
%
% The algorithm was implemented by Dhanesh Ramachandram [2]. However, the input data of her/his
% algorithm should lie in the range [0,255]. My code doesn't have this
% requirement.
%
% Example
% -------
%      t = func_threshold(T);
%
% Reference: [1]. T. W. Ridler, S. Calvard, Picture thresholding using an iterative selection method, 
%            IEEE Trans. System, Man and Cybernetics, SMC-8, pp. 630-632, 1978.
%            [2]. Dhanesh Ramachandram, Automatic Thresholding. Available online at: http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=3195&objectType=file
%
% Jing Tian
% Contact me : scuteejtian@hotmail.com
% This program is written in Mar. 2006 during my postgraduate studying in Singapore.

% Convert all N-D arrays into a single column.  
I = double(I(:));

% STEP 1: Compute mean intensity of image from histogram, set T(1) = mean(I)

[counts, N] = hist(I, 256);
i = 1;
mu1 = cumsum(counts);
T(i) = (sum(N.*counts)) / mu1(end);

% STEP 2: compute the sample mean of the data classified by the above threshold
mu2 = cumsum(counts(N<=T(i)));
MBT = sum(N(N<=T(i)).*counts(N<=T(i)))/mu2(end);

mu3 = cumsum(counts(N>T(i)));
MAT = sum(N(N>T(i)).*counts(N>T(i)))/mu3(end);
i=i+1;

% new T = (MAT+MBT)/2
T(i) = (MAT+MBT)/2;

% STEP 3 repeat step 2 while T(i)~=T(i-1)
thre = T(i);

while abs(T(i)-T(i-1))>=1
    mu2 = cumsum(counts(N<=T(i)));
    MBT = sum(N(N<=T(i)).*counts(N<=T(i)))/mu2(end);

    mu3 = cumsum(counts(N>T(i)));
    MAT = sum(N(N>T(i)).*counts(N>T(i)))/mu3(end);

    i=i+1;
    T(i) = (MAT+MBT)/2; 
    thre = T(i);
end