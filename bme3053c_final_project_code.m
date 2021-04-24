% BME3053C Group 13 Final Project: Brain Tumor Detection and Sizing in MRI Scans
%
% Authors / Group Members: Kendall Moran, Abigail Misiura, Wasiq Rashid
% Course: BME3053C Computer Applications for BME3053C
% Term: Spring 2021
% J. Crayton Pruitt Family Department of Biomedical Engineering
% University of Florida
% Emails: kendall.moran@ufl.edu, wasiqrashid@ufl.edu, abbymisiura@ufl.edu
% April 24, 2021

clc;clear

files = dir('*.jpg'); % load all .jpg files in the current directory into structure "files"

%% Isolate brain from image containing brain and skull structures
for aa = 1:length(files)
    
    img = imread(files(aa).name);
    if ndims(img) == 3
        img = rgb2gray(img);
    end
	subplot(331)
	imshow(img)
	title('Original Image')
	
	% Threshold image so that only the skull and brain remain; all noise is classified 
	% as background (black, intensity = 0)
	% This is done to make the separation between the skull structure and the brian more clear
    subplot(332)
    binaryImgC = img > -1;
    imshow(binaryImgC)
    title('Binary img > -1')
    binaryImgO = img < 50;
    subplot(333)
    imshow(binaryImgO)
    title('Binary img < 50')
	bwOutline = binaryImgC - binaryImgO;
	
	% Erode and rebinarize image to account for thresholding errors
    seD = strel('diamond',1);
    imgErode = imerode(bwOutline,seD);
    imgErode = imbinarize(imgErode);
	
    % Identify largest area in new binary image of skull and brain structure
	% This is ideally just the brain
    largestAreaBinary = bwareafilt(imgErode,1);
	
    % Subtract largest area from non-eroded binary image (ideally subtracting the brain from the binary image)
    brainOutline = bwOutline - largestAreaBinary;
    
    % Dilate binary image to increase the size of the skull 
	% structure that should be the only thing left in the binary image
	% This is done to account for failure to accurately outline the brain
    se90 = strel('line',3,90);
    se0 = strel('line',3,0);
    brainOutline = imdilate(brainOutline, [se90 se0]);
	subplot(334)
    imshow(brainOutline)
    title('Brain Outline for Skull Removal')
	
    % Remove brain outline (skull) from original image by using indices in the binary image = 1 as guide
	% Corresponding indices on copy of original 
	% image will have intensity set to 0 (to make those pixels into background)
	noskullImg = img;
    for ii = 1:size(img,1)
        for jj = 1:size(img,2)
            if brainOutline(ii,jj) == 1
                noskullImg(ii,jj) = 0;
            end
        end
    end
    subplot(335)
    imshow(noskullImg)
    title('Brain w/ Skull Removed')
    
    % Calculate and show a binary image containing just brain structure
    subplot(336)
    imgBrainArea = noskullImg > 50;
    imshow(imgBrainArea)
    title('Brain Area')
    
    % Calculate # of white pixels present in the brain area binary image to determine total brain area
    total_brain_area = length(find(imgBrainArea == 1)); %units: pixels
    subplot(337)
    imshow(labeloverlay(img,imgBrainArea))
    title('Brain Area Overlay')
    
    %% PART 2: Find and characterize tumor
    
    % Move through indices in original image that correspond to 
	% white pixels on the brain area binary image and save each index to a matrix
    [ro, co] = find(imgBrainArea == 1);
    imgGrayScaleValues = ones(size(ro));
    
	% Obtain average intensity values at each of these indices
    for ii = 1:1:length(ro)
        imgGrayScaleValues(ii) = imgGrayScaleValues(ii)*img(ro(ii), co(ii));
    end
    
	% Calculate average intensity of brain tissue in this image
    avgGrayScaleValue = mean(imgGrayScaleValues);
    
    % Create new image without skull structure (just brain structure)
    newImg = ones([size(img,1),size(img,2)]);
    newImg = uint8(newImg);
    
	% Using the binary brain area image, create a new image that contains only the brain structure
    for jj = 1:1:size(img,1)
        for kk = 1:1:size(img,2)
            if imgBrainArea(jj,kk) == 1
                newImg(jj,kk) = img(jj,kk);
            else
                newImg(jj,kk) = 0;
            end
        end
    end
    
    % Smooth image to aid in processing using a local mean filter
    ksizen = 8;
    hn = ones(ksizen)/ksizen^2;
    newImgSmooth = imfilter(newImg,hn);
    
    % Determine areas of high variation from average brian tissue color
    imgBinary = (newImgSmooth > (avgGrayScaleValue + 0.25*avgGrayScaleValue));
    subplot(338)
    imshow(imgBinary)
    title('Binary Image Tumor')
	
	% Dilate, fill, clear border, erode, and identify the largest 
	% area in the binary image of high variation entities in the brain structure
	% This identified largest area should be the brain tumor
    sen90 = strel('line',8,90);
    sen0 = strel('line',8,0);
    imgDil = imdilate(imgBinary,[sen90 sen0]);
    imgFill = imfill(imgDil,'holes');
    imgClearBorder = imclearborder(imgFill,26);
    seD = strel('diamond',5);
    imgErode = imerode(imgClearBorder,seD);
    imgSized = bwareafilt(imgErode,1);
    
    % Determine total area of tumor and derive size of tumor relative to total tumor area
    total_tumor_area = length(find(imgSized == 1)); %units: pixels
    tumor_size = total_tumor_area/total_brain_area;
    
    % Show overlayed tumor on MRI scan
    subplot(339)
    imshow(labeloverlay(img,imgSized))
    title('Tumor Overlay on MRI Scan');
    
    % Classify tumor based on size relative to brain
    if tumor_size <= .05
        text(size(img,2),size(img,1)+20,...
            strcat('No tumor detected.'),...
            'FontSize',8,'HorizontalAlignment','right');
    elseif tumor_size >= .05 && tumor_size <= .10
        text(size(img,2),size(img,1)+20,...
            strcat('Tumor Classification is Small; size = ',num2str(tumor_size*100),' %'),...
            'FontSize',8,'HorizontalAlignment','right');
    elseif tumor_size > .10 && tumor_size <= .20
        text(size(img,2),size(img,1)+20,...
            strcat('Tumor Classification is Developing; size = ',num2str(tumor_size*100),' %'),...
            'FontSize',8,'HorizontalAlignment','right');
    elseif tumor_size > .20 && tumor_size <= .30
        text(size(img,2),size(img,1)+20,...
            strcat('Tumor Classification is Developed; size = ',num2str(tumor_size*100),' %'),...
            'FontSize',8,'HorizontalAlignment','right');
    else
        text(size(img,2),size(img,1)+20,...
            strcat('Tumor Classification is Massive; size = ',num2str(tumor_size*100),' %'),...
            'FontSize',8,'HorizontalAlignment','right');
    end
    saveas(gcf, sprintf('Result %s',files(aa).name))
end