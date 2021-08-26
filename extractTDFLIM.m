% [FlimData, Image, FileName] = extractTDFLIM(PhotonCountFilter,
% ExcludePixelIndices)
function [FlimData, Image, FileName] = extractTDFLIM(PhotonCountFilter, ...
    ExcludePixelIndices)
    if ~exist('PhotonCountFilter', 'var') || ...
            isempty(PhotonCountFilter) || ...
            ~isnumeric(PhotonCountFilter) || ...
            (numel(PhotonCountFilter) ~= 2)
        PhotonCountFilter = [0, Inf];
        fprintf('PhotonCountFilter := [0, Inf]\n');
    end
    
    if ~exist('ExcludePixelIndices', 'var') || ~isnumeric(ExcludePixelIndices)
        ExcludePixelIndices = [];
        fprintf('ExcludePixelIndices := []\n');
    end
    
    [FileName, FilePath] =  uigetfile('*.iss-tdflim', ...
        'Select a TDFLIM data file');
    
    [~, FileNameNoExtension, ~] = fileparts(FileName);
    UnzipTargetFolderPath = [FilePath, FileNameNoExtension];
    unzip([FilePath, FileName], UnzipTargetFolderPath);
    [FlimData, Image] = parseFlimData([FilePath, FileName], ...
        PhotonCountFilter, ExcludePixelIndices);
    
    fprintf('%s\n', FileName);
end

function [FlimData, Image] = parseFlimData(TDFLIMFilePath, ...
    PhotonCountFilter, ExcludePixelIndices)
    FlimProp = parseFlimProperties(TDFLIMFilePath);
    [FilePath, FileName, ~] = fileparts(TDFLIMFilePath);
    FileID = fopen([FilePath, filesep, FileName, filesep, ...
        'data', filesep, 'PrimaryDecayData.bin']);
    
    for ChannelNo = 1 : FlimProp.ChannelCount
        FlimData(ChannelNo).ExcludePixelIndices = ExcludePixelIndices;
        FlimData(ChannelNo).TotalChannelNumber = FlimProp.ChannelCount;
        FlimData(ChannelNo).ChannelNumber = ChannelNo;
        FlimData(ChannelNo).ADCResolution = FlimProp.ADCResolution;
        FlimData(ChannelNo).TACTimeRange = FlimProp.TACTimeRange;
        FlimData(ChannelNo).PixelDwellTime = FlimProp.PixelDwellTime;
        FlimData(ChannelNo).MacroTimeClockFrequency = FlimProp.MacroTimeClockFrequency;
        FlimData(ChannelNo).ActualDimensionUnit = FlimProp.CoordUnitType;
        FlimData(ChannelNo).FramePixelWidth = FlimProp.FramePixelWidth;
        FlimData(ChannelNo).FramePixelHeight = FlimProp.FramePixelHeight;
        FlimData(ChannelNo).FrameActualWidth = FlimProp.FrameWidth;
        FlimData(ChannelNo).FrameActualHeight = FlimProp.FrameHeight;
        FlimData(ChannelNo).PixelPhotonCountFilter = ...
            [min(PhotonCountFilter), max(PhotonCountFilter)];
        FlimData(ChannelNo).DecayHistogramTimeAxis = ...
            linspace(FlimProp.TACTimeRange / FlimProp.ADCResolution / 2, ...
            FlimProp.TACTimeRange - FlimProp.TACTimeRange / FlimProp.ADCResolution / 2, ...
            FlimProp.ADCResolution);
        FlimData(ChannelNo).AllPixelsDecayHistogram = ...
            zeros(FlimProp.ADCResolution, 1);
        for m = 1 : FlimProp.FramePixelHeight
            for n = 1 : FlimProp.FramePixelWidth
                FlimData(ChannelNo).PixelDecayHistogram{m, n} = ...
                    fread(FileID, FlimProp.ADCResolution, 'uint16');
                Image(ChannelNo, m, n) = ...
                    sum(FlimData(ChannelNo).PixelDecayHistogram{m, n});
                if (Image(ChannelNo, m, n) <= max(PhotonCountFilter)) && ...
                        (Image(ChannelNo, m, n) >= min(PhotonCountFilter)) && ...
                        ~ismember((n - 1) * FlimProp.FramePixelHeight + m, ...
                        ExcludePixelIndices)
                    FlimData(ChannelNo).AllPixelsDecayHistogram = ...
                        FlimData(ChannelNo).AllPixelsDecayHistogram + ...
                        FlimData(ChannelNo).PixelDecayHistogram{m, n};
                end
            end
        end
        FlimData(ChannelNo).AllPixelsDecayPDF = ...
            FlimData(ChannelNo).AllPixelsDecayHistogram / ...
            (sum(FlimData(ChannelNo).AllPixelsDecayHistogram) * ...
            FlimProp.TACTimeRange / FlimProp.ADCResolution);
        % convert to PDF
    end
end

function FlimProp = parseFlimProperties(TDFLIMFilePath)
    [FilePath, FileName, ~] = fileparts(TDFLIMFilePath);
    ImageProp = getImageProperties([FilePath, filesep, FileName, filesep, ...
        'dataProps', filesep, 'Core.xml']);
    
    FlimProp.CoordUnitType = ImageProp.Children(find(strcmp({ImageProp.Children.Name},'CoordUnitType'))).Children.Data;
    DimensionIndex = find(strcmp({ImageProp.Children.Name},'Dimensions'));
%     flimProp.timeSeriesCount = str2num(imageProp.Children(dimensionIndex).Children(find(strcmp({imageProp.Children(dimensionIndex).Children.Name},'TimeSeriesCount'))).Children.Data);
    FlimProp.ChannelCount = str2num(ImageProp.Children(DimensionIndex).Children(find(strcmp({ImageProp.Children(DimensionIndex).Children.Name},'ChannelCount'))).Children.Data);
%     flimProp.frameCount = str2num(imageProp.Children(dimensionIndex).Children(find(strcmp({imageProp.Children(dimensionIndex).Children.Name},'FrameCount'))).Children.Data);
    FlimProp.FramePixelHeight = str2num(ImageProp.Children(DimensionIndex).Children(find(strcmp({ImageProp.Children(DimensionIndex).Children.Name},'FrameHeight'))).Children.Data);
    FlimProp.FramePixelWidth = str2num(ImageProp.Children(DimensionIndex).Children(find(strcmp({ImageProp.Children(DimensionIndex).Children.Name},'FrameWidth'))).Children.Data);
    BoundaryIndex = find(strcmp({ImageProp.Children.Name},'Boundary'));
%     flimProp.frameTop = str2num(imageProp.Children(boundaryIndex).Children(find(strcmp({imageProp.Children(boundaryIndex).Children.Name},'FrameTop'))).Children.Data);
%     flimProp.frameBottom = str2num(imageProp.Children(boundaryIndex).Children(find(strcmp({imageProp.Children(boundaryIndex).Children.Name},'FrameBottom'))).Children.Data);
%     flimProp.frameLeft = str2num(imageProp.Children(boundaryIndex).Children(find(strcmp({imageProp.Children(boundaryIndex).Children.Name},'FrameLeft'))).Children.Data);
%     flimProp.frameRight = str2num(imageProp.Children(boundaryIndex).Children(find(strcmp({imageProp.Children(boundaryIndex).Children.Name},'FrameRight'))).Children.Data);
     FlimProp.FrameWidth = str2num(ImageProp.Children(BoundaryIndex).Children(find(strcmp({ImageProp.Children(BoundaryIndex).Children.Name},'FrameWidth'))).Children.Data);
     FlimProp.FrameHeight = str2num(ImageProp.Children(BoundaryIndex).Children(find(strcmp({ImageProp.Children(BoundaryIndex).Children.Name},'FrameHeight'))).Children.Data);
%     flimProp.stackTop = str2num(imageProp.Children(boundaryIndex).Children(find(strcmp({imageProp.Children(boundaryIndex).Children.Name},'StackTop'))).Children.Data);
%     flimProp.stackBottom = str2num(imageProp.Children(boundaryIndex).Children(find(strcmp({imageProp.Children(boundaryIndex).Children.Name},'StackBottom'))).Children.Data);
%     flimProp.stackHeight = str2num(imageProp.Children(boundaryIndex).Children(find(strcmp({imageProp.Children(boundaryIndex).Children.Name},'StackHeight'))).Children.Data);
%     
%     channelIndex = find(strcmp({imageProp.Children.Name},'ChannelIds'));
%     channelSubIndex = find(strcmp({imageProp.Children(channelIndex).Children.Name}, 'ChannelId'));
%     for iChannel = 1:length(channelSubIndex)
%         flimProp.channel(iChannel) = str2num(imageProp.Children(channelIndex).Children(channelSubIndex(iChannel)).Children.Data);
%     end
%     
%     timeSeriesIndex = find(strcmp({imageProp.Children.Name},'TimeSeries'));
%     flimProp.timeSeriesIntervalTime = str2num(imageProp.Children(timeSeriesIndex).Children(find(strcmp({imageProp.Children(timeSeriesIndex).Children.Name},'TimeSeriesIntervalTime'))).Children.Data);
%     
    PhotonCountSettingsIndex = find(strcmp({ImageProp.Children.Name},'PhotonCountingSettings'));
    FlimProp.ADCResolution = str2num(ImageProp.Children(PhotonCountSettingsIndex).Children(find(strcmp({ImageProp.Children(PhotonCountSettingsIndex).Children.Name},'AdcResolution'))).Children.Data);
    FlimProp.TACTimeRange = str2num(ImageProp.Children(PhotonCountSettingsIndex).Children(find(strcmp({ImageProp.Children(PhotonCountSettingsIndex).Children.Name},'TacTimeRange'))).Children.Data);
    FlimProp.MacroTimeClockFrequency = str2num(ImageProp.Children(PhotonCountSettingsIndex).Children(find(strcmp({ImageProp.Children(PhotonCountSettingsIndex).Children.Name},'MacroTimeClockFrequency'))).Children.Data);
    FlimProp.PixelDwellTime = str2num(ImageProp.Children(find(strcmp({ImageProp.Children.Name},'PixelDwellTime'))).Children.Data);
%     flimProp.pixelIntervalTime = str2num(imageProp.Children(find(strcmp({imageProp.Children.Name},'PixelIntervalTime'))).Children.Data);
%     flimProp.lineIntervalTime = str2num(imageProp.Children(find(strcmp({imageProp.Children.Name},'LineIntervalTime'))).Children.Data);
%     flimProp.frameIntervalTime = str2num(imageProp.Children(find(strcmp({imageProp.Children.Name},'FrameIntervalTime'))).Children.Data);
%     flimProp.integratedFrameCount = str2num(imageProp.Children(find(strcmp({imageProp.Children.Name},'IntegratedFrameCount'))).Children.Data);
end
