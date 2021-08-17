clear; clc;

%% Parameter setting
Prefix = '20200901_MAD1-mNGAlone+CDC20siRNA_15Percent488nm_1sDwellTime_100pinhole';
AllIndices = 1 : 7;
LeftEdge = 5;
RightEdge = 20;
% EvenlySpacedCtrlPointNum = 63; % 2*7*9*13=1638
MarkerSize = 9;
LineWidth = 2;
AxisLineWidth = 2;
FontSize = 15;

% ErrorbarColor = [1, 0.75, 0.75];
% MarkerColor = 'r';
ErrorbarColor = [0.75, 0.75, 0.75];
MarkerColor = 'k';

%% Calculation
j = 0;
for i = AllIndices
    j = j + 1;
    clear('IRFProb', 'OutlierIdx', 'FlimData', 'PhotonCountFilter', ...
        'Results', 'Idx');
    load(sprintf('%s_%d.mat', Prefix, i));
    Idx = (FlimData(1).DecayHistogramTimeAxis >= LeftEdge) & ...
            (FlimData(1).DecayHistogramTimeAxis <= RightEdge);
    AllValidPixelDecay(j, :) = FlimData(1).AllPixelsDecayHistogram(Idx);
    NormalizedAllValidPixelDecay(j, :) = AllValidPixelDecay(j, :) / ...
        sum(AllValidPixelDecay(j, :));
end
TimeAxis = FlimData(1).DecayHistogramTimeAxis(Idx);
clear('AllIndices', 'OutlierIdx', 'FlimData', 'PhotonCountFilter', ...
    'Results', 'Idx');
Length = length(TimeAxis);
WeightedNormalized = sum(AllValidPixelDecay) / sum(sum(AllValidPixelDecay));

%% Plotting
h = figure(1);
h.Position = [300, 300, 700, 450];
hold on;
errorbar(TimeAxis, mean(NormalizedAllValidPixelDecay), ...
    std(NormalizedAllValidPixelDecay) / sqrt(j), ...
    'CapSize', 0, 'LineStyle', 'none', 'Color', ErrorbarColor, ...
    'LineWidth', LineWidth);
scatter(TimeAxis, WeightedNormalized, MarkerSize, MarkerColor, 'filled');
set(gca, 'LineWidth', AxisLineWidth, 'FontSize', FontSize);
xlabel('Microtime (ns)');
ylabel('Frequency');

%% Save variables
clear('h');
save(sprintf('%s_AllPlotting.mat', Prefix));