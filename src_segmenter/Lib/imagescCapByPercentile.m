function f = imagescCapByPercentile(data,prcLow,prcHigh)
% function f = imagescCapByPercentile(data,prcLow,prcHigh)
% function plots an image using imagesc. It receives a lower and upper
% percentile and caps all values below/above it

lowVal = prctile(data(:),prcLow);
highVal = prctile(data(:),prcHigh);

f = imagesc(data,[lowVal highVal]);