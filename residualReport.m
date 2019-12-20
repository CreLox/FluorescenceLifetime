% ResidualReportFigureHandle = residualReport(TData, YData, YModel,
% varargin)
function ResidualReportFigureHandle = residualReport(TData, YData, ...
    YModel, varargin)
    %% Parse inputs
    TData  = reshape(TData,  1, []);
    YData  = reshape(YData,  1, []);
    YModel = reshape(YModel, 1, []);
    if length(unique([length(TData), length(YData), length(YModel)])) > 1
        error('Lengths of data are not consistent.');
    end
    TimeInterval = uniquetol(diff(TData));
    if length(TimeInterval) > 1
        error('Time ticks are not equispaced.');
    end
    
    %% Calculate residuals and ACFs
    Residuals = YModel - YData;
    ACF = calculateACF(Residuals, floor(length(TData) / 2));
    
    %% Plot
    ResidualReportFigureHandle = figure;
    % Upper: residuals
    ResidualPlot = subplot(2, 1, 1);
    hold on;
        plot(TData, Residuals, varargin{:});
        plot([min(TData), max(TData)], [0, 0], 'k--', 'LineWidth', 1.5);
        set(ResidualPlot, 'FontSize', 15, 'LineWidth', 1.5);
        xlabel('Microtime (ns)');
        ylabel('Residual');
    hold off;
    % Lower: auto-correlation (ACF) of residuals
    ResidualACFPlot = subplot(2, 1, 2);
    hold on;
        plot((1 : length(ACF)) * TimeInterval, ACF, varargin{:});
        plot([0, max(TData)], [0, 0], 'k--', 'LineWidth', 1.5);
        set(ResidualACFPlot, 'FontSize', 15, 'LineWidth', 1.5);
        xlabel('Time lag (ns)');
        ylabel('ACF');
    hold off;
end

function ACF = calculateACF(Data, MaxLag)
    ACF = zeros(1, MaxLag);
    Mean = mean(Data);
    for i = 1 : MaxLag
        ACF(i) = (Data(1 : end - i) - Mean) * ...
            (Data(1 + i : end) - Mean)' / (length(Data) - i - 1) / ...
            var(Data);
    end
end
