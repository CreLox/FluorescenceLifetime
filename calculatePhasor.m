% [PhasorG, PhasorS, PixelIndices] = calculatePhasor(FlimData,
% IntensityThreshold, Omega, IRFTransform)
function [PhasorG, PhasorS, PixelIndices] = calculatePhasor(FlimData, ...
    IntensityThreshold, Omega, IRFTransform)
    if (~isnumeric(IntensityThreshold)) || (numel(IntensityThreshold) ~= 2)
        error('`IntensityThreshold'' has to be an interval.');
    end
        
    Length = numel(FlimData.PixelDecayHistogram);
    PhasorG = zeros(1, Length);
    PhasorS = zeros(1, Length);
    PixelIndices = 1 : Length;
    CosSeries = cos(Omega * FlimData.DecayHistogramTimeAxis);
    SinSeries = sin(Omega * FlimData.DecayHistogramTimeAxis);
    PixelDecayHistograms = FlimData.PixelDecayHistogram;
    
    parpool(feature('numcores'));
    
    parfor ii = 1 : Length
        Sum = sum(PixelDecayHistograms{ii});
        if (Sum >= min(IntensityThreshold)) && ...
                (Sum <= max(IntensityThreshold))
            Real = CosSeries * PixelDecayHistograms{ii} / Sum;
            Imag = SinSeries * PixelDecayHistograms{ii} / Sum;
            PhasorG(ii) = real((Real + Imag * 1i) / IRFTransform);
            PhasorS(ii) = imag((Real + Imag * 1i) / IRFTransform);
        end
    end
    
    VoidIdx = (PhasorG == 0) & (PhasorS == 0);
    PhasorG(VoidIdx) = [];
    PhasorS(VoidIdx) = [];
    PixelIndices(VoidIdx) = [];
    
    delete(gcp('nocreate'));
end
