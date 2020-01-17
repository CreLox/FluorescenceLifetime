% calculateIRF(EarlyPulseOrLatePulse, MicroTimeRange)
function calculateIRF(EarlyPulseOrLatePulse, MicroTimeRange)
    %% Read the header and micro-time data
    [Trace, Filename, FCSHeader] = readMicroTime;
    
    %% Determine parameters
    ADCResolution = double(FCSHeader.MaxMicroTimeResolution);
    if ~exist('MicroTimeRange', 'var') || isempty(MicroTimeRange)
        MicroTimeRange = double(FCSHeader.MicroTimeRange); % ns
    end
    if strcmpi(EarlyPulseOrLatePulse, 'early')
        TimeWindow = 1 : (ADCResolution / 2);
    elseif strcmpi(EarlyPulseOrLatePulse, 'late')
        TimeWindow = (ADCResolution / 2 + 1) : ADCResolution;
    elseif strcmpi(EarlyPulseOrLatePulse, 'whole') || ...
            strcmpi(EarlyPulseOrLatePulse, 'entire') || ...
            strcmpi(EarlyPulseOrLatePulse, 'all')
        TimeWindow = 1 : ADCResolution;
    else
        error('Please specify the microtime window.');
    end
    
    %% Calculate IRF
    PhotonCounts = histcounts(Trace{1}.MicroTimeData, ...
        0 : (MicroTimeRange / ADCResolution) : MicroTimeRange);
%     NormalizedPhotonCounts = PhotonCounts / sum(PhotonCounts);
%     IRFProb = NormalizedPhotonCounts(TimeWindow);
    IRFProb = PhotonCounts(TimeWindow) / ...
        sum(PhotonCounts(TimeWindow));
    
    %% Save
    save([Filename, '.mat'], 'IRFProb');
end
