% Result = eventCountPerMicron2(FlimData, CalculationFunctionHandle)
% To calculate the average event count per square micron, use
% CalculationFunctionHandle <- @(x) mean(x)
% To calculate the median event count per square micron, use
% CalculationFunctionHandle <- @(x) median(x)
function Result = eventCountPerMicron2(FlimData, CalculationFunctionHandle)
    Result = zeros(1, FlimData(1).TotalChannelNumber);
    for ChannelNo = 1 : FlimData(1).TotalChannelNumber
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
            if (EventCount <= max(FlimData(ChannelNo).PixelPhotonCountFilter)) && ...
                    (EventCount >= min(FlimData(ChannelNo).PixelPhotonCountFilter)) && ...
                    ~ismember((n - 1) * FlimData(ChannelNo).FramePixelHeight + m, ...
                    FlimData(ChannelNo).ExcludePixelIndices)
                i = i + 1;
                IncludedList(i) = double(EventCount) / ActualPixelAreaInMicron2;
            end
        end
        end
        Result(ChannelNo) = CalculationFunctionHandle(IncludedList(1 : i));
    end
end
