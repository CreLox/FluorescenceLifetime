% Result = eventCountPerMicron2(FlimData, CalculationFunctionHandle)
% To calculate the average event count per square micron, use
% CalculationFunctionHandle <- @(x) mean(x)
% To calculate the median event count per square micron, use
% CalculationFunctionHandle <- @(x) median(x)
function Result = eventCountPerMicron2(FlimData, CalculationFunctionHandle)
    Result = zeros(1, FlimProp.ChannelCount);
    for ChannelNo = 1 : FlimProp.ChannelCount
        ActualPixelHeightInMicron = FlimData(ChannelNo).FrameActualHeight / ...
            double(FlimData(ChannelNo).FramePixelHeight);
        ActualPixelWidthInMicron = FlimData(ChannelNo).FrameActualWidth / ...
            double(FlimData(ChannelNo).FramePixelWidth);
        ActualPixelAreaInMicron2 = ActualPixelHeightInMicron * ...
            ActualPixelWidthInMicron;
        i = 0;
        IncludedList = zeros(1, FlimData(ChannelNo).FramePixelHeight * ...
            FlimData(ChannelNo).FramePixelWidth);
        for m = 1 : FlimData(ChannelNo).FramePixelHeight
        for n = 1 : FlimData(ChannelNo).FramePixelWidth
            EventCount = sum(FlimData(ChannelNo).PixelDecayHistogram{m, n});
            if (EventCount <= max(PhotonCountFilter)) && ...
                    (EventCount >= min(PhotonCountFilter)) && ...
                    ~ismember((n - 1) * FlimProp.FramePixelHeight + m, ...
                    ExcludePixelIndices)
                i = i + 1;
                IncludedList(i) = double(EventCount) / ActualPixelAreaInMicron2;
            end
        end
        end
        Result(ChannelNo) = CalculationFunctionHandle(IncludedList(1 : i));
    end
end
