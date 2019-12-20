% [UpdatedFigureHandle, PhasorG, PhasorS, PixelIndices] =
% plotPhasor(FlimData, IntensityThreshold, Omega, IRFTransform,
% OverlayFigureHandle, varargin)
function [UpdatedFigureHandle, PhasorG, PhasorS, PixelIndices] = ...
    plotPhasor(FlimData, IntensityThreshold, Omega, IRFTransform, ...
    OverlayFigureHandle, varargin)
    if (length(FlimData) > 1)
        FlimData = FlimData(2);
        warning('The input has > 1 channels. Channel #2 is processed.')
    end
    if ~exist('OverlayFigureHandle', 'var') || isempty(OverlayFigureHandle)
        UpdatedFigureHandle = figure;
        UpdatedFigureHandle.UserData.Omega = Omega;
        UpdatedFigureHandle.UserData.IntensityThreshold = IntensityThreshold;
        hold on;
            xlabel('g');
            ylabel('s');
            plot(0 : 0.001 : 1, sqrt(0.25 - (-0.5 : 0.001 : 0.5) .^ 2), ...
                'k--', 'LineWidth', 1.5);
            plot([0, 1], [0, 0], 'k--', 'LineWidth', 1.5);
            [PhasorTickG, PhasorTickS] = ...
                calculateUniversalCircleTickCoordinates(0 : 5, Omega);
            scatter(PhasorTickG, PhasorTickS, ...
                'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
            axis('equal');
            set(gca, 'FontSize', 16, 'LineWidth', 1.5);
            xlim([-0.1, 1.1]);
            ylim([-0.1, 0.7]);
            title(['FLIM phasor ($\omega = $', ...
                sprintf('%.2e ns$^{-1}$, ', Omega), '$\ge$', ...
                sprintf('%d photons)', IntensityThreshold)], ...
                'Interpreter', 'latex', 'FontSize', 16, 'FontWeight', 'normal');
    else
        if (OverlayFigureHandle.UserData.Omega ~= Omega)
            error('Current phasor plot has a different modulation frequency.');
        end
        if (OverlayFigureHandle.UserData.IntensityThreshold ~= IntensityThreshold)
            error('Current phasor plot has a different pixel intensity threshold.');
        end
        UpdatedFigureHandle = figure(OverlayFigureHandle);
        hold on;
    end
            [PhasorG, PhasorS, PixelIndices] = calculatePhasor(FlimData, ...
                IntensityThreshold, Omega, IRFTransform);
            scatter(PhasorG, PhasorS, varargin{:});
        hold off;
end

function [PhasorTickG, PhasorTickS] = ...
    calculateUniversalCircleTickCoordinates(TauArray, Omega)
    PhasorTickG = 1 ./ (1 + Omega ^ 2 * TauArray .^ 2);
    PhasorTickS = Omega * TauArray ./ (1 + Omega ^ 2 * TauArray .^ 2);
end
