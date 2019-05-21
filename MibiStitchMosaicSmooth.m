% MIBI smooth stitching script
% Author: Dmitry Tebaykin
% Contact: dmitry.tebaykin@stanford.edu

%% Necessary parameters
% Provide the XML file path from the run, stitching parameters will be
% extracted automatically. Example: xmlFileName = '180501_Hip_Panel3ug_Final-2b.xml';
xmlFileName = '';

% Output folder for stitched images. Default: current working directory
OutputFolder = [pwd, '/Stitched'];

% Point to folder where the Point folders with TIFs are located. pwd stands for current
% working directory (path at the top of Matlab)
% Example for a different folder: TIFs_PATH = [pwd, '/extracted']
TIFs_PATH = [pwd]; 
channel = 'VGLUT2';
dataSize = 1020; % Resolution of one frame, minus 4 pixels. Example: 512x512 - 4 = 508

% Stitch start and end points.
startPoint = 19; % Start stitching from this point number
endPoint = 27; % End stitching with this point number. Zero means all points to the end
skipPoints = []; % These points will be skipped during stitching (The stitch should advance, leaving a blank space)

%% Set these if no XML is available
% Set stitching parameters manually if no XML file is available
xNumPoint = 3; % Set this to the number of rows
yNumPoint = 3; % Set this to the number of columns
direction = 1; % Choose starting stitch direction: 0 = left, 1 = right

%% new stitch
% X and Y refer to pixel matrix row and column
ydRight = 1020; % Shift this many pixels when moving right, ydRight = dataSize is default (no coregistering)
xdRight = 10; % Vertical tilt of the image, shift this many pixels up each time when moving right

ydLeft = dataSize - ydRight; % do not change, similar to ydRight
xdLeft = -xdRight; % do not change, similar to xdRight

ydTop = 10; % Shift right by ydTop pixels when moving up one row. Horizontal tilt
xdTop = -18; % Should be negative or 0. Controls vertical coregistration when moving up one row. Positive value would yield blank space between rows

if exist(xmlFileName, 'file')
    textXML = fileread(xmlFileName);
    paramNames= {'XAttrib', 'YAttrib'};
    pointsLoc = zeros(0,2);

    for i=1:length(paramNames)
        pattern=[paramNames{i},'="([\+-\w.]+)"\>'];
        [matchExp,tok,ext]= regexp(textXML, pattern, 'match','tokens','tokenExtents');
    
        for j=1:length(tok)
            pointsLoc(j,i) = str2double(tok{j}{1});
        end
    end
    
    % Calculate number of rows and cols
    if endPoint == 0
        endPoint = length(pointsLoc);
    end
    
else
    disp('XML file not found, using scripts preset parameters.');
 
    if endPoint == 0
        endPoint = xNumPoint * yNumPoint;
    end
   
    if (direction == 0)
        startPosGlobal = ([(xNumPoint - 1/2) * dataSize, (yNumPoint - 1/2) * dataSize]); % Starting point: bottom right
    else
        startPosGlobal = ([(xNumPoint - 1/2) * dataSize, (1/2) * dataSize]); % Starting point: bottom left
    end 
end

% Create list of points for this stitch
pointList = startPoint : endPoint + 1;

allDataStitch = zeros((xNumPoint + 2) * dataSize, (yNumPoint + 2) * dataSize);

% Create a weights matrix
weights = zeros(dataSize, dataSize);
for k = 1:floor(dataSize/2)
    weights([k, dataSize - k + 1], k : dataSize - k + 1) = k;
    weights(k : dataSize - k + 1, [k, dataSize - k + 1] ) = k;
end

% Main stitching loop, this code should not be modified on run-to-run basis
for i=1:xNumPoint
    xloc = xNumPoint - i + 1;
    for j=1:yNumPoint
        yloc = yNumPoint - j + 1;
        currPoint = (i-1) * yNumPoint + j;
       
        % Set serpentine direction for even and odd rows
        if (mod(i,2) == 0)
            currentDirection = ~direction;
            if direction == 0
                yloc = j;
            end
        else
            currentDirection = direction; 
            if direction == 1
                yloc = j;
            end
        end
       
        % Get current data frame 
        currData = double(imread([TIFs_PATH, '/Point', num2str(pointList(currPoint)), '/TIFs/', channel, '.tif']));
        currData = currData(3 : dataSize + 2, 3 : dataSize + 2);
       
        % Get first position
        if (i == 1) && (j == 1) % first point. No coregistering
            currPos = startPosGlobal;
            allDataStitch(currPos(1) : currPos(1) + dataSize - 1, currPos(2) : currPos(2) + dataSize - 1) = currData;
            continue;
        end
           
       % Stitching starts here.
       lastPos = currPos;
              
       if (currentDirection == 1) && ~(yloc == 1) % registering along right movement
           currPos = ([lastPos(1) + xdRight, lastPos(2) + ydRight]);          
       elseif ((currentDirection == 0) && (yloc == yNumPoint)) || ((currentDirection == 1) && (yloc == 1)) % registration along top movement
           currPos = ([lastPos(1) - dataSize - xdTop, lastPos(2) + ydTop]); % shift coordinates. if more pos moving up or increasing gap between frames. 
       elseif (currentDirection == 0) && ~(yloc == yNumPoint) %registering along left movement
           currPos = ([lastPos(1) + xdLeft, lastPos(2) - ydRight]);
       end
       
       % Skip the point if needed, leaving blank space in the stitch
       if ismember(currPoint, skipPoints) 
           continue;
       end
       
       % Add the current point to the stitch matrix, adjusting for existing
       % pixels in the overlap
       prevData = allDataStitch(currPos(1) : currPos(1) + dataSize - 1, currPos(2) : currPos(2) + dataSize - 1);
       % disp(size(currData))
       currData = MibiCalcOverlap(prevData, currData, weights);

       allDataStitch(currPos(1) : currPos(1) + dataSize - 1, currPos(2) : currPos(2) + dataSize - 1) = currData;
   end
end



% plot final image
%figure; 
data=allDataStitch;
% data(data>capImage) = capImage;
% imagesc(data);
% colormap(gray);
% colorbar;
% title(p{1}.massDS.Label{plotChannelInd});T
%set(gca,'xtick',[],'ytick',[]);

if ~exist(OutputFolder,'dir')
    mkdir(OutputFolder);
end

%Make and save images and close figures
imwrite((uint16(data)),[OutputFolder,'/Stitched_',channel,'.tif']);
close all;
