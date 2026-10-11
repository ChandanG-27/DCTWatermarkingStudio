
clc;
clear;
close all;

% DCT Watermark Extraction
% Project: DCT Watermarking Studio

% Check required files
if ~isfile('watermarked_image.png')
    error('Run watermark_embedding.m first.');
end

if ~isfile('watermark_metadata.mat') || ...
   ~isfile('watermark_used.mat')
    error('Required metadata files are missing.');
end

% Load metadata and reference watermark
load('watermark_metadata.mat', 'wmRows', 'wmCols');
load('watermark_used.mat', 'watermark');

% Load watermarked image
img = imread('watermarked_image.png');

if size(img, 3) == 3
    img = rgb2gray(img);
end

img = double(img);

% Check dimensions
if wmRows > floor(size(img,1)/8) || ...
   wmCols > floor(size(img,2)/8)
    error('Watermark dimensions do not fit the image.');
end

% Extract watermark bits
extractedWatermark = false(wmRows, wmCols);

for r = 1:wmRows
    for c = 1:wmCols

        rowStart = (r - 1) * 8 + 1;
        colStart = (c - 1) * 8 + 1;

        block = img(rowStart:rowStart+7, ...
                    colStart:colStart+7);

        D = dct2(block);

        % Same coefficient pair used during embedding
        extractedWatermark(r,c) = D(3,4) > D(4,3);
    end
end

% Save extracted watermark
imwrite(extractedWatermark, 'extracted_watermark.png');

% Compare extracted bits with the embedded watermark
if isequal(size(watermark), size(extractedWatermark))
    accuracy = 100 * mean( ...
        watermark(:) == extractedWatermark(:));

    fprintf('Recovery accuracy: %.2f%%\n', accuracy);
else
    accuracy = NaN;
    disp('Watermark dimensions do not match.');
end

% Display results
figure;

subplot(1,2,1);
imshow(watermark);
title('Watermark Used');

subplot(1,2,2);
imshow(extractedWatermark);
title(sprintf('Extracted Watermark (%.2f%%)', accuracy));

disp('Extraction completed.');
disp('Saved: extracted_watermark.png');
