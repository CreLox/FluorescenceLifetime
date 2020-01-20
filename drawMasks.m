% SelectedPixelIndices = drawMasks(ImageMatrix)
function SelectedPixelIndices = drawMasks(ImageMatrix)
    h = figure;
    imshow(squeeze(ImageMatrix), []);
    
    Mask = false(size(squeeze(ImageMatrix)));
    doDraw = 'y';
    while strcmpi(doDraw, 'y') || strcmpi(doDraw, 'yes') || ...
            strcmpi(doDraw, 'yep') || strcmpi(doDraw, 't') || ...
            strcmpi(doDraw, 'true') || isempty(doDraw)
        NewArea = drawfreehand;
        Mask = Mask | NewArea.createMask;
        doDraw = input('Add one more? ', 's');
    end
    SelectedPixelIndices = find(Mask);
    
    close(h);
end
