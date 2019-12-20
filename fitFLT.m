function [Trace, Results] = fitFLT(IRFProb, Channel)
    close all;
    
    if (Channel == 1) % red, ns
        Offset = 25; % late pulse
    end
    if (Channel == 2) % green, ns
        Offset = 0; % early pulse
    end
    EvalTEdges = 0 : (50 / 4096) : 25;
    EvalTCenters = ((25 / 4096) : (50 / 4096) : (25 - 25 / 4096)) + Offset;
    Xlim = [0, 25] + Offset;
    
    figure(1);
    hold on;
        set(gca, 'LineWidth', 2, 'FontSize', 16);
        xlabel('Microtime (ns)');
        ylabel('Counts');
        xlim(Xlim);

        [Trace, ~] = readMicroTime;
        histogram(Trace{Channel}.MicroTimeData, EvalTEdges + Offset, ...
            'DisplayStyle', 'stairs', 'EdgeColor', 'k');
        Trace{Channel}.Detected = histcounts(Trace{Channel}.MicroTimeData, ...
            EvalTEdges + Offset);
        Results = deconvolveIRF(Trace{Channel}.Detected, IRFProb, ...
            'Optimization2', EvalTEdges);
        FullConvolution = conv(IRFProb, Results.Decay, 'full');
        plot(EvalTCenters, FullConvolution(1 : length(IRFProb)), 'r');
        if (Results.OptimX(1) >= 0.5)
            Results.OptimX = [Results.OptimX(1 : 2), ...
                1 - Results.OptimX(1), Results.OptimX(3)];
        else
            Results.OptimX = [1 - Results.OptimX(1), Results.OptimX(3), ...
                Results.OptimX(1 : 2)];
        end
    hold off;
end
