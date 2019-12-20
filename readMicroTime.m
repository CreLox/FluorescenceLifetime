% [Trace, Filename] = readMicroTime
% (A file selection UI window will pop up to allow the user to select a
% .fcs file)
% Note: 1. please put this .m file and AlbaV5FCSFileFormat.txt under the
% same folder in MATLAB search paths.
% 2. Trace is a cell array of struct, each element of which corresponds to
% one channel. Trace{i}.MicroTimeData are in nanoseconds with single
% precision.
function [Trace, Filename] = readMicroTime
    %% Read the header
    FCSHeader = readHeader(strcat(fileparts(mfilename('fullpath')), ...
        filesep, 'AlbaV5FCSFileFormat.txt'), [], '.fcs');
    [~, Filename, ~] = fileparts(FCSHeader.FilePath);
    if (FCSHeader.PositionSeriesCount > 1) || ...
        (FCSHeader.TimeSeriesCount > 1)
        error('More than 1 position/time series!');
    end
    if (FCSHeader.AcquisitionMode ~= 2)
        error('Not time-resolved!');
    end
    
    %% Read the micro time trace(s)
    Trace = cell(1, FCSHeader.ChannelNumber);
    fid = fopen(FCSHeader.FilePath, 'r');
    fseek(fid, FCSHeader.MicroTimeOffset, 'bof');
    for i = 1 : FCSHeader.ChannelNumber
        Trace{i}.Length = fread(fid, 1, 'uint64') / ...
            uint64(FCSHeader.BytesPerDatum);
        if (FCSHeader.BytesPerDatum == 2)
            Trace{i}.MicroTimeData = single(fread(fid, Trace{i}.Length, 'uint16')) * ...
                FCSHeader.MicroTimeRange / ...
                single(FCSHeader.MaxMicroTimeResolution);
        else
            Trace{i}.MicroTimeData = single(fread(fid, Trace{i}.Length, 'uint32')) * ...
                FCSHeader.MicroTimeRange / ...
                single(FCSHeader.MaxMicroTimeResolution);
        end
    end
end
