%% Step 1
close all; clear; clc;
[FlimDataPre, Image, ~] = extractTDFLIM;
Image = squeeze(Image);
figure(1);
imshow(Image, []); % Raw Image
[min(Image(:)), max(Image(:))] % Show the pixel readout range
axis on;

%% Step 2
f2 = figure(2);
PhotonCountFilter = [145, 334]; % <- Change this accordingly
imshowThresholding(Image, PhotonCountFilter, f2);
axis on;

%% Step 3: phasor filtering
% Plot phasor- and intensity-filtered Image
close(f2);
load('20210825_mirror_irf.mat'); % <- Change this accordingly
[PhasorG, PhasorS, PixelIndices] = calculatePhasor(FlimDataPre, ...
    PhotonCountFilter, Omega, IRFTransform);
Outlier = (PhasorS < (PhasorG - 0.2));
OutlierIdx = PixelIndices(Outlier);
Image(OutlierIdx) = 0;
f2 = figure(2);
h = imshowThresholding(Image, PhotonCountFilter, f2);
h.UserData = Image;
axis on;

% Outlier mask
figure(3);
OutlierMapping = false(256);
OutlierMapping(OutlierIdx) = true;
imshow(OutlierMapping);
axis on;

% The wait is usually long - thank god when it is finally finished!
% (play the sound effect of the Holy Hand Grenade, a.k.a. Handel's
% "Hallelujah", when this step finishes)
% https://en.wikipedia.org/wiki/Rabbit_of_Caerbannog
load handel.mat; soundsc(y(1000:16500)); clear Fs y;

%% Step 4: extra pixel-filtering
OutlierIdx = [OutlierIdx, drawMasks(h)];

%% Step 5: fitting
close all;
FittingOption = 'Fitting2S';
% FittingOption = 'Fitting2';
[FlimData, ~, FileName] = extractTDFLIM(PhotonCountFilter, OutlierIdx);
Results = fitFLIM(FlimData, IRFProb, FittingOption, 1)

MedianEventCountPerPixel = eventCountPer('Pixel', FlimData, @(x) median(x))
A0WeightedMean = harmmeanWeighted([Results.OptimX(2), Results.OptimX(4)], ...
    [Results.OptimX(1), Results.OptimX(3)])
TotalIntensityWeightedMean = Results.OptimX(1) * Results.OptimX(2) + ...
    Results.OptimX(3) * Results.OptimX(4)

[~, FileName, ~] = fileparts(FileName);
figure(1); savefig(sprintf('%s.fig', FileName));
figure(2); savefig(sprintf('%s_Residuals.fig', FileName));
save(FileName, 'FlimData', 'FittingOption', 'IRFProb', 'OutlierIdx', ...
    'PhotonCountFilter', 'Results', '-v7.3');
