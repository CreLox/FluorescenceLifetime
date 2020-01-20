% SelectedPixelIndices = drawMasks(ImageMatrix)
function SelectedPixelIndices = drawMasks(ImageMatrix)
    h = figure;
    imshow(squeeze(ImageMatrix), []);
    
    Number = 0;
    doDraw = 'y';
    while strcmpi(doDraw, 'y') || strcmpi(doDraw, 'yes') || ...
            strcmpi(doDraw, 'yep') || strcmpi(doDraw, 't') || ...
            strcmpi(doDraw, 'true') || isempty(doDraw)
        Number = Number + 1;
        NewArea{Number} = drawrectangle;
        doDraw = input('Add one more? ', 's');
    end
    
    Mask = false(size(squeeze(ImageMatrix)));
    for i = 1 : Number
        Mask = Mask | NewArea{i}.createMask;
    end
    SelectedPixelIndices = find(Mask);
    
    close(h);
end
