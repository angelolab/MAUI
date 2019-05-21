% Calculate the intersection of two frames: previous and current. 
% Inputs:
% previous - overlap in the previous data
% current - overlap in the current frame
% Output:
%   currentAdj - current frame, adjusted for the overlap
%
% Author: Dmitry Tebaykin
% Contact: dmitry.tebaykin@stanford.edu

function currentAdj = MibiCalcOverlap(previous, current, weights)
% TODO: consider OVERLAP_BUFFER - area before the overlap that does not
% inherit from the other frame, but is affected by overlaps brightness
% values. Default: 0 pixels

currentAdj = current;

% Find all non-zero pixels from previous frames in the current frame
[row, col, val] = find(previous);

% If there is no overlap with previous frames - return
if isempty(val)
    return;
end

% Calculate distances from each point in the overlap to the center of the
% current frame.
% distances = zeros(1,length(val));
% for i = 1:length(val)
%     distances(i) = pdist([ceil(nrow / 2), ceil(ncol / 2); row(i), col(i)]);
% end

% Find the maximum weight
%[~, minInd] = min(distances);
% if row(minInd) > floor(nrow / 2) && col(minInd) > floor(ncol / 2)
%     row(minInd) = nrow - row(minInd);
%     col(minInd) = ncol - col(minInd);
% end
% maxWeight = max(row(minInd), col(minInd));
maxWeight = max(max(weights(row, col)));

% Adjust the current frame accordingly
% For now: assuming previous frame does not go past center of the current
% frame
for k = 1:length(val)
    i = row(k);
    j = col(k);
    currentAdj(i, j) = round((maxWeight - weights(i,j) + 1) / maxWeight * previous(i,j) + weights(i,j) / maxWeight * current(i,j));
end
