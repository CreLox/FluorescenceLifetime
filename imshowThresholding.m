% FigureHandle = imshowThresholding(Image, Interval, ExistingFigureHandle)
function FigureHandle = imshowThresholding(Image, Interval, ...
    ExistingFigureHandle)
    if ~exist('Interval', 'var') || ...
            isempty(Interval) || ...
            ~isnumeric(Interval) || ...
            (numel(Interval) ~= 2)
        warning('Interval := [0, Inf]');
        Interval = [0, Inf];
    end
    Image = squeeze(Image);
    
    if ~exist('ExistingFigureHandle', 'var') || ...
            isempty(ExistingFigureHandle) 
        FigureHandle = figure;
    else
        FigureHandle = figure(ExistingFigureHandle);
    end
    imshow(Image .* ((Image >= min(Interval)) & (Image <= max(Interval))), []);
    colorbar;
end
