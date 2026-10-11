
clc;
clear;
close all;

% DCT Watermark Generation
% Project: DCT Watermarking Studio

% Enter watermark text
watermarkText = input('Enter your watermark text: ', 's');

% Convert text into an image
figure('Visible', 'off');
axis off;

text(0.1, 0.5, watermarkText, ...
    'FontSize', 24, ...
    'FontWeight', 'bold', ...
    'Interpreter', 'none');

set(gca, 'Position', [0 0 1 1]);

frame = getframe(gca);
watermarkImage = frame2im(frame);

% Convert RGB image to grayscale
if size(watermarkImage, 3) == 3
    watermarkImage = rgb2gray(watermarkImage);
end

% Convert to binary watermark
watermarkImage = imbinarize(watermarkImage);

% Display watermark
figure;
imshow(watermarkImage);
title('Generated Text Watermark');

% Save watermark
imwrite(watermarkImage, 'watermark.png');

disp('Watermark generated and saved as watermark.png');
