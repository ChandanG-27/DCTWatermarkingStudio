
function DCT_Watermarking_GUI
% DCT DIGITAL IMAGE WATERMARKING STUDIO
% Separate panels for input and extracted watermark

clc;

originalImage = [];
watermarkedImage = [];
watermark = [];
extractedWatermark = [];
watermarkText = '';
alpha = 30;

% ================= MAIN WINDOW =================
fig = uifigure('Name','DCT Watermarking Studio', ...
    'Position',[40 40 1450 850], ...
    'Color',[0.035 0.065 0.12]);

uilabel(fig,'Text','DCT WATERMARKING STUDIO', ...
    'Position',[25 795 900 35], ...
    'FontSize',25,'FontWeight','bold', ...
    'FontColor',[0.25 0.72 1]);

uilabel(fig,'Text','Invisible Digital Image Watermarking | MATLAB', ...
    'Position',[28 770 800 22], ...
    'FontSize',13,'FontColor',[0.8 0.87 0.96]);

% ================= FOUR IMAGE PANELS =================
p1 = uipanel(fig,'Title','1. ORIGINAL IMAGE', ...
    'Position',[15 435 345 310], ...
    'BackgroundColor',[0.07 0.12 0.20], ...
    'ForegroundColor','white');

p2 = uipanel(fig,'Title','2. WATERMARKED IMAGE', ...
    'Position',[370 435 345 310], ...
    'BackgroundColor',[0.07 0.12 0.20], ...
    'ForegroundColor','white');

p3 = uipanel(fig,'Title','3. INPUT / GENERATED WATERMARK', ...
    'Position',[725 435 345 310], ...
    'BackgroundColor',[0.07 0.12 0.20], ...
    'ForegroundColor','white');

p4 = uipanel(fig,'Title','4. EXTRACTED WATERMARK', ...
    'Position',[1080 435 355 310], ...
    'BackgroundColor',[0.07 0.12 0.20], ...
    'ForegroundColor','white');

ax1 = uiaxes(p1,'Position',[8 30 329 250]);
ax2 = uiaxes(p2,'Position',[8 30 329 250]);
ax3 = uiaxes(p3,'Position',[8 30 329 250]);
ax4 = uiaxes(p4,'Position',[8 30 339 250]);

formatAxes(ax1);
formatAxes(ax2);
formatAxes(ax3);
formatAxes(ax4);

title(ax1,'Original Image','Color','white');
title(ax2,'Watermarked Image','Color','white');
title(ax3,'Input Watermark','Color','white');
title(ax4,'Extracted Watermark','Color','white');

% ================= CONTROL PANEL =================
ctrl = uipanel(fig,'Title','WATERMARK CONTROLS', ...
    'Position',[15 205 700 215], ...
    'BackgroundColor',[0.07 0.12 0.20], ...
    'ForegroundColor','white');

uilabel(ctrl,'Text','Custom watermark text:', ...
    'Position',[15 160 160 25],'FontColor','white');

textBox = uieditfield(ctrl,'text', ...
    'Position',[175 160 300 30], ...
    'Value','CHANDAN G');

uibutton(ctrl,'Text','Generate Text', ...
    'Position',[490 160 190 30], ...
    'BackgroundColor',[0.08 0.43 0.8], ...
    'FontColor','white','ButtonPushedFcn',@generateText);

uibutton(ctrl,'Text','Load Original Image', ...
    'Position',[15 105 205 35], ...
    'ButtonPushedFcn',@loadOriginal);

uibutton(ctrl,'Text','Load Watermark Image', ...
    'Position',[235 105 205 35], ...
    'ButtonPushedFcn',@loadWatermark);

uibutton(ctrl,'Text','Embed Watermark', ...
    'Position',[455 105 225 35], ...
    'BackgroundColor',[0.04 0.52 0.36], ...
    'FontColor','white','ButtonPushedFcn',@embed);

uilabel(ctrl,'Text','Embedding strength:', ...
    'Position',[15 55 140 25],'FontColor','white');

alphaBox = uieditfield(ctrl,'numeric', ...
    'Position',[155 53 80 30], ...
    'Limits',[5 100],'Value',30);

uibutton(ctrl,'Text','Save Watermarked PNG', ...
    'Position',[255 50 200 35], ...
    'ButtonPushedFcn',@saveWatermarked);

uibutton(ctrl,'Text','Clear Results', ...
    'Position',[470 50 210 35], ...
    'ButtonPushedFcn',@clearResults);

% ================= EXTRACTION PANEL =================
extPanel = uipanel(fig,'Title','BLIND EXTRACTION', ...
    'Position',[730 205 705 215], ...
    'BackgroundColor',[0.07 0.12 0.20], ...
    'ForegroundColor','white');

uilabel(extPanel,'Text', ...
    'Upload a saved watermarked image to recover its watermark.', ...
    'Position',[15 160 660 25], ...
    'FontColor','white','FontSize',12);

uibutton(extPanel,'Text','Upload Watermarked Image & Extract', ...
    'Position',[15 105 320 40], ...
    'BackgroundColor',[0.35 0.24 0.72], ...
    'FontColor','white','ButtonPushedFcn',@extractFromFile);

uibutton(extPanel,'Text','Extract Current Image', ...
    'Position',[350 105 320 40], ...
    'ButtonPushedFcn',@extractCurrent);

uibutton(extPanel,'Text','JPEG Quality 90 Test', ...
    'Position',[15 50 200 35], ...
    'ButtonPushedFcn',@jpegTest);

resultLabel = uilabel(extPanel,'Text','Matching bits: --', ...
    'Position',[235 50 435 30], ...
    'FontColor',[0.35 0.9 0.65],'FontSize',14);

% ================= METRICS AND LOG =================
bottom = uipanel(fig,'Title','PERFORMANCE METRICS & PROCESS LOG', ...
    'Position',[15 15 1420 175], ...
    'BackgroundColor',[0.07 0.12 0.20], ...
    'ForegroundColor','white');

mseLabel = uilabel(bottom,'Text','MSE: --', ...
    'Position',[15 110 210 30], ...
    'FontColor',[0.25 0.72 1],'FontSize',17);

psnrLabel = uilabel(bottom,'Text','PSNR: -- dB', ...
    'Position',[230 110 250 30], ...
    'FontColor',[0.35 0.9 0.65],'FontSize',17);

logBox = uitextarea(bottom, ...
    'Position',[15 10 1390 90], ...
    'Editable','off', ...
    'Value',{'Ready. Load an original image to begin.'});

% ================= CALLBACKS =================

    function logMessage(msg)
        v = logBox.Value;
        if ischar(v)
            v = {v};
        end
        logBox.Value = [v; {msg}];
        drawnow;
    end

    function formatAxes(ax)
        ax.Color = [0.025 0.04 0.07];
        ax.XColor = 'none';
        ax.YColor = 'none';
    end

    function loadOriginal(~,~)
        [f,p] = uigetfile( ...
            {'*.png;*.jpg;*.jpeg;*.bmp','Image files'}, ...
            'Choose Original Image');

        if isequal(f,0)
            return;
        end

        try
            originalImage = imread(fullfile(p,f));

            if ndims(originalImage)==2
                originalImage = repmat(originalImage,1,1,3);
            elseif size(originalImage,3)>3
                originalImage = originalImage(:,:,1:3);
            end

            watermarkedImage = [];
            extractedWatermark = [];

            imshow(originalImage,'Parent',ax1);
            title(ax1,'Original Image','Color','white');

            cla(ax2);
            cla(ax4);

            logMessage(['Original image loaded: ' f]);
        catch ME
            uialert(fig,ME.message,'Image Error');
        end
    end

    function loadWatermark(~,~)
        [f,p] = uigetfile( ...
            {'*.png;*.bmp;*.jpg;*.jpeg','Image files'}, ...
            'Choose Watermark Image');

        if isequal(f,0)
            return;
        end

        try
            raw = imread(fullfile(p,f));

            if ndims(raw)==3
                raw = rgb2gray(raw(:,:,1:3));
            end

            watermark = raw > 127;

            % Make foreground white and background black.
            if mean(double(watermark(:))) > 0.5
                watermark = ~watermark;
            end

            watermark = cropBinary(watermark);
            watermarkText = '';

            imshow(watermark,'Parent',ax3);
            title(ax3,'Input Watermark Image','Color','white');

            logMessage(['Watermark image loaded: ' f]);
            logMessage(sprintf('Watermark dimensions: %d x %d', ...
                size(watermark,1),size(watermark,2)));
        catch ME
            uialert(fig,ME.message,'Watermark Error');
        end
    end

    function generateText(~,~)
        s = strtrim(textBox.Value);

        if isempty(s)
            uialert(fig,'Enter watermark text first.','Empty Text');
            return;
        end

        if isempty(originalImage)
            uialert(fig,'Load the original image first.','Missing Image');
            return;
        end

        tf = [];

        try
            tf = figure('Visible','off','Color','black', ...
                'Position',[100 100 1200 240]);

            ta = axes(tf,'Position',[0 0 1 1], ...
                'Color','black');
            axis(ta,[0 1 0 1]);
            axis(ta,'off');

            text(ta,0.5,0.5,s, ...
                'Color','white','FontSize',100, ...
                'FontWeight','bold', ...
                'HorizontalAlignment','center', ...
                'VerticalAlignment','middle', ...
                'Interpreter','none');

            drawnow;
            fr = getframe(ta);
            close(tf);

            bw = rgb2gray(fr.cdata)>100;
            bw = cropBinary(bw);

            maxR = floor(size(originalImage,1)/8);
            maxC = floor(size(originalImage,2)/8);

            scale = min([1, maxR/size(bw,1), maxC/size(bw,2)]);

            newR = max(1,floor(size(bw,1)*scale));
            newC = max(1,floor(size(bw,2)*scale));

            watermark = imresize(bw,[newR newC],'nearest');
            watermarkText = s;

            imshow(watermark,'Parent',ax3);
            title(ax3,'Generated Text Watermark','Color','white');

            logMessage(['Text watermark generated: ' s]);
            logMessage(sprintf('Watermark size: %d x %d', ...
                size(watermark,1),size(watermark,2)));
        catch ME
            if ~isempty(tf) && isvalid(tf)
                close(tf);
            end
            uialert(fig,ME.message,'Text Generation Error');
        end
    end

    function bw = cropBinary(bw)
        bw = logical(bw);
        [r,c] = find(bw);

        if isempty(r)
            error('No foreground pixels found in watermark.');
        end

        bw = bw(min(r):max(r),min(c):max(c));
    end

    function embed(~,~)
        if isempty(originalImage) || isempty(watermark)
            uialert(fig, ...
                'Load an image and generate or load a watermark first.', ...
                'Missing Input');
            return;
        end

        try
            alpha = alphaBox.Value;

            maxR = floor(size(originalImage,1)/8);
            maxC = floor(size(originalImage,2)/8);

            if size(watermark,1)>maxR || size(watermark,2)>maxC
                scale = min(maxR/size(watermark,1), ...
                            maxC/size(watermark,2));

                watermark = imresize(watermark, ...
                    [max(1,floor(size(watermark,1)*scale)), ...
                     max(1,floor(size(watermark,2)*scale))], ...
                    'nearest');

                imshow(watermark,'Parent',ax3);
                title(ax3,'Input Watermark (Resized)','Color','white');
                logMessage('Watermark resized to fit image capacity.');
            end

            yc = rgb2ycbcr(originalImage);
            Y = double(yc(:,:,1));
            Yw = Y;

            [nr,nc] = size(watermark);

            for k = 1:numel(watermark)
                r = floor((k-1)/nc)*8+1;
                c = mod(k-1,nc)*8+1;

                D = dct2(Yw(r:r+7,c:c+7));

                if watermark(k)
                    D(4,5) = abs(D(4,5))+alpha;
                else
                    D(4,5) = -abs(D(4,5))-alpha;
                end

                Yw(r:r+7,c:c+7) = idct2(D);
            end

            yc(:,:,1) = uint8(min(max(round(Yw),0),255));
            watermarkedImage = ycbcr2rgb(yc);

            imshow(watermarkedImage,'Parent',ax2);
            title(ax2,'Watermarked Image','Color','white');

            delta = double(originalImage)-double(watermarkedImage);
            mse = mean(delta(:).^2);

            if mse==0
                psnr = Inf;
            else
                psnr = 10*log10(255^2/mse);
            end

            mseLabel.Text = sprintf('MSE: %.4f',mse);
            psnrLabel.Text = sprintf('PSNR: %.4f dB',psnr);

            logMessage('Watermark embedded successfully.');
            extractCurrent([],[]);
        catch ME
            uialert(fig,ME.message,'Embedding Error');
        end
    end

    function extracted = decodeImage(img,wmSize)
        yc = rgb2ycbcr(img);
        Y = double(yc(:,:,1));

        nr = wmSize(1);
        nc = wmSize(2);

        if nr*8>size(Y,1) || nc*8>size(Y,2)
            error('Watermark dimensions do not fit this image.');
        end

        extracted = false(nr,nc);

        for k = 1:nr*nc
            r = floor((k-1)/nc)*8+1;
            c = mod(k-1,nc)*8+1;

            D = dct2(Y(r:r+7,c:c+7));
            extracted(k) = D(4,5)>0;
        end
    end

    function extractCurrent(~,~)
        if isempty(watermarkedImage) || isempty(watermark)
            uialert(fig, ...
                'Embed a watermark or upload a watermarked image.', ...
                'Missing Data');
            return;
        end

        try
            extractedWatermark = decodeImage( ...
                watermarkedImage,size(watermark));

            showExtracted();

            matches = sum(extractedWatermark(:)==watermark(:));
            pct = 100*matches/numel(watermark);

            resultLabel.Text = sprintf( ...
                'Matching bits: %d / %d (%.2f%%)', ...
                matches,numel(watermark),pct);

            logMessage(sprintf('Extraction accuracy: %.2f%%',pct));
        catch ME
            uialert(fig,ME.message,'Extraction Error');
        end
    end

    function showExtracted()
        imshow(extractedWatermark,'Parent',ax4);
        title(ax4,'Extracted Watermark','Color','white');
    end

    function saveWatermarked(~,~)
        if isempty(watermarkedImage) || isempty(watermark)
            uialert(fig,'Embed a watermark first.','Nothing to Save');
            return;
        end

        [f,p] = uiputfile('*.png', ...
            'Save Watermarked Image','watermarked_image.png');

        if isequal(f,0)
            return;
        end

        try
            outFile = fullfile(p,f);
            imwrite(watermarkedImage,outFile);

            [~,base,~] = fileparts(f);
            metaFile = fullfile(p,[base '_metadata.mat']);

            wmSize = size(watermark);
            watermarkData = watermark;
            save(metaFile,'wmSize','alpha','watermarkText','watermarkData');

            logMessage(['Saved watermarked PNG: ' outFile]);
            logMessage(['Saved metadata: ' metaFile]);
        catch ME
            uialert(fig,ME.message,'Save Error');
        end
    end

    function extractFromFile(~,~)
        [f,p] = uigetfile( ...
            {'*.png;*.jpg;*.jpeg;*.bmp','Watermarked images'}, ...
            'Select Watermarked Image');

        if isequal(f,0)
            return;
        end

        try
            img = imread(fullfile(p,f));

            if ndims(img)==2
                img = repmat(img,1,1,3);
            elseif size(img,3)>3
                img = img(:,:,1:3);
            end

            [~,base,~] = fileparts(f);
            metaFile = fullfile(p,[base '_metadata.mat']);

            if exist(metaFile,'file')
                data = load(metaFile,'wmSize','watermarkData');

                wmSize = data.wmSize;

                if isfield(data,'watermarkData')
                    watermark = data.watermarkData;
                end

                logMessage('Matching metadata loaded.');
            else
                answer = inputdlg( ...
                    {'Watermark height in pixels:', ...
                     'Watermark width in pixels:'}, ...
                    'Watermark Dimensions',[1 35],{'16','64'});

                if isempty(answer)
                    return;
                end

                wmSize = [str2double(answer{1}), ...
                          str2double(answer{2})];

                if any(~isfinite(wmSize)) || any(wmSize<1) || ...
                        any(wmSize~=floor(wmSize))
                    error('Enter valid positive integer dimensions.');
                end
            end

            extractedWatermark = decodeImage(img,wmSize);
            watermarkedImage = img;

            imshow(img,'Parent',ax2);
            title(ax2,'Uploaded Watermarked Image','Color','white');

            showExtracted();

            resultLabel.Text = sprintf( ...
                'Extracted %d bits',numel(extractedWatermark));

            outWM = fullfile(p,[base '_extracted_watermark.png']);
            imwrite(extractedWatermark,outWM);

            logMessage(['Uploaded watermarked image: ' f]);
            logMessage(['Extracted watermark saved: ' outWM]);
        catch ME
            uialert(fig,ME.message,'Extraction Error');
        end
    end

    function jpegTest(~,~)
        if isempty(watermarkedImage) || isempty(watermark)
            uialert(fig,'Embed a watermark first.','Missing Data');
            return;
        end

        tempFile = [tempname '.jpg'];

        try
            imwrite(watermarkedImage,tempFile,'Quality',90);
            jpegImg = imread(tempFile);
            delete(tempFile);

            jpegWM = decodeImage(jpegImg,size(watermark));

            matches = sum(jpegWM(:)==watermark(:));
            pct = 100*matches/numel(watermark);

            logMessage(sprintf( ...
                'JPEG quality 90 recovery: %.2f%% (%d/%d bits).', ...
                pct,matches,numel(watermark)));
        catch ME
            if exist(tempFile,'file')
                delete(tempFile);
            end
            uialert(fig,ME.message,'JPEG Test Error');
        end
    end

    function clearResults(~,~)
        originalImage = [];
        watermarkedImage = [];
        watermark = [];
        extractedWatermark = [];
        watermarkText = '';

        cla(ax1);
        cla(ax2);
        cla(ax3);
        cla(ax4);

        mseLabel.Text = 'MSE: --';
        psnrLabel.Text = 'PSNR: -- dB';
        resultLabel.Text = 'Matching bits: --';

        logBox.Value = {'Ready. Load an original image to begin.'};
    end
end
