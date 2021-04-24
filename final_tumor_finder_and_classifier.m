% BME 3053C Project (Group 13)
% 
% Authors: Kendall Moran, Wasiq Rashid, Abigail Misiura
% Group Members: Kendall Moran, Wasiq Rashid, Abigail Misiura
% Course: BME 3053C Computer Applications for BME
% Term: Spring 2021
% J. Crayton Pruitt Family Department of Biomedical Engineering
% University of Florida
% Email: wasiqrashid@ufl.edu
% April 24, 2021

clc;clear

files = dir('*.jpg'); % load all .jpg files in the current directory

%% Find brain without skull
for aa = 1:length(files)% loop through your images
    
    img = imread(files(aa).name);
    disp(files(aa))
    if ndims(img) == 3
        img = rgb2gray(img);
    end
    
    subplot(441)
    imshow(img)
    title('Original Image')
    subplot(442)
    binaryImgC = img > -1;
    imshow(binaryImgC)
    title('Binary img > -1')
    binaryImgO = img < 50;
    subplot(443)
    imshow(binaryImgO)
    title('Binary img < 50')
    subplot(444)
    bwOutline = binaryImgC - binaryImgO;
    seD = strel('diamond',1);
    imgErode = imerode(bwOutline,seD);
    imgErode = imbinarize(imgErode);
    % identify largest area
    largestAreaBinary = bwareafilt(imgErode,1);
    % subtract largest area from non-eroded binary image
    brainOutline = bwOutline - largestAreaBinary;
    imshow(bwOutline)
    title('Binary minus brain')
    subplot(445)
    
    % Dilate binary image
    se90 = strel('line',3,90);
    se0 = strel('line',3,0);
    brainOutline = imdilate(brainOutline, [se90 se0]);
    imshow(brainOutline)
    title('Brain Outline for Skull Removal')
    % remove brain outline (skull) from original image
    noskullImg = img;
    for ii = 1:size(img,1)
        for jj = 1:size(img,2)
            if brainOutline(ii,jj) == 1
                noskullImg(ii,jj) = 0;
            end
        end
    end
    subplot(446)
    imshow(noskullImg)
    title('Brain w/ Skull Removed')
    
    % show the binary image detailing brain area
    subplot(447)
    imgBrainArea = noskullImg > 50;
    imshow(imgBrainArea)
    title('Brain Area')
    
    % Calculate # of white pixels present in the processed image to find
    % the brain area
    total_brain_area = length(find(imgBrainArea == 1)); %units: pixels
    subplot(448)
    imshow(labeloverlay(img,imgBrainArea))
    title('Brain Area Overlay')
    
    %% PART 2: Find and characterize tumor
    
    % Move through area of normal image to get average tissue color using
    % binary brain area image boundaries to ignore skull and non-brain tissue
    [ro, co] = find(imgBrainArea == 1);
    imgGrayScaleValues = ones(size(ro));
    
    for ii = 1:1:length(ro)
        imgGrayScaleValues(ii) = imgGrayScaleValues(ii)*img(ro(ii), co(ii));
    end
    
    avgGrayScaleValue = mean(imgGrayScaleValues);
    
    % create new image without skull
    newImg = ones([size(img,1),size(img,2)]);
    newImg = uint8(newImg);
    
    for jj = 1:1:size(img,1)
        for kk = 1:1:size(img,2)
            if imgBrainArea(jj,kk) == 1
                newImg(jj,kk) = img(jj,kk);
            else
                newImg(jj,kk) = 0;
            end
        end
    end
    
    % Smooth image to aid in processing
    ksizen = 8;
    hn = ones(ksizen)/ksizen^2;
    newImgSmooth = imfilter(newImg,hn);
    
    % Determine areas of high variation from average brian tissue color
    imgBinary = (newImgSmooth > (avgGrayScaleValue + 0.25*avgGrayScaleValue));
    subplot(4,4,9)
    imshow(imgBinary)
    title('Binary Image')
    sen90 = strel('line',8,90);
    sen0 = strel('line',8,0);
    imgDil = imdilate(imgBinary,[sen90 sen0]);
    imgFill = imfill(imgDil,'holes');
    imgClearBorder = imclearborder(imgFill,26);
    seD = strel('diamond',5);
    imgErode = imerode(imgClearBorder,seD);
    imgSized = bwareafilt(imgErode,1);
    
    % Determine total area of tumor and derive size of tumor
    total_tumor_area = length(find(imgSized == 1)); %units: pixels
    tumor_size = total_tumor_area/total_brain_area;
    
    % Show overlayed tumor on MRI scan
    subplot(4,4,10)
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