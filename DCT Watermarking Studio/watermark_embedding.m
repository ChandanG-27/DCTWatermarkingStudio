
clc;
clear;
close all;

% DCT Watermark Embedding
% Project: DCT Watermarking Studio

% Select original image
[filename, pathname] = uigetfile( ...
    {'*.png;*.jpg;*.jpeg;*.bmp', 'Image Files'}, ...
    'Select Original Image');

if isequal(filename, 0)
    disp('No image selected.');
    return;
end

originalImage = imread(fullfile(pathname, filename));

% Convert original image to grayscale
if size(originalImage, 3) == 3
    grayImage = rgb2gray(originalImage);
else
    grayImage = originalImage;
end

% Load watermark image
if ~isfile('watermark.png')
    error('Run watermark_generation.m first.');
end

wmImage = imread('watermark.png');

if size(wmImage, 3) == 3
    wmImage = rgb2gray(wmImage);
end

% Convert watermark to binary
wmImage = im2double(wmImage);
binaryWM = wmImage > 0.5;

% Find foreground pixels (white text)
[rr, cc] = find(binaryWM);

if isempty(rr)
    error('Watermark contains no white foreground pixels.');
end

% Crop watermark around the text
binaryWM = binaryWM(min(rr):max(rr), min(cc):max(cc));

% Calculate available 8x8 blocks
maxRows = floor(size(grayImage, 1) / 8);
maxCols = floor(size(grayImage, 2) / 8);

% Preserve watermark aspect ratio while fitting the image
scale = min([1, maxRows / size(binaryWM, 1), ...
                maxCols / size(binaryWM, 2)]);

newRows = max(1, floor(size(binaryWM, 1) * scale));
newCols = max(1, floor(size(binaryWM, 2) * scale));

watermark = imresize(binaryWM, [newRows, newCols], 'nearest');
watermark = logical(watermark);

wmRows = size(watermark, 1);
wmCols = size(watermark, 2);

fprintf('Watermark rows: %d\n', wmRows);
fprintf('Watermark columns: %d\n', wmCols);

% Embedding strength
alpha = 120;

% Store image as double
watermarkedImage = double(grayImage);

% Embed watermark using DCT coefficient pairs
for r = 1:wmRows
    for c = 1:wmCols

        rowStart = (r - 1) * 8 + 1;
        colStart = (c - 1) * 8 + 1;

        block = watermarkedImage( ...
            rowStart:rowStart+7, colStart:colStart+7);

        D = dct2(block);

        a = D(3,4);
        b = D(4,3);
        midpoint = (a + b) / 2;

        if watermark(r,c)
            D(3,4) = midpoint + alpha/2;
            D(4,3) = midpoint - alpha/2;
        else
            D(3,4) = midpoint - alpha/2;
            D(4,3) = midpoint + alpha/2;
        end

        reconstructedBlock = idct2(D);

        watermarkedImage( ...
            rowStart:rowStart+7, colStart:colStart+7) = ...
            reconstructedBlock;
    end
end

% Convert to 8-bit image and save as PNG
watermarkedImage = uint8(min(max( ...
    round(watermarkedImage), 0), 255));

imwrite(watermarkedImage, 'watermarked_image.png');

% Save metadata and exact embedded watermark
save('watermark_metadata.mat', 'wmRows', 'wmCols', 'alpha');
save('watermark_used.mat', 'watermark');

% Display results
figure;
subplot(1,3,1);
imshow(grayImage);
title('Original Image');

subplot(1,3,2);
imshow(watermark);
title('Watermark Used');

subplot(1,3,3);
imshow(watermarkedImage);
title('Watermarked Image');

disp('Embedding completed successfully.');
disp('Saved: watermarked_image.png');
disp('Saved: watermark_metadata.mat');
disp('Saved: watermark_used.mat');
