%%
ccc;
h = figure;
hold on;

%%
LineWidth = 1.5;
FontSize = 15;
set(gca, 'LineWidth', LineWidth);
set(gca, 'FontSize', FontSize);
ylabel('PDF');
xlabel('Microtime (ns)');
GrayColor = [0.75, 0.75, 0.75];
PinkColor = [1, 0.75, 0.75];

PhotonCountFilter7 = [329, 429];
PhotonCountFilter8 = [329, 489];
PhotonCountFilter9 = [387, 487];

PhotonCountFilter3 = [429, 559];
PhotonCountFilter4 = [624, 854];
PhotonCountFilter5 = [488, 688];

%% 
% m1_cell7
[FlimData7, ~] = extractTDFLIM(PhotonCountFilter7);
% m1_cell8
[FlimData8, ~] = extractTDFLIM(PhotonCountFilter8);
% m1_cell9
[FlimData9, ~] = extractTDFLIM(PhotonCountFilter9);

errorbar(FlimData7.DecayHistogramTimeAxis, mean(...
    [(FlimData7.AllPixelsDecayPDF)'; (FlimData8.AllPixelsDecayPDF)'; (FlimData9.AllPixelsDecayPDF)']), ...
    std(...
    [(FlimData7.AllPixelsDecayPDF)'; (FlimData8.AllPixelsDecayPDF)'; (FlimData9.AllPixelsDecayPDF)']), ...
    'CapSize', 0, 'LineStyle', 'none', 'Color', GrayColor, ...
    'LineWidth', LineWidth);
scatter(FlimData7.DecayHistogramTimeAxis, mean(...
    [(FlimData7.AllPixelsDecayPDF)'; (FlimData8.AllPixelsDecayPDF)'; (FlimData9.AllPixelsDecayPDF)']), ...
    '.k');

%%
% m2_cell3
[FlimData3, ~] = extractTDFLIM(PhotonCountFilter3);
% m2_cell4
[FlimData4, ~] = extractTDFLIM(PhotonCountFilter4);
% m2_cell5
[FlimData5, ~] = extractTDFLIM(PhotonCountFilter5);

errorbar(FlimData7.DecayHistogramTimeAxis, mean(...
    [(FlimData3.AllPixelsDecayPDF)'; (FlimData4.AllPixelsDecayPDF)'; (FlimData5.AllPixelsDecayPDF)']), ...
    std(...
    [(FlimData3.AllPixelsDecayPDF)'; (FlimData4.AllPixelsDecayPDF)'; (FlimData5.AllPixelsDecayPDF)']), ...
    'CapSize', 0, 'LineStyle', 'none', 'Color', PinkColor, ...
    'LineWidth', LineWidth);
scatter(FlimData7.DecayHistogramTimeAxis, mean(...
    [(FlimData3.AllPixelsDecayPDF)'; (FlimData4.AllPixelsDecayPDF)'; (FlimData5.AllPixelsDecayPDF)']), ...
    '.r');

%%
hold off;
