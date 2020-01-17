function calculateIRF(EarlyPulseOrLatePulse, TimeWindow)
    %% Read the header and micro-time data
    [Trace, Filename, FCSHeader] = readMicroTime;
    
    %% Determine parameters
    ADCResolution = double(FCSHeader.MaxMicroTimeResolution);
    if ~exist('TimeWindow', 'var') || isempty(TimeWindow)
        TimeWindow = double(FCSHeader.MicroTimeRange); % ns
    end
    if strcmpi(EarlyPulseOrLatePulse, 'early')
        HalfedTimeWindow = 1 : (ADCResolution / 2);
    elseif strcmpi(EarlyPulseOrLatePulse, 'late')
        HalfedTimeWindow = (ADCResolution / 2 + 1) : ADCResolution;
    else
        error('Please specify between the early pulse or the late pulse.');
    end
    
    %% Calculate IRF
    PhotonCounts = histcounts(Trace{1}.MicroTimeData, ...
        0 : (TimeWindow / ADCResolution) : TimeWindow);
    IRFProb = PhotonCounts(HalfedTimeWindow) / ...
        sum(PhotonCounts(HalfedTimeWindow));
    
    %% Save
    save([Filename, '.mat'], 'IRFProb');
end
