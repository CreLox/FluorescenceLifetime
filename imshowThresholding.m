% imshowThresholding(Image, Interval)
function imshowThresholding(Image, Interval)
    if ~exist('Interval', 'var') || ...
            isempty(Interval) || ...
            ~isnumeric(Interval) || ...
            (numel(Interval) ~= 2)
        warning('Interval := [0, Inf]');
        Interval = [0, Inf];
    end
    Image = squeeze(Image);
    
    figure;
    imshow(Image .* ((Image >= min(Interval)) & (Image <= max(Interval))), []);
    colorbar;
end
