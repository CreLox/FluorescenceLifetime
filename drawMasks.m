% SelectedPixelIndices = drawMasks(Image)
function SelectedPixelIndices = drawMasks(Image)
    if isnumeric(Image)
        h = figure;
        imshow(squeeze(Image), []);
        Mask = false(size(squeeze(Image)));
    elseif isa(Image, 'matlab.ui.Figure')
        h = figure(Image);
        Mask = false(size(Image.UserData));
    else
        error('The input has to be either a matrix or a figure handle');
    end
    
    Number = 0;
    doDraw = 'y';
    while strcmpi(doDraw, 'y') || strcmpi(doDraw, 'yes') || ...
            strcmpi(doDraw, 'yep') || strcmpi(doDraw, 't') || ...
            strcmpi(doDraw, 'true') || isempty(doDraw)
        figure(h); % set h as the active figure
        Number = Number + 1;
        NewArea{Number} = drawrectangle;
        doDraw = input('Add one more? ', 's');
    end
    
    
    for i = 1 : Number
        Mask = Mask | NewArea{i}.createMask;
    end
    SelectedPixelIndices = find(Mask);
    SelectedPixelIndices = reshape(SelectedPixelIndices, 1, ...
        numel(SelectedPixelIndices));
    
    close(h);
end
